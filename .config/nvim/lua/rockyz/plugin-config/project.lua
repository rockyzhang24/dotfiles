local map = require('rockyz.keymap').map
local theme = require('rockyz.plugin-config.telescope.theme')

local ivy = theme.get_ivy(false)

require("project_nvim").setup {
  manual_mode = true,
  silent_chdir = false,
}

-- Change the current directory to the project directory
map('n', '<Leader>/', '<Cmd>ProjectRoot<CR>')
-- Telescope integration
map('n', '<Leader>fp', function()
  require('telescope').extensions.projects.projects(ivy)
end)
