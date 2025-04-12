vim.treesitter.start()

vim.keymap.set('n', 'q', ':q<CR>', { buffer = true, silent = true, nowait = true })
