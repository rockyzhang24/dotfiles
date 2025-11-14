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
            local follow_cursor_hl = vim.t.outline_follow_cursor and 'StlComponentOn' or 'StlComponentInactive'
            local follow_cursor = string.format('[%%#%s#%s%%*]', follow_cursor_hl, icons.misc.pointer)
            winbar = winbar .. ' ' .. follow_cursor
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

-- Recursively find the path of symbols at the current cursor position
local function find_symbol_path(symbols, bufnr, client, symbol_path_component)
    if symbols == nil then
        return
    end
    -- vim.pos and vim.range require Neovim 0.12
    local cursor_pos = vim.pos.cursor(vim.api.nvim_win_get_cursor(0))
    local cursor_range = vim.range(cursor_pos, cursor_pos)
    for _, symbol in ipairs(symbols) do
        -- Some LSPs (e.g., bash) are still using the deprecated SymbolInformation[] as the response
        -- of Document Symbols request. The symbol range is located at symbol.location.range instead
        -- of symbol.range
        local symbol_range = vim.range.lsp(bufnr, symbol.range or symbol.location.range, client.offset_encoding)
        if vim.range.has(symbol_range, cursor_range) then
            local kind = vim.lsp.protocol.SymbolKind[symbol.kind] or 'Unknown'
            local icon = icons.symbol_kinds[kind]
            local colored_icon = string.format('%%#SymbolKind%s#%s%%*', kind, icon)
            table.insert(symbol_path_component, colored_icon .. ' ' .. symbol.name)
            find_symbol_path(symbol.children, bufnr, client, symbol_path_component)
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

    local cursor_pos = vim.pos.cursor(vim.api.nvim_win_get_cursor(winid))

    for _, client in ipairs(clients) do
        client:request(method, params, function(_, result, _)

            if not vim.api.nvim_win_is_valid(winid) then
                return
            end

            local new_cursor_pos = vim.pos.cursor(vim.api.nvim_win_get_cursor(winid))
            if new_cursor_pos ~= cursor_pos then
                return
            end

            local symbol_path_components = {}
            find_symbol_path(result, bufnr, client, symbol_path_components)
            vim.w[winid].breadcrumbs = table.concat(symbol_path_components, ' ' .. delimiter .. ' ')
            vim.cmd('redrawstatus')

        end, bufnr)
    end
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
