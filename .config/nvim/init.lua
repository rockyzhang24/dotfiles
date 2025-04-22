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

require('rockyz.minpac')
require('rockyz.options')
require('rockyz.keymaps')
require('rockyz.color')
require('rockyz.autocmds')
require('rockyz.commands')
require('rockyz.abbreviations')
require('rockyz.indentline')
require('rockyz.indentscope')
require('rockyz.tabline')
require('rockyz.winbar')
require('rockyz.statusline')
require('rockyz.quickfix')
require('rockyz.lsp')
require('rockyz.statuscolumn')
require('rockyz.fzf')
require('rockyz.mru_win')
require('rockyz.mru')

-- Fzf
vim.opt.runtimepath:append(vim.env.HOME .. '/gitrepos/fzf')
