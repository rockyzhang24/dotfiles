require('illuminate').configure {
  delay = 300,
  filetypes_denylist = {
    'aerial',
    'fugitive',
    'help',
    'NvimTree',
    'neo-tree',
    'qf',
    'startify',
  },
}

-- Go to closest reference before/after the cursor
vim.keymap.set('n', '[r', require('illuminate').goto_prev_reference)
vim.keymap.set('n', ']r', require('illuminate').goto_next_reference)
