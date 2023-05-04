local map = require('rockyz.keymap').map

require('symbols-outline').setup({
  preview_bg_highlight = 'NormalFloat',
  fold_markers = { '', '' },
})

-- Toggle symbols outline
map('n', '<BS>s', '<Cmd>SymbolsOutline<CR>')
