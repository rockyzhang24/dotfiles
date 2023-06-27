require('scrollview').setup {
  byte_limit = 1000000,
  line_limit = 20000,
  always_show = true,
  column = 1,
  excluded_filetypes = {},
  signs_on_startup = {
    -- 'conflicts',
    -- 'cursor',
    'diagnostics',
    -- 'folds',
    -- 'loclist',
    -- 'marks',
    -- 'quickfix',
    'search',
    -- 'spell',
    -- 'textwidth',
    -- 'trail',
  },
  signs_show_in_folds = true,
  diagnostics_error_symbol = '❙',
  diagnostics_warn_symbol = '❙',
  diagnostics_hint_symbol = '❙',
  diagnostics_info_symbol = '❙',
  search_symbol = '',

  search_priority = 999,
  diagnostics_error_priority = 4,
  diagnostics_warn_priority = 3,
  diagnostics_hint_priority = 2,
  diagnostics_info_priority = 1,
}

-- Enable gitsigns
require('scrollview.contrib.gitsigns').setup {
  add_symbol = '│',
  change_symbol = '│',
  delete_symbol = '_',
}
