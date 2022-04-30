require("project_nvim").setup {
  manual_mode = true,
  silent_chdir = false,
}

local map_opts = { silent = true }

-- Change the current directory to the project directory
vim.keymap.set('n', '<Leader>/', '<Cmd>ProjectRoot<CR>', map_opts)
-- Telescope integration
vim.keymap.set('n', '<Leader>fp', '<Cmd>Telescope projects<CR>', map_opts)
