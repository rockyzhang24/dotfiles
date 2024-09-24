-- Define icons and titles for special filetypes
-- icons are used by tabline, winbar and statusline
-- titles are used by tabline

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
  cmdwin = { -- for Command-line window
    icon = icons.misc.command,
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
  fugitiveblame = {
    icon = icons.git.commit,
    title = 'Fugitive Blame',
  },
  fzf = {
    icon = icons.misc.search,
    title = 'FZF',
  },
  ['gitsigns.blame'] = {
    icon = icons.git.commit,
    title = 'Gitsigns Blame',
  },
  harpoon = {
    icon = icons.misc.list,
    title = 'Harpoon List',
  },
  help = {
    icon = icons.misc.help,
    title = 'Vim Help',
  },
  kitty_scrollback = {
    icon = icons.misc.page_previous,
    title = 'Kitty Scrollback',
  },
  loclist = {
    icon = icons.misc.quickfix,
    title = 'Location List',
  },
  man = {
    icon = icons.misc.book,
    title = 'Man',
  },
  noname = { -- for nvim_buf_get_name() is empty
    icon = icons.misc.file,
    title = 'No Name',
  },
  oil = {
    icon = icons.misc.explorer,
    title = 'Oil',
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
