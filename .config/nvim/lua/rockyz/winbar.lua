local M = {}

local devicon = require('nvim-web-devicons')
local navic = require('nvim-navic')
local misc_icons = require('rockyz.icons').misc
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

M.winbar = function()
  local contents = ''

  -- Winbar header: a window number with powerline style
  contents = contents .. '%#WinbarHeader# ' .. get_win_num() .. ' %#WinbarTriangleSep#' .. tri_sep .. '%*'

  -- Deal with the special buffers
  local ft = vim.bo.filetype
  if ft == 'qf' then
    -- Quickfix
    local is_loclist = vim.fn.getloclist(0, { filewinid = 0 }).filewinid ~= 0
    local list_type = is_loclist and 'Location List' or 'Quickfix List'
    local list_title = is_loclist and vim.fn.getloclist(0, { title = 0 }).title or vim.fn.getqflist({ title = 0 }).title
    contents = contents .. ' ' .. list_type
    if list_title ~= '' then
      contents = contents .. ' ' .. misc_icons.delimiter .. ' ' .. list_title
    end
    return contents
  elseif ft == 'fugitive' then
    -- Fugitive: show the repo path
    return contents
      .. ' Fugitive: '
      .. string.match(vim.fn.expand('%:h:h'), 'fugitive://(.*)')
  elseif ft == 'oil' then
    -- Oil: show the parent dir
    return contents
      .. ' Oil: '
      .. string.match(vim.fn.expand('%'), 'oil://(.*)')
  elseif ft == 'git' then
    -- Git
    return contents .. ' ' .. vim.fn.expand('%')
  elseif ft == 'term' then
    -- Terminal
    return contents .. ' ' .. vim.fn.expand('%')
  elseif ft == 'aerial' then
    -- Aerial
    return contents .. ' Outline (Aerial)'
  end

  -- File path
  local path = vim.fn.expand('%:~:.:h')
  if path ~= '' and path ~= '.' then
    if vim.api.nvim_win_get_width(0) < math.floor(vim.o.columns / 3) then
      path = vim.fn.pathshorten(path)
    else
      path = path:gsub('^~', 'HOME'):gsub('^/', 'ROOT/'):gsub('/', ' ' .. misc_icons.delimiter .. ' ')
    end
    contents = contents .. ' ' .. path .. ' ' .. misc_icons.delimiter
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
    contents = contents .. misc_icons.delimiter .. ' ' .. (context == '' and misc_icons.ellipsis or context)
  end

  return contents
end

vim.o.winbar = "%{%v:lua.require('rockyz.winbar').winbar()%}"

return M
