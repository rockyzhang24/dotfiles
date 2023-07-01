local map = require('rockyz.keymap').map

map('n', ',a', require("harpoon.mark").add_file)
map('n', ',h', require("harpoon.ui").toggle_quick_menu)

map('n', ',1', function() require("harpoon.ui").nav_file(1) end)
map('n', ',2', function() require("harpoon.ui").nav_file(2) end)
map('n', ',3', function() require("harpoon.ui").nav_file(3) end)
map('n', ',4', function() require("harpoon.ui").nav_file(4) end)
