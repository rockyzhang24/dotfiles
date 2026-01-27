-- The structure of each tab:
-- Indicator Tab_number. Icon Title Diagnostic_info Modification_indicator
--                        ^     ^
--                        |_____|
--                           |___ get_icon_and_title()

local M = {}

local icons = require('rockyz.icons')
local special_filetypes = require('rockyz.special_filetypes')

local cached_hls = {}

---Get get the filetype icon and the title
---@param winid number The winid of the current window in the tabpage.
---@param is_cur boolean Whether it's the current tabpage. It's used to set the highlight group for
---icons.
---@param title_hl string The highlight group for this tab title part.
---@return string, string
local function get_icon_and_title(winid, is_cur, title_hl)
    local bufnr = vim.api.nvim_win_get_buf(winid)
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    local filetype = vim.bo[bufnr].filetype
    -- For special filetypes, e.g., fzf or term
    if vim.fn.win_gettype(winid) == 'loclist' then
        filetype = 'loclist'
    end
    local sp_ft = special_filetypes[filetype]
    or vim.fn.win_gettype(winid) == 'command' and special_filetypes['cmdwin']
    or bufname == '' and special_filetypes['noname']
    if sp_ft then
        local icon = sp_ft.icon
        local icon_hl = is_cur and 'TabDefaultIconActive' or 'TabDefaultIcon'
        local title = sp_ft.title
        return string.format('%%#%s#%s%%#%s# [%s]', icon_hl, icon, title_hl, title),
            string.format('%s [%s]', icon, title)
    end
    -- For normal filetype
    local title = vim.fn.fnamemodify(bufname, ':t')
    if filetype == 'git' then
        title = 'Git'
    end
    if vim.wo[winid].diff then
        title = title .. '[diff]'
    end
    local has_devicons, devicons = pcall(require, 'nvim-web-devicons')
    if has_devicons then
        local icon, icon_color = devicons.get_icon_color_by_filetype(filetype, { default = true })
        local icon_hl = string.format('TabIcon%s-%s', is_cur and 'Active' or '', filetype)
        -- Defined the highlight group for the icon. Its fg is fetched from devicons, its bg and sp
        -- should respect the title part.
        if not cached_hls[icon_hl] then
            local tab_hl_def = vim.api.nvim_get_hl(0, { name = title_hl })
            vim.api.nvim_set_hl(
                0,
                icon_hl,
                { fg = icon_color, bg = tab_hl_def.bg, underline = tab_hl_def.underline, sp = tab_hl_def.sp }
            )
            cached_hls[icon_hl] = true
        end
        return string.format('%%#%s#%s%%#%s# %s', icon_hl, icon, title_hl, title),
            icon .. ' ' .. title
    end
    local icon_title = icons.misc.file .. ' ' .. title
    return icon_title, icon_title
end

---Create a centered viewport around the current tab
---@param current integer The current tabpage number
---@param widths table<integer, integer> A map from tabpage number to its **visible** width
---@param view_width integer Maximum width for the tab area
---@return integer left The tabpage number of the leftmost tab of the viewport
---@return integer right The tabpage number of the rightmost tab of the viewport
local function create_view(current, widths, view_width)
    local sum = widths[current]
    local left = current
    local right = current

    while true do
        local expanded = false

        -- Try to expand to the left tab
        local wl = widths[left - 1] or math.huge
        if sum + wl <= view_width then
            left = left - 1
            sum = sum + wl
            expanded = true
        end
        -- Try to expand to the right tab
        local wr = widths[right + 1] or math.huge
        if sum + wr <= view_width then
            right = right + 1
            sum = sum + wr
            expanded = true
        end

        if not expanded then
            break
        end
    end

    return left, right
end

local function strw(s)
    return vim.api.nvim_strwidth(s)
end

function M.render()
    local tabids = vim.api.nvim_list_tabpages()
    local cur = vim.api.nvim_get_current_tabpage()

    -- Stores the format string of each tab. The format string contains highlight group (%#hl#),
    -- click target (%iT), etc. It's used for rendering the tabline.
    local tabs = {}
    -- Stores the **visible** text for each tab, with all format sequences removed. It's used for
    -- calculating the viewport of the centered scrollable tabline.
    local vis_tabs = {}

    -- For each tab, build:
    -- 1) a render string (with format sequences such as highlight group)
    -- 2) a visible string (for viewport calculation)
    for i, tabid in ipairs(tabids) do
        local winid = vim.api.nvim_tabpage_get_win(tabid)
        local bufnr = vim.api.nvim_win_get_buf(winid)
        local is_cur = tabid == cur -- current tab or not
        local tab_hl = is_cur and 'TabLineSel' or 'TabLine'

        -- Collect diagnostic info
        local cur_diag = 0 -- diagnostic count of the current window in the tab
        local total_error = 0 -- total error count across all wins in the tab
        local total_warn = 0 -- total warn count across all wins in the tab
        local wins = vim.api.nvim_tabpage_list_wins(tabid)
        for _, win in ipairs(wins) do
            local buf = vim.api.nvim_win_get_buf(win)
            local diag = vim.diagnostic.count(buf)
            local error = diag[vim.diagnostic.severity.ERROR] or 0
            local warn = diag[vim.diagnostic.severity.WARN] or 0
            total_error = total_error + error
            total_warn = total_warn + warn
            if win == winid then
                cur_diag = error + warn
            end
        end
        local total_diag = total_error + total_warn -- diagnostic count across all windows in the tab
        local diag_hl = ''
        if total_error > 0 then
            diag_hl = is_cur and 'TabErrorActive' or 'TabError'
        elseif total_warn > 0 then
            diag_hl = is_cur and 'TabWarnActive' or 'TabWarn'
        end

        -- Sections of this tab that include format sequences such as highlight group. It's the real
        -- tabline string for this tab.
        local fmt_items = {}
        -- Plain text for this tab.
        local vis_items = {}

        -- Indicator, the bar on the leftmost of the tab
        -- %iT label at the beginning of each tab is used for mouse click
        local indicator_hl = is_cur and 'TabIndicatorActive' or 'TabIndicatorInactive'
        table.insert(fmt_items, string.format('%%%sT%%#%s#%s%%#%s#', i, indicator_hl, icons.separators.bar_left_bold, tab_hl))
        table.insert(vis_items, string.format('%%%sT%s', i, icons.separators.bar_left_bold))

        -- Tab number
        table.insert(fmt_items, i .. '.')
        table.insert(vis_items, i .. '.')

        -- Icon and title
        local title_hl = diag_hl ~= '' and diag_hl or tab_hl
        local fmt_title, vis_title = get_icon_and_title(winid, is_cur, title_hl)
        table.insert(fmt_items, fmt_title)
        table.insert(vis_items, vis_title)

        -- Status
        local status = {}
        local vis_status = {}
        -- (1). Diagnostic info
        -- Display the diagnostic count for the current window in this tabpage and the total diagnostic
        -- count across all windows
        if total_diag > 0 then
            table.insert(
                status,
                string.format('%%#%s#[%s/%s]%%#%s#', diag_hl, cur_diag, total_diag, tab_hl)
            )
            table.insert(vis_status, string.format('[%s/%s]', cur_diag, total_diag))
        end
        -- (2). "Modified" indicator
        local bufmodified = vim.fn.getbufvar(bufnr, '&mod')
        if bufmodified ~= 0 then
            if total_diag > 0 then
                table.insert(
                    status,
                    string.format('%%#%s#[+]%%#%s#', diag_hl, tab_hl)
                )
            else
                table.insert(status, '[+]')
            end
            table.insert(vis_status, '[+]')
        end
        table.insert(fmt_items, table.concat(status))
        table.insert(vis_items, table.concat(vis_status))

        -- Assemble this tab
        local tab = string.format('%%#%s#%s ', tab_hl, table.concat(fmt_items, ' '))
        table.insert(tabs, tab)
        table.insert(vis_tabs, table.concat(vis_items, ' '))
    end

    -- Calculate the centered scrollable viewport
    local total = #tabs
    local cur_i = vim.api.nvim_tabpage_get_number(cur)

    local widths = {}
    for i, tab in ipairs(vis_tabs) do
        widths[i] = strw(tab)
    end

    local count = string.format('[%s/%s]', cur_i, total)
    local count_w = strw(count)

    local avail = vim.o.columns - count_w
    local has_left, has_right = false, false

    local left, right = create_view(cur_i, widths, avail)

    if left > 1 then
        has_left = true
        avail = avail - strw(icons.misc.left_double_chevron)
    end
    if right < total then
        has_right = true
        avail = avail - strw(icons.misc.right_double_chevron)
    end

    left, right = create_view(cur_i, widths, avail)

    -- Assemble the final tabline string:
    -- [optional 󰄽] [tab1] [tab2] ... [tabn] [optional 󰄾]          [right-aligned count]
    local tabline = {}
    if has_left then
        table.insert(tabline, "%#TabLineFill#" .. icons.misc.left_double_chevron .. '  ')
    end
    for i = left, right do
        table.insert(tabline, tabs[i])
    end
    if has_right then
        table.insert(tabline, "%#TabLineFill#" .. icons.misc.right_double_chevron)
    end

    table.insert(tabline, "%#TabLineFill#%=" .. count)
    table.insert(tabline, "%#TabLineFill#%T")
    return table.concat(tabline)
end

vim.o.showtabline = 2
vim.o.tabline = "%{%v:lua.require('rockyz.tabline').render()%}"

return M
