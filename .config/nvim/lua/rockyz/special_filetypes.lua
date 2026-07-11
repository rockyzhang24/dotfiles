---Define UI metadata for special buffers and window types.

local icons = require('rockyz.icons')

---@class rockyz.SpecialFiletype
---@field icon string Icon displayed in UI components
---@field title string Title displayed in UI components
---@field icon_hl? string Highlight group for the icon

---@type table<string, rockyz.SpecialFiletype>
local special_filetypes = {
    aerial = {
        icon = icons.misc.outline,
        title = 'Outline [Aerial]',
    },
    ['ccc-ui'] = {
        icon = icons.misc.color,
        title = 'Color Picker',
    },
    callhierarchy = {
        icon = icons.misc.references,
        title = 'Call Hierarchy',
        icon_hl = 'Special',
    },
    cmdwin = { -- Command-line window
        icon = icons.misc.code,
        title = 'Command-line',
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
        icon_hl = 'Special',
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
    noname = { -- Unnamed buffer
        icon = icons.misc.file,
        title = 'No Name',
    },
    ['nvim-pack'] = {
        icon = icons.symbol_kinds.Method,
        title = 'Nvim Pack',
        icon_hl = 'Special',
    },
    oil = {
        icon = icons.misc.explorer,
        title = 'Oil',
    },
    outline = {
        icon = icons.misc.outline,
        title = 'Outline',
        icon_hl = 'Special',
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
        icon_hl = 'Conditional',
    },
    tagbar = {
        icon = icons.misc.outline,
        title = 'Tagbar',
    },
    term = {
        icon = icons.misc.term,
        title = 'Term',
    },
    TerminalPanel = {
        icon = icons.misc.term,
        title = 'Terminals',
    },
    TelescopePrompt = {
        icon = icons.misc.search,
        title = 'Telescope',
    },
}

return special_filetypes
