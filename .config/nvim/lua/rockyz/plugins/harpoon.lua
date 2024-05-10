local harpoon = require('harpoon')
harpoon:setup()

local opts = {
  border = vim.g.border_style,
  title = '',
  ui_max_width = 80,
}

vim.keymap.set('n', '<Leader>a', function()
  harpoon:list():add()
end)
vim.keymap.set('n', '<C-;>', function()
  harpoon.ui:toggle_quick_menu(harpoon:list(), opts)
end)

vim.keymap.set('n', '<M-h>', function()
  harpoon:list():select(1)
end)
vim.keymap.set('n', '<M-j>', function()
  harpoon:list():select(2)
end)
vim.keymap.set('n', '<M-k>', function()
  harpoon:list():select(3)
end)
vim.keymap.set('n', '<M-l>', function()
  harpoon:list():select(4)
end)


vim.keymap.set('n', '<Leader><M-h>', function()
  harpoon:list():replace_at(1)
end)
vim.keymap.set('n', '<Leader><M-j>', function()
  harpoon:list():replace_at(2)
end)
vim.keymap.set('n', '<Leader><M-k>', function()
  harpoon:list():replace_at(3)
end)
vim.keymap.set('n', '<Leader><M-l>', function()
  harpoon:list():replace_at(4)
end)
