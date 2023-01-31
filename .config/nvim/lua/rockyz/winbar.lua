local M = {}

local devicon = require("nvim-web-devicons")

local function get_win_num()
  local win_num = vim.api.nvim_win_get_number(0)
  -- Whether the current window is a maximized one (by maximized.nvim)
  local maximized = vim.t.maximized and '   ' or ''
  return '[' .. win_num .. maximized .. ']'
end

local function get_file_icon_and_name()
  local filename = vim.fn.expand('%:t')
  local file_icon, file_icon_color = devicon.get_icon_color_by_filetype(vim.bo.filetype, { default = true })
  vim.api.nvim_set_hl(0, 'WinbarFileIcon', { fg = file_icon_color })
  return '%#WinbarFileIcon#' .. file_icon .. '%* ' .. (filename == '' and '[No Name]' or filename)
end

local function get_modified()
  local modified = vim.api.nvim_eval_statusline('%m', {}).str
  return modified == '' and '' or ' %#Normal#' .. modified .. '%*'
end

local disabled_filetypes = {
  'aerial',
  'minpacprgs',
  'neo-tree',
  'NvimTree',
  'qf',
  'fugitive',
  'startify',
}

M.winbar = function()

  local delimiter = ' > '
  local contents = get_win_num()

  for _, ft in pairs(disabled_filetypes) do
    if (vim.bo.filetype == ft) then
      return contents
    end
  end

  contents = contents .. ' %<'

  local path = vim.fn.expand('%:~:.:h')
  local file_icon_and_name = get_file_icon_and_name()
  local modified = get_modified()

  if path ~= '' and path ~= '.' then
    contents = contents .. path .. delimiter
  end

  contents = contents .. file_icon_and_name .. modified

  return contents
end

vim.o.winbar = "%{%v:lua.require('rockyz.winbar').winbar()%}"

return M
