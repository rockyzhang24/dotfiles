-- The structure of each tab:
-- Indicator Tab_number. Icon Title Diagnostic_info Modification_indicator
--                        ^     ^
--                        |_____|
--                           |___ build_title_section()

local M = {}

local icons = require('rockyz.icons')
local special_filetypes = require('rockyz.special_filetypes')

local has_devicons, devicons = pcall(require, 'nvim-web-devicons')

local icon_highlight_cache = {}

---@class DiagnosticCounts
---@field current_window integer Number of errors and warnings in the current window
---@field total integer Total number of errors and warnings across all windows in the tabpage
---@field total_error integer Total number of errors across all windows in the tabpage
---@field total_warn integer Total number of warnings across all windows in the tabpage

---@class TablineSection
---@field formatted string Text with tabline format sequences (e.g., highlight group %#...#, mouse
---click targets %iT, etc)
---@field visible string Plain visible text used for width calculation. Format sequences are removed.

---@param winid integer
---@param bufnr integer
---@param filetype string
---@return table|nil
local function find_special_filetype(winid, bufnr, filetype)
    local win_type = vim.fn.win_gettype(winid)
    local bufname = vim.api.nvim_buf_get_name(bufnr)

    if win_type == 'loclist' then
        return special_filetypes.loclist
    end

    if win_type == 'command' then
        return special_filetypes.cmdwin
    end

    if bufname == '' then
        return special_filetypes.noname
    end

    return special_filetypes[filetype]
end

---Create a centered viewport around the current tab
---@param current integer Current tabpage index
---@param widths table<integer, integer> A map from tabpage number to its **visible** width
---@param available_width integer Maximum width for the tab area
---@return integer left The tabpage number of the leftmost tab of the viewport
---@return integer right The tabpage number of the rightmost tab of the viewport
local function compute_viewport(current, widths, available_width)
    local sum = widths[current]
    local left = current
    local right = current

    while true do
        local expanded = false

        -- Try to expand to the left tab
        local wl = widths[left - 1] or math.huge
        if sum + wl <= available_width then
            left = left - 1
            sum = sum + wl
            expanded = true
        end
        -- Try to expand to the right tab
        local wr = widths[right + 1] or math.huge
        if sum + wr <= available_width then
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

---@param text string
---@return integer
local function display_width(text)
    return vim.api.nvim_strwidth(text)
end

---@param tabpage integer
---@return DiagnosticCounts
local function collect_diagnostic_counts(tabpage)
    local current_winid = vim.api.nvim_tabpage_get_win(tabpage)

    local current_window = 0 -- diagnostic count of the current window in the tab
    local total_error = 0 -- total error count across all wins in the tab
    local total_warn = 0 -- total warn count across all wins in the tab

    for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
        local bufnr = vim.api.nvim_win_get_buf(winid)
        local counts = vim.diagnostic.count(bufnr)

        local error = counts[vim.diagnostic.severity.ERROR] or 0
        local warn = counts[vim.diagnostic.severity.WARN] or 0

        total_error = total_error + error
        total_warn = total_warn + warn

        if winid == current_winid then
            current_window = error + warn
        end
    end

    return {
        current_window = current_window,
        total = total_error + total_warn,
        total_error = total_error,
        total_warn = total_warn,
    }
end

---@param diagnostic_counts DiagnosticCounts
---@param is_current boolean
---@return string
local function get_diagnostic_highlight(diagnostic_counts, is_current)
    if diagnostic_counts.total_error > 0 then
        return is_current and 'TabErrorActive' or 'TabError'
    elseif diagnostic_counts.total_warn > 0 then
        return is_current and 'TabWarnActive' or 'TabWarn'
    end
    return ''
end

---@param index integer
---@param is_current boolean
---@param tab_highlight string
---@return TablineSection
local function build_indicator(index, is_current, tab_highlight)
    local indicator_highlight = is_current and 'TabIndicatorActive' or 'TabIndicatorInactive'
    return {
        formatted = string.format(
            '%%%sT%%#%s#%s%%#%s#',
            index,
            indicator_highlight,
            icons.block.left_one_quarter,
            tab_highlight
        ),
        visible = icons.block.left_one_quarter,
    }
end

---@param index integer
---@return TablineSection
local function build_number(index)
    local text = index .. '.'
    return {
        formatted = text,
        visible = text,
    }
end

---Ensure the highlight group for a devicon exists.
---The foreground color is taken from nvim-web-devicons. The background and text attributes are
---inherited from the title highlight group.
---@param icon_highlight string
---@param base_highlight string
---@param icon_color string
local function ensure_icon_highlight(icon_highlight, base_highlight, icon_color)
    if icon_highlight_cache[icon_highlight] then
        return
    end
    local base_hl_def = vim.api.nvim_get_hl(0, { name = base_highlight })
    vim.api.nvim_set_hl( 0, icon_highlight, {
        fg = icon_color,
        bg = base_hl_def.bg,
        underline = base_hl_def.underline,
        sp = base_hl_def.sp,
    })
    icon_highlight_cache[icon_highlight] = true
end

---Build the icon/title section for a tab
---@param winid integer Window id
---@param is_current boolean Whether the tabpage is the current one
---@param title_highlight string Highlight group used for the title
---@return TablineSection
local function build_title_section(winid, is_current, title_highlight)
    local bufnr = vim.api.nvim_win_get_buf(winid)
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    local filetype = vim.bo[bufnr].filetype

    -- For special filetypes, e.g., fzf or term
    local special = find_special_filetype(winid, bufnr, filetype)
    if special then
        local icon = special.icon
        local icon_highlight = is_current and 'TabDefaultIconActive' or 'TabDefaultIcon'
        local title = special.title
        return {
            formatted = string.format('%%#%s#%s%%#%s# [%s]', icon_highlight, icon, title_highlight, title),
            visible = string.format('%s [%s]', icon, title),
        }
    end

    -- For normal filetype
    local title = vim.fn.fnamemodify(bufname, ':t')
    if filetype == 'git' then
        title = 'Git'
    end
    if vim.wo[winid].diff then
        title = title .. '[diff]'
    end
    if has_devicons then
        local icon, icon_color = devicons.get_icon_color_by_filetype(filetype, { default = true })
        local icon_highlight = string.format('TabIcon%s-%s', is_current and 'Active' or '', filetype)

        ensure_icon_highlight(icon_highlight, title_highlight, icon_color)

        return {
            formatted = string.format(
                '%%#%s#%s%%#%s# %s',
                icon_highlight,
                icon,
                title_highlight,
                title
            ),
            visible = icon .. ' ' .. title,
        }
    end
    local icon_title = icons.misc.file .. ' ' .. title
    return {
        formatted = icon_title,
        visible = icon_title,
    }
end

---@param diagnostic_counts DiagnosticCounts
---@param diagnostic_highlight string
---@param tab_highlight string
---@param modified boolean
---@return TablineSection
local function build_status(diagnostic_counts, diagnostic_highlight, tab_highlight, modified)
    local formatted_parts = {}
    local visible_parts = {}

    -- (1). Diagnostic info
    -- Display the diagnostic count for the current window in this tabpage and the total diagnostic
    -- count across all windows
    if diagnostic_counts.total > 0 then
        table.insert(
            formatted_parts,
            string.format(
                '%%#%s#[%s/%s]%%#%s#',
                diagnostic_highlight,
                diagnostic_counts.current_window,
                diagnostic_counts.total,
                tab_highlight
            )
        )
        table.insert(
            visible_parts,
            string.format('[%s/%s]', diagnostic_counts.current_window, diagnostic_counts.total)
        )
    end

    -- (2). "Modified" indicator
    if modified then
        if diagnostic_counts.total > 0 then
            table.insert(
                formatted_parts,
                string.format('%%#%s#[+]%%#%s#', diagnostic_highlight, tab_highlight)
            )
        else
            table.insert(formatted_parts, '[+]')
        end
        table.insert(visible_parts, '[+]')
    end

    return {
        formatted = table.concat(formatted_parts),
        visible = table.concat(visible_parts),
    }
end

---@param parts string[]
---@param visible_parts string[]
---@param section TablineSection
local function append_section(parts, visible_parts, section)
    if section.formatted == '' and section.visible == '' then
        return
    end
    table.insert(parts, section.formatted)
    table.insert(visible_parts, section.visible)
end

---@param index integer
---@param tabpage integer
---@param current_tabpage integer
---@return TablineSection
local function build_tab(index, tabpage, current_tabpage)
    local winid = vim.api.nvim_tabpage_get_win(tabpage)
    local bufnr = vim.api.nvim_win_get_buf(winid)
    local is_current = tabpage == current_tabpage -- current tab or not
    local tab_highlight = is_current and 'TabLineSel' or 'TabLine'

    local diagnostic_counts = collect_diagnostic_counts(tabpage)

    local diagnostic_highlight = get_diagnostic_highlight(diagnostic_counts, is_current)

    -- Sections of this tab that include format sequences such as highlight group. It's the real
    -- tabline string for this tab.
    local parts = {}
    -- Plain text for this tab.
    local visible_parts = {}

    -- Indicator, the bar on the leftmost of the tab.
    -- %iT label at the beginning of each tab is used for mouse click
    local indicator = build_indicator(index, is_current, tab_highlight)
    append_section(parts, visible_parts, indicator)

    -- Tab number
    local number = build_number(index)
    append_section(parts, visible_parts, number)

    -- Icon and title
    local title_highlight = diagnostic_highlight ~= '' and diagnostic_highlight or tab_highlight
    local title = build_title_section(winid, is_current, title_highlight)
    append_section(parts, visible_parts, title)

    -- Status
    local modified = vim.bo[bufnr].modified
    local status = build_status(
        diagnostic_counts,
        diagnostic_highlight,
        tab_highlight,
        modified
    )
    append_section(parts, visible_parts, status)

    return {
        formatted = string.format(
            '%%#%s#%s ',
            tab_highlight,
            table.concat(parts, ' ')
        ),
        visible = table.concat(visible_parts, ' '),
    }
end

function M.render()
    local tabpages = vim.api.nvim_list_tabpages()
    local current_tabpage = vim.api.nvim_get_current_tabpage()

    ---@type TablineSection[]
    local tabs = {}

    -- For each tab, build:
    -- 1) a render string (with format sequences such as highlight group)
    -- 2) a visible string (for viewport calculation)
    for i, tabpage in ipairs(tabpages) do
        local tab = build_tab(i, tabpage, current_tabpage)
        table.insert(tabs, tab)
    end

    -- Calculate the centered scrollable viewport
    local total = #tabs
    local current_tab_index = vim.api.nvim_tabpage_get_number(current_tabpage)

    local widths = {}
    for i, tab in ipairs(tabs) do
        widths[i] = display_width(tab.visible)
    end

    local count = string.format('[%s/%s]', current_tab_index, total)
    local count_width = display_width(count)

    local available_width = vim.o.columns - count_width
    local has_left, has_right = false, false

    local left, right = compute_viewport(current_tab_index, widths, available_width)

    if left > 1 then
        has_left = true
        available_width = available_width - display_width(icons.misc.left_double_chevron)
    end
    if right < total then
        has_right = true
        available_width = available_width - display_width(icons.misc.right_double_chevron)
    end

    left, right = compute_viewport(current_tab_index, widths, available_width)

    -- Assemble the final tabline string:
    -- [optional 󰄽] [tab1] [tab2] ... [tabn] [optional 󰄾]          [right-aligned count]
    local tabline = {}
    if has_left then
        table.insert(tabline, "%#TabLineFill#" .. icons.misc.left_double_chevron .. '  ')
    end
    for i = left, right do
        table.insert(tabline, tabs[i].formatted)
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
