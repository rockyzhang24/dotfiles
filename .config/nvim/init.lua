-- Use the new lua module loader
vim.loader.enable()

vim.cmd('source ~/.config/nvim/viml/options.vim')
vim.cmd('source ~/.config/nvim/viml/autocmds.vim')
vim.cmd('source ~/.config/nvim/viml/plugins.vim')

require('rockyz.mappings')
require('rockyz.globals')
require('rockyz.plugin_config_loader')
require('rockyz.color')
require('rockyz.autocmds')
require('rockyz.commands')
require('rockyz.abbreviations')
require('rockyz.qf')
require('rockyz.winbar')
require('rockyz.tabline')
