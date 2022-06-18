require('maximize').setup {
  default_keymaps = false
}

vim.keymap.set('n', '<Leader>m', "<Cmd>lua require('maximize').toggle()<CR>")
