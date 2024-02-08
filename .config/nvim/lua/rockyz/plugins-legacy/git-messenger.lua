vim.g.git_messenger_no_default_mappings = 1
vim.g.git_messenger_always_into_popup = 1
vim.g.git_messenger_popup_content_margins = 0
vim.g.git_messenger_conceal_word_diff_marker = 0
vim.g.git_messenger_floating_win_opts = {
  border = vim.g.border_style,
}

vim.keymap.set('n', ',m', '<Cmd>GitMessenger<CR>')
