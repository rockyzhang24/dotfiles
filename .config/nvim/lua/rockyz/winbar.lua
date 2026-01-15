-- The winbar's structure:
--
-- Header | Path > Icon > Name [diagnostics and modified indicator] > Breadcrumbs
-- ^          ^      ^     ^
-- |          |      |     |___ get_name()
-- |          |      |___ get_icon()
-- |          |____ get_path()
-- |___ get_header()
--

local M = {}

local icons  = require('rockyz.icons')
local delimiter = icons.caret.right
local special_filetypes = require('rockyz.special_filetypes')
local api = require('rockyz.utils.api')

-- Cache the highlight groups of filetype icons
local cached_hls = {}

-- Header has the window number and the indicator of maximization
local function get_header()
    local items = {}
    -- Window number
    local winnr = string.format('[%s]', vim.api.nvim_win_get_number(0))
    table.insert(items, winnr)
    -- Indicator of window maximization
    if vim.w.maximized == 1 then
        table.insert(items, icons.misc.maximized .. ' ')
    end
    return string.format('%%#WinbarHeader#%s%%*', table.concat(items, ' '))
end

-- Check if the current window is special
local function is_special_ft(ft, winid)
    return special_filetypes[ft] ~= nil or vim.fn.win_gettype(winid) == 'command'
end

-- Handle the window with special filetype
local function special_ft_component(ft, winid)
    if vim.fn.win_gettype(winid) == 'command' then
        ft = 'cmdwin'
    end

    local icon = special_filetypes[ft].icon
    local title
    local rest = {}
    if ft == 'floggraph' or ft == 'fugitive' or ft == 'oil' or ft == 'term' then
        title = vim.fn.expand('%')
    elseif ft == 'qf' then
        local is_loclist = vim.fn.win_gettype(winid) == 'loclist'
        title = is_loclist and 'Location List' or 'Quickfix List'
        local what = { title = 0, size = 0, idx = 0 }
        local list = is_loclist and vim.fn.getloclist(0, what) or vim.fn.getqflist(what)
        if list.title ~= '' then
            table.insert(rest, string.format('%%#WinbarQuickfixTitle#%s%%*', list.title))
        end
        table.insert(rest, string.format('[%s/%s]', list.idx, list.size))
    elseif vim.fn.win_gettype(winid) == 'command' then
        title = 'Command-line'
    else
        title = special_filetypes[ft].title
    end
    local rest_str = table.concat(rest, ' ' .. delimiter .. ' ')
    return string.format('%%#WinbarPath#%s %s%%*', icon, title)
        .. (rest_str ~= '' and (' ' .. delimiter .. ' ' .. rest_str) or '')
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

-- Get the filetype icon
local function get_icon()
    local ft = vim.bo.filetype
    local has_devicons, devicons = pcall(require, 'nvim-web-devicons')
    if has_devicons then
        local icon, icon_color = devicons.get_icon_color_by_filetype(ft, { default = true })
        local icon_hl = 'WinbarFileIconFor' .. ft
        if not cached_hls[icon_hl] then
            local bg_color = vim.api.nvim_get_hl(0, { name = 'Winbar' }).bg
            vim.api.nvim_set_hl(0, icon_hl, { fg = icon_color, bg = bg_color })
            cached_hls[icon_hl] = true
        end
        return string.format('%%#%s#%s%%*', icon_hl, icon)
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

M.render = function()
    local ft = vim.bo.filetype
    local winid = vim.api.nvim_get_current_win()

    local header = get_header()

    -- 1. Window with special filetype

    if is_special_ft(ft, winid) then
        local winbar = header .. ' ' .. special_ft_component(ft, winid)
        -- Show "follow cursor" indicator in outline window
        if ft == 'outline' then
            local follow_cursor_hl = vim.t.is_outline_follow_cursor_enabled and 'StlComponentOn' or 'StlComponentInactive'
            local follow_cursor = string.format('[%%#%s#%s%%*]', follow_cursor_hl, icons.misc.pointer)
            winbar = winbar .. ' ' .. follow_cursor
            local provider = string.format('[%s]', vim.t.outline_provider)
            winbar = winbar .. ' ' .. provider
        end
        return winbar
    end

    -- 2. Window with normal filetype

    local items = {}
    table.insert(items, header)

    -- Path
    local path = get_path()
    if path ~= '' then
        table.insert(items, path)
        table.insert(items, delimiter)
    end

    -- File icon
    local icon = get_icon()
    table.insert(items, icon)

    local diag_cnt = vim.diagnostic.count(0)
    local error_cnt = diag_cnt[vim.diagnostic.severity.ERROR] or 0
    local warn_cnt = diag_cnt[vim.diagnostic.severity.WARN] or 0
    local hl = error_cnt > 0 and 'WinbarError' or (warn_cnt > 0 and 'WinbarWarn' or 'WinbarFilename')

    -- Name
    local name = get_name()
    table.insert(items, string.format('%%#%s#%s%%*', hl, name))

    -- Status
    local status = {}
    -- (1). Diagnostic count
    local diag_total = error_cnt + warn_cnt
    if diag_total ~= 0 then
        table.insert(status, string.format('%%#%s#[%s]%%*', hl, diag_total))
    end
    -- (2). "Modified" indicator
    local bufnr = vim.api.nvim_get_current_buf()
    local mod = vim.fn.getbufvar(bufnr, '&mod')
    if mod ~= 0 then
        local hl_mod = diag_total == 0 and 'WinbarModified' or hl
        table.insert(status, '%#' .. hl_mod .. '#[+]%*')
    end
    local status_str = table.concat(status, '')
    if status_str ~= '' then
        table.insert(items, status_str)
    end

    -- Breadcrumbs
    if vim.w.breadcrumbs ~= '' then
        table.insert(items, delimiter)
    end
    table.insert(items, vim.w.breadcrumbs)

    return table.concat(items, ' ')
end

-- Breadcrumbs
-- Reference: https://github.com/juniorsundar/nvim/blob/main/lua/config/lsp/breadcrumbs.lua

---Check if the cursor position (line, char) is inside a LSP range
---TODO: later it can be implemented using vim.pos and vim.range, but they have bugs right now
---(e.g., when pasting a large block of code at the end of the file, vim.pos.lsp will throw an
---"index out of range" error)
---@param range lsp.Range line and character inside are 0-indexed
local function range_contains_cursor(bufnr, range, cursor_pos, offset_encoding)
    local row = range['start'].line
    local end_row = range['end'].line

    local cursor_row = cursor_pos[1] - 1 -- make it 0-indexed
    local cursor_col = cursor_pos[2] -- cursor's col defaults to be 0-indexed

    if cursor_row < row or cursor_row > end_row then
        return false
    end

    local col = range['start'].character
    if col > 0 then
        local line = api.get_lines(bufnr, { row })[row] or ''
        col = vim.str_byteindex(line, offset_encoding, col, false)
    end

    if cursor_row == row and cursor_col < col then
        return false
    end

    local end_col = range['end'].character
    if end_col > 0 then
        local end_line = api.get_lines(bufnr, { end_row })[end_row] or ''
        end_col = vim.str_byteindex(end_line, offset_encoding, end_col, false)
    end

    if cursor_row == end_row and cursor_col > end_col then
        return false
    end

    return true
end

---Recursively find the path of symbols at the current cursor position
---@param symbols lsp.DocumentSymbol[]|lsp.SymbolInformation[]
---@param cursor_pos table Cursor position, the result of vim.api.nvim_win_get_cursor(0)
local function find_symbol_path(bufnr, symbols, client, cursor_pos, symbol_path_component)
    if symbols == nil then
        return
    end
    for _, symbol in ipairs(symbols) do
        -- Some LSPs (e.g., bash) are still using the deprecated SymbolInformation[] as the response
        -- of Document Symbols request. The symbol range is located at symbol.location.range instead
        -- of symbol.range
        if range_contains_cursor(bufnr, symbol.range or symbol.location.range, cursor_pos, client.offset_encoding) then
            local kind = vim.lsp.protocol.SymbolKind[symbol.kind] or 'Unknown'
            local icon = icons.symbol_kinds[kind]
            local colored_icon = string.format('%%#SymbolKind%s#%s%%*', kind, icon)
            table.insert(symbol_path_component, colored_icon .. ' ' .. symbol.name)
            find_symbol_path(symbol.children, client, cursor_pos, symbol_path_component)
            return
        end
    end
end

local function get_breadcrumbs()
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

    vim.lsp.buf_request_all(bufnr, method, params, function(results, _, _)
        if not vim.api.nvim_win_is_valid(winid) then
            return
        end
        local new_cursor_pos = vim.api.nvim_win_get_cursor(winid)
        if new_cursor_pos[1] ~= cursor_pos[1] or new_cursor_pos[2] ~= cursor_pos[2] then
            return
        end
        -- The structure of "results":
        -- results[ctx.client_id] = { err = err, error = err, result = result, context = ctx }
        for client_id, data in pairs(results) do
            if data.err then
                vim.notify('Error: failed to request document symbols for displaying breadcrumbs', vim.log.levels.WARN)
                return
            end
            local symbol_path_components = {}
            local client = vim.lsp.get_client_by_id(client_id)
            find_symbol_path(bufnr, data.result, client, cursor_pos, symbol_path_components)
            vim.w[winid].breadcrumbs = table.concat(symbol_path_components, ' ' .. delimiter .. ' ')
            vim.cmd('redrawstatus')
        end
    end)
end

-- Refresh the breadcrumbs of the current window
vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI', 'BufWinEnter' }, {
    group = vim.api.nvim_create_augroup('rockyz.winbar.breadcrumbs', { clear = true }),
    callback = function()
        get_breadcrumbs()
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
