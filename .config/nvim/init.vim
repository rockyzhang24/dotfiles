"  _   _ ____   __   _(_)_ __ ___  _ __ ___
" | | | |_  /___\ \ / / | '_ ` _ \| '__/ __|
" | |_| |/ /_____\ V /| | | | | | | | | (__
"  \__, /___|     \_/ |_|_| |_| |_|_|  \___|
"  |___/

" Author: Rocky Zhang (@yanzhang0219)

" ========== General ========== {{{

set nocompatible
filetype plugin indent on
syntax on
set number
set relativenumber
set cursorline
set wrap
set autoindent
set scrolloff=4
set autoread
set showcmd
set wildmenu
set wildmode=list:longest,full
set textwidth=0
set colorcolumn=80
set list
set listchars=trail:▫
set foldenable
set foldmethod=indent
set foldlevel=99
set completeopt=menuone,preview,noinsert
set notimeout
set ttimeoutlen=0
set shortmess+=c
set inccommand=split
set updatetime=100

" Searching
set hlsearch
set incsearch
set ignorecase
set smartcase

" Avoid highlighting the last search when sourcing vimrc
exec "nohlsearch"

" Show status bar
set laststatus=2

" Convert tabs to spaces
set expandtab

" Indent using 2 spaces
set tabstop=2
set shiftwidth=2
set softtabstop=2

set splitbelow
set splitright

" Enable mouse
set mouse=a

" presistent undo (use set undodir=... to change the undodir, default is ~/.local/share/nvim/undo)
if has('persistent_undo')
  set undofile
endif

" Terminal
let g:neoterm_autoscroll = '1'

" }}}

" ========== Autocommands ========== {{{

augroup general
  autocmd!

  " Jump to the position when you last quit
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") && &filetype != 'gitcommit' |
      \ exe "normal! g'\"" |
    \ endif

  " Automatically deletes all trailing whitespaces at end of each line on save
  autocmd BufWritePre * %s/\s\+$//e

  " Automatically start insert mode when enter terminal
  autocmd TermOpen term://* startinsert

augroup END

augroup filetypes
  autocmd!

  " Disables auto-wrap using textwidth and automatic commenting on newline
  autocmd FileType * setlocal formatoptions-=t formatoptions-=c formatoptions-=r formatoptions-=o

  autocmd FileType vim setlocal foldmethod=marker foldlevel=0 textwidth=0
  autocmd FileType markdown packadd markdown-preview.nvim |
                          \ source ~/.config/nvim/md-snippets.vim
augroup END

" }}}

" ========== Mappings ========== {{{

let mapleader=" "
let maplocalleader="\\"

" ---- Window ----

" Close all but current window (maximize)
noremap <Leader>wm <C-w>o

" Focus movement around windows
noremap <C-k> <C-w>k
noremap <C-j> <C-w>j
noremap <C-h> <C-w>h
noremap <C-l> <C-w>l

" Resize splits with arrow keys (up/right -> enlarge, down/left -> shrink)
noremap <Up> :res +5<CR>
noremap <Down> :res -5<CR>
noremap <Left> :vertical resize -5<CR>
noremap <Right> :vertical resize +5<CR>

" ---- Searching ----

" No highlight search
nnoremap <silent> <Leader><Enter> :<C-u>noh<CR><C-l>

" Use very magic mode when searching
nnoremap / /\v
nnoremap ? ?\v

" ---- Operator-pending Mappings ----

" Inside next/last parentheses
onoremap in( :<C-u>normal! f(vi(<CR>
onoremap il( :<C-u>normal! F)vi(<CR>

" ---- Movement ----

" Fast movement
noremap J 5j
noremap K 5k

" ---- Command Line ----

" Cursor movement in command line
cnoremap <C-p> <Up>
cnoremap <C-N> <Down>
cnoremap <C-B> <Left>
cnoremap <C-F> <Right>
cnoremap <C-A> <Home>
cnoremap <C-E> <End>
" (Meta-b for one WORD left)
cnoremap ∫ <S-Left>
" (Meta-f for one WORD right)
cnoremap ƒ <S-Right>

" Ctrl-o to open command-line window
cnoremap <C-O> <C-F>

" ---- Terminal ----

tnoremap <C-N> <C-\><C-N>
tnoremap <C-O> <C-\><C-N><C-O>

" ---- Toggling ----

" spell check
nnoremap <Leader>ts :setlocal spell! spelllang=en_us<CR>

" ---- Vimrc ----

" edit & source vimrc
nnoremap <Leader>ev :vsplit $MYVIMRC<CR>
nnoremap <Leader>sv :source $MYVIMRC<CR>

" ---- Others ----

" Copy to system clipboard
noremap Y "+y

" Jump to the next '<++>' and edit it
nnoremap <silent> <Leader><Leader> <Esc>/<++><CR>:nohlsearch<CR>c4l

" Indent
vnoremap < <gv
vnoremap > >gv

" }}}

" ========== Plugins ========== {{{

" Minpac plugin manager (load minpac on demand)
function! PackInit() abort
  packadd minpac
  call minpac#init({'progress_open': 'vertical', 'status_open': 'vertical', 'status_auto': 'TRUE'})

  call minpac#add('k-takata/minpac', {'type': 'opt'})

  call minpac#add('neoclide/coc.nvim', {'branch': 'release'})
  call minpac#add('tpope/vim-surround')
  call minpac#add('junegunn/fzf.vim')
  call minpac#add('tomtom/tcomment_vim')
  call minpac#add('RRethy/vim-illuminate')
  call minpac#add('RRethy/vim-hexokinase', { 'do': 'make hexokinase' })

  " Git
  call minpac#add('tpope/vim-fugitive')
  call minpac#add('airblade/vim-gitgutter')

  " Markdown
  call minpac#add('vimwiki/vimwiki', {'rev': 'dev'})
  call minpac#add('iamcco/markdown-preview.nvim', {'type': 'opt', 'do': 'packadd markdown-preview.nvim | call mkdp#util#install()'})

  " Appearance
  call minpac#add('yggdroot/indentline')
  call minpac#add('yanzhang0219/eleline.vim')
  call minpac#add('mhinz/vim-startify')
  call minpac#add('ryanoasis/vim-devicons')
  call minpac#add('morhetz/gruvbox')

  " Testing
  " call minpac#add('mg979/vim-xtabline')

endfunction

" Enable matchit.vim plugin which is shipped with Vim
runtime macros/matchit.vim

" Basic vim plugin in FZF
set rtp+=~/gitrepos/fzf

" }}}

" ========== Dress up ========== {{{

set termguicolors

colorscheme gruvbox
set background=dark

" Remove background color to make vim transparent in Alacritty
hi Normal guibg=NONE ctermbg=NONE

" }}}

" ========== Plugin settings ========== {{{

" ---- minpac ----

command! PluginUpdate source $MYVIMRC | call PackInit() | call minpac#update()
command! PluginDelete source $MYVIMRC | call PackInit() | call minpac#clean()
command! PluginStatus packadd minpac | call minpac#status()

" ---- fzf ----

" Make the preview use the config of command-line fzf (defined in ~/.config/fzf/fzf) instead of
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
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

let g:fzf_history_dir = '~/.local/share/fzf-vim-history'

" Disable the statusline for fzf window
if has('nvim') && !exists('g:fzf_layout')
  augroup fzf
    autocmd  FileType fzf set laststatus=0 noshowmode noruler
          \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler
  augroup END
endif

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

function! s:delete_buffers(lines)
  execute 'bwipeout' join(map(a:lines, {_, line -> split(line)[0]}))
endfunction

command! BD call fzf#run(fzf#wrap({
  \ 'source': s:list_buffers(),
  \ 'sink*': { lines -> s:delete_buffers(lines) },
  \ 'options': '--multi --reverse --bind ctrl-a:select-all+accept'
\ }))

" ---- vim-illuminate ----

augroup illuminate_augroup
    autocmd!
    autocmd VimEnter * hi illuminatedWord cterm=underline gui=underline
augroup END

" ---- vim-hexokinase ----

let g:Hexokinase_ftEnabled = ['css', 'html', 'javascript']
nnoremap <Leader>tc :HexokinaseToggle<CR>

" ---- gitgutter ----

let g:gitgutter_map_keys = 0
" nnoremap <Leader>gf :GitGutterFold<CR>
" nnoremap <Leader>gp :GitGutterPrevHunk<CR>
" nnoremap <Leader>gn :GitGutterNextHunk<CR>

" ---- vimwiki ----
" let g:vimwiki_list = [{'path': '~/Dropbox/vimwiki/', 'syntax': 'markdown', 'ext': '.md'}]

" ---- markdown-preview ----

" Open a new window of Chrome in the same workspace
function! g:Open_browser(url)
    silent exe 'silent !open -na "Google Chrome" --args --new-window ' . a:url
endfunction
let g:mkdp_browserfunc = 'g:Open_browser'

" ---- indentLine ----

let g:indentLine_enabled = 0
let g:indentLine_fileTypeExclude = ['startify', 'help', 'markdown']
let g:indentLine_char = '¦'

" ---- startify ----

function! StartifyEntryFormat()
  return 'WebDevIconsGetFileTypeSymbol(absolute_path) ." ". entry_path'
endfunction

let g:ascii = [
      \ '                                 __                ',
      \ ' __  __  ____            __  __ /\_\    ___ ___    ',
      \ '/\ \/\ \/\_ ,`\  _______/\ \/\ \\/\ \ /'' __` __`\ ',
      \ '\ \ \_\ \/_/  /_/\______\ \ \_/ |\ \ \/\ \/\ \/\ \ ',
      \ ' \/`____ \/\____\/______/\ \___/  \ \_\ \_\ \_\ \_\',
      \ '  `/___/> \/____/         \/__/    \/_/\/_/\/_/\/_/',
      \ '     /\___/                                        ',
      \ '     \/__/                                         ',
      \ ]

let g:startify_custom_header = 'startify#pad(g:ascii)'

" Enable cursorline
augroup starity
  autocmd User Startified setlocal cursorline
augroup END

" }}}
