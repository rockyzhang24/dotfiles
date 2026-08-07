vim.keymap.set('x', 'q', ":lua require('tsht').nodes()<CR>", { silent = true })
vim.keymap.set('o', 'q', ":<C-u>lua require('tsht').nodes()<CR>", { silent = true })
