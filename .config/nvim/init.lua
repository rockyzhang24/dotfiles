-- Use the new lua module loader
vim.loader.enable()

-- Global variables may be needed by other file, so load it first.
require('rockyz.globals')

vim.cmd('source ~/.config/nvim/viml/options.vim')
vim.cmd('source ~/.config/nvim/viml/autocmds.vim')
vim.cmd('source ~/.config/nvim/viml/plugins.vim')

require('rockyz.mappings')
require('rockyz.plugin_config_loader')
require('rockyz.color')
require('rockyz.autocmds')
require('rockyz.commands')
require('rockyz.abbreviations')
require('rockyz.qf')
require('rockyz.winbar')
require('rockyz.tabline')
require('rockyz.lsp')
