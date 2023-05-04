local g = vim.g
local map = require('rockyz.keymap').map

g.choosewin_blink_on_land = 0
g.choosewin_tabline_replace = 0

map('n', '-', '<Plug>(choosewin)', { remap = true })
