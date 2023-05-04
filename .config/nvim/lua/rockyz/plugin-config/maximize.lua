local map = require('rockyz.keymap').map

require('maximize').setup {
  default_keymaps = false
}

map('n', '<Leader>m', "<Cmd>lua require('maximize').toggle()<CR>")
