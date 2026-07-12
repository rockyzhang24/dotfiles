-- Show a lightbulb when code actions are available at the cursor
--
-- Like VSCode, the lightbulb is displayed at the beginning (the first column) of the same line, or
-- the previous line if the space is not enough.
--
-- This is implemented by using window-local extmark
--
-- Reference: the source code of vim.lsp.buf.code_action() in
-- https://github.com/neovim/neovim/blob/master/runtime/lua/vim/lsp/buf.lua

local has_icons, icons = pcall(require, 'rockyz.icons')
local LIGHTBULB_ICON = has_icons and icons.misc.lightbulb or ''

local LIGHTBULB_VIRT_TEXT = LIGHTBULB_ICON .. ' '
local LIGHTBULB_VIRT_TEXT_WIDTH = vim.fn.strdisplaywidth(LIGHTBULB_VIRT_TEXT)

local CODE_ACTION_METHOD = 'textDocument/codeAction'

local default_extmark_opts = {
    virt_text = {
        { LIGHTBULB_VIRT_TEXT, 'LightBulb' },
    },
    hl_mode = 'combine',
    virt_text_win_col = 0,
}

---Get the 1-based line number where the lightbulb should be displayed
---@return integer
local function get_lightbulb_line()
    local line = vim.fn.line('.')
    local topline = vim.fn.line('w0')
    local indent = vim.fn.indent('.')

    if indent >= LIGHTBULB_VIRT_TEXT_WIDTH then
        return line
    end

    if line == topline then
        return line + 1
    end

    return line - 1
end

---Remove the lightbulb extmark
---@param winid integer
local function remove_lightbulb(winid)
    if not vim.api.nvim_win_is_valid(winid) then
        return
    end

    local bufnr = vim.w[winid].bulb_bufnr
    local ns_id = vim.w[winid].bulb_ns_id
    local mark_id = vim.w[winid].bulb_mark_id

    if bufnr == nil or ns_id == nil or mark_id == nil then
        return
    end

    if vim.api.nvim_buf_is_valid(bufnr) then
        pcall(vim.api.nvim_buf_del_extmark, bufnr, ns_id, mark_id)
    end

    vim.w[winid].prev_lightbulb_line = nil
    vim.w[winid].bulb_mark_id = nil
    vim.w[winid].bulb_bufnr = nil
end

---Show the lightbulb extmark
---@param winid integer
---@param bufnr integer
---@param lightbulb_line integer 0-based line number
local function show_lightbulb(winid, bufnr, lightbulb_line)
    -- No need to update the bulb if its position does not change
    if not vim.api.nvim_win_is_valid(winid) or not vim.api.nvim_buf_is_valid(bufnr) then
        return
    end

    if vim.w[winid].bulb_bufnr ~= bufnr then
        remove_lightbulb(winid)
    end

    if lightbulb_line == vim.w[winid].prev_lightbulb_line then
        return
    end

    -- Create a window-local namespace for the extmark
    if vim.w[winid].bulb_ns_id == nil then
        local ns_id = vim.api.nvim_create_namespace('rockyz.bulb.' .. winid)
        vim.api.nvim__ns_set(ns_id, { wins = { winid } })
        vim.w[winid].bulb_ns_id = ns_id
    end

    -- Create or move the lightbulb extmark
    local extmark_opts = vim.tbl_extend('keep', default_extmark_opts, {
        id = vim.w[winid].bulb_mark_id,
    })
    vim.w[winid].bulb_mark_id = vim.api.nvim_buf_set_extmark(
        bufnr,
        vim.w[winid].bulb_ns_id,
        lightbulb_line,
        0,
        extmark_opts
    )

    vim.w[winid].prev_lightbulb_line = lightbulb_line
    vim.w[winid].bulb_bufnr = bufnr
end

---Return the diagnostics on the given line that belong to the client
---@param client vim.lsp.Client
---@param bufnr integer
---@param cursor_lnum integer 0-based line number
---@return vim.Diagnostic[]
local function get_client_diagnostics(client, bufnr, cursor_lnum)
    -- For each client, only retrieve the diagnostics that belong to it. They are the ones that are
    -- pushed to this client by the server and ones this client pulls from the server.

    ---@type vim.Diagnostic[]
    local diagnostics = {}
    local ns_push = vim.lsp.diagnostic.get_namespace(client.id, false)

    -- vim.diagnostic.get() returns vim.Diagnostic[].
    --
    -- Internally, the diagnostics, i.e., lsp.Diagnostic[], returned from the server are converted
    -- to vim.Diagnostic[] and cached, but the original lsp.Diagnostic is stored to
    -- vim.Diagnostic.user_data.lsp.
    --
    -- Reference: the source code of handle_diagnostics() in
    -- https://github.com/neovim/neovim/blob/master/runtime/lua/vim/lsp/diagnostic.lua

    client:_provider_foreach('textDocument/diagnostic', function(cap)
        local ns_pull = vim.lsp.diagnostic.get_namespace(client.id, true, cap.identifier)
        vim.list_extend(
            diagnostics,
            vim.diagnostic.get(bufnr, {
                namespace = ns_pull,
                lnum = cursor_lnum,
            })
        )
    end)

    vim.list_extend(
        diagnostics,
        vim.diagnostic.get(bufnr, {
            namespace = ns_push,
            lnum = cursor_lnum,
        })
    )
    return diagnostics
end

---Returns whether the diagnostic contains the cursor position
---@param diagnostic vim.Diagnostic
---@param cursor_lnum integer 0-based line number
---@param cursor_col integer 0-based byte offset
---@return boolean
local function diagnostic_contains_cursor(diagnostic, cursor_lnum, cursor_col)
    -- Filter the diagnostics at the cursor position
    -- TODO: use vim.pos once it becomes stable, see diagnostic_contains_cursor() in
    -- https://github.com/neovim/neovim/blob/master/runtime/lua/vim/lsp/buf.lua

    local end_lnum = diagnostic.end_lnum or diagnostic.lnum
    local end_col = diagnostic.end_col or diagnostic.col

    -- A zero-length diagnostic applies only at its exact position
    if diagnostic.lnum == end_lnum and diagnostic.col == end_col then
        return cursor_lnum == diagnostic.lnum and cursor_col == diagnostic.col
    end

    return (
        diagnostic.lnum < cursor_lnum
            or diagnostic.lnum == cursor_lnum and diagnostic.col <= cursor_col
    ) and (
        end_lnum > cursor_lnum
            or end_lnum == cursor_lnum and end_col > cursor_col
    )
end

---Builds the code action request parameters for the given client
---@param client vim.lsp.Client
---@param winid integer
---@param bufnr integer
---@param cursor_lnum integer 0-based line number
---@param cursor_col integer 0-based byte offset
---@return lsp.CodeActionParams
local function make_code_action_params(client, winid, bufnr, cursor_lnum, cursor_col)
    local context = {
        triggerKind = vim.lsp.protocol.CodeActionTriggerKind.Invoked
    }

    local diagnostics = get_client_diagnostics(client, bufnr, cursor_lnum)

    local params = vim.lsp.util.make_range_params(winid, client.offset_encoding)
    ---@cast params lsp.CodeActionParams
    params.context = vim.tbl_extend('force', context, {
        diagnostics = vim.iter(diagnostics):map(function(diagnostic)
            if diagnostic_contains_cursor(diagnostic, cursor_lnum, cursor_col) then
                return diagnostic.user_data.lsp
            end
        end):totable()
    })

    return params
end

-- Update the lightbulb at the current cursor position
local function update_lightbulb()
    -- Don't display the bulb in diff window
    if vim.wo.diff then
        return
    end

    local winid = vim.api.nvim_get_current_win()
    local bufnr = vim.api.nvim_get_current_buf()
    local lightbulb_line = get_lightbulb_line() - 1 -- 0-based for extmark
    local clients = vim.lsp.get_clients({ bufnr = bufnr, method = CODE_ACTION_METHOD })

    -- Ignore stale LSP responses. Code action requests are asynchronous, so an older request may
    -- finish after the cursor has already moved.
    vim.w[winid].bulb_version = (vim.w[winid].bulb_version or 0) + 1
    local request_id = vim.w[winid].bulb_version

    if #clients == 0 then
        remove_lightbulb(winid)
        return
    end

    local has_code_action = false
    local pending_client_count = #clients
    local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
    local cursor_lnum = cursor_row - 1 -- 0-indexed

    for _, client in ipairs(clients) do
        local params = make_code_action_params(client, winid, bufnr, cursor_lnum, cursor_col)
        local request_sent = client:request(CODE_ACTION_METHOD, params, function(_, result, _)
            if
                not vim.api.nvim_win_is_valid(winid)
                or vim.wo[winid].diff
                or not vim.api.nvim_buf_is_valid(bufnr)
                or vim.api.nvim_win_get_buf(winid) ~= bufnr
                or vim.w[winid].bulb_version ~= request_id
            then
                return
            end

            pending_client_count = pending_client_count - 1

            if has_code_action then
                return
            end

            for _, action in ipairs(result or {}) do
                if action then
                    has_code_action = true
                    break
                end
            end

            if has_code_action then
                if lightbulb_line < vim.api.nvim_buf_line_count(bufnr) then
                    show_lightbulb(winid, bufnr, lightbulb_line)
                else
                    remove_lightbulb(winid)
                end
            elseif pending_client_count == 0 then
                remove_lightbulb(winid)
            end
        end, bufnr)

        if not request_sent then
            pending_client_count = pending_client_count - 1
            if pending_client_count == 0 and not has_code_action then
                remove_lightbulb(winid)
            end
        end
    end
end

vim.api.nvim_create_augroup('rockyz.lightbulb', { clear = true })
vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
    group = 'rockyz.lightbulb',
    callback = update_lightbulb,
})
