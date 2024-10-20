-- The winbar's structure:
-- Header | Path_prefix > Path > Icon > Name [diagnostics/modified indicator] > Breadcrumbs
-- ^            ^          ^       ^     ^
-- |            |__________|       |     |___ name_component()
-- |                 |             |___ icon_component()
-- |                 |___ path_component()
-- |___ header_component()

local M = {}

local navic = require('nvim-navic')
local icons  = require('rockyz.icons')
local delimiter = icons.caret.right
local special_filetypes = require('rockyz.special_filetypes')

-- Cache the highlight groups created for different icons
local cached_hls = {}

local function header_component()
    local items = {}
    -- Window number: used for window switching
    local winnr = string.format('[%s]', vim.api.nvim_win_get_number(0))
    table.insert(items, winnr)
    -- "Maximized" indicator
    if vim.w.maximized == 1 then
        table.insert(items, icons.misc.maximized)
    end

    local header = string.format(
        '%%#WinbarHeader# %s %%#WinbarTriangleSep#%s%%*',
        table.concat(items, ' '),
        icons.separators.triangle_right
    )
    return header
end

local function path_component()
    -- Window with special filetype (like term, aerial, etc) does not have path component
    local ft = vim.bo.filetype
    local winid = vim.api.nvim_get_current_win()
    if special_filetypes[ft] or ft == 'git' or vim.fn.win_gettype(winid) == 'command' then
        return ''
    end
    -- Window with normal filetype displays the path of the file
    -- Winbar displays the path with two parts: prefix (icon and a pre-defined name) and path
    local fullpath = vim.fn.expand('%')
    if fullpath == '' then
        return ''
    end
    local icon = icons.misc.folder
    if string.find(fullpath, '^fugitive://') or string.find(fullpath, '^gitsigns://') then
        icon = icons.misc.source_control
    end
    local path = vim.fn.fnamemodify(fullpath, ':~:h')
    return string.format('%%#WinbarPath#%s%s%%*', icon, path)
end

local function icon_component()
    local ft = vim.bo.filetype
    local winid = vim.api.nvim_get_current_win()
    -- Window with special filetype
    local fmt_str = '%%#WinbarSpecialIcon#%s%%*'
    if special_filetypes[ft] then
        return string.format(fmt_str, special_filetypes[ft].icon)
    end
    if vim.fn.win_gettype(winid) == 'command' then
        return string.format(fmt_str, special_filetypes.cmdwin.icon)
    end
    -- Window with normal filetype
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

local function name_component()
    -- For window with special filetype
    local ft = vim.bo.filetype
    local winid = vim.api.nvim_get_current_win()
    if ft == 'aerial' then
        return 'Outline [Aerial]'
    end
    if ft == 'floggraph' or ft == 'fugitive' or ft == 'oil' or ft == 'term' then
        return vim.fn.expand('%')
    end
    if ft == 'fugitiveblame' then
        return 'Fugitive Blame'
    end
    if ft == 'gitsigns.blame' then
        return 'Gitsigns Blame'
    end
    if ft == 'kitty_scrollback' then
        return 'Kitty Scrollback'
    end
    if ft == 'qf' then
        local is_loclist = vim.fn.win_gettype(winid) == 'loclist'
        local type = is_loclist and 'Location List' or 'Quickfix List'
        local what = { title = 0, size = 0, idx = 0 }
        local list = is_loclist and vim.fn.getloclist(0, what) or vim.fn.getqflist(what)
        -- The output format is like {list type} > {list title} > {current idx}
        -- E.g., "Quickfix List > Diagnostics > [1/10]"
        local items = {}
        table.insert(items, type) -- type
        if list.title ~= '' then
            table.insert(items, list.title) -- title
        end
        table.insert(items, string.format('[%s/%s]', list.idx, list.size)) -- index
        return table.concat(items, ' ' .. delimiter .. ' ')
    end
    if ft == 'tagbar' then
        return 'Tagbar'
    end
    if vim.fn.win_gettype(winid) == 'command' then
        return 'Command-line Window'
    end
    -- For window with normal filetype
    local filename = vim.fn.expand('%:t')
    if filename == '' then
        filename = '[No Name]'
    end
    return filename
end

M.render = function()
    local items = {}

    -- Header
    -- It is the first part of the winbar with powerline style
    local header = header_component()
    table.insert(items, header)

    -- Path
    local path = path_component()
    if path ~= '' then
        table.insert(items, path)
        table.insert(items, delimiter)
    end

    -- File icon
    local icon = icon_component()
    table.insert(items, icon)

    local diag_cnt = vim.diagnostic.count(0)
    local error_cnt = diag_cnt[vim.diagnostic.severity.ERROR] or 0
    local warn_cnt = diag_cnt[vim.diagnostic.severity.WARN] or 0
    local hl = error_cnt > 0 and 'WinbarError' or (warn_cnt > 0 and 'WinbarWarn' or 'WinbarFilename')

    -- Name
    local name = name_component()
    table.insert(items, string.format('%%#%s#%s%%*', hl, name))

    -- Diagnostic count
    local diag_total = error_cnt + warn_cnt
    if diag_total ~= 0 then
        table.insert(items, string.format('%%#%s#(%s)%%*', hl, diag_total))
    end

    -- "Modified" indicator
    local bufnr = vim.api.nvim_get_current_buf()
    local mod = vim.fn.getbufvar(bufnr, '&mod')
    if mod ~= 0 then
        local hl_mod = diag_total == 0 and 'WinbarModified' or hl
        table.insert(items, string.format('%%#%s#%s%%*', hl_mod, icons.misc.circle_filled))
    end

    -- Truncate if too long
    items[#items] = items[#items] .. '%<'

    -- Breadcrumbs
    if navic.is_available() then
        local context = navic.get_location()
        local breadcrumbs = delimiter .. ' ' .. (context == '' and icons.misc.ellipsis or context)
        table.insert(items, breadcrumbs)
    end

    return table.concat(items, ' ')
end

-- vim.o.winbar = "%{%v:lua.require('rockyz.winbar').render()%}"

vim.api.nvim_create_autocmd('BufWinEnter', {
    group = vim.api.nvim_create_augroup('rockyz/winbar', { clear = true }),
    callback = function()
        if not vim.api.nvim_win_get_config(0).zindex then
            vim.wo.winbar = "%{%v:lua.require('rockyz.winbar').render()%}"
        end
    end,
})

return M
