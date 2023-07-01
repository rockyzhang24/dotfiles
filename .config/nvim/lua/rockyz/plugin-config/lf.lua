-- Config for rockyzhang24/lf.vim

local g = vim.g
local map = require('rockyz.keymap').map

g.lf_map_keys = 0
g.lf_title = ' Explorer '
g.lf_titleposition = 'center'
g.lf_replace_netrw = 1

map('n', '<Leader>e', '<Cmd>Lf<CR>')
