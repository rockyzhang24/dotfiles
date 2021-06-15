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
set ttimeoutlen=0
set notimeout
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
set mouse=a
set hlsearch
set incsearch
set ignorecase
set smartcase
set title
set noswapfile
set nobackup nowritebackup  " coc requirements
set signcolumn=yes
set spelllang=en_us
set pumheight=20
set grepprg=rg\ --vimgrep\ $*
set grepformat=%f:%l:%c:%m
let &showbreak = '↪ '
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


" Avoid highlighting the last search when sourcing vimrc
exec "nohlsearch"

" presistent undo (use set undodir=... to change the undodir, default is ~/.local/share/nvim/undo)
if has('persistent_undo')
  set undofile
endif

" Terminal
let g:neoterm_autoscroll = '1'

" }}} General

" ========== Dress up ========== {{{1
" ==============================

set termguicolors

set background=dark

" Nord
" let g:nord_cursor_line_number_background = 1
" let g:nord_italic = 1

" Gruvbox
" autocmd vimenter * ++nested colorscheme gruvbox

" Sonokai
let g:sonokai_style = 'shusia'
let g:sonokai_enable_italic = 1
let g:sonokai_disable_italic_comment = 1
let g:sonokai_better_performance = 1
let g:sonokai_current_word = 'underline'

colorscheme sonokai

" In Alacritty, to make vim transparent, if the colorscheme doesn't have an option
" to use transparent background, we should remove the background color by uncommenting
" the line below (don't forget to use the same color for Alacritty itself)
" hi Normal guibg=NONE ctermbg=NONE

" Terminal
let g:terminal_color_0  = '#21222C'
let g:terminal_color_1  = '#FF5555'
let g:terminal_color_2  = '#50FA7B'
let g:terminal_color_3  = '#F1FA8C'
let g:terminal_color_4  = '#BD93F9'
let g:terminal_color_5  = '#FF79C6'
let g:terminal_color_6  = '#8BE9FD'
let g:terminal_color_7  = '#F8F8F2'
let g:terminal_color_8  = '#6272A4'
let g:terminal_color_9  = '#FF6E6E'
let g:terminal_color_10 = '#69FF94'
let g:terminal_color_11 = '#FFFFA5'
let g:terminal_color_12 = '#D6ACFF'
let g:terminal_color_13 = '#FF92DF'
let g:terminal_color_14 = '#A4FFFF'
let g:terminal_color_15 = '#FFFFFF'

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

augroup END

augroup filetypes
  autocmd!

  " Disables auto-wrap text and comments
  autocmd FileType * setlocal formatoptions-=t formatoptions-=c formatoptions-=r formatoptions-=o
  " vim
  autocmd FileType vim setlocal foldmethod=marker foldlevel=0 textwidth=0
  " make
  autocmd FileType make setlocal tabstop=8 softtabstop=8 shiftwidth=8 noexpandtab
  " markdown
  autocmd FileType markdown packadd markdown-preview.nvim

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
        \ IndentLinesDisable
  autocmd BufWinEnter,WinEnter term://* startinsert

augroup END

" }}} Autocommands

" ========== Commands ========== {{{1
" ==============================

" Format the current buffer
command! -nargs=0 Format :call CocAction('format')

" Fold the current buffer
command! -nargs=? Fold :call CocAction('fold', <f-args>)

" Organize imports
command! -nargs=0 OR :call CocAction('runCommand', 'editor.action.organizeImport')

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

call SetupCommandAbbrs('C', 'CocConfig')
call SetupCommandAbbrs('L', 'CocList')
call SetupCommandAbbrs('T', 'tabe')
call SetupCommandAbbrs('S', 'CocCommand snippets.editSnippets')

" }}} Abbreviation

" ========== Mappings ========== {{{1
" ==============================

" ----- General ----- {{{2
" ===================

let mapleader=" "

" Make j and k move line by line, but behave normally when given a count
nnoremap <expr> j (v:count == 0 ? 'gj' : 'j')
nnoremap <expr> k (v:count == 0 ? 'gk' : 'k')

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

" }}}

" ----- Object ----- {{{2
" ==================

" Inside next/last parentheses
onoremap in( :<C-u>normal! f(vi(<CR>
onoremap il( :<C-u>normal! F)vi(<CR>

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

" NOTE: Meta key is the right Option key in my iTerm2

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

" fzf to switch buffers (fzf.vim)
nnoremap <Leader>bb :Buffers<CR>

" Switch to buffer N (vim-xtabline)
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

" ----- coc.nvim (c) ----- {{{2
" ========================

" Use tab to trigger completion with characters ahead and navigate.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Trigger completion.
inoremap <silent><expr> <C-o> coc#refresh()

" Make <CR> auto-select the first completion item and notify coc.nvim to format on enter
inoremap <silent><expr> <CR> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Symbol renaming (rename the symbol under the cursor and all its references)
nmap <Leader>crn <Plug>(coc-rename)

" Refactor (open a vsplit window for refactoring the symbol under the cursor like rename, add/remove lines, etc)
" Reference: https://github.com/neoclide/coc.nvim/wiki/Multiple-cursors-support#use-refactor-action
nmap <Leader>crf <Plug>(coc-refactor)

" Formatting selected code.
xmap <Leader>cf <Plug>(coc-format-selected)
nmap <Leader>cf <Plug>(coc-format-selected)

" Applying codeAction to the selected region.
" Example: `<Leader>casap` for current paragraph
xmap <Leader>cas <Plug>(coc-codeaction-selected)
nmap <Leader>cas <Plug>(coc-codeaction-selected)
" Run codeAction for the whole current file, the current line
nmap <Leader>caf <Plug>(coc-codeaction)
nmap <Leader>cal <Plug>(coc-codeaction-line)

" Text objects regarding function and class
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"

" Use CTRL-S for selections ranges (e.g., select the whole if block)
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" CocList (cl)
" Show all supported lists
nnoremap <silent> <Leader>cll :<C-u>CocList<CR>
" Shows commands
nnoremap <silent> <Leader>clc :<C-u>CocList commands<CR>
" Show all diagnostics
nnoremap <silent> <Leader>cld :<C-u>CocList diagnostics<CR>
" Show symbols of the current document
nnoremap <silent> <Leader>clo :<C-u>CocList outline<CR>
" Show symbols in workspace
nnoremap <silent> <Leader>cls :<C-u>CocList -I symbols<CR>
" Yank list (coc-yank)
nnoremap <silent> <Leader>cly :<C-u>CocList -A --normal yank<cr>
" Do the default action for the next/prev item in the list (list won't be reopened)
nnoremap <silent> <Leader>cln :<C-u>CocNext<CR>
nnoremap <silent> <Leader>clp :<C-u>CocPrev<CR>
" Reopen the latest list
nnoremap <silent> <Leader>clr :<C-u>CocListResume<CR>

" coc-snippets
" https://github.com/neoclide/coc-snippets
imap <C-l> <Plug>(coc-snippets-expand)
vmap <C-j> <Plug>(coc-snippets-select)
let g:coc_snippet_next = '<C-j>'
let g:coc_snippet_prev = '<C-k>'
imap <C-j> <Plug>(coc-snippets-expand-jump)

" }}}

" ----- Find/Files (f) ----- {{{2
" ==========================

" fzf to open file (fzf.vim)
nnoremap <Leader>ff :Files<CR>
nnoremap <Leader>fF :Files<Space>

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

" ----- History & Help (h) ----- {{{2
" ==============================

" fzf for the command and search history (fzf.vim)
nnoremap <Leader>h: :History:<CR>
nnoremap <Leader>h/ :History/<CR>

" fzf for help tags (fzf.vim)
nnoremap <Leader>h? :Helptags<CR>

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
  silent execute "grep! -R " . shellescape(@@) . " ."
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

" Toggle indent lines (indentLine)
nnoremap <Leader>ti :IndentLinesToggle<CR>

" Toggle colors (vim-hexokinase)
nnoremap <Leader>tc :HexokinaseToggle<CR>

" Toggle undotree (undotree.vim)
nnoremap <Leader>tu :UndotreeToggle<CR>

" Toggle vista (vista.vim)
nnoremap <Leader>tv :Vista!!<CR>

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
nnoremap <Leader>Tls :tabs<CR>

" Move buffer position on the tabline (vim-xtabline)
nnoremap <Leader>Tb[ :XTabMoveBufferPrev<CR>
nnoremap <Leader>Tb] :XTabMoveBufferNext<CR>

" Move the current tab to the right/left
nnoremap <Leader>T. :tabmove +<CR>
nnoremap <Leader>T, :tabmove -<CR>

" }}}

" ----- Vista.vim & vimrc (v) ----- {{{2
" =================================

nnoremap <Leader>vf :silent! Vista finder coc<CR>

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

" Close all windows except the current (o for only)
nnoremap <Leader>wo <C-w>o

" Go to the preview window
nnoremap <Leader>wP <C-w>P

" Close the preview window
nnoremap <Leader>wz <C-w>z

" Close the window right below the current window
nnoremap <Leader>wbc <C-w>j:q<CR>

" Move current window to new tab
nnoremap <Leader>wT <C-w>T

" Resize
nnoremap <Leader>wJ <C-w>5-
nnoremap <Leader>wK <C-w>5+
nnoremap <Leader>wH <C-w>5<
nnoremap <Leader>wL <C-w>5>

" Balance size
nnoremap <Leader>w= <C-w>=

" Exchange the current window with window N (must be in the same column or row)
nnoremap <Leader>wx <C-w>x

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
  call minpac#add('yggdroot/indentline')
  call minpac#add('mbbill/undotree')
  call minpac#add('mhinz/vim-startify')
  call minpac#add('tyru/open-browser.vim')

  " Tree-sitter
  call minpac#add('nvim-treesitter/nvim-treesitter', {'do': 'TSUpdate'})

  " LSP
  call minpac#add('neoclide/coc.nvim', {'branch': 'release'})

  " Tags
  call minpac#add('ludovicchabant/vim-gutentags')
  call minpac#add('skywind3000/gutentags_plus')
  call minpac#add('liuchengxu/vista.vim')

  " Languages
  call minpac#add('neoclide/jsonc.vim')

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
  call minpac#add('yanzhang0219/eleline.vim')

  " Icons
  call minpac#add('ryanoasis/vim-devicons')

  " Color schemes
  call minpac#add('morhetz/gruvbox')
  call minpac#add('arcticicestudio/nord-vim')
  call minpac#add('dracula/vim', { 'name': 'dracula' })
  call minpac#add('sainnhe/sonokai')
  call minpac#add('sainnhe/gruvbox-material')

  " Testing

endfunction

" Enable matchit.vim plugin which is shipped with Vim
runtime macros/matchit.vim

" Basic vim plugin in FZF
set rtp+=~/gitrepos/fzf

" }}} Plugins

" ========== Plugin settings ========== {{{1
" =====================================

" ----- coc.nvim ----- {{{2
" ====================

" Reference: https://github.com/neoclide/coc.nvim#example-vim-configuration

" coc extensions
let g:coc_global_extensions = [
      \ 'coc-html',
      \ 'coc-css',
      \ 'coc-tsserver',
      \ 'coc-pyright',
      \ 'coc-go',
      \ 'coc-json',
      \ 'coc-prettier',
      \ 'coc-eslint',
      \ 'coc-rls',
      \ 'coc-sh',
      \ 'coc-vimlsp',
      \ 'coc-yank',
      \ 'coc-snippets',
      \ 'coc-marketplace']

augroup cocgroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Highlight for cursor ranges
hi CocCursorRange guibg=#b16286 guifg=#ebdbb2

" Highlight for the yanked text (coc-yank)
hi HighlightedyankRegion cterm=bold gui=bold ctermbg=0 guibg=#13354A

let g:coc_status_error_sign = ' '
let g:coc_status_warning_sign = ' '

command! -nargs=0 Prettier :CocCommand prettier.formatFile

" Golang: auto-format and add missing imports on save
autocmd BufWritePre *.go :call CocAction('runCommand', 'editor.action.organizeImport')

" }}}

" ----- eleline.vim ----- {{{2
" =======================

let g:eleline_powerline_fonts = 1

" }}}

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

" ----- indentLine ----- {{{2
" ======================

let g:indentLine_fileTypeExclude = ['startify', 'help', 'markdown', 'json', 'jsonc']
let g:indentLine_bufTypeExclude = ['terminal']
let g:indentLine_char = '|'

" }}}
"
" ----- minpac ----- {{{2
" ==================

command! PluginUpdate source $MYVIMRC | call PackInit() | call minpac#update()
command! PluginDelete source $MYVIMRC | call PackInit() | call minpac#clean()
command! PluginStatus packadd minpac | call minpac#status()

function! PackList(...)
  call PackInit()
  return join(sort(keys(minpac#getpluglist())), "\n")
endfunction

" Define a command, OpenPluginDir, to open a new iTerm2 window and cd into the directory where a plugin is installed
" (The custom command, iterm, is defined at ~/.config/bin/iterm)
command! -nargs=1 -complete=custom,PackList
      \ OpenPluginDir call PackInit() | silent exec "!iterm \"cd " . minpac#getpluginfo(<q-args>).dir . "\""

" Define a command, OpenPluginUrl, to open the plugin's git repo in Chrome
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

" ----- vista.vim ----- {{{2
" =====================

let g:vista_sidebar_width = 50
let g:vista_default_executive = 'coc'
let g:vista_fzf_preview = ['right:50%']
let g:vista#renderer#enable_icon = 1
let g:vista_icon_indent = ["╰─▸ ", "├─▸ "]

" Show the nearest function in the statusline automatically
autocmd VimEnter * call vista#RunForNearestMethodOrFunction()

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
"
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

" }}} Plugin settings
