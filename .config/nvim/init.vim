" ============================================
" Author: Rocky Zhang <yanzhang0219@gmail.com>
" GitHub: https://github.com/rockyzhang24
" ============================================

" Globals
lua require('rockyz.globals')

" Options
source ~/.config/nvim/viml/options.vim

" Dress up quickfix window
lua require('rockyz.qf')

" Set winbar
lua require('rockyz.winbar')

" Set tabline
source ~/.config/nvim/viml/tabline.vim

" Color scheme
source ~/.config/nvim/viml/color.vim

" Autocmds
source ~/.config/nvim/viml/autocmds.vim
lua require('rockyz.autocmds')

" Commands
lua require('rockyz.commands')

" Abbreviations
source ~/.config/nvim/viml/abbreviations.vim

" Mappings
source ~/.config/nvim/viml/mappings.vim
lua require('rockyz.mappings')

" Plugins
source ~/.config/nvim/viml/plugins.vim

" Plugin configurations
lua require('rockyz.plugin_config_loader')
