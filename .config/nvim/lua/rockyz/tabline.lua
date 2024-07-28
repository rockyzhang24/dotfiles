-- The structure of each tab is like:
-- Tab_number. Icon Title Diagnostic_info Modification_indicator Right_border
--              ^     ^
--              |_____|
--                 |___ get_icon_and_title()

local M = {}

local icons = require('rockyz.icons')
local special_filetypes = require('rockyz.special_filetypes')

local cached_hls = {}

---Get get the filetype icon and the title
---@param winid number The winid of the current window in the tabpage.
---@param is_cur boolean Whether it's the current tabpage. It's used to set the highlight group for
---icons.
---@param title_hl string The highlight group for this tab title part.
---@return string
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
    return string.format('%%#%s#%s%%#%s# [%s]', icon_hl, icon, title_hl, title)
  end
  -- For normal filetype
  local title = vim.fn.fnamemodify(bufname, ':t')
  if filetype == 'git' then
    title = 'Git'
  end
  if vim.wo[winid].diff then
    title = title .. ' (diff)'
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
    return string.format('%%#%s#%s%%#%s# %s', icon_hl, icon, title_hl, title)
  end
  return icons.misc.file .. title
end

function M.render()
  local tabs = {}

  -- Render each tab
  for i, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
    local winid = vim.api.nvim_tabpage_get_win(tabpage)
    local bufnr = vim.api.nvim_win_get_buf(winid)
    local is_cur = tabpage == vim.api.nvim_get_current_tabpage() -- current tab or not
    local tab_hl = is_cur and 'TabLineSel' or 'TabLine'

    -- Collect diagnostic info
    local cur_diag = 0 -- diagnostic count of the current window in the tab
    local total_error = 0 -- total error count across all wins in the tab
    local total_warn = 0 -- total warn count across all wins in the tab
    local wins = vim.api.nvim_tabpage_list_wins(tabpage)
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

    local items = {}

    -- Tab number
    -- %iT label at the beginning of each tab is used for mouse click
    local num = string.format('%%%sT %s.', i, i)
    table.insert(items, num)

    -- Icon and title
    local title_hl = diag_hl ~= '' and diag_hl or tab_hl
    local tab_title = get_icon_and_title(winid, is_cur, title_hl)
    table.insert(items, tab_title)

    -- Diagnostic info
    -- Display the diagnostic count for the current window in this tabpage and the total diagnostic
    -- count across all windows
    if total_diag > 0 then
      table.insert(
        items,
        string.format('%%#%s#(%s/%s)%%#%s#', diag_hl, cur_diag, total_diag, tab_hl)
      )
    end

    -- "Modified" indicator
    local bufmodified = vim.fn.getbufvar(bufnr, '&mod')
    if bufmodified ~= 0 then
      if total_diag > 0 then
        table.insert(
          items,
          string.format('%%#%s#%s%%#%s#', diag_hl, icons.misc.circle_filled, tab_hl)
        )
      else
        table.insert(items, icons.misc.circle_filled)
      end
    end

    -- Right border
    local border = '%#TabBorderRight#|'
    table.insert(items, border)

    -- Assemble tabline for this one tab
    local tab = string.format('%%#%s#%s', tab_hl, table.concat(items, ' '))
    table.insert(tabs, tab)
  end

  -- Assemble the complete tabline for all tabs
  local tabline = table.concat(tabs)
  tabline = string.format('%s%%#TabLineFill#%%T', tabline)
  return tabline
end

vim.o.showtabline = 2
vim.o.tabline = "%{%v:lua.require('rockyz.tabline').render()%}"

return M
