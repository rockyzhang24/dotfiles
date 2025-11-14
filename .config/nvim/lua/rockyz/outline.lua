local icons = require('rockyz.icons')
local M = {}

---@type integer The tabid of the current tabpage
local tab

---Store the state of the outline in the current tabpage
---@class TabOutlineState
---@field bufnr integer|nil The bufnr of the outline buffer
---@field win integer|nil The winid of the outline window
---@field source_bufnr integer|nil The bufnr of the source buffer
---@field contents string[] Contents that will be displayed in outline
---@field highlights table Information to highlight the icon and detail by extmarks
---@field jumps table Information for jump operations
---@field follow_cursor boolean Whether "follow cursor" is enabled
---@field prev_source_buftype string The buftype of previous buffer

---Store per-tab outline state, indexed by tabid
---@type table<integer, TabOutlineState>
local states = {}

local function create_outline_buffer()
    local state = states[tab]
    if not state.bufnr or not vim.api.nvim_buf_is_valid(state.bufnr) then
        state.bufnr = vim.api.nvim_create_buf(false, true)
        vim.bo[state.bufnr].filetype = 'outline'
    end
end

local function format_symbols(symbols, ctx)
    if symbols == nil then
        return
    end
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    if not client then
        return
    end
    local state = states[tab]
    local offset_encoding = client.offset_encoding

    local function _format_symbols(_symbols, prefix)
        for _, symbol in ipairs(_symbols) do
            local kind = vim.lsp.protocol.SymbolKind[symbol.kind] or 'Unknown'
            local icon = icons.symbol_kinds[kind]

            -- Line that will be displayed in the outline buffer
            local line = {}
            table.insert(line, icon)
            table.insert(line, symbol.name)
            local detail
            if symbol.detail and symbol.detail ~= '' then
                detail = string.gsub(symbol.detail, '\n', '')
                table.insert(line, detail)
            end
            table.insert(state.contents, prefix .. table.concat(line, ' '))

            -- Necessary information to highlight the icon and symbol detail by extmarks
            local icon_col = #prefix
            local highlight = {}
            highlight.icon = {
                kind = kind,
                col = icon_col,
                end_col = icon_col + #icon,
            }
            if detail then
                local detail_col = #prefix + #icon + #symbol.name + 2
                highlight.detail = {
                    col = detail_col,
                    end_col = detail_col + #detail,
                }
            end
            table.insert(state.highlights, highlight)

            -- Necessary information for jump operations.
            -- * jump to the symbol in source buffer by vim.lsp.util.show_document(location, offset_encoding)
            -- * follow cursor (i.e., auto jump to the symbol in outline)
            -- * reveal (i.e., jump to the symbol in outline by a keymap)
            table.insert(state.jumps, {
                range = symbol.range,
                selection_range = symbol.selectionRange,
                offset_encoding = offset_encoding,
            })

            if symbol.children then
                _format_symbols(symbol.children, prefix .. string.rep(' ', 4))
            end
        end
    end

    _format_symbols(symbols, '')
end

local function apply_highlights()
    local state = states[tab]
    local ns = vim.api.nvim_create_namespace('rockyz.outline.highlights')
    for i, hl in ipairs(state.highlights) do
        vim.api.nvim_buf_set_extmark(state.bufnr, ns, i - 1, hl.icon.col, { end_col = hl.icon.end_col, hl_group = 'SymbolKind' .. hl.icon.kind })
        if hl.detail then
            vim.api.nvim_buf_set_extmark(state.bufnr, ns, i - 1, hl.detail.col, { end_col = hl.detail.end_col, hl_group = 'Description' })
        end
    end
end

-- Set contents in the outline buffer
local function set_contents(contents)
    local state = states[tab]
    vim.bo[state.bufnr].modifiable = true
    vim.api.nvim_buf_set_lines(state.bufnr, 0, -1, false, contents)
    vim.bo[state.bufnr].modifiable = false
end

local function request(bufnr)
    local method = 'textDocument/documentSymbol'
    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':t')
    filename = filename ~= '' and filename or '[No Name]'

    local clients = vim.lsp.get_clients({ method = method, bufnr = bufnr })
    if not next(clients) then
        set_contents({ string.format("No symbols found in document '%s'", filename) })
        return
    else
        set_contents({ string.format("Loading document symbols for '%s'%s", filename, icons.misc.ellipsis) })
    end
    local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }
    local state = states[tab]
    state.contents, state.highlights, state.jumps = {}, {}, {}
    vim.lsp.buf_request_all(bufnr, method, params, function(results, _, _)
        -- The structure of "results":
        -- results[ctx.client_id] = { err = err, error = err, result = result, context = ctx }
        for _, data in pairs(results) do
            if data.err then
                set_contents({ string.format("Error: failed to request document symbols for '%s'", filename) })
                return
            end
            -- During the callback, if the outline window is not valid or switching to a different
            -- source buffer, terminate the callback execution.
            if
                not state.win
                or not vim.api.nvim_win_is_valid(state.win)
                or state.source_bufnr ~= data.context.bufnr
            then
                return
            end
            format_symbols(data.result, data.context)
        end
        set_contents(state.contents)
        apply_highlights()
    end)
end

-- The foldexpr set to the outline window
function M.get_fold()
    local function indent_level(lnum)
        return vim.fn.indent(lnum) / vim.bo[states[tab].bufnr].shiftwidth
    end
    local this_indent = indent_level(vim.v.lnum)
    local next_indent = indent_level(vim.v.lnum + 1)
    if next_indent == this_indent then
        return this_indent
    elseif next_indent < this_indent then
        return this_indent
    elseif next_indent > this_indent then
        return '>' .. next_indent
    end
end

local function select(opts)
    local state = states[tab]
    local lnum = vim.fn.line('.')
    local jump = state.jumps[lnum]
    local location = { -- lsp.Location
        uri = vim.uri_from_bufnr(state.source_bufnr),
        range = jump.range,
    }
    vim.lsp.util.show_document(location, jump.offset_encoding, { reuse_win = true, focus = opts.focus })
end

-- In outline reveal the symbol that is under the cursor of the source buffer
local function reveal_symbol()
    local state = states[tab]
    if not state.win or not vim.api.nvim_win_is_valid(state.win) then
        return
    end
    local cursor_pos = vim.pos.cursor(vim.api.nvim_win_get_cursor(0))
    local cursor_range = vim.range(cursor_pos, cursor_pos)
    local count = 0
    for i = #state.jumps, 1, -1 do
        local jump = state.jumps[i]
        count = count + 1
        local range = vim.range.lsp(state.source_bufnr, jump.range, jump.offset_encoding)
        if vim.range.has(range, cursor_range) then
            vim.api.nvim_win_call(state.win, function()
                vim.api.nvim_win_set_cursor(state.win, { #state.jumps - count + 1, 0 })
            end)
            return
        end
    end
end

local function disable_follow_cursor()
    vim.api.nvim_del_augroup_by_name(string.format('rockyz.outline.tab%s_follow_cursor', tab))
end

local function enable_follow_cursor()
    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        group = vim.api.nvim_create_augroup(string.format('rockyz.outline.tab%s_follow_cursor', tab), { clear = true }),
        buffer = states[tab].source_bufnr,
        callback = function()
            reveal_symbol()
        end,
    })
end

local keymaps = {
    -- Outline buffer local keymaps
    ['local'] = {
        -- Jump to the symbol in source window
        ['<Enter>'] = function()
            select({ focus = true })
        end,
        -- Peak
        ['p'] = function()
            select({ focus = false })
        end,
        -- Peak prev
        ['<C-k>'] = function()
            local cur = vim.api.nvim_win_get_cursor(0)
            cur[1] = cur[1] - 1
            pcall(vim.api.nvim_win_set_cursor, 0, cur)
            select({ focus = false })
        end,
        -- Peak next
        ['<C-j>'] = function()
            local cur = vim.api.nvim_win_get_cursor(0)
            cur[1] = cur[1] + 1
            pcall(vim.api.nvim_win_set_cursor, 0, cur)
            select({ focus = false })
        end,
    },
    -- Global keymaps
    global = {
        -- Toggle "follow cursor"
        -- vim.t.outline_follow_cursor can be used to check "follow cursor" status in statusline and
        -- winbar
        ['\\c'] = function()
            local state = states[tab]
            if state.follow_cursor then
                disable_follow_cursor()
                vim.t[tab].outline_follow_cursor = false
            else
                enable_follow_cursor()
                vim.t[tab].outline_follow_cursor = true
            end
            state.follow_cursor = not state.follow_cursor
            -- Update the statusline and winbar
            vim.api.nvim__redraw({ win = state.win, winbar = true })
        end,
        -- Refresh outline
        ['<Leader>sr'] = function()
            request(states[tab].source_bufnr)
        end,
        -- In the outline reveal the symbol that is under the cursor of the source buffer
        -- It's available in both source buffer and outline buffer
        gs = function()
            local source_win = vim.fn.bufwinid(states[tab].source_bufnr)
            vim.api.nvim_win_call(source_win, function()
                reveal_symbol()
            end)
        end,
    },
}

local function set_keymaps()
    for key, action in pairs(keymaps['local']) do
        vim.keymap.set('n', key, action, { buffer = states[tab].bufnr })
    end
    for key, action in pairs(keymaps.global) do
        vim.keymap.set('n', key, action)
    end
end

local function del_keymaps()
    for key, _ in pairs(keymaps.global) do
        vim.keymap.del('n', key)
    end
end

local function debounce(fn, ms)
    local timer = vim.uv.new_timer()
    return function(...)
        local args = { ... }
        timer:stop()
        timer:start(ms, 0, vim.schedule_wrap(function()
            fn(unpack(args))
        end))
    end
end

local function del_autocmd()
    vim.api.nvim_del_augroup_by_name('rockyz.outline')
end

local function set_autocmd()
    local group = vim.api.nvim_create_augroup('rockyz.outline', { clear = true })

    vim.api.nvim_create_autocmd({ 'LspAttach', 'BufEnter' }, {
        group = group,
        callback = function(event)
            local state = states[tab]
            if state.win and vim.api.nvim_win_is_valid(state.win) and vim.bo[event.buf].buftype == '' then
                state.source_bufnr = event.buf
                -- No need to update outline if the current buffer was switched from a special
                -- buffer and hasn't been modified
                if state.prev_source_buftype ~= '' and vim.b[event.buf].last_changedtick == vim.b[event.buf].changedtick then
                    return
                end
                -- Bash LS returns empty result without using this defer_fn wrapper. I don't know why!
                -- Should I debounce request for 'BufWinEnter'?
                vim.defer_fn(function()
                    create_outline_buffer()
                    request(event.buf)
                    if state.follow_cursor then
                        enable_follow_cursor()
                    end
                end, 0)
            end
        end,
    })

    vim.api.nvim_create_autocmd({ 'BufLeave' }, {
        group = group,
        callback = function(event)
            vim.b[event.buf].last_changedtick = vim.b[event.buf].changedtick
            states[tab].prev_source_buftype = vim.bo[event.buf].buftype
        end,
    })

    -- Update the outline upon text change in the source buffer
    vim.api.nvim_create_autocmd({ 'TextChanged' }, {
        group = group,
        buffer = states[tab].source_bufnr,
        callback = debounce(function(event)
            request(event.buf)
        end, 1000)
    })

    vim.api.nvim_create_autocmd({ 'WinClosed' }, {
        group = group,
        pattern = tostring(states[tab].win),
        callback = function()
            del_autocmd()
            del_keymaps()
        end,
    })

end

local function is_opened()
    return states[tab] and states[tab].win and vim.api.nvim_win_is_valid(states[tab].win)
end

local function open()
    local bufnr = vim.api.nvim_get_current_buf()
    create_outline_buffer()
    local win = vim.api.nvim_open_win(states[tab].bufnr, true, {
        width = 50,
        split = 'right',
        win = -1,
        style = 'minimal',
    })
    vim.wo[win].list = true
    vim.wo[win].wrap = false
    vim.wo[win].foldcolumn = '1'
    vim.wo[win].statuscolumn = '%C '
    vim.wo[win].cursorline = true
    vim.wo[win].foldmethod = 'expr'
    vim.wo[win].foldexpr = 'v:lua.require("rockyz.outline").get_fold()'
    states[tab].win = win
    states[tab].source_bufnr = bufnr
    vim.cmd('wincmd p')
    request(bufnr)
    set_keymaps()
    set_autocmd()
end

local function close()
    if states[tab].win and vim.api.nvim_win_is_valid(states[tab].win) then
        vim.api.nvim_win_close(states[tab].win, true)
        -- autocmds will be deleted by the "WinClosed" autocmd
    end
end

local function toggle_outline_window()
    if is_opened() then
        close()
    else
        open()
    end
end

vim.keymap.set('n', '\\s', function()
    toggle_outline_window()
end)

vim.api.nvim_create_autocmd({ 'VimEnter', 'TabEnter' }, {
    callback = function()
        tab = vim.api.nvim_get_current_tabpage()
        if not states[tab] then
            states[tab] = {
                bufnr = nil,
                win = nil,
                source_bufnr = nil,
                contents = {},
                highlights = {},
                jumps = {},
                follow_cursor = false,
            }
        end
    end,
})

vim.api.nvim_create_autocmd({ 'TabClosed' }, {
    callback = function(event)
        states[event.file] = nil
    end,
})

return M
