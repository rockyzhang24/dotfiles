require('symbols-outline').setup({
  preview_bg_highlight = 'NormalFloat',
  fold_markers = { '', '' },
})

-- Toggle symbols outline
vim.keymap.set('n', '<Leader>o', '<Cmd>SymbolsOutline<CR>')
