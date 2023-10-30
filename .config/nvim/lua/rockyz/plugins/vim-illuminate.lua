local illuminate = require('illuminate')

illuminate.configure({
  delay = 300,
  filetypes_denylist = {
    'aerial',
    'fugitive',
    'git',
    'help',
    'neo-tree',
    'NvimTree',
    'qf',
    'startify',
  },
})

-- Go to closest reference before/after the cursor
vim.keymap.set('n', '[r', function()
  illuminate.goto_prev_reference()
end)
vim.keymap.set('n', ']r', function()
  illuminate.goto_next_reference()
end)
