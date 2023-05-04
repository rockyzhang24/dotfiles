local g = vim.g
local map = require('rockyz.keymap').map

g.git_messenger_no_default_mappings = 1
g.git_messenger_always_into_popup = 1
g.git_messenger_popup_content_margins = 0
g.git_messenger_conceal_word_diff_marker = 0
g.git_messenger_floating_win_opts = {
  border = g.border_enabled and 'single' or 'none',
}

map('n', ',m', '<Cmd>GitMessenger<CR>')
