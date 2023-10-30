local treesj = require('treesj')
treesj.setup({
  use_default_keymaps = false,
})

vim.keymap.set('n', 'gS', treesj.split)
vim.keymap.set('n', 'gJ', treesj.join)
