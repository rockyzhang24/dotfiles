local get_ivy = require('rockyz.plugins.telescope').get_ivy

require('project_nvim').setup({
  manual_mode = true,
  silent_chdir = false,
})

-- Change the current directory to the project directory
vim.keymap.set('n', '<Leader>cd', '<Cmd>ProjectRoot<CR>')
-- Telescope integration
vim.keymap.set('n', '<Leader>fp', function()
  require('telescope').extensions.projects.projects(get_ivy({
    previewer = false,
    layout_config = {
      height = 0.3,
    },
    prompt_prefix = 'Projects> ',
  }))
end)
