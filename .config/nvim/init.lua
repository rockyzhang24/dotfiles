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

vim.cmd('source ~/.config/nvim/viml/options.vim')
vim.cmd('source ~/.config/nvim/viml/autocmds.vim')
vim.cmd('source ~/.config/nvim/viml/plugins.vim')

require('rockyz.indentline')
require('rockyz.keymaps')
require('rockyz.color')
require('rockyz.autocmds')
require('rockyz.commands')
require('rockyz.abbreviations')
require('rockyz.quickfix')
require('rockyz.winbar')
require('rockyz.tabline')
require('rockyz.statusline')
require('rockyz.lsp')
