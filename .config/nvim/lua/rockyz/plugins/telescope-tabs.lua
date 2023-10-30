local telescope_tabs = require('telescope-tabs')
local get_ivy = require('rockyz.plugins.telescope').get_ivy

telescope_tabs.setup({
  show_preview = false,
  close_tab_shortcut_i = '<M-d>',
})

vim.keymap.set('n', '<Leader>ft', function()
  telescope_tabs.list_tabs(get_ivy({
    previewer = false,
    layout_config = {
      height = 0.3,
    },
    prompt_prefix = 'Tabs> ',
  }))
end)
