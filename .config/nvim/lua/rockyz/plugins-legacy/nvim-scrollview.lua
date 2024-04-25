require('scrollview').setup({
  always_show = true,
  winblend_gui = 20,
  signs_on_startup = {
    'conflicts',
    'diagnostics',
    'search',
    'spell',
  },
  signs_show_in_folds = true,

  -- The higher the priority, the closer it will be to the scrollbar
  search_priority = 999,
  conflicts_bottom_priority = 80,
  conflicts_middle_priority = 75,
  conflicts_top_priority = 70,
  spell_priority = 10,
  diagnostics_error_priority = 4,
  diagnostics_warn_priority = 3,
  diagnostics_hint_priority = 2,
  diagnostics_info_priority = 1,

  diagnostics_error_symbol = '󰨓',
  diagnostics_warn_symbol = '󰨓',
  diagnostics_hint_symbol = '󰨓',
  diagnostics_info_symbol = '󰨓',
  search_symbol = '',
})

-- Enable gitsigns
require('scrollview.contrib.gitsigns').setup({
  add_symbol = '│',
  change_symbol = '│',
  delete_symbol = '_',
})
