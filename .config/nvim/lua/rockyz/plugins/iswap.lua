require('iswap').setup({
  keys = 'asdfghjklqwertyuiopzxcvbnmASDFGHJKLQWERTYUIOPZXCVBNM1234567890',
  grey = 'disable',
})

-- Use cx as the prefix for keymaps regarding exchange. It's consistent with tommcdo/vim-exchange. i
-- for "interactively".
vim.keymap.set('n', 'cxi', '<Cmd>ISwap<CR>')
