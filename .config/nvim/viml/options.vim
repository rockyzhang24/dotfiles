set number
set relativenumber
set cursorline
set cursorlineopt=number,screenline
set noshowmode
set noshowcmd
set wildmode=longest:full,full
set textwidth=100
set fillchars=fold:\ ,foldopen:,foldclose:,foldsep:\ ,eob:\ ,msgsep:‾,
set foldcolumn=1
set foldlevel=99
set foldlevelstart=99
set foldtext=
set completeopt=menu,menuone,noselect
set timeoutlen=500
set shortmess+=a shortmess+=c shortmess+=I
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
set sessionoptions+=terminal,globals,winpos
set isfname-==
set shada=!,'500,<50,s10,h
set synmaxcol=300
set cindent
set cinoptions+=g-1
set mouse=
set mousemodel=extend
set list
"
" Set the listchars
"
" I use tab and leadmultispace in listchars to display the indent line. If the file is
" * using tab as indentation: set tab to the indent line character and leadmultispace to a
" special character for denotation.
" * using space as indentation: set leadmultispace to the indent line character followed by spaces
" (the number of the spaces depends on how many spaces for each step of indent)
"
" listchars should be updated based on the indentation setting of the current buffer, see the
" autocmd in ../lua/rockyz/autocmds.lua
function! s:set_listchars() abort
  let l:set_listchars = 'set listchars=trail:•,extends:#,nbsp:.,precedes:❮,extends:❯,'
  if &expandtab
    " Space indentation
    " If shiftwidth is 0, vim will use tabstop value
    let l:spaces = &shiftwidth == 0 ? &tabstop : &shiftwidth
    let l:set_listchars = l:set_listchars . 'tab:›\ ,leadmultispace:' . escape(g:indentline_char, '|') . repeat('\ ', l:spaces - 1)
  else
    " Tab indentation
    let l:set_listchars = l:set_listchars . 'tab:' . escape(g:indentline_char, '|') . '\ ,leadmultispace:␣'
  endif
  exec l:set_listchars
endfunction
call s:set_listchars()

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
