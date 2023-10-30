set number
set relativenumber
set cursorline
set cursorlineopt=number,screenline
set noshowmode
set wildmode=longest:full,full
set textwidth=100
set colorcolumn=100
set list
set listchars=tab:›\ ,trail:•,extends:#,nbsp:.,precedes:❮,extends:❯
set fillchars=fold:\ ,foldopen:,foldclose:,foldsep:\ ,eob:\ ,msgsep:‾,
set foldcolumn=1
set foldlevel=99
set foldlevelstart=99
set completeopt=menu,menuone,noselect
set timeoutlen=500
set shortmess+=a shortmess+=c shortmess+=I
set updatetime=200
set laststatus=3
set matchpairs+=<:>
set splitbelow
set splitright
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=-1 " falls back to 'shiftwidth'
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
set grepprg=rg\ --vimgrep\ --smart-case\ $*
set grepformat=%f:%l:%c:%m
set breakindent
set breakindentopt=shift:2
let &showbreak = '↪ '
" presistent undo (use set undodir=... to change the undodir, default is ~/.local/share/nvim/undo)
set undofile
set nrformats=octal,bin,hex,unsigned,alpha
set sessionoptions+=terminal,globals,winpos
set isfname-==
set shada=!,'500,<50,s10,h
set synmaxcol=300
set cindent
set cinoptions+=g-1
set mouse=a
set mousemodel=extend
" Avoid highlighting the last search when sourcing vimrc
exec "nohlsearch"
" Latex
let g:tex_flavor = "latex"
" Soft wrap in Man page
let g:man_hardwrap = 0
