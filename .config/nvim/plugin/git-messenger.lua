vim.g.git_messenger_no_default_mappings = 1
vim.g.git_messenger_always_into_popup = 1
vim.g.git_messenger_popup_content_margins = 0
vim.g.git_messenger_conceal_word_diff_marker = 0
vim.g.git_messenger_floating_win_opts = {
    border = vim.g.border_style
}
vim.g.git_messenger_max_popup_height = vim.o.lines - 5
vim.g.git_messenger_max_popup_width = math.floor(vim.o.columns * 0.5)

vim.keymap.set('n', ',m', '<Plug>(git-messenger)')
