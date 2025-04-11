vim.keymap.set('o', 'm', ':<C-U>lua require("tsht").nodes()<CR>')
vim.keymap.set('v', 'm', ':lua require("tsht").nodes()<CR>')
