require('project_nvim').setup({
  manual_mode = true,
  silent_chdir = false,
})

-- Change the current directory to the project directory
vim.keymap.set('n', '<Leader>cd', '<Cmd>ProjectRoot<CR>')
-- Telescope integration
vim.keymap.set('n', '<Leader>fp', function()
  require('telescope').extensions.projects.projects({
    previewer = false,
    prompt_prefix = 'Projects> ',
  })
end)
