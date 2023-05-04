local g = vim.g
local map = require('rockyz.keymap').map

g.clever_f_across_no_line = 1

map('n', ';', '<Plug>(clever-f-repeat-forward)', { reamp = true })
map('n', '<Leader>,', '<Plug>(clever-f-repeat-back)', { remap = true })
