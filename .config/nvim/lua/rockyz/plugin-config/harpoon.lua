local map_opts = {
  silent = true,
}

vim.keymap.set('n', '<Leader>ha', function() require("harpoon.mark").add_file() end, map_opts)
vim.keymap.set('n', '<BS>h', function() require("harpoon.ui").toggle_quick_menu() end, map_opts)

vim.keymap.set('n', ',1', function() require("harpoon.ui").nav_file(1) end, map_opts)
vim.keymap.set('n', ',2', function() require("harpoon.ui").nav_file(2) end, map_opts)
vim.keymap.set('n', ',3', function() require("harpoon.ui").nav_file(3) end, map_opts)
vim.keymap.set('n', ',4', function() require("harpoon.ui").nav_file(4) end, map_opts)
