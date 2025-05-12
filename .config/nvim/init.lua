--[[

=====================================================================
=====================================================================
========                                    .-----.          ========
========         .----------------------.   | === |          ========
========         |.-""""""""""""""""""-.|   |-----|          ========
========         ||                    ||   | === |          ========
========         ||   ROCKY'S NEOVIM   ||   |-----|          ========
========         ||                    ||   | === |          ========
========         ||                    ||   |-----|          ========
========         ||:Tutor              ||   |:::::|          ========
========         |'-..................-'|   |____o|          ========
========         `"")----------------(""`   ___________      ========
========        /::::::::::|  |::::::::::\  \ no mouse \     ========
========       /:::========|  |==hjkl==:::\  \ required \    ========
========      '""""""""""""'  '""""""""""""'  '""""""""""'   ========
========                                                     ========
=====================================================================
=====================================================================

--]]

-- Use the new lua module loader
vim.loader.enable()

-- Global variables may be needed by other file, so load it first.
require('rockyz.globals')

local modules = {
    'minpac',
    'options',
    'keymaps',
    'color',
    'autocmds',
    'commands',
    'abbreviations',
    'indentline',
    'indentscope',
    'tabline',
    'winbar',
    'statusline',
    'quickfix',
    'lsp',
    'statuscolumn',
    'fzf',
    'mru_win',
    'mru',
    'lf',
    'leetcode',
    'yank',
}

for _, module in ipairs(modules) do
    require('rockyz.' .. module)
end

-- Fzf
vim.opt.runtimepath:append(vim.env.HOME .. '/gitrepos/fzf')
