local M = {}

local icons = require('rockyz.icons')
local special_filetypes = require('rockyz.special_filetypes')

local cached_hls = {}

---Get get the icon of the filetype and the title (e.g, file name)
---@param winid number The winid of the current window in the tabpage
---@param is_cur boolean If it's the current tabpage. It's used to set the highlight group in the
---active tab and inactive tab.
---@return string
local function get_icon_and_tile(winid, is_cur)
  local tab_hl = is_cur and 'TabLineSel' or 'TabLine'
  local bufnr = vim.api.nvim_win_get_buf(winid)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local filetype = vim.bo[bufnr].filetype
  -- Adjust filetype for location list
  if vim.fn.win_gettype(winid) == 'loclist' then
    filetype = 'loclist'
  end
  -- For special filetypes, e.g., fzf or term
  local sp_ft = special_filetypes[filetype]
    or vim.fn.win_gettype(winid) == 'command' and special_filetypes['cmdwin']
    or bufname == '' and special_filetypes['noname']
  if sp_ft then
    local icon = sp_ft.icon
    local icon_hl = is_cur and 'TabDefaultIconActive' or 'TabDefaultIcon'
    local title = sp_ft.title
    return string.format('%%#%s#%s%%#%s# [%s]', icon_hl, icon, tab_hl, title)
  end
  -- For normal files
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
    if not cached_hls[icon_hl] then
      local tab_hl_def = vim.api.nvim_get_hl(0, { name = tab_hl })
      vim.api.nvim_set_hl(
        0,
        icon_hl,
        { fg = icon_color, bg = tab_hl_def.bg, underline = tab_hl_def.underline, sp = tab_hl_def.sp }
      )
      cached_hls[icon_hl] = true
    end
    return string.format('%%#%s#%s%%#%s# %s', icon_hl, icon, tab_hl, title)
  end
  return icons.misc.file .. title
end

function M.render()
  local tabs = {}

  -- Render each tab
  for i, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
    local winid = vim.api.nvim_tabpage_get_win(tabpage)
    local bufnr = vim.api.nvim_win_get_buf(winid)
    local is_cur = tabpage == vim.api.nvim_get_current_tabpage()

    local items = {}

    -- Tab number
    -- %iT label at the beginning of each tab is used for mouse click
    local num = string.format('%%%sT %s.', i, i)
    table.insert(items, num)

    -- Icon and title
    local tab_title = get_icon_and_tile(winid, is_cur)
    table.insert(items, tab_title)

    -- "Modified" indicator
    local bufmodified = vim.fn.getbufvar(bufnr, '&mod')
    if bufmodified ~= 0 then
      table.insert(items, icons.misc.circle_filled)
    end

    -- Right border
    local border_hl = is_cur and 'TabBorderRightActive' or 'TabBorderRight'
    local border = string.format('%%#%s#%s', border_hl, icons.separators.bar_right)
    table.insert(items, border)

    -- Assemble tabline for this tab
    local tab = is_cur and '%#TabLineSel#' or '%#TabLine#'
    tab = tab .. table.concat(items, ' ')
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
