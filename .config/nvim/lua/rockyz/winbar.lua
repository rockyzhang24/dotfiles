-- The winbar's structure:
--
-- Winbar
-- ├── Header  <-- get_header()
-- └── Body
--     ├── Special filetype
--     │   ├── SpecialComponent  <-- get_special_component()
--     │   └── ExtraItems (for outline, callhierarchy, etc)
--     │
--     └── Normal filetype
--         ├── Path         <-- get_path()
--         ├── FileIcon     <-- get_icon()
--         ├── Name         <-- get_name()
--         ├── Indicators (diagnostics and modified)
--         └── Breadcrumbs  <-- vim.w.breadcrumbs

local M = {}

local icons  = require('rockyz.icons')
local delimiter = icons.caret.right
local special_filetypes = require('rockyz.special_filetypes')
local api = require('rockyz.utils.api')

local has_devicons, devicons = pcall(require, 'nvim-web-devicons')

-- Cache the highlight groups of filetype icons
local icon_highlight_cache = {}

-- Header has the window number and the indicator of maximization
local function get_header()
    local header_items = {}
    -- Window number
    local window_number = string.format('[%s]', vim.api.nvim_win_get_number(0))
    table.insert(header_items, window_number)
    -- Indicator of window maximization
    if vim.w.maximized then
        table.insert(header_items, icons.misc.maximized .. ' ')
    end
    return string.format('%%#WinbarHeader#%s%%*', table.concat(header_items, ' '))
end

-- Check if the current window is special
local function is_special_window(ft, winid)
    return special_filetypes[ft] ~= nil or vim.fn.win_gettype(winid) == 'command'
end

---Render the special component
---@param icon string
---@param icon_hl string
---@param title string
---@param suffix_items string[]
---@return string
local function render_special_component(icon, icon_hl, title, suffix_items)
    local component = string.format(
        '%%#%s#%s %%#WinbarPath#%s%%*',
        icon_hl,
        icon,
        title
    )

    local suffix = table.concat(suffix_items, ' ' .. delimiter .. ' ')
    if suffix ~= '' then
        component = component .. ' ' .. delimiter .. ' ' .. suffix
    end

    return component
end

---Build the main component for a special buffer
---@param ft string
---@param winid integer
---@return string
local function get_special_component(ft, winid)
    local win_type = vim.fn.win_gettype(winid)

    if win_type == 'command' then
        ft = 'cmdwin'
    end

    ---@type rockyz.SpecialFiletype
    local special = special_filetypes[ft]
    local icon = special.icon
    local icon_hl = special.icon_hl or 'WinbarPath'

    local title
    local suffix_items = {}

    if ft == 'floggraph' or ft == 'fugitive' or ft == 'oil' or ft == 'term' then
        title = vim.fn.expand('%')
    elseif ft == 'qf' then
        local is_loclist = win_type == 'loclist'
        title = is_loclist and 'Location List' or 'Quickfix List'
        local what = { title = 0, size = 0, idx = 0 }
        local list = is_loclist and vim.fn.getloclist(0, what) or vim.fn.getqflist(what)
        if list.title ~= '' then
            table.insert(suffix_items, string.format('%%#WinbarQuickfixTitle#%s%%*', list.title))
        end
        table.insert(suffix_items, string.format('[%s/%s]', list.idx, list.size))
    elseif win_type == 'command' then
        title = 'Command-line'
    else
        title = special.title
    end

    return render_special_component(icon, icon_hl, title, suffix_items)
end

-- Get the file path for the window with normal filetype
local function get_path()
    local fullpath = vim.fn.expand('%')
    if fullpath == '' then
        return ''
    end
    local icon = icons.misc.folder
    if string.find(fullpath, '^fugitive://') or string.find(fullpath, '^gitsigns://') then
        icon = icons.misc.source_control
    end
    local path = vim.fn.fnamemodify(fullpath, ':~:h')
    return string.format('%%#WinbarPath#%s %s%%*', icon, path)
end

---Get the icon of the current buffer's filetype
---@return string
local function get_icon()
    local ft = vim.bo.filetype

    if has_devicons then
        local icon, icon_color = devicons.get_icon_color_by_filetype(ft, { default = true })
        local icon_hl = 'WinbarFileIconFor' .. ft

        if not icon_highlight_cache[icon_hl] and icon_color then
            local bg_color = vim.api.nvim_get_hl(0, { name = 'Winbar' }).bg
            vim.api.nvim_set_hl(0, icon_hl, { fg = icon_color, bg = bg_color })
            icon_highlight_cache[icon_hl] = true
        end

        return icon_color and string.format('%%#%s#%s%%*', icon_hl, icon) or icon
    end

    return icons.misc.file
end

-- Get the filename
local function get_name()
    local filename = vim.fn.expand('%:t')
    if filename == '' then
        filename = '[No Name]'
    end
    return filename
end

local function render_special(ft, winid)
    local segments = {
        get_special_component(ft, winid)
    }

    local extra_items = {}

    if ft == 'outline' then
        -- Show "follow cursor", "provider", "filter on/off" indicators in outline window
        local provider = string.format('[%s]', vim.t.outline_provider)
        table.insert(extra_items, provider)

        local filter_kinds_hl = vim.t.filter_on and 'WinbarComponentOn' or 'WinbarComponentInactive'
        local filter_kinds = string.format('[%%#%s#%s%%*]', filter_kinds_hl, icons.misc.filter)
        table.insert(extra_items, filter_kinds)

        local follow_cursor_hl = vim.t.is_outline_follow_cursor_enabled and 'WinbarComponentOn' or 'WinbarComponentInactive'
        local follow_cursor = string.format('[%%#%s#%s%%*]', follow_cursor_hl, icons.misc.pointer)
        table.insert(extra_items, follow_cursor)
    elseif ft == 'callhierarchy' then
        -- Show "incoming/outgoing calls" indicator in call hierarchy window
        local call_mode = string.format(
            '[%%#WinbarComponentOn#%s %%*]',
            vim.t.call_hierarchy_mode == 'incoming' and icons.misc.call_incoming
            or icons.misc.call_outgoing
        )
        table.insert(extra_items, call_mode)
    end

    if next(extra_items) then
        table.insert(segments, table.concat(extra_items, ' '))
    end

    return table.concat(segments, ' ')
end

---Render the winbar counter for a normal file buffer
---@return string
local function render_normal()
    local segments = {}

    -- Path
    local path = get_path()
    if path ~= '' then
        table.insert(segments, path)
        table.insert(segments, delimiter)
    end

    -- File icon
    local icon = get_icon()
    table.insert(segments, icon)

    local diagnostic_count = vim.diagnostic.count(0)
    local error_count = diagnostic_count[vim.diagnostic.severity.ERROR] or 0
    local warning_count = diagnostic_count[vim.diagnostic.severity.WARN] or 0
    local file_status_hl = error_count > 0 and 'WinbarError' or (warning_count > 0 and 'WinbarWarn' or 'WinbarFilename')

    -- Name
    local name = get_name()
    table.insert(segments, string.format('%%#%s#%s%%*', file_status_hl, name))

    -- Indicators
    local indicators = {}

    -- (1). Diagnostic count
    local diagnostic_total = error_count + warning_count
    if diagnostic_total ~= 0 then
        table.insert(indicators, string.format('%%#%s#[%s]%%*', file_status_hl, diagnostic_total))
    end

    -- (2). "Modified" indicator
    local bufnr = vim.api.nvim_get_current_buf()
    local is_modified = vim.bo[bufnr].modified
    if is_modified then
        local modified_hl = diagnostic_total == 0 and 'WinbarModified' or file_status_hl
        table.insert(indicators, '%#' .. modified_hl .. '#[+]%*')
    end

    local indicators_str = table.concat(indicators, '')
    if indicators_str ~= '' then
        table.insert(segments, indicators_str)
    end

    -- Breadcrumbs
    if vim.w.breadcrumbs ~= '' then
        table.insert(segments, delimiter)
    end
    table.insert(segments, vim.w.breadcrumbs)

    return table.concat(segments, ' ')
end

function M.render()
    local ft = vim.bo.filetype
    local winid = vim.api.nvim_get_current_win()

    local header = get_header()

    -- 1. Special buffer: header + special component + extra_items
    if is_special_window(ft, winid) then
        return header .. ' ' .. render_special(ft, winid)
    end

    -- 2. Normal buffer: header + path + file_icon + name + indicators + breadcrumbs
    return header .. ' ' .. render_normal()
end

--------------------------------------------------------------------------------
-- Breadcrumbs
--------------------------------------------------------------------------------

-- Reference: https://github.com/juniorsundar/nvim/blob/main/lua/custom/micro.nvim/lua/micro/breadcrumbs.lua

---Check whether the cursor position (line, char) is inside a LSP range
---LSP character offsets are converted to byte columns before comparison
---
---TODO: later it can be implemented using vim.pos and vim.range, but they have bugs right now
---(e.g., when pasting a large block of code at the end of the file, vim.pos.lsp will throw an
---"index out of range" error)
---@param bufnr integer
---@param range lsp.Range line and character inside are 0-indexed
---@param cursor_pos [integer, integer] Cursor position from nvim_win_get_cursor(); row is
---1-indexed, column is 0-indexed
---@param offset_encoding string
---@return boolean
local function range_contains_cursor(bufnr, range, cursor_pos, offset_encoding)
    local start_row = range['start'].line
    local end_row = range['end'].line

    local cursor_row = cursor_pos[1] - 1 -- make it 0-indexed
    local cursor_col = cursor_pos[2] -- cursor's col defaults to be 0-indexed

    if cursor_row < start_row or cursor_row > end_row then
        return false
    end

    local start_col = range['start'].character
    if start_col > 0 then
        local start_line = api.get_lines(bufnr, { start_row })[start_row]
        start_col = vim.str_byteindex(start_line, offset_encoding, start_col, false)
    end

    if cursor_row == start_row and cursor_col < start_col then
        return false
    end

    local end_col = range['end'].character
    if end_col > 0 then
        local end_line = api.get_lines(bufnr, { end_row })[end_row]
        end_col = vim.str_byteindex(end_line, offset_encoding, end_col, false)
    end

    if cursor_row == end_row and cursor_col > end_col then
        return false
    end

    return true
end

---Build the symbol path containing the current cursor position
---@param bufnr integer
---@param symbols lsp.DocumentSymbol[]|lsp.SymbolInformation[]
---@param offset_encoding string
---@param cursor_pos table Cursor position, the result of vim.api.nvim_win_get_cursor(0)
---@param symbol_path_components string[]
local function build_symbol_path(bufnr, symbols, offset_encoding, cursor_pos, symbol_path_components)
    if symbols == nil then
        return
    end
    for _, symbol in ipairs(symbols) do
        -- Some LSPs (e.g., bash) are still using the deprecated SymbolInformation[] as the response
        -- of Document Symbols request. The symbol range is located at symbol.location.range instead
        -- of symbol.range
        local range = symbol.range or (symbol.location and symbol.location.range)
        if range and range_contains_cursor(bufnr, range, cursor_pos, offset_encoding) then
            local kind = vim.lsp.protocol.SymbolKind[symbol.kind] or 'Unknown'
            local icon = icons.symbol_kinds[kind]
            local colored_icon = string.format('%%#SymbolKind%s#%s%%*', kind, icon)
            table.insert(symbol_path_components, colored_icon .. ' ' .. symbol.name)
            build_symbol_path(bufnr, symbol.children, offset_encoding, cursor_pos, symbol_path_components)
            return
        end
    end
end

---@param winid integer
---@param breadcrumbs string
local function set_breadcrumbs(winid, breadcrumbs)
    vim.w[winid].breadcrumbs = breadcrumbs
    vim.cmd('redrawstatus')
end

local function refresh_breadcrumbs()
    local bufnr = vim.api.nvim_get_current_buf()
    local winid = vim.api.nvim_get_current_win()
    local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }
    local method = 'textDocument/documentSymbol'
    local clients = vim.lsp.get_clients( { method = method, bufnr = bufnr })
    if not next(clients) then
        vim.w[winid].breadcrumbs = ''
        return
    end

    local cursor_pos = vim.api.nvim_win_get_cursor(winid)

    vim.lsp.buf_request_all(bufnr, method, params, function(results, ctx, _)
        if not vim.api.nvim_win_is_valid(winid) then
            return
        end
        if not vim.api.nvim_buf_is_valid(ctx.bufnr) then
            return
        end
        if ctx.bufnr ~= vim.api.nvim_win_get_buf(winid) then
            return
        end

        local current_cursor_pos = vim.api.nvim_win_get_cursor(winid)
        if current_cursor_pos[1] ~= cursor_pos[1] or current_cursor_pos[2] ~= cursor_pos[2] then
            return
        end

        -- The structure of "results":
        -- results[ctx.client_id] = { err = err, error = err, result = result, context = ctx }
        for client_id, data in pairs(results) do
            if data.err then
                goto continue
            end

            local client = vim.lsp.get_client_by_id(client_id)
            if client and client.offset_encoding then
                local symbol_path_components = {}
                build_symbol_path(bufnr, data.result, client.offset_encoding, cursor_pos, symbol_path_components)

                if next(symbol_path_components) then
                    local breadcrumbs = table.concat(symbol_path_components, ' ' .. delimiter .. ' ')
                    set_breadcrumbs(winid, breadcrumbs)
                    return
                end
            end

            ::continue::
        end

        set_breadcrumbs(winid, '')
    end)
end

-- Refresh the breadcrumbs of the current window
vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI', 'BufWinEnter' }, {
    group = vim.api.nvim_create_augroup('rockyz.winbar.breadcrumbs', { clear = true }),
    callback = function()
        refresh_breadcrumbs()
    end,
})

-- vim.o.winbar = "%{%v:lua.require('rockyz.winbar').render()%}"

vim.api.nvim_create_autocmd('BufWinEnter', {
    group = vim.api.nvim_create_augroup('rockyz.winbar', { clear = true }),
    callback = function()
        if not vim.api.nvim_win_get_config(0).zindex then
            vim.wo.winbar = "%{%v:lua.require('rockyz.winbar').render()%}"
        end
    end,
})

return M
