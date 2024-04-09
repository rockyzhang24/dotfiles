local M = {}

local devicon = require('nvim-web-devicons')
local navic = require('nvim-navic')
local icons = require('rockyz.icons').misc
local tri_sep = require('rockyz.icons').separators.triangle_right

local function get_win_num()
  local win_num = vim.api.nvim_win_get_number(0)
  return '[' .. win_num .. ']'
end

local function get_file_icon_and_name()
  local filename = vim.fn.expand('%:t')
  local ft = vim.bo.filetype
  local file_icon, file_icon_color = devicon.get_icon_color_by_filetype(ft, { default = true })
  vim.api.nvim_set_hl(0, 'WinbarFileIcon', { fg = file_icon_color, underline = true, sp = '#000000' })
  return '%#WinbarFileIcon#' .. file_icon .. '%* ' .. (filename == '' and '[No Name]' or filename)
end

local function get_modified()
  local modified = vim.api.nvim_eval_statusline('%m', {}).str
  return modified == '' and '' or ' %#Normal#' .. modified .. '%*'
end

M.get_winbar = function()
  local winbar = ''

  -- Winbar header: a window number with powerline style
  winbar = winbar .. '%#WinbarHeader# ' .. get_win_num() .. ' %#WinbarTriangleSep#' .. tri_sep .. '%*'

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
      winbar = winbar .. ' ' .. icons.delimiter .. ' ' .. list_title -- show title
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
  elseif ft == 'aerial' then
    -- Aerial
    return winbar .. ' Outline (Aerial)'
  elseif vim.fn.win_gettype(winid) == 'command' then
    -- Command-line window
    return winbar .. ' Command-line window'
  end

  -- File path
  local path = vim.fn.expand('%:~:.:h')
  -- For the window of fugitive diff (it's a regular buffer but with 'diff' set)
  if string.find(path, '^fugitive:') then
    local fugitive_git_path, fugitive_file_path = string.match(path, '^fugitive://(%S+//%d+/)(.*)')
    fugitive_git_path = vim.fn.fnamemodify(fugitive_git_path, ':~:.')
    path = fugitive_file_path
    winbar = winbar .. ' Fugitive [' .. fugitive_git_path .. '] ' .. icons.delimiter
  end
  if path ~= '' and path ~= '.' then
    if vim.api.nvim_win_get_width(0) < math.floor(vim.o.columns / 3) then
      path = vim.fn.pathshorten(path)
    else
      path = path:gsub('^~', 'HOME'):gsub('^/', 'ROOT/'):gsub('/', ' ' .. icons.delimiter .. ' ')
    end
    winbar = winbar .. ' ' .. path .. ' ' .. icons.delimiter
  end

  -- File name and modified indicator
  local file_icon_and_name = get_file_icon_and_name()
  local modified = get_modified()
  winbar = winbar .. ' ' .. file_icon_and_name .. modified

  -- Truncate if too long
  winbar = winbar .. ' %<'

  -- Breadcrumbs
  if navic.is_available() then
    local context = navic.get_location()
    winbar = winbar .. icons.delimiter .. ' ' .. (context == '' and icons.ellipsis or context)
  end

  return winbar
end

vim.o.winbar = "%{%v:lua.require('rockyz.winbar').get_winbar()%}"

return M
