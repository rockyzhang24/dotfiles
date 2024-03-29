local M = {}

local devicon = require('nvim-web-devicons')
local navic = require('nvim-navic')
local icons = require('rockyz.icons').winbar

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

M.winbar = function()
  local contents = ''

  -- Window number
  contents = contents .. get_win_num()

  -- Deal with the special buffers
  local ft = vim.bo.filetype
  if ft == 'qf' then
    local is_loclist = vim.fn.getloclist(0, { filewinid = 0 }).filewinid ~= 0
    local list_type = is_loclist and 'Location List' or 'Quickfix List'
    local list_title = is_loclist and vim.fn.getloclist(0, { title = 0 }).title or vim.fn.getqflist({ title = 0 }).title
    return contents .. ' %#Directory#' .. icons.quickfix .. '%* ' .. list_type .. ' ' .. icons.delimiter .. ' ' .. list_title
  elseif ft == 'fugitive' then
    -- fugitive: show the repo path
    return contents
      .. ' %#Directory#'
      .. icons.source_control
      .. '%* Fugitive: '
      .. string.match(vim.fn.expand('%:h:h'), 'fugitive://(.*)')
  elseif ft == 'oil' then
    -- oil: show the parent dir
    return contents
      .. ' %#Directory#'
      .. icons.explorer
      .. '%* Oil: '
      .. string.match(vim.fn.expand('%'), 'oil://(.*)')
  elseif ft == 'git' then
    return contents .. ' %#Directory#' .. icons.source_control .. '%* ' .. vim.fn.expand('%')
  elseif ft == 'term' then
    return contents .. ' %#Directory#' .. icons.term .. '%* ' .. vim.fn.expand('%')
  elseif ft == 'aerial' then
    return contents .. ' %#Directory#' .. icons.outline .. '%* Outline (Aerial)'
  end

  -- File path
  local path = vim.fn.expand('%:~:.:h')
  if path ~= '' and path ~= '.' then
    if vim.api.nvim_win_get_width(0) < math.floor(vim.o.columns / 3) then
      path = vim.fn.pathshorten(path)
    else
      path = path:gsub('^~', 'HOME'):gsub('^/', 'ROOT/'):gsub('/', ' ' .. icons.delimiter .. ' ')
    end
    local colored_folder = '%#WinbarFolder#' .. icons.folder .. '%*'
    contents = contents .. ' ' .. colored_folder .. ' ' .. path .. ' ' .. icons.delimiter
  end

  -- File name and modified indicator
  local file_icon_and_name = get_file_icon_and_name()
  local modified = get_modified()
  contents = contents .. ' ' .. file_icon_and_name .. modified

  -- Truncate if too long
  contents = contents .. ' %<'

  -- Breadcrumbs
  if navic.is_available() then
    local context = navic.get_location()
    contents = contents .. icons.delimiter .. ' ' .. (context == '' and icons.ellipsis or context)
  end

  return contents
end

vim.o.winbar = "%{%v:lua.require('rockyz.winbar').winbar()%}"

return M
