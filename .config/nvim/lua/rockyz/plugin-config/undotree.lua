local g = vim.g
local map = require('rockyz.keymap').map

g.undotree_WindowLayout = 2
g.undotree_ShortIndicators = 1
g.undotree_SetFocusWhenToggle = 1
g.undotree_SplitWidth = 30

-- Toggle undotree
map('n', '<Leader><Leader>u', '<Cmd>UndotreeToggle<CR>')
