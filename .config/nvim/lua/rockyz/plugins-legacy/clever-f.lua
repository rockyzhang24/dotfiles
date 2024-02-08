vim.g.clever_f_across_no_line = 1

vim.keymap.set('n', ';', '<Plug>(clever-f-repeat-forward)', { reamp = true })
vim.keymap.set('n', '<Leader>,', '<Plug>(clever-f-repeat-back)', { remap = true })
