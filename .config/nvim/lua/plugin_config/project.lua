require("project_nvim").setup {
  manual_mode = true,
  silent_chdir = false,
}

-- Change the current directory to the project directory
vim.keymap.set('n', '<Leader>/', '<Cmd>ProjectRoot<CR>', { silent = true })
