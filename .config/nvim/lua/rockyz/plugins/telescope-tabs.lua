local telescope_tabs = require('telescope-tabs')

telescope_tabs.setup({
  show_preview = false,
  close_tab_shortcut_i = '<M-d>',
})

vim.keymap.set('n', '<Leader>ft', function()
  telescope_tabs.list_tabs({
    prompt_prefix = 'Tabs> ',
  })
end)
