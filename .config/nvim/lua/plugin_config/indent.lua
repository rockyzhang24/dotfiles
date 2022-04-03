require("indent_blankline").setup {
  char = '│',
  filetype_exclude = {
    'startify',
    'help',
    'markdown',
    'json',
    'jsonc',
    'WhichKey',
    'man',
    'aerial',
    'NvimTree',
    'minpac',
    'minpacprgs',
  },
  buftype_exclude = {
    'terminal',
  },
  use_treesitter = true,
  show_current_context = true,
  -- context_char = '┃',
  show_current_context_start = true,
  context_patterns = {
    'class',
    '^func',
    'method',
    '^if',
    'while',
    'for',
    'with',
    'try',
    'except',
    'arguments',
    'argument_list',
    'object',
    'dictionary',
    'element',
    'table',
    'tuple',
  },
}

-- Toggle indent line
vim.keymap.set('n', '\\i', '<Cmd>IndentBlanklineToggle<CR>')
