local M = {}

local aerial = require('aerial')

-- Format the list representing the symbol path
-- Grab it from https://github.com/stevearc/aerial.nvim/blob/master/lua/lualine/components/aerial.lua
local function format_symbols(symbols, depth, separator, icons_enabled)
  local parts = {}
  depth = depth or #symbols

  if depth > 0 then
    symbols = { unpack(symbols, 1, depth) }
  else
    symbols = { unpack(symbols, #symbols + 1 + depth) }
  end

  for _, symbol in ipairs(symbols) do
    if icons_enabled then
      table.insert(parts, string.format("%s %s", symbol.icon, symbol.name))
    else
      table.insert(parts, symbol.name)
    end
  end

  return table.concat(parts, separator)
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

  local win_num = vim.api.nvim_win_get_number(0)

  for _, ft in pairs(disabled_filetypes) do
    if (vim.bo.filetype == ft) then
      return '[' .. win_num .. ']'
    end
  end

  -- Get a list representing the symbol path by aerial.get_location (see
  -- https://github.com/stevearc/aerial.nvim/blob/master/lua/aerial/init.lua#L127),
  -- and format the list to get the symbol path.
  -- Grab it from
  -- https://github.com/stevearc/aerial.nvim/blob/master/lua/lualine/components/aerial.lua#L89
  local symbols = aerial.get_location(true)
  local symbol_path = format_symbols(symbols, nil, ' > ', true)

  local modified = vim.api.nvim_eval_statusline('%m', {}).str

  return '[' .. win_num .. '] '
      .. '%F'
      .. (modified == '' and '' or ' ' .. modified)
      .. ' > '
      .. (symbol_path == '' and '...' or symbol_path)
end

vim.api.nvim_set_hl(0, 'WinBar', { cterm = { bold = false }, bold = false })

vim.o.winbar = "%{%v:lua.require('winbar').winbar()%}"

return M
