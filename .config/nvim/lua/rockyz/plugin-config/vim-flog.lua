local g = vim.g
local map = require('rockyz.keymap').map

g.flog_default_opts = {
  max_count = 1000,
}

map('n', ',ll', '<Cmd>Flog<CR>')
map('n', ',lf', '<Cmd>Flog -raw-args=--follow -path=%<CR>') -- git log for current file
