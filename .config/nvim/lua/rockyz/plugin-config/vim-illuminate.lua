local illuminate = require('illuminate')
illuminate.configure {
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
vim.keymap.set('n', '[r', function()
  illuminate.goto_prev_reference()
  vim.cmd('normal! zz')
end)
vim.keymap.set('n', ']r', function()
  illuminate.goto_next_reference()
  vim.cmd('normal! zz')
end)
