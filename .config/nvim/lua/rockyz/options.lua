vim.o.number = true
vim.o.relativenumber = true
vim.o.laststatus = 3
vim.o.cursorline = true
vim.o.showmode = false
vim.o.textwidth = 100
vim.o.wildmode = 'longest:full,full'
vim.o.list = true
vim.opt.listchars = {
  trail = '•',
  nbsp = '.',
  precedes = '‹',
  extends = '›',
}
vim.opt.fillchars = {
  fold = ' ',
  foldopen = '',
  foldclose = '',
  foldsep = ' ',
  eob = ' ',
  msgsep = '‾',
}
vim.o.foldcolumn = '1'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
-- Transparent foldtext (https://github.com/neovim/neovim/pull/20750)
vim.o.foldtext = ''
vim.o.completeopt = 'menu,menuone,noselect,popup'
vim.o.timeoutlen = 500
vim.o.updatetime = 250
vim.opt.shortmess:append('acS')
vim.opt.matchpairs:append('<:>')
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = -1 -- fall back to shiftwidth
vim.o.shiftround = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.opt.diffopt:append('vertical,algorithm:patience,linematch:60')
vim.o.signcolumn = 'yes'
vim.o.spelllang = 'en_us'
vim.o.pumheight = 15
vim.o.pumwidth = 20
vim.o.breakindent = true
vim.o.breakindentopt = 'shift:2'
vim.o.showbreak = '↪ '
-- Presistent undo (use set undodir=... to change the undodir, default is ~/.local/share/nvim/undo)
vim.o.undofile = true
vim.o.nrformats = 'octal,bin,hex,unsigned,alpha'
vim.opt.sessionoptions:append('globals,localoptions,winpos')
vim.opt.isfname:remove('=')
vim.o.shada = "!,'500,<50,s10,h"
vim.o.synmaxcol = 300
vim.o.cindent = true
vim.opt.cinoptions:append('g-1')
vim.o.scrolloff = 3
vim.o.mouse = 'a'
vim.o.mousemodel = 'extend'

-- Avoid highlighting the last search when sourcing vimrc
vim.cmd('nohlsearch')
-- Latex
vim.g.tex_flavor = 'latex'
-- Soft wrap in Man page
vim.g.man_hardwrap = 0
-- Disable health checks for these providers
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
-- Netrw
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
vim.g.netrw_localcopydircmd = 'cp -r'
