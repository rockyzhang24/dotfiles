require('iswap').setup({
    keys = 'asdfghjklqwertyuiopzxcvbnmASDFGHJKLQWERTYUIOPZXCVBNM1234567890',
    grey = 'disable',
})

-- Use cx as the prefix for keymaps regarding exchange. It's consistent with tommcdo/vim-exchang.
vim.keymap.set('n', 'cxI', '<Cmd>ISwap<CR>')
