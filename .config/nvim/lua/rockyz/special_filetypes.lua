-- This is used to set the icon and title for special buffers in statusline, winbar and tabline

local icons = require('rockyz.icons')

local special_filetypes = {
  aerial = {
    icon = icons.misc.outline,
    title = 'Outline',
  },
  ['ccc-ui'] = {
    icon = icons.misc.color,
    title = 'Color Picker',
  },
  CmdWin = { -- for Command-line window
    icon = icons.misc.rocket,
    title = 'Command-line Window',
  },
  floggraph = {
    icon = icons.misc.graph,
    title = 'Flog Graph',
  },
  fugitive = {
    icon = icons.git.branch,
    title = 'Fugitive',
  },
  fzf = {
    icon = icons.misc.search,
    title = 'FZF',
  },
  harpoon = {
    icon = icons.misc.list,
    title = 'Harpoon List',
  },
  help = {
    icon = icons.misc.help,
    title = 'Vim Help',
  },
  man = {
    icon = icons.misc.book,
    title = 'Man',
  },
  noname = { -- for nvim_buf_get_name() is empty
    icon = icons.misc.file,
    title = 'No Name',
  },
  Outline = {
    icon = icons.misc.outline,
    title = 'Outline',
  },
  OverseerForm = {
    icon = icons.misc.task,
    title = 'Overseer Form',
  },
  OverseerList = {
    icon = icons.misc.task,
    title = 'Overseer List',
  },
  qf = {
    icon = icons.misc.quickfix,
    title = 'Quickfix List',
  },
  tagbar = {
    icon = icons.misc.outline,
    title = 'Tagbar',
  },
  term = {
    icon = icons.misc.term,
    title = 'Term',
  },
  TelescopePrompt = {
    icon = icons.misc.search,
    title = 'Telescope',
  },
}

return special_filetypes
