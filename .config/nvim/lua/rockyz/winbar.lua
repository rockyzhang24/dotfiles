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

local icons = require('rockyz.icons')
local delimiter = icons.caret.right
local special_filetypes = require('rockyz.special_filetypes')
local api = require('rockyz.utils.api')

local has_devicons, devicons = pcall(require, 'nvim-web-devicons')

-- Cache the highlight groups of filetype icons
local icon_highlight_cache = {}

---Escape literal text embedded in the winbar format string
---@param text string
---@return string
local function escape_winbar_text(text)
    return text:gsub('%%', '%%%%')
end

---Render the winbar header for the current window.
---@return string
local function get_header()
    local header_items = {}
    local window_number = string.format('[%s]', vim.api.nvim_win_get_number(0))
    table.insert(header_items, window_number)

    -- Show the maximization indicator
    if vim.w.maximized then
        table.insert(header_items, icons.misc.maximized .. ' ')
    end

    return string.format('%%#WinbarHeader#%s%%*', table.concat(header_items, ' '))
end

-- Check if the current window is special
local function is_special_window(filetype, winid)
    return special_filetypes[filetype] ~= nil or vim.fn.win_gettype(winid) == 'command'
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
        escape_winbar_text(title)
    )

    local suffix = table.concat(suffix_items, ' ' .. delimiter .. ' ')
    if suffix ~= '' then
        component = component .. ' ' .. delimiter .. ' ' .. suffix
    end

    return component
end

---Build the main component for a special buffer
---@param filetype string
---@param winid integer
---@return string
local function get_special_component(filetype, winid)
    local win_type = vim.fn.win_gettype(winid)

    if win_type == 'command' then
        filetype = 'cmdwin'
    end

    ---@type rockyz.SpecialFiletype
    local special = special_filetypes[filetype]
    local icon = special.icon
    local icon_hl = special.icon_hl or 'WinbarPath'

    local title
    local suffix_items = {}

    if filetype == 'floggraph' or filetype == 'fugitive' or filetype == 'oil' or filetype == 'term' then
        title = vim.fn.expand('%')
    elseif filetype == 'qf' then
        local is_loclist = win_type == 'loclist'
        title = is_loclist and 'Location List' or 'Quickfix List'
        local what = { title = 0, size = 0, idx = 0 }
        local list = is_loclist and vim.fn.getloclist(0, what) or vim.fn.getqflist(what)
        if list.title ~= '' then
            table.insert(
                suffix_items,
                string.format('%%#WinbarQuickfixTitle#%s%%*', escape_winbar_text(list.title))
            )
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
    local full_path = vim.fn.expand('%')
    if full_path == '' then
        return ''
    end
    local icon = icons.misc.folder
    if vim.startswith(full_path, 'fugitive://') or vim.startswith(full_path, 'gitsigns://') then
        icon = icons.misc.source_control
    end
    local path = vim.fn.fnamemodify(full_path, ':~:h')
    return string.format('%%#WinbarPath#%s %s%%*', icon, escape_winbar_text(path))
end

---Get the icon of the current buffer's filetype
---@return string
local function get_icon()
    local filetype = vim.bo.filetype

    if has_devicons then
        local icon, icon_color = devicons.get_icon_color_by_filetype(filetype, { default = true })
        local icon_hl = 'WinbarFileIconFor' .. filetype

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
    return escape_winbar_text(filename)
end

---Render the winbar content for a special buffer
---@param filetype string
---@param winid integer
---@return string
local function render_special(filetype, winid)
    local components = {
        get_special_component(filetype, winid)
    }

    local extra_items = {}

    if filetype == 'outline' then
        -- Show "follow cursor", "provider", "filter on/off" indicators in outline window
        local provider = string.format('[%s]', vim.t.outline_provider)
        table.insert(extra_items, provider)

        local filter_kinds_hl = vim.t.filter_on and 'WinbarComponentOn' or 'WinbarComponentInactive'
        local filter_kinds = string.format('[%%#%s#%s%%*]', filter_kinds_hl, icons.misc.filter)
        table.insert(extra_items, filter_kinds)

        local follow_cursor_hl = vim.t.is_outline_follow_cursor_enabled and 'WinbarComponentOn' or 'WinbarComponentInactive'
        local follow_cursor = string.format('[%%#%s#%s%%*]', follow_cursor_hl, icons.misc.pointer)
        table.insert(extra_items, follow_cursor)
    elseif filetype == 'callhierarchy' then
        -- Show "incoming/outgoing calls" indicator in call hierarchy window
        local call_mode = string.format(
            '[%%#WinbarComponentOn#%s %%*]',
            vim.t.call_hierarchy_mode == 'incoming' and icons.misc.call_incoming
            or icons.misc.call_outgoing
        )
        table.insert(extra_items, call_mode)
    end

    if next(extra_items) then
        table.insert(components, table.concat(extra_items, ' '))
    end

    return table.concat(components, ' ')
end

---Render the winbar content for a normal file buffer
---@return string
local function render_normal()
    local components = {}

    -- Path
    local path = get_path()
    if path ~= '' then
        table.insert(components, path)
        table.insert(components, delimiter)
    end

    -- File icon
    local icon = get_icon()
    table.insert(components, icon)

    local diagnostic_count = vim.diagnostic.count(0)
    local error_count = diagnostic_count[vim.diagnostic.severity.ERROR] or 0
    local warning_count = diagnostic_count[vim.diagnostic.severity.WARN] or 0
    local file_status_hl = error_count > 0 and 'WinbarError' or (warning_count > 0 and 'WinbarWarn' or 'WinbarFilename')

    -- Name
    local name = get_name()
    table.insert(components, string.format('%%#%s#%s%%*', file_status_hl, name))

    -- Indicators
    local indicators = {}

    -- (1) Diagnostic count
    local diagnostic_total = error_count + warning_count
    if diagnostic_total ~= 0 then
        table.insert(indicators, string.format('%%#%s#[%s]%%*', file_status_hl, diagnostic_total))
    end

    -- (2) Modified indicator
    local current_bufnr = vim.api.nvim_get_current_buf()
    local is_modified = vim.bo[current_bufnr].modified
    if is_modified then
        local modified_hl = diagnostic_total == 0 and 'WinbarModified' or file_status_hl
        table.insert(indicators, '%#' .. modified_hl .. '#[+]%*')
    end

    local indicator_text = table.concat(indicators, '')
    if indicator_text ~= '' then
        table.insert(components, indicator_text)
    end

    -- Breadcrumbs
    local breadcrumb_text = vim.w.breadcrumbs or ''
    if breadcrumb_text ~= '' then
        table.insert(components, delimiter)
        table.insert(components, breadcrumb_text)
    end

    return table.concat(components, ' ')
end

---Render the winbar for the current window.
---@return string
function M.render()
    local filetype = vim.bo.filetype
    local current_winid = vim.api.nvim_get_current_win()

    local header = get_header()

    -- 1. Special buffer: header + special component + extra_items
    if is_special_window(filetype, current_winid) then
        return header .. ' ' .. render_special(filetype, current_winid)
    end

    -- 2. Normal buffer: header + path + file_icon + name + indicators + breadcrumbs
    return header .. ' ' .. render_normal()
end

--------------------------------------------------------------------------------
-- Breadcrumbs
--------------------------------------------------------------------------------

-- Reference: https://github.com/juniorsundar/nvim/blob/main/lua/custom/micro.nvim/lua/micro/breadcrumbs.lua

---Return whether the cursor position is inside an LSP range
---Convert LSP character offsets to byte columns before comparison
---
---TODO: later it can be implemented using vim.pos and vim.range, but they have bugs right now
---(e.g., when pasting a large block of code at the end of the file, vim.pos.lsp will throw an
---"index out of range" error)
---@param bufnr integer
---@param range lsp.Range line and character inside are 0-indexed
---@param cursor_position [integer, integer] Cursor position from nvim_win_get_cursor(); row is
---1-indexed, column is 0-indexed
---@param offset_encoding string
---@return boolean
local function range_contains_cursor(bufnr, range, cursor_position, offset_encoding)
    local range_start = range.start
    local range_end = range['end']
    local start_row = range_start.line
    local end_row = range_end.line

    local cursor_row = cursor_position[1] - 1 -- convert to 0-indexed
    local cursor_column = cursor_position[2] -- 0-indexed

    if cursor_row < start_row or cursor_row > end_row then
        return false
    end

    local start_column = range_start.character
    if start_column > 0 then
        local start_line_text = api.get_lines(bufnr, { start_row })[start_row]
        start_column = vim.str_byteindex(start_line_text, offset_encoding, start_column, false)
    end

    if cursor_row == start_row and cursor_column < start_column then
        return false
    end

    local end_column = range_end.character
    if end_column > 0 then
        local end_line_text = api.get_lines(bufnr, { end_row })[end_row]
        end_column = vim.str_byteindex(end_line_text, offset_encoding, end_column, false)
    end

    if cursor_row == end_row and cursor_column >= end_column then
        return false
    end

    return true
end

---Build the symbol path containing the current cursor position
---@param bufnr integer
---@param document_symbols lsp.DocumentSymbol[]|lsp.SymbolInformation[]|nil
---@param offset_encoding string
---@param cursor_position [integer, integer] Result of vim.api.nvim_win_get_cursor(0)
---@param symbol_path_components string[]
local function build_symbol_path(
    bufnr,
    document_symbols,
    offset_encoding,
    cursor_position,
    symbol_path_components
)
    if document_symbols == nil then
        return
    end
    for _, document_symbol in ipairs(document_symbols) do
        -- Some LSPs, such as bash, still return the deprecated SymbolInformation[] from the
        -- document-symbol request. Its range is stored in document_symbol.location.range rather than
        -- document_symbol.range.
        local symbol_range = document_symbol.range or (document_symbol.location and document_symbol.location.range)

        if
            symbol_range
            and range_contains_cursor(bufnr, symbol_range, cursor_position, offset_encoding)
        then
            local symbol_kind = vim.lsp.protocol.SymbolKind[document_symbol.kind] or 'Unknown'
            local symbol_icon = icons.symbol_kinds[symbol_kind]
            local highlighted_icon =
                string.format('%%#SymbolKind%s#%s%%*', symbol_kind, symbol_icon)
            table.insert(
                symbol_path_components,
                highlighted_icon .. ' ' .. escape_winbar_text(document_symbol.name)
            )
            build_symbol_path(
                bufnr,
                document_symbol.children,
                offset_encoding,
                cursor_position,
                symbol_path_components
            )
            return
        end
    end
end

---Set breadcrumb text for a window
---@param winid integer
---@param breadcrumb_text string
local function set_breadcrumbs(winid, breadcrumb_text)
    vim.w[winid].breadcrumbs = breadcrumb_text
    vim.cmd('redrawstatus')
end

---Refresh breadcrumbs for the current window
local function refresh_breadcrumbs()
    local current_bufnr = vim.api.nvim_get_current_buf()
    local current_winid = vim.api.nvim_get_current_win()
    local request_params = {
        textDocument = vim.lsp.util.make_text_document_params(current_bufnr)
    }
    local method = 'textDocument/documentSymbol'
    local document_symbol_clients = vim.lsp.get_clients({
        method = method,
        bufnr = current_bufnr,
    })
    if not next(document_symbol_clients) then
        set_breadcrumbs(current_winid, '')
        return
    end

    local request_cursor_position = vim.api.nvim_win_get_cursor(current_winid)
    local request_changedtick = vim.api.nvim_buf_get_changedtick(current_bufnr)

    vim.lsp.buf_request_all(current_bufnr, method, request_params, function(results, ctx)
        if not vim.api.nvim_win_is_valid(current_winid) then
            return
        end

        if not vim.api.nvim_buf_is_valid(ctx.bufnr) then
            return
        end

        if ctx.bufnr ~= vim.api.nvim_win_get_buf(current_winid) then
            return
        end

        if vim.api.nvim_buf_get_changedtick(ctx.bufnr) ~= request_changedtick then
            return
        end

        local current_cursor_position = vim.api.nvim_win_get_cursor(current_winid)
        if current_cursor_position[1] ~= request_cursor_position[1]
            or current_cursor_position[2] ~= request_cursor_position[2]
        then
            return
        end

        -- Results are keyed by client ID
        -- results[client_id] = { err = err, error = err, result = result, context = ctx }
        for client_id, client_result in pairs(results) do
            if not client_result.err then
                local client = vim.lsp.get_client_by_id(client_id)
                if client and client.offset_encoding then
                    local symbol_path_components = {}
                    build_symbol_path(
                        current_bufnr,
                        client_result.result,
                        client.offset_encoding,
                        request_cursor_position,
                        symbol_path_components
                    )

                    if next(symbol_path_components) then
                        local breadcrumb_text = table.concat(symbol_path_components, ' ' .. delimiter .. ' ')
                        set_breadcrumbs(current_winid, breadcrumb_text)
                        return
                    end
                end
            end
        end

        set_breadcrumbs(current_winid, '')
    end)
end

local breadcrumbs_augroup = vim.api.nvim_create_augroup('rockyz.winbar.breadcrumbs', { clear = true })
local winbar_augroup = vim.api.nvim_create_augroup('rockyz.winbar', { clear = true })

vim.api.nvim_create_autocmd('ColorScheme', {
    group = winbar_augroup,
    callback = function()
        icon_highlight_cache = {}
    end,
})

-- Refresh the breadcrumbs of the current window
vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI', 'BufWinEnter' }, {
    group = breadcrumbs_augroup,
    callback = refresh_breadcrumbs,
})

-- vim.o.winbar = "%{%v:lua.require('rockyz.winbar').render()%}"

-- WinEnter covers splits from floating windows because BufWinEnter is not triggered for an already
-- visible buffer
vim.api.nvim_create_autocmd({ 'BufWinEnter', 'WinEnter' }, {
    group = winbar_augroup,
    callback = function()
        local window_config = vim.api.nvim_win_get_config(0)
        if window_config.relative == '' then
            vim.wo.winbar = "%{%v:lua.require('rockyz.winbar').render()%}"
        end
    end,
})

return M
