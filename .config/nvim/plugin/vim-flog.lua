vim.g.flog_default_opts = {
  max_count = 1000,
}

vim.keymap.set('n', ',L', '<Cmd>Flog<CR>')
vim.keymap.set('n', ',l', '<Cmd>Flog -raw-args=--follow -path=%<CR>') -- git log for current file
