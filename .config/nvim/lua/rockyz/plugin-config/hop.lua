local map = require('rockyz.keymap').map
local hop = require('hop')

hop.setup {
  case_insensitive = true,
  char2_fallback_key = '<CR>',
}

map({ 'n', 'o', 'x' }, '<Leader>j', hop.hint_char2)
