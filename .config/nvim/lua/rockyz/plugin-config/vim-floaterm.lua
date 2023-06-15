local g = vim.g
local api = vim.api

g.floaterm_position = 'bottom'
g.floaterm_borderchars = '─'
g.floaterm_width = api.nvim_get_option_value('columns', {})
g.floaterm_height = 0.7
