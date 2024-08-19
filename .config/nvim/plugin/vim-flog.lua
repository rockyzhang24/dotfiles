vim.g.flog_default_opts = {
  max_count = 1000,
}

-- Use special font symbols to render git commit graph. It's supported by kitty since 0.36.0
if vim.env.KITTY_WINDOW_ID then
  vim.g.flog_enable_extended_chars = true
end

vim.keymap.set('n', ',L', '<Cmd>Flog<CR>')
vim.keymap.set('n', ',l', '<Cmd>Flog -raw-args=--follow -path=%<CR>') -- git log for current file
