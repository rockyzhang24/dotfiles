-- Show a lightbulb when code actions are available at the cursor
--
-- Like VSCode, the lightbulb is displayed at the beginning (the first column) of the same line, or
-- the previous line if the space is not enough.
--
-- This is implemented by using window-local extmark

local icon = require('rockyz.icons').misc.lightbulb

local method = 'textDocument/codeAction'

local opts = {
    virt_text = {
        { icon, 'LightBulb' },
    },
    virt_text_win_col = 0,
}

-- Get the line number where the bulb should be displayed
local function get_bulb_linenr()
    local linenr = vim.fn.line('.')
    if vim.fn.indent('.') <= 2 then
        if linenr == vim.fn.line('w0') then
            return linenr + 1
        else
            return linenr - 1
        end
    end
    return linenr
end

-- Remove the lightbulb
local function lightbulb_remove(winid, bufnr)
    if
        not vim.api.nvim_win_is_valid(winid)
        or vim.w[winid].bulb_ns_id == nil and vim.w[winid].bulb_mark_id == nil
    then
        return
    end
    vim.api.nvim_buf_del_extmark(bufnr, vim.w[winid].bulb_ns_id, vim.w[winid].bulb_mark_id)
    vim.w[winid].prev_bulb_line = nil
end

-- Create or update the lightbulb
local function lightbulb_update(winid, bufnr, bulb_line)
    -- No need to update the bulb if its position does not change
    if not vim.api.nvim_win_is_valid(winid) or bulb_line == vim.w[winid].prev_bulb_line then
        return
    end
    -- Create a window-local namespace for the extmark
    if vim.w[winid].bulb_ns_id == nil then
        local ns_id = vim.api.nvim_create_namespace('rockyz.bulb.' .. winid)
        vim.api.nvim__ns_set(ns_id, { wins = { winid } })
        vim.w[winid].bulb_ns_id = ns_id
    end
    -- Create an extmark or update the existing one
    if vim.w[winid].bulb_mark_id == nil then
        vim.w[winid].bulb_mark_id = vim.api.nvim_buf_set_extmark(bufnr, vim.w[winid].bulb_ns_id, bulb_line, 0, opts)
        vim.w[winid].bulb_mark_opts = vim.tbl_extend('keep', opts, {
            id = vim.w[winid].bulb_mark_id,
        })
    else
        vim.api.nvim_buf_set_extmark(bufnr, vim.w[winid].bulb_ns_id, bulb_line, 0, vim.w[winid].bulb_mark_opts)
    end
    vim.w[winid].prev_bulb_line = bulb_line
end

local function lightbulb()
    -- Don't display the bulb in diff window
    if vim.wo.diff then
        return
    end

    local winid = vim.api.nvim_get_current_win()
    local bufnr = vim.api.nvim_get_current_buf()
    local bulb_line = get_bulb_linenr() - 1 -- 0-based for extmark
    local clients = vim.lsp.get_clients({ bufnr = bufnr, method = method })
    local has_action = false
    local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
    local cursor_lnum = cursor_row - 1 -- 0-indexed

    for _, client in ipairs(clients) do
        local context = {}
        -- For each client, only retrieve the diagnostics that belong to it. They are the ones that are
        -- pushed to this client by the server and ones this client pulls from the server.
        -- NOTE: Diagnostics returned by vim.diagnostic.get() are vim.Diagnostics[].
        local ns_push = vim.lsp.diagnostic.get_namespace(client.id, false)
        local ns_pull = vim.lsp.diagnostic.get_namespace(client.id, true)
        local diagnostics = {}
        vim.list_extend(diagnostics, vim.diagnostic.get(bufnr, { namespace = ns_pull }))
        vim.list_extend(diagnostics, vim.diagnostic.get(bufnr, { namespace = ns_push }))

        -- Fetch lsp diagnostics (lsp.Diagnostics[]) that only overlaps the cursor position
        context.diagnostics = vim.iter(diagnostics):map(function(d)
            --
            -- After the client receives diagnostics (lsp.Diagnostics[]) from the server, each lsp
            -- diagnostic gets converted to vim diagnostic (vim.Diagnostics[]) and then catched. In the
            -- conversion, the original lsp diagnostic is stored in diagnostic.user_data.lsp.
            -- Reference: handle_diagnostics() in
            -- https://github.com/neovim/neovim/blob/master/runtime/lua/vim/lsp/diagnostic.lua
            --
            -- Now we need the lsp diagnostics and use them to request code actions. We just need to fetch
            -- them from vim diagnostic's user_data.lsp.
            -- Reference: code_action() in
            -- https://github.com/neovim/neovim/blob/master/runtime/lua/vim/lsp/buf.lua
            --
            if
                (d.lnum < cursor_lnum or d.lnum == cursor_lnum and d.col <= cursor_col)
                and (d.end_lnum > cursor_lnum or d.end_lnum == cursor_lnum and d.end_col > cursor_col)
            then
                return d.user_data.lsp
            end
        end):totable()

        local params = vim.lsp.util.make_range_params(winid, client.offset_encoding)
        params.context = context

        client:request(method, params, function(_, result, _)
            if has_action then
                return
            end
            for _, action in pairs(result or {}) do
                if action then
                    has_action = true
                end
            end
            if has_action then
                lightbulb_update(winid, bufnr, bulb_line)
            else
                lightbulb_remove(winid, bufnr)
            end
        end, bufnr)
    end
end

vim.api.nvim_create_augroup('rockyz.lightbulb', { clear = true })
vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
    group = 'rockyz.lightbulb',
    callback = lightbulb,
})
