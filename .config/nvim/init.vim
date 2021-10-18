" ===========================================
"  _   _ ____   __   _(_)_ __ ___  _ __ ___
" | | | |_  /___\ \ / / | '_ ` _ \| '__/ __|
" | |_| |/ /_____\ V /| | | | | | | | | (__
"  \__, /___|     \_/ |_|_| |_| |_|_|  \___|
"  |___/
" ===========================================

" Author: Rocky Zhang (yanzhang0219@gmail.com)
" GitHub: https://github.com/yanzhang0219


" ========== Automation ========== {{{1
" ================================

if empty(glob('~/.config/nvim/pack/minpac'))
  echo "Downloading minpac as the plugin manager..."
  silent !git clone https://github.com/k-takata/minpac.git ~/.config/nvim/pack/minpac/opt/minpac
  echo "Installing plugins..."
  augroup plugins_install
    autocmd!
    autocmd VimEnter * call PackInit() | call minpac#update()
  augroup END
endif

" }}}

" ========== General ========== {{{1
" =============================

set nocompatible
filetype plugin indent on
syntax on
set number
set relativenumber
set cursorline
set hidden  " allow buffer switch without saving
set wrap
set autoindent
set scrolloff=5
set autoread
set showcmd
set wildmenu
set wildmode=list:longest,full
set textwidth=80
set colorcolumn=80
set list
set listchars=tab:›\ ,trail:▫,extends:#,nbsp:.
set foldenable
set foldmethod=indent
set foldlevel=99
set completeopt=menuone,preview,noinsert
set ttimeoutlen=50
" set notimeout
set timeoutlen=500
set shortmess+=c
set inccommand=split
set updatetime=100
set laststatus=2
set showtabline=2
set matchpairs+=<:>
set splitbelow
set splitright
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set shiftround
" set mouse=a
set hlsearch
set incsearch
set ignorecase
set smartcase
set title
set noswapfile
set signcolumn=yes
set spelllang=en_us
set pumheight=20
set grepprg=rg\ --vimgrep\ $*
set grepformat=%f:%l:%c:%m
set breakindent
set breakindentopt=shift:2
set showbreak=↳
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
set confirm
set undofile " presistent undo (use set undodir=... to change the undodir, default is ~/.local/share/nvim/undo)

" Avoid highlighting the last search when sourcing vimrc
exec "nohlsearch"

" Terminal
let g:neoterm_autoscroll = '1'

" }}} General

" ========== Dress up ========== {{{1
" ==============================

set termguicolors

set background=dark

colorscheme tokyonight

" }}} Dress up

" ========== Autocommands ========== {{{1
" ==================================

augroup general
  autocmd!
  " Jump to the position when you last quit
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") && &filetype != 'gitcommit' |
      \ exe "normal! g'\"" |
    \ endif

  " Automatically equalize splits when Vim is resized
  autocmd VimResized * wincmd =
augroup END

augroup filetypes
  autocmd!
  " Disables auto-wrap text and comments
  autocmd FileType * setlocal formatoptions-=t formatoptions-=c formatoptions-=r formatoptions-=o
  " vim
  autocmd FileType vim setlocal foldmethod=marker foldlevel=0 textwidth=0
  " markdown
  autocmd FileType markdown packadd markdown-preview.nvim
augroup END

augroup tab_setting
  autocmd FileType make setlocal tabstop=8 softtabstop=8 shiftwidth=8 noexpandtab
  autocmd FileType python setlocal tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab
  autocmd FileType markdown setlocal tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab
augroup END

" Remove all trailing whitespaces at the end of each line on save excluding a few filetypes
" Reference: http://vimcasts.org/episodes/tidying-whitespace/
function! RemoveTrailingWhitespaces()
  if !exists("b:exclusion")
    let _s=@/
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    let @/=_s
    call cursor(l, c)
  endif
endfunction
augroup remove_trailing_whitespaces
  autocmd!
  autocmd Filetype markdown let b:exclusion=1
  autocmd BufWritePre * call RemoveTrailingWhitespaces()
augroup END

" Neovim builtin terminal
augroup terminal
  autocmd!
  " Automatically start insert mode when enter terminal, and disable line number and indentline
  autocmd TermOpen term://* startinsert |
        \ setlocal nonumber norelativenumber |
        \ IndentBlanklineDisable
  autocmd BufWinEnter,WinEnter term://* startinsert
augroup END

" }}} Autocommands

" ========== Commands ========== {{{1
" ==============================

" Open file in VSCode
command! -nargs=0 VSCode execute ":!code -g %:p\:" . line('.') . ":" . col('.')

" }}} Commands

" ========== Abbreviation ========== {{{1
" ==================================

function! SetupCommandAbbrs(from, to)
  exec 'cnoreabbrev <expr> '.a:from
        \ .' ((getcmdtype() ==# ":" && getcmdline() ==# "'.a:from.'")'
        \ .'? ("'.a:to.'") : ("'.a:from.'"))'
endfunction

call SetupCommandAbbrs('T', 'tabe')

" }}} Abbreviation

" ========== Mappings ========== {{{1
" ==============================

" ----- General ----- {{{2
" ===================

let mapleader=" "

" Smarter j and k navigation
nnoremap <expr> j v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj'
nnoremap <expr> k v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk'

noremap H ^
noremap L $

" Move the selections up and down with corresponding indentation
xnoremap J :m '>+1<CR>gv=gv
xnoremap K :m '<-2<CR>gv=gv

" Jump to the next '<++>' and edit it
nnoremap <silent> <Leader><Leader> <Esc>/<++><CR>:nohlsearch<CR>c4l
inoremap <silent> ,f <Esc>/<++><CR>:nohlsearch<CR>"_c4l

" Indent
vnoremap < <gv
vnoremap > >gv

" Copy
nnoremap Y y$
vnoremap Y "+y

" Delete but not save to a register
nnoremap s "_d

" Paste and then format
nnoremap p p=`]

" Increment and decrement
nnoremap + <C-a>
nnoremap - <C-x>
xnoremap + g<C-a>
xnoremap - g<C-x>

" Switch between the current and the last buffer
nnoremap <Backspace> <C-^>

" When navigating, center the cursor
nnoremap {  {zz
nnoremap }  }zz
nnoremap n  nzz
nnoremap N  Nzz
nnoremap ]c ]czz
nnoremap [c [czz
nnoremap [j <C-o>zz
nnoremap ]j <C-i>zz
nnoremap ]s ]szz
nnoremap [s [szz

" Make dot work over visual line selections
xnoremap . :norm.<CR>

" Execute a macro over visual line selections
xnoremap Q :'<,'>:normal @q<CR>

" Redirect change operations to the blackhole
nnoremap c "_c
nnoremap C "_C

" Clone current paragraph
nnoremap cp yap<S-}>p

" }}}

" ----- Text object ----- {{{2
" ==================

" Inside next/last parentheses
onoremap in) :<C-u>normal! f(vi(<CR>
onoremap il) :<C-u>normal! F)vi(<CR>

" Hunk (vim-gitgutter)
omap ih <Plug>(GitGutterTextObjectInnerPending)
xmap ih <Plug>(GitGutterTextObjectInnerVisual)
omap ah <Plug>(GitGutterTextObjectOuterPending)
xmap ah <Plug>(GitGutterTextObjectOuterVisual)

" }}}

" ----- Misc ----- {{{2
" ================

" Javadoc comment (tcomment_vim)
nmap <C-_>j <C-_>2<C-_>b
imap <C-_>j <C-_>2<C-_>b

" }}}

" ----- Terminal (Meta) ----- {{{2
" ===========================

" NOTE: I set the meta key to the right Option key.

" Toggle a terminal at the bottom
nnoremap <expr> <M-`> ':set splitbelow<CR>:split<CR>:resize +10<CR>' . (bufexists('term://term-main') ? ':buffer term://term-main<CR>' : ':terminal<CR><C-\><C-n>:file term://term-main<CR>A')
tnoremap <M-`> <C-\><C-n>:quit<CR>

" Close the current terminal window
tnoremap <M-c> <C-\><C-n>:quit<CR>

" Close and delete the current terminal buffer
tnoremap <M-d> <C-\><C-n>:bdelete!<CR>

" Back to normal mode in the terminal buffer
tnoremap <M-[> <C-\><C-n>

" Switching between split windows
tnoremap <M-h> <C-\><C-n><C-w>h
tnoremap <M-j> <C-\><C-n><C-w>j
tnoremap <M-k> <C-\><C-n><C-w>k
tnoremap <M-l> <C-\><C-n><C-w>l
nnoremap <M-h> <C-w>h
nnoremap <M-j> <C-w>j
nnoremap <M-k> <C-w>k
nnoremap <M-l> <C-w>l

" In terminal mode, use <M-r> to simulate <C-r> in insert mode for inserting the content of a register
" Reference: http://vimcasts.org/episodes/neovim-terminal-paste/
tnoremap <expr> <M-r> '<C-\><C-n>"' . nr2char(getchar()) . 'pi'

" }}}

" ----- Command line ----- {{{2
" ========================

" Cursor movement in command line (Emacs style)
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap ∫ <S-Left>
cnoremap ƒ <S-Right>

" Ctrl-o to open command-line window
set cedit=\<C-o>

" Save the file that requireds root permission
cnoremap w!! w !sudo tee % >/dev/null

" Get the full path of the current file
cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<cr>

" }}}

" ----- Arglist (a) ----- {{{2
" =======================

nnoremap <Leader>an :next<CR>
nnoremap <Leader>ap :previous<CR>
nnoremap <Leader>aH :first<CR>
nnoremap <Leader>aL :last<CR>

" }}}

" ----- Buffer (b) ----- {{{2
" ======================

nnoremap <Leader>bh :Startify<CR>
nnoremap <Leader>bn :bnext<CR>
nnoremap <Leader>bp :bprevious<CR>

" Goto the alternate (recent) buffer
nnoremap <Leader>br <C-^>

" Close and delete the current buffer from the buffer list (vim-xtabline)
nnoremap <Leader>bd :bdelete<CR>

" Buffer delete (fzf.vim)
nnoremap <Leader>bD :BD<CR>

" Go to a selected buffer (fzf.vim)
nnoremap <Leader>bb :Buffers<CR>

" Go to buffer N (vim-xtabline)
nmap <Leader>b1 1<Plug>(XT-Select-Buffer)
nmap <Leader>b2 2<Plug>(XT-Select-Buffer)
nmap <Leader>b3 3<Plug>(XT-Select-Buffer)
nmap <Leader>b4 4<Plug>(XT-Select-Buffer)
nmap <Leader>b5 5<Plug>(XT-Select-Buffer)
nmap <Leader>b6 6<Plug>(XT-Select-Buffer)
nmap <Leader>b7 7<Plug>(XT-Select-Buffer)
nmap <Leader>b8 8<Plug>(XT-Select-Buffer)
nmap <Leader>b9 9<Plug>(XT-Select-Buffer)

" Open current buffer in a new tab
nnoremap <Leader>bT :tabedit %<CR>

" }}}

" ----- Find/Files (f) ----- {{{2
" ==========================

" fzf to open file (fzf.vim)
nnoremap <Leader>ff :Files<CR>
nnoremap <Leader>fF :Files<Space>

" fzf for the command and search history (fzf.vim)
nnoremap <Leader>f: :History:<CR>
nnoremap <Leader>f/ :History/<CR>

" fzf for help tags (fzf.vim)
nnoremap <Leader>f? :Helptags<CR>

" }}}

" ----- Git (g) ----- {{{2
" ===================

" Jump between hunks (vim-gitgutter)
nmap <Leader>ghn <Plug>(GitGutterNextHunk)
nmap <Leader>ghp <Plug>(GitGutterPrevHunk)

" Load all hunks (in the current project) into quickfix
nnoremap <Leader>ghq :GitGutterQuickFix<CR>:copen<CR>

" Preview the hunk (vim-gitgutter)
nmap <Leader>ghP <Plug>(GitGutterPreviewHunk)

" Stage or undo hunks
nmap <Leader>ghs <Plug>(GitGutterStageHunk)
xmap <Leader>ghs <Plug>(GitGutterStageHunk)
nmap <Leader>ghu <Plug>(GitGutterUndoHunk)

" Fold/unfold all unchanged lines (vim-gitgutter)
nnoremap <Leader>ghf :GitGutterFold<CR>

" }}}

" ----- Markdown (m) ----- {{{2
" ========================

" Markdown preview in a browser window (markdown-preview.nvim)
nnoremap <Leader>mp :MarkdownPreview<CR>

" Generate TOC (vim-markdown-toc)
nnoremap <Leader>mc :GenTocGFM<CR>

" }}}

" ----- Plugin management (P) ----- {{{2
" =================================

" Update/install or delete plugins
nnoremap <Leader>Pu :PluginUpdate<CR>
nnoremap <Leader>Pd :PluginDelete<CR>

" Open the plugin's directory or github url by given the plugin's name
nnoremap <Leader>PD :OpenPluginDir<Space>
nnoremap <Leader>PU :OpenPluginUrl<Space>

" }}}

" ----- Quickfix (q) ----- {{{2
" ========================

nnoremap <Leader>qo :copen<CR>
nnoremap <Leader>qc :cclose<CR>
nnoremap <Leader>qn :cnext<CR>
nnoremap <Leader>qp :cprevious<CR>
nnoremap <Leader>qH :cfirst<CR>
nnoremap <Leader>qL :clast<CR>

" }}}

" ----- Refactor (r) ----- {{{2
" ========================

" Alignment (tabular)
noremap <Leader>ra :Tabularize /

" Split one line into multiple lines, or join a block into a single-line statement (splitjoin.vim)
nnoremap <Leader>rj :SplitjoinJoin<CR>
nnoremap <Leader>rs :SplitjoinSplit<CR>

" }}}

" ----- Searching (s) ----- {{{2
" =========================

" Clean search highlighting
nnoremap <silent> <Leader>/ :<C-u>nohlsearch<CR>

" n for searching forward and N for searching backward regardless of / or ?
nnoremap <expr> n (v:searchforward ? 'n' : 'N')
nnoremap <expr> N (v:searchforward ? 'N' : 'n')

" Make * and # search for the current selection in visual mode
function! s:VSetSearch(cmdtype)
  let temp = @s
  norm! gv"sy
  let @/ = '\V' . substitute(escape(@s, a:cmdtype.'\'), '\n', '\\n', 'g')
  let @s = temp
endfunction
xnoremap * :<C-u>call <SID>VSetSearch('/')<CR>/<C-R>=@/<CR><CR>
xnoremap # :<C-u>call <SID>VSetSearch('?')<CR>?<C-R>=@/<CR><CR>

" Implement a Grep Operator which can be used with any of Vim's built-in or custom motions to
" select the text you want to search for.
" Reference: https://learnvimscriptthehardway.stevelosh.com/chapters/32.html
function! s:GrepOperator(type)
  let saved_unnamed_register = @@
  if a:type ==# 'v'
    normal! `<v`>y
  elseif a:type ==# 'char'
    normal! `[v`]y
  else
    return
  endif
  silent execute "grep! " . shellescape(@@) . " ."
  copen
  let @@ = saved_unnamed_register
endfunction
nnoremap <Leader>sG :set operatorfunc=<SID>GrepOperator<cr>g@
vnoremap <Leader>sG :<c-u>call <SID>GrepOperator(visualmode())<cr>

" Rg under pwd (fzf)
nnoremap <Leader>sr :Rg<CR>

" }}}

" ----- Session (S) ----- {{{2
" =======================

" Session management (vim-xtabline)
nnoremap <Leader>Ss :XTabSaveSession<CR>
nnoremap <Leader>Sl :XTabLoadSession<CR>
nnoremap <Leader>Sd :XTabDeleteSession<CR>

" }}}

" ----- Toggle (t) ----- {{{2
" ======================

" Toggle spell checking
nnoremap <Leader>ts :setlocal spell! spelllang=en_us<CR>

" Toggle wrap
nnoremap <Leader>tw :set wrap!<CR>

" Toggle indent lines (indent-blankline.nvim)
nnoremap <Leader>ti :IndentBlanklineToggle<CR>

" Toggle colors (vim-hexokinase)
nnoremap <Leader>tc :HexokinaseToggle<CR>

" Toggle undotree (undotree.vim)
nnoremap <Leader>tu :UndotreeToggle<CR>

" }}}

" ----- Tab (T) ----- {{{2
" ===================

" Create a new tab with a empty buffer
nnoremap <Leader>Tt :tabedit<CR>

" Change tabline mode (vim-xtabline)
nnoremap <Leader>Tmb :XTabMode buffers<CR>
nnoremap <Leader>Tmt :XTabMode tabs<CR>
nnoremap <Leader>Tma :XTabMode arglist<CR>

" Close the current tab and all its windows
nnoremap <Leader>Tc :tabclose<CR>

" Close all tabs except the current (o for only)
nnoremap <Leader>To :tabonly<CR>

" Go to the next/prev tab
nnoremap <Leader>Tn :tabnext<CR>
nnoremap <Leader>Tp :tabprevious<CR>

" Go to the first/last tab
nnoremap <Leader>TH :tabfirst<CR>
nnoremap <Leader>TL :tablast<CR>

" Go to the recent tab
nnoremap <Leader>Tr <C-w>g<Tab>

" Open a file in a new tab
nnoremap <Leader>Te :tabedit<Space>

" Focus tab by tab number
let i = 1
while i <= 9
  execute 'nnoremap <silent> <Leader>T' . i . ' :' . i . 'tabnext<CR>'
  let i = i + 1
endwhile

" List all tabs
nnoremap <Leader>Tl :tabs<CR>

" Move buffer position on the tabline (vim-xtabline)
nnoremap <Leader>Tb[ :XTabMoveBufferPrev<CR>
nnoremap <Leader>Tb] :XTabMoveBufferNext<CR>

" Move the current tab to the right/left
nnoremap <Leader>T. :tabmove +<CR>
nnoremap <Leader>T, :tabmove -<CR>

" }}}

" ----- vimrc (v) ----- {{{2
" =================================

" Edit and source vim config file
nnoremap <Leader>ve :tabedit $MYVIMRC<CR>
nnoremap <Leader>vs :source $MYVIMRC<CR>

" }}}

" ----- Window (w) ----- {{{2
" ======================

" Create a split window to up (horizontal), down (horizontal), left (vertical), right (vertical)
nnoremap <silent> <Leader>wk :set nosplitbelow<CR><C-w>s:set splitbelow<CR>
nnoremap <silent> <Leader>wj :set splitbelow<CR><C-w>s
nnoremap <silent> <Leader>wh :set nosplitright<CR><C-w>v:set splitright<CR>
nnoremap <silent> <Leader>wl :set splitright<CR><C-w>v

" Change two-windows layout to up-and-down or side-by-side (the cursor retains in its original window)
nnoremap <expr> <Leader>w- (winnr() == 1 ? '<C-w>K' : '<C-w>t<C-w>K<C-w>p')
nnoremap <expr> <Leader>w\ (winnr() == 1 ? '<C-w>H' : '<C-w>t<C-w>H<C-w>p')

" Focus movement around windows
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Focus window by window number
let i = 1
while i <= 9
  execute 'nnoremap <silent> <Leader>w' . i . ' :' . i . 'wincmd w<CR>'
  let i = i + 1
endwhile

" Go to the recent window
nnoremap <Leader>wr <C-w>p

" Close the current window
nnoremap <Leader>wc <C-w>c

" Close the window right below the current window
nnoremap <Leader>wC <C-w>j:q<CR>

" Close all windows except the current (o for only)
nnoremap <Leader>wo <C-w>o

" Go to the preview window
nnoremap <Leader>wP <C-w>P

" Close the preview window
nnoremap <Leader>wz <C-w>z

" Move current window to new tab
nnoremap <Leader>wT <C-w>T

" Resize
nnoremap <Leader>wJ <C-w>5-
nnoremap <Leader>wK <C-w>5+
nnoremap <Leader>wH <C-w>5<
nnoremap <Leader>wL <C-w>5>

" Balance size
nnoremap <Leader>w= <C-w>=

" Focus the undotree window (undotree.vim)
nnoremap <Leader>wu :UndotreeFocus<CR>

" }}}

" }}} Mapppings

" ========== Plugins ========== {{{1
" =============================

" Minpac plugin manager (load minpac on demand)
function! PackInit() abort
  packadd minpac
  call minpac#init({'progress_open': 'vertical', 'status_open': 'vertical', 'status_auto': 'TRUE'})

  call minpac#add('k-takata/minpac', {'type': 'opt'})

  call minpac#add('tpope/vim-surround')
  call minpac#add('junegunn/fzf.vim')
  call minpac#add('tomtom/tcomment_vim')
  call minpac#add('RRethy/vim-illuminate')
  call minpac#add('RRethy/vim-hexokinase', { 'do': 'make hexokinase' })
  call minpac#add('airblade/vim-rooter')
  call minpac#add('AndrewRadev/splitjoin.vim')
  call minpac#add('godlygeek/tabular')
  call minpac#add('gcmt/wildfire.vim')
  call minpac#add('mg979/vim-visual-multi')
  call minpac#add('lukas-reineke/indent-blankline.nvim')
  call minpac#add('mbbill/undotree')
  call minpac#add('mhinz/vim-startify')
  call minpac#add('tyru/open-browser.vim')
  call minpac#add('folke/which-key.nvim')
  call minpac#add('p00f/nvim-ts-rainbow')
  call minpac#add('tpope/vim-repeat')

  " Tree-sitter
  call minpac#add('nvim-treesitter/nvim-treesitter', {'do': 'TSUpdate'})

  " Tags
  call minpac#add('ludovicchabant/vim-gutentags')
  call minpac#add('skywind3000/gutentags_plus')

  " Git
  call minpac#add('tpope/vim-fugitive')
  call minpac#add('airblade/vim-gitgutter')

  " Markdown
  call minpac#add('iamcco/markdown-preview.nvim', {'type': 'opt', 'do': 'packadd markdown-preview.nvim | call mkdp#util#install()'})
  call minpac#add('mzlogin/vim-markdown-toc')
  call minpac#add('dhruvasagar/vim-table-mode')
  call minpac#add('dkarter/bullets.vim')

  " Lines
  call minpac#add('mg979/vim-xtabline')

  " Icons
  call minpac#add('ryanoasis/vim-devicons')

  " Color schemes
  call minpac#add('folke/tokyonight.nvim')

  " Testing

endfunction

" Enable matchit.vim plugin which is shipped with Vim
runtime macros/matchit.vim

" Basic vim plugin in FZF
set rtp+=~/gitrepos/fzf

" }}} Plugins

" ========== Plugin settings ========== {{{1
" =====================================

" ----- fzf ----- {{{2
" ===============

" Make the preview use the config of command-line fzf (defined in ~/.config/fzf/fzf-config) instead of
" preview.sh shipped with fzf.vim
" let g:fzf_preview_window = ''

function! s:build_quickfix_list(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
  copen
  cc
endfunction

let g:fzf_action = {
  \ 'ctrl-l': function('s:build_quickfix_list'),
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-h': 'split',
  \ "ctrl-v": 'vsplit' }

let g:fzf_history_dir = '~/.local/share/fzf-vim-history'

" GGrep, a wrapper of git grep
command! -bang -nargs=* GGrep
  \ call fzf#vim#grep(
  \   'git grep --line-number -- '.shellescape(<q-args>), 0,
  \   fzf#vim#with_preview({'dir': systemlist('git rev-parse --show-toplevel')[0]}), <bang>0)

function! s:list_buffers()
  redir => list
  silent ls
  redir END
  return split(list, "\n")
endfunction

function! s:delete_buffers(lines, hasBang)
  execute (a:hasBang ? 'bwipeout!' : 'bwipeout') join(map(a:lines, {_, line -> split(line)[0]}))
endfunction

" Delete buffers from buffer list
" BD[!], [!] to delete the unsaved buffers
command! -bang BD call fzf#run(fzf#wrap({
  \ 'source': s:list_buffers(),
  \ 'sink*': { lines -> s:delete_buffers(lines, <bang>0) },
  \ 'options': '--header "Select the buffers you want to delete from the buffer list" --multi --reverse --bind ctrl-a:select-all'
\ }))

" }}}

" ----- indent-blankline.nvim ----- {{{2
" =================================

let g:indent_blankline_filetype_exclude = ['startify', 'help', 'markdown', 'json', 'jsonc', 'WhichKey']
let g:indent_blankline_buftype_exclude = ['terminal']
let g:indent_blankline_use_treesitter = v:true
let g:indent_blankline_show_current_context = v:true


" }}}

" ----- minpac ----- {{{2
" ==================

command! PluginUpdate source $MYVIMRC | call PackInit() | call minpac#update()
command! PluginDelete source $MYVIMRC | call PackInit() | call minpac#clean()
command! PluginStatus packadd minpac | call minpac#status()

function! PackList(...)
  call PackInit()
  return join(sort(keys(minpac#getpluglist())), "\n")
endfunction

" Define a command, OpenPluginDir, to open a new terminal window and cd into the directory where a plugin is installed
command! -nargs=1 -complete=custom,PackList
      \ OpenPluginDir call PackInit() | silent exec "!kitty --single-instance -d " . minpac#getpluginfo(<q-args>).dir . " &> /dev/null"

" Define a command, OpenPluginUrl, to open the plugin's git repo in browser
command! -nargs=1 -complete=custom,PackList
      \ OpenPluginUrl call PackInit() | silent exec "!open -a \"Google Chrome\" " . minpac#getpluginfo(<q-args>).url

" }}}

" ----- markdown-preview.nvim ----- {{{2
" =================================

" Use a new window of Safari for markdown preview
function! g:Open_browser(url)
    silent exe 'silent !osascript -e "tell application \"Safari\" to make new document with properties {URL:\"' . a:url . '\"}"'
endfunction
let g:mkdp_browserfunc = 'g:Open_browser'

" Not auto close the preview browser window
let g:mkdp_auto_close = 0

" Recognized filetypes (MarkdownPreview... commands will be availabe)
let g:mkdp_filetypes = ['markdown']

" }}}

" ----- nvim-treesitter ----- {{{2
" ===========================

lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = "maintained",
  highlight = {
    enable = true,
    disable = {}
  },
}
EOF

" }}}

" ----- nvim-ts-rainbow ----- {{{2
" =========================

lua <<EOF
require'nvim-treesitter.configs'.setup {
  rainbow = {
    enable = true,
    extended_mode = true,
    max_file_lines = 1000,
  }
}
EOF

" }}}

" ----- splitjoin.vim ----- {{{2
" =========================

let g:splitjoin_split_mapping = ''
let g:splitjoin_join_mapping = ''

" }}}

" ----- tcomment_vim ----- {{{2
" ========================

" Disable the redundant preset map
let g:tcomment_mapleader2 = ''

" }}}

" ----- undotree.vim ----- {{{2
" ========================

let g:undotree_WindowLayout = 2
let g:undotree_ShortIndicators = 1
let g:undotree_SetFocusWhenToggle = 1

" }}}

" ----- vim-fugitive ----- {{{2
" ========================

" Reference: http://vimcasts.org/episodes/fugitive-vim-browsing-the-git-object-database/
augroup fugitiveautocmd
  autocmd!

  " Use .. to go up to the parent directory if the buffer containing a git blob or tree
  autocmd User fugitive
        \ if fugitive#buffer().type() =~# '^\%(tree\|blob\)$' |
        \   nnoremap <buffer> .. :edit %:h<CR> |
        \ endif

  " Make bufferlist clean
  autocmd BufReadPost fugitive://* set bufhidden=delete

augroup END

" }}}

" ----- vim-gitgutter ----- {{{2
" =========================

" Disable the preset mappings
let g:gitgutter_map_keys = 0

" Not to use floating window for hunk preview
let g:gitgutter_preview_win_floating = 0

" }}}

" ----- vim-gutentags & gutentags_plus ----- {{{2
" ==========================================

" Reference: https://zhuanlan.zhihu.com/p/36279445

" Tips: If we need the tags for a project not managed by vcs, we can touch a .root file under the project root folder
let g:gutentags_project_root = ['.git', '.root', '.project']

" Tag file name for ctags
let g:gutentags_ctags_tagfile = '.tags'

" Using both ctags and gtags
let g:gutentags_modules = []
if executable('ctags')
	let g:gutentags_modules += ['ctags']
endif
if executable('gtags-cscope') && executable('gtags')
	let g:gutentags_modules += ['gtags_cscope']
endif

" Move tag files out of project dir to avoid being polluted
let g:gutentags_cache_dir = expand('~/.cache/tags')

let g:gutentags_ctags_extra_args = ['--fields=+n']

" Disable connecting gtags database automatically (gutentags_plus will handle the database connection)
let g:gutentags_auto_add_cscope = 0

" Disable default maps
let g:gutentags_plus_nomap = 1

" Focus to quickfix window after searching
let g:gutentags_plus_switch = 1

" }}}

" ----- vim-hexokinase ----- {{{2
" ==========================

let g:Hexokinase_highlighters = ['backgroundfull']
let g:Hexokinase_optInPatterns = 'full_hex,rgb,rgba,hsl,hsla'

" }}}

" ----- vim-illuminate ----- {{{2
" ==========================

augroup illuminate_augroup
    autocmd!
    autocmd VimEnter * hi illuminatedWord cterm=underline gui=underline
augroup END

" }}}

" ----- vim-markdown-toc ----- {{{2
" ============================

let g:vmt_cycle_list_item_markers = 1

" }}}

" ----- vim-openbrowser.vim ----- {{{2
" ===============================

let g:netrw_nogx = 1
nmap gx <Plug>(openbrowser-smart-search)
vmap gx <Plug>(openbrowser-smart-search)

" ----}}}

" ----- vim-rooter ----- {{{2
" ======================

let g:rooter_pattern = ['.git/', 'package.json']

" Only change directory for the current tab
let g:rooter_cd_cmd = 'tcd'

" For non-project file, change to the file's directory
let g:rooter_change_directory_for_non_project_files = 'current'

" }}}

" ----- vim-startify ----- {{{2
" ========================

" Make vim-rooter works when a file is opened from startify
let g:startify_change_to_dir = 0

function! StartifyEntryFormat()
  return 'WebDevIconsGetFileTypeSymbol(absolute_path) ." ". entry_path'
endfunction

" let g:ascii = [
"       \ '                                 __                ',
"       \ ' __  __  ____            __  __ /\_\    ___ ___    ',
"       \ '/\ \/\ \/\_ ,`\  _______/\ \/\ \\/\ \ /'' __` __`\ ',
"       \ '\ \ \_\ \/_/  /_/\______\ \ \_/ |\ \ \/\ \/\ \/\ \ ',
"       \ ' \/`____ \/\____\/______/\ \___/  \ \_\ \_\ \_\ \_\',
"       \ '  `/___/> \/____/         \/__/    \/_/\/_/\/_/\/_/',
"       \ '     /\___/                                        ',
"       \ '     \/__/                                         ',
"       \ ]

let g:ascii = [
      \ '                                               ',
      \ ' ██╗   ██╗███████╗     ██╗   ██╗██╗███╗   ███╗ ',
      \ ' ╚██╗ ██╔╝╚══███╔╝     ██║   ██║██║████╗ ████║ ',
      \ '  ╚████╔╝   ███╔╝█████╗██║   ██║██║██╔████╔██║ ',
      \ '   ╚██╔╝   ███╔╝ ╚════╝╚██╗ ██╔╝██║██║╚██╔╝██║ ',
      \ '    ██║   ███████╗      ╚████╔╝ ██║██║ ╚═╝ ██║ ',
      \ '    ╚═╝   ╚══════╝       ╚═══╝  ╚═╝╚═╝     ╚═╝ ',
      \ '                                               ',
      \ ]

let g:startify_custom_header = 'startify#pad(g:ascii)'

" Enable cursorline
augroup starity
  autocmd User Startified setlocal cursorline
augroup END

" }}}

" ----- vim-table-mode ----- {{{2
" ==========================

let g:table_mode_map_prefix = '<Leader>mt'

" }}}

" ----- vim-visual-multi ----- {{{2
" ============================

let g:VM_theme = 'iceblue'

let g:VM_maps = {}
let g:VM_maps["Undo"] = 'u'
let g:VM_maps["Redo"] = '<C-r>'

" }}}

" ----- vim-xtabline ----- {{{2
" ========================

let g:xtabline_settings = get(g:, 'xtabline_settings', {})
let g:xtabline_settings.tabline_modes = ['buffers', 'tabs', 'arglist']
let g:xtabline_settings.enable_mappings = 0
let g:xtabline_settings.wd_type_indicator = 1

" }}}

" ----- which-key.nvim ----- {{{2
" ========================

lua << EOF
  -- Basic settings
  require("which-key").setup {
    plugins = {
      marks = false,
      registers = false,
      presets = false
    },
    window = {
      border = "single",
    },
    show_help = false,
    triggers = {"<leader>", "g"},
  }

  -- Document
  local wk = require("which-key")

  wk.register({
    g = {
      d = "Go to definition",
      r = "Go to references",
      y = "Go to type definition",
      i = "Go to implementation",
      x = "which_key_ignore",
      ["%"] = "which_key_ignore",
    },
  })

  wk.register({
    ["/"] = "Clear highlight",
    ["<space>"] = "Go to the next placeholder",
  }, { prefix = "<leader>" })

  -- arglist
  wk.register({
    a = {
      name = "arglist",
      n = "Next",
      p = "Previous",
      H = "First",
      L = "Last",
    },
  }, { prefix = "<leader>" })

  -- buffer
  wk.register({
    b = {
      name = "buffer",
      h = "Home (startify)",
      n = "Next",
      p = "Previous",
      r = "Recent (alternate)",
      d = "Close and delete the current buffer",
      D = "Delete buffers (FZF)",
      b = "Select buffer (FZF)",
      ["1"] = "Go to buffer #1",
      ["2"] = "Go to buffer #2",
      ["3"] = "Go to buffer #3",
      ["4"] = "Go to buffer #4",
      ["5"] = "Go to buffer #5",
      ["6"] = "Go to buffer #6",
      ["7"] = "Go to buffer #7",
      ["8"] = "Go to buffer #8",
      ["9"] = "Go to buffer #9",
      T = "Open the current buffer in a new tab",
    },
  }, { prefix = "<leader>" })

  -- find/file
  wk.register({
    f = {
      name = "find/file",
      f = "find & open files in PWD",
      F = "find & open files in the given dir",
      [":"] = "Find command-history",
      ["/"] = "Find searching-history",
      ["?"] = "Find help tags",
    },
  }, { prefix = "<leader>" })

  -- git
  wk.register({
    g = {
      name = "git",
      -- hunks
      h = {
        name = "hunk",
        n = "Next hunk",
        p = "Prev hunk",
        q = "Load all hunks to quickfix",
        P = "Preview hunk",
        s = "Stage hunks",
        u = "Undo hunks",
        f = "Fold/unfold",
      },
    },
  }, { prefix = "<leader>" })

  wk.register({
    g = {
      name = "git",
      h = {
        name = "hunk",
        s = "Stage hunks",
      },
    },
  }, { prefix = "<leader>", mode = "v" })

  -- markdown
  wk.register({
    m = {
      name = "markdown",
      p = "Preview",
      c = "Generate TOC",
      t = {
        name = "Table mode",
        m = "Toggle table mode",
        t = "Tableize",
      },
    },
  }, { prefix = "<leader>" })

  wk.register({
    m = {
      name = "markdown",
      t = {
        name = "Table mode",
        t = "Tableize",
      },
    },
  }, { prefix = "<leader>", mode = "v" })

  -- plugin management
  wk.register({
    P = {
      name = "plugin",
      u = "Update Plugins",
      d = "Delete Plugins",
      U = "Open URL",
      D = "Open directory",
    },
  }, { prefix = "<leader>" })

  -- quickfix
  wk.register({
    q = {
      name = "quickfix",
      o = "Open",
      c = "Close",
      n = "Next",
      p = "Prev",
      H = "First",
      L = "Last",
    },
  }, { prefix = "<leader>" })

  -- refactor
  wk.register({
    r = {
      name = "refactor",
      a = "Tabularize",
      j = "Join",
      s = "Split",
    },
  }, { prefix = "<leader>" })

  wk.register({
    r = {
      name = "refactor",
      a = "Tabularize",
    },
  }, { prefix = "<leader>", mode = "v" })

  -- search
  wk.register({
    s = {
      name = "search",
      G = "Grep",
      r = "Rg",
    },
  }, { prefix = "<leader>" })

  wk.register({
    s = {
      name = "search",
      G = "Grep",
    },
  }, { prefix = "<leader>", mode = "v" })

  -- session
  wk.register({
    S = {
      name = "session",
      s = "Save",
      l = "Load",
      d = "Delete",
    },
  }, { prefix = "<leader>" })

  -- toggle
  wk.register({
    t = {
      name = "toggle",
      s = "Spell",
      w = "Wrap",
      i = "Indent line",
      c = "Color",
      u = "Undotree",
    },
  }, { prefix = "<leader>" })

  -- tab
  wk.register({
    T = {
      name = "tab",
      t = "New tab with empty buffer",
      c = "Close current tab and its windows",
      o = "Close all but the current tabs",
      n = "Next",
      p = "Prev",
      H = "First",
      L = "Last",
      r = "Recent",
      e = "Open a file in new tab",
      l = "List all tabs",
      ["."] = "Move current tab to right",
      [","] = "Move current tab to left",
      ["1"] = "Go to tab #1",
      ["2"] = "Go to tab #2",
      ["3"] = "Go to tab #3",
      ["4"] = "Go to tab #4",
      ["5"] = "Go to tab #5",
      ["6"] = "Go to tab #6",
      ["7"] = "Go to tab #7",
      ["8"] = "Go to tab #8",
      ["9"] = "Go to tab #9",
      -- change tabline mode
      m = {
        name = "tabline mode",
        b = "Buffer mode",
        t = "Tab mode",
        a = "Arglist mode",
      },
      -- move buffer in the tabline
      b = {
        name = "move buffer in tabline",
        ["["] = "Move to prev",
        ["]"] = "Move to next",
      },
    },
  }, { prefix = "<leader>" })

  -- vimrc
  wk.register({
    v = {
      name = "vimrc",
      e = "Edit vimrc",
      s = "Source vimrc",
    },
  }, { prefix = "<leader>" })

  -- window
  wk.register({
    w = {
      name = "window",
      h = "Split (Up)",
      j = "Split (Down)",
      h = "Split (Left)",
      l = "SPlit (Right)",
      ["-"] = "Change layout to up-and-down",
      ["\\"] = "change layout to side-by-side",
      ["1"] = "Go to window #1",
      ["2"] = "Go to window #2",
      ["3"] = "Go to window #3",
      ["4"] = "Go to window #4",
      ["5"] = "Go to window #5",
      ["6"] = "Go to window #6",
      ["7"] = "Go to window #7",
      ["8"] = "Go to window #8",
      ["9"] = "Go to window #9",
      r = "Go to the recent window",
      c = "Close window",
      C = "Close window below",
      o = "Close all but the current window",
      P = "Go to the preview window",
      z = "Close the preview window",
      T = "Move window to a new tab",
      ["="] = "Balance size",
      u = "Go to undotree window",
      J = "Resize: decrease height",
      K = "Resize: increase height",
      H = "Resize: decrease width",
      L = "Resize: increase width",
    },
  }, { prefix = "<leader>" })
EOF

" }}}

" }}} Plugin settings

" ========== Lua ========== {{{1
" =========================

lua require('config')

" }}} Lua
