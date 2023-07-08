local telescope_tabs = require("telescope-tabs")
local map = require("rockyz.keymap").map
local ivy = require("rockyz.plugin-config.telescope.theme").get_ivy(false)

telescope_tabs.setup {
  show_preview = false,
  close_tab_shortcut_i = '<M-d>',
}

map('n', '<Leader>ft', function()
  telescope_tabs.list_tabs(ivy)
end)
