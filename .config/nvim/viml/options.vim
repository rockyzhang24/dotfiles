set number
set relativenumber
set cursorline
set cursorlineopt=number,screenline
set noshowmode
set noshowcmd
set wildmode=longest:full,full
set textwidth=100
set list
set listchars=trail:•,extends:#,nbsp:.,precedes:❮,extends:❯
set fillchars=fold:\ ,foldopen:,foldclose:,foldsep:\ ,eob:\ ,msgsep:‾,
set foldcolumn=1
set foldlevel=99
set foldlevelstart=99
" Transparent foldtext (https://github.com/neovim/neovim/pull/20750)
set foldtext=
set completeopt=menu,menuone,noselect,popup
set timeoutlen=500
set shortmess+=a shortmess+=c shortmess+=S
set updatetime=250
set laststatus=3
set matchpairs+=<:>
set splitbelow
set splitright
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=-1 " falls back to shiftwidth
set shiftround
set ignorecase
set smartcase
set title
set titlestring=%t%(\ %m%)\ %<%(\ (%{expand(\"%:~:.:h\")})%)%(\ %a%)
set diffopt+=vertical diffopt+=algorithm:patience diffopt+=linematch:60
set noswapfile
set nobackup
set signcolumn=yes
set spelllang=en_us
set pumheight=15
set pumwidth=20
set winminwidth=10
set breakindent
set breakindentopt=shift:2
let &showbreak = '↪ '
" Presistent undo (use set undodir=... to change the undodir, default is ~/.local/share/nvim/undo)
set undofile
set nrformats=octal,bin,hex,unsigned,alpha
set sessionoptions+=globals,localoptions,winpos
set isfname-==
set shada=!,'500,<50,s10,h
set synmaxcol=300
set cindent
set cinoptions+=g-1
set mouse=a
set mousemodel=extend
" Avoid highlighting the last search when sourcing vimrc
exec 'nohlsearch'
" Latex
let g:tex_flavor = 'latex'
" Soft wrap in Man page
let g:man_hardwrap = 0
" Disable health checks for these providers
let g:loaded_python3_provider = 0
let g:loaded_ruby_provider = 0
let g:loaded_perl_provider = 0
let g:loaded_node_provider = 0
" Netrw
let g:netrw_banner = 0
let g:netrw_winsize = 25
let g:netrw_localcopydircmd = 'cp -r'
