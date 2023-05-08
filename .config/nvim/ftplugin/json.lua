local map = require('rockyz.keymap').map
local api = vim.api

-- When creating a new line with o, make sure there is a trailing comma on the
-- current line
map('n', 'o', function()
  local line = api.nvim_get_current_line()
  local should_add_comma = string.find(line, '[^,{[]$')
  if should_add_comma then
    return 'A,<cr>'
  else
    return 'o'
  end
end, { buffer = true, expr = true })
