local hop = require('hop')

hop.setup {
  case_insensitive = true,
  char2_fallback_key = '<CR>',
}

vim.keymap.set('n', '<Leader>j', hop.hint_char2)
