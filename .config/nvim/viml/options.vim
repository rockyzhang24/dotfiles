set number
set relativenumber
set cursorline
set cursorlineopt=number,screenline
" set scrolloff=5
" set sidescrolloff=5
set noshowmode
set noshowcmd
set wildmode=longest:full,full
set textwidth=80
set colorcolumn=80,120
set list
set listchars=tab:›\ ,trail:•,extends:#,nbsp:.,precedes:❮,extends:❯
set fillchars=fold:\ ,foldopen:,foldclose:,foldsep:\ ,eob:\ ,msgsep:‾,
set foldcolumn=1
set foldmethod=manual
set foldlevel=99
set foldlevelstart=99
" set foldmethod=expr
" set foldexpr=nvim_treesitter#foldexpr() " treesitter based folding
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
set diffopt+=vertical diffopt+=algorithm:patience
set noswapfile
set nobackup
set signcolumn=yes
set spelllang=en_us
set pumheight=20
" set pumblend=5
" set winblend=5
set winminwidth=10
set grepprg=rg\ --vimgrep\ --smart-case\ $*
set grepformat=%f:%l:%c:%m
set breakindent
set breakindentopt=shift:2
let &showbreak = '﬌ '
set wildignore=*.o,*.obj,*~,*.exe,*.a,*.pdb,*.lib
set wildignore+=*.so,*.dll,*.swp,*.egg,*.jar,*.class,*.pyc,*.pyo,*.bin,*.dex
set wildignore+=*.log,*.pyc,*.sqlite,*.sqlite3,*.min.js,*.min.css,*.tags
set wildignore+=*.zip,*.7z,*.rar,*.gz,*.tar,*.gzip,*.bz2,*.tgz,*.xz
set wildignore+=*.png,*.jpg,*.gif,*.bmp,*.tga,*.pcx,*.ppm,*.img,*.iso
set wildignore+=*.pdf,*.dmg,*.app,*.ipa,*.apk,*.mobi,*.epub
set wildignore+=*.mp4,*.avi,*.flv,*.mov,*.mkv,*.swf,*.swc
set wildignore+=*.ppt,*.pptx,*.doc,*.docx,*.xlt,*.xls,*.xlsx,*.odt,*.wps
set wildignore+=*/.git/*,*/.svn/*,*.DS_Store
set wildignore+=*/node_modules/*,*/nginx_runtime/*,*/build/*,*/logs/*,*/dist/*,*/tmp/*
" presistent undo (use set undodir=... to change the undodir, default is ~/.local/share/nvim/undo)
set undofile
set nrformats=octal,bin,hex,unsigned,alpha
set sessionoptions+=terminal,globals,winpos
set isfname-==
set shada=!,'500,<50,s10,h
set lazyredraw
set mouse=a
" Avoid highlighting the last search when sourcing vimrc
exec "nohlsearch"
" Latex
let g:tex_flavor = "latex"
" Soft wrap in Man page
let g:man_hardwrap = 0
