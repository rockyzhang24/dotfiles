local M = {}

local navic = require('nvim-navic')
local icons  = require('rockyz.icons')
local delimiter = icons.misc.delimiter

-- Cache the highlight groups created for different icons
local cached_hls = {}

local function get_winnr()
  local winnr = vim.api.nvim_win_get_number(0)
  return '[' .. winnr .. ']'
end

local function get_maximize_status()
  return vim.w.maximized == 1 and ' ' .. icons.misc.maximized or ''
end

local function get_file_icon_and_name()
  local filename = vim.fn.expand('%:t')
  if filename == '' then
    filename = '[No Name]'
  end
  local ft = vim.bo.filetype
  local has_devicons, devicons = pcall(require, 'nvim-web-devicons')
  if has_devicons then
    local icon, icon_color = devicons.get_icon_color_by_filetype(ft, { default = true })
    local icon_hl = 'WinbarFileIconFor' .. ft
    if not cached_hls[icon_hl] then
      vim.api.nvim_set_hl(0, icon_hl, { fg = icon_color, underline = true, sp = '#000000' })
      cached_hls[icon_hl] = true
    end
    return string.format('%%#%s#%s%%* %s', icon_hl, icon, filename)
  end
  return icons.misc.file .. filename
end

local function get_modified()
  local modified = vim.api.nvim_eval_statusline('%m', {}).str
  return modified ~= '' and string.format(' %%#WinbarModified#%s%%*', modified) or ''
end

M.render = function()
  local winbar = ''

  -- Winbar header: showing key information with powerline style.
  local header = get_winnr() .. get_maximize_status()
  winbar = string.format('%%#WinbarHeader# %s %%#WinbarTriangleSep#%s%%*', header, icons.separators.triangle_right)

  -- Deal with the special buffers
  local ft = vim.bo.filetype
  local winid = vim.api.nvim_get_current_win()
  if ft == 'qf' then
    -- Quickfix
    local is_loclist = vim.fn.getloclist(0, { filewinid = 0 }).filewinid ~= 0
    local list_type = is_loclist and 'Location List' or 'Quickfix List'
    local what = { title = 0, size = 0, idx = 0 }
    local list = is_loclist and vim.fn.getloclist(0, what) or vim.fn.getqflist(what)
    local list_title = list.title
    winbar = winbar .. ' ' .. list_type -- show type (quickfix or location list)
    if list_title ~= '' then
      winbar = winbar .. ' ' .. delimiter .. list_title -- show title
    end
    winbar = winbar .. ' [' .. list.idx .. '/' .. list.size .. ']' -- show size of the list and current focused idx
    return winbar
  elseif ft == 'fugitive' then
    -- Fugitive: show the repo path
    return winbar
      .. ' Fugitive: '
      .. string.match(vim.fn.expand('%:h:h'), 'fugitive://(.*)')
  elseif ft == 'oil' then
    -- Oil: show the parent dir
    return winbar
      .. ' Oil: '
      .. string.match(vim.fn.expand('%'), 'oil://(.*)')
  elseif ft == 'git' then
    -- Git
    return winbar .. ' ' .. vim.fn.expand('%')
  elseif ft == 'term' then
    -- Terminal
    return winbar .. ' ' .. vim.fn.expand('%')
  elseif ft == 'aerial' or ft == 'Outline' then
    -- Aerial
    return winbar .. ' Outline'
  elseif vim.fn.win_gettype(winid) == 'command' then
    -- Command-line window
    return winbar .. ' Command-line window'
  end

  -- File path
  local path = vim.fn.expand('%:~:.:h')
  -- For the window of fugitive diff (it's a regular buffer but with 'diff' set)
  if string.find(path, '^fugitive:') then
    local fugitive_git_path, fugitive_file_path = string.match(path, '^fugitive://(%S+//%w+)/(.*)')
    fugitive_git_path = vim.fn.fnamemodify(fugitive_git_path, ':~:.')
    path = fugitive_file_path
    winbar = winbar .. ' Fugitive [' .. fugitive_git_path .. '] ' .. delimiter
  end
  if path ~= '' and path ~= '.' then
    if vim.api.nvim_win_get_width(0) < math.floor(vim.o.columns / 3) then
      path = vim.fn.pathshorten(path)
    else
      path = path:gsub('^~', 'HOME'):gsub('^/', 'ROOT/'):gsub('/', ' ' .. delimiter)
    end
    winbar = winbar .. ' ' .. path .. ' ' .. delimiter
  end

  -- File name and modified indicator
  local file_icon_and_name = get_file_icon_and_name()
  local modified = get_modified()
  winbar = winbar .. file_icon_and_name .. modified

  -- Truncate if too long
  winbar = winbar .. ' %<'

  -- Breadcrumbs
  if navic.is_available() then
    local context = navic.get_location()
    winbar = winbar .. delimiter .. (context == '' and icons.misc.ellipsis or context)
  end

  return winbar
end

vim.o.winbar = "%{%v:lua.require('rockyz.winbar').render()%}"

return M
