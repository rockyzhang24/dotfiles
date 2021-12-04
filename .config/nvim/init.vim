" Author: Rocky Zhang <yanzhang0219@gmail.com>
" GitHub: https://github.com/yanzhang0219

" ---------- [ General ] ---------- {{{

filetype plugin indent on
syntax on
set nocompatible
set number
set relativenumber
set cursorline
set hidden  " Allow buffer switch without saving
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
set fillchars=fold:\ ,
set foldenable
set foldmethod=indent
set foldlevel=99
set completeopt=menuone,preview,noinsert
set ttimeoutlen=50
set timeoutlen=500
set shortmess+=c
set inccommand=split
set updatetime=100  " For vim-gitgutter
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
set hlsearch
set incsearch
set ignorecase
set smartcase
set title
set noswapfile
set signcolumn=yes
set spelllang=en_us
set pumheight=20
set grepprg=rg\ --vimgrep\ --smart-case\ $*
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
set formatoptions-=tc
set undofile " presistent undo (use set undodir=... to change the undodir, default is ~/.local/share/nvim/undo)

" Avoid highlighting the last search when sourcing vimrc
exec "nohlsearch"

" Terminal
let g:neoterm_autoscroll = '1'

" }}}

" ---------- [ Colors ] ---------- {{{

set termguicolors
set background=dark
colorscheme tokyonight

" }}}

" ---------- [ Autocommands ] ---------- {{{

augroup general
  autocmd!

  " Jump to the position when you last quit
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") && &filetype !~# 'commit' |
      \ exe "normal! g'\"" |
    \ endif

  " Automatically equalize splits when Vim is resized
  autocmd VimResized * wincmd =

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

" }}}

" ---------- [ Abbreviation ] ---------- {{{

call utils#SetupCommandAbbrs('T', 'tabedit')

" }}}

" ---------- [ Mappings ] ---------- {{{

let mapleader=" "

" Smarter j and k navigation
nnoremap <expr> j v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj'
nnoremap <expr> k v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk'

" Go to the start and end of the line easier
noremap H ^
noremap L $

" Move the selections up and down with corresponding indentation
xnoremap J :m '>+1<CR>gv=gv
xnoremap K :m '<-2<CR>gv=gv

" Jump to the next '<++>' and edit it
nnoremap <silent> <Leader><Leader> <Esc>/<++><CR>:nohlsearch<CR>c4l
inoremap <silent> ,f <Esc>/<++><CR>:nohlsearch<CR>"_c4l

" Indent
xnoremap < <gv
xnoremap > >gv

" Copy
nnoremap Y y$
xnoremap Y "+y

" Copy the entire buffer
nnoremap <silent> y% :<C-u>%y<CR>
nnoremap <silent> Y% :<C-u>%y +<CR>

" Paste and then format
nnoremap p p=`]

" Paste over the selected text
xnoremap p "_c<Esc>p

" Delete but not save to a register
nnoremap s "_d
xnoremap s "_d
nnoremap S "_D
nnoremap ss "_dd
nnoremap c "_c
xnoremap c "_c
nnoremap C "_C
nnoremap cc "_cc

" Increment and decrement
nnoremap + <C-a>
nnoremap - <C-x>
xnoremap + g<C-a>
xnoremap - g<C-x>

" Switch between the current and the last buffer
nnoremap <Backspace> <C-^>

" Make dot work over visual line selections
xnoremap . :norm.<CR>

" Execute a macro over visual line selections
xnoremap Q :'<,'>:normal @q<CR>

" Redirect change operations to the blackhole
nnoremap c "_c
nnoremap C "_C

" Clone current paragraph
nnoremap cp yap<S-}>p

" Remove all the trailing whitespaces
nnoremap <silent> _$ :call utils#Preserve("%s/\\s\\+$//e")<CR>;

" Format the whole file
nnoremap <silent> _= :call utils#Preserve("normal gg=G")<CR>;

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

" Navigation in the argument list
nnoremap <silent> [a :<C-u>previous<CR>
nnoremap <silent> ]a :<C-u>next<CR>
nnoremap <silent> [A :<C-u>first<CR>
nnoremap <silent> ]A :<C-u>last<CR>

" Navigation in the buffer list
nnoremap <silent> [b :<C-u>bprevious<CR>
nnoremap <silent> ]b :<C-u>bnext<CR>
nnoremap <silent> [B :<C-u>bfirst<CR>
nnoremap <silent> ]B :<C-u>blast<CR>

" Navigation in the quickfix list
nnoremap <silent> [q :<C-u>cprevious<CR>
nnoremap <silent> ]q :<C-u>cnext<CR>
nnoremap <silent> [Q :<C-u>cfirst<CR>
nnoremap <silent> ]Q :<C-u>clast<CR>

" Navigation in the location list
nnoremap <silent> [l :<C-u>lprevious<CR>
nnoremap <silent> ]l :<C-u>lnext<CR>
nnoremap <silent> [L :<C-u>lfirst<CR>
nnoremap <silent> ]L :<C-u>llast<CR>

" Navigate in the tabs
nnoremap <silent> [t :<C-u>tabprevious<CR>
nnoremap <silent> ]t :<C-u>tabnext<CR>
nnoremap <silent> [T :<C-u>tabfirst<CR>
nnoremap <silent> ]T :<C-u>tablast<CR>

" Toggle spell checking
nnoremap <silent> yos :setlocal spell! spelllang=en_us<CR>:set spell?<CR>

" Toggle wrap
nnoremap <silent> yow :set wrap!<CR>:set wrap?<CR>

" Close location list or quickfix list windows
nnoremap <silent> \q :<C-u>windo lclose <Bar> cclose <CR>

" Delete the current buffer and switch back to the previous one
nnoremap <silent> \d :<C-u>bprevious <Bar> bdelete #<CR>

" Close the current tab
nnoremap <silent> \w :tabclose<CR>

" Insert blank lines above or below the current line and preserve the cursor position
nnoremap <expr> [<Space> 'm`' . v:count . 'O<Esc>``'
nnoremap <expr> ]<Space> 'm`' . v:count . 'o<Esc>``'

" Edit and source vim config file
nnoremap <silent> <Leader>ve :<C-u>tabedit $MYVIMRC<CR>
nnoremap <silent> <Leader>vs :<C-u>source $MYVIMRC<CR>

" Window

" Focus movement around windows
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Create a split window to up (horizontal), down (horizontal), left (vertical), right (vertical)
nnoremap <silent> <Leader>wk :set nosplitbelow<CR><C-w>s:set splitbelow<CR>
nnoremap <silent> <Leader>wj :set splitbelow<CR><C-w>s
nnoremap <silent> <Leader>wh :set nosplitright<CR><C-w>v:set splitright<CR>
nnoremap <silent> <Leader>wl :set splitright<CR><C-w>v

" Focus window by window number
let i = 1
while i <= 9
  execute 'nnoremap <silent> <Leader>' . i . ' :' . i . 'wincmd w<CR>'
  let i = i + 1
endwhile

" Close all windows except the current (o for only)
nnoremap <Leader>wo <C-w>o

" Sizing
nnoremap <C-Down> <C-w>5-
nnoremap <C-Up> <C-w>5+
nnoremap <C-Left> <C-w>5<
nnoremap <C-Right> <C-w>5>

" Balance size
nnoremap <Leader>= <C-w>=

" Searching

" Clean search highlighting
nnoremap <silent> \/ :<C-u>nohlsearch<CR>

" n for searching forward and N for searching backward regardless of / or ?
nnoremap <expr> n (v:searchforward ? 'n' : 'N')
nnoremap <expr> N (v:searchforward ? 'N' : 'n')

" Make * and # search for the current selection
xnoremap * :<C-u>call utils#VSetSearch('/')<CR>/<C-R>=@/<CR><CR>
xnoremap # :<C-u>call utils#VSetSearch('?')<CR>?<C-R>=@/<CR><CR>

" Grep operator
nnoremap \g :<C-u>set operatorfunc=utils#GrepOperator<cr>g@
xnoremap \g :<C-u>call utils#GrepOperator(visualmode())<cr>

" Find and replace
nnoremap \s :%s/
xnoremap \s :s/

" Command-line

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

" Get the full path of the current file
cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<cr>

" Terminal
" right Option as Meta

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

" ---------- [ Plugins ] ---------- {{{

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
  call minpac#add('AndrewRadev/splitjoin.vim')  " gS and gJ for split and join
  call minpac#add('godlygeek/tabular')
  call minpac#add('lukas-reineke/indent-blankline.nvim')
  call minpac#add('mbbill/undotree')
  call minpac#add('mhinz/vim-startify')
  call minpac#add('tyru/open-browser.vim')
  call minpac#add('p00f/nvim-ts-rainbow')
  call minpac#add('nvim-lualine/lualine.nvim')

  " LSP
  call minpac#add('neovim/nvim-lspconfig')

  " Autocomplete
  call minpac#add('hrsh7th/nvim-cmp')
  call minpac#add('hrsh7th/cmp-nvim-lsp')
  call minpac#add('hrsh7th/cmp-buffer')

  " Tree-sitter
  call minpac#add('nvim-treesitter/nvim-treesitter', {'do': 'TSUpdate'})

  " Tags
  call minpac#add('ludovicchabant/vim-gutentags')
  call minpac#add('skywind3000/gutentags_plus')

  " Git
  call minpac#add('tpope/vim-fugitive')
  call minpac#add('airblade/vim-gitgutter')

  " Markdown
  call minpac#add('mzlogin/vim-markdown-toc') " run :toc
  call minpac#add('dhruvasagar/vim-table-mode', {'type': 'opt'}) " <Leader>tm to toggle on/off
  call minpac#add('instant-markdown/vim-instant-markdown', {'type': 'opt'})
  call minpac#add('dkarter/bullets.vim')

  " Icons
  call minpac#add('ryanoasis/vim-devicons')

  " Color schemes
  call minpac#add('folke/tokyonight.nvim')

endfunction

" Enable matchit.vim plugin which is shipped with Vim
runtime macros/matchit.vim

" Basic vim plugin in FZF
set rtp+=~/gitrepos/fzf

" }}}

" ---------- [ Plugin settings ] ---------- {{{

" fzf {{{

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
  \ 'ctrl-x': 'split',
  \ "ctrl-v": 'vsplit' }

let g:fzf_history_dir = '~/.local/share/fzf-vim-history'

" GGrep, a wrapper of git grep
command! -bang -nargs=* GGrep
  \ call fzf#vim#grep(
  \   'git grep --line-number -- '.shellescape(<q-args>), 0,
  \   fzf#vim#with_preview({'dir': systemlist('git rev-parse --show-toplevel')[0]}), <bang>0)

" Delete buffers from buffer list
" Run command :BD[!], [!] to delete the unsaved buffers
function! s:list_buffers()
  redir => list
  silent ls
  redir END
  return split(list, "\n")
endfunction

function! s:delete_buffers(lines, hasBang)
  execute (a:hasBang ? 'bwipeout!' : 'bwipeout') join(map(a:lines, {_, line -> split(line)[0]}))
endfunction

command! -bang BD call fzf#run(fzf#wrap({
  \ 'source': s:list_buffers(),
  \ 'sink*': { lines -> s:delete_buffers(lines, <bang>0) },
  \ 'options': '--header "Select the buffers you want to delete from the buffer list" --multi --reverse --bind ctrl-a:select-all'
\ }))

" Go to a selected buffer
nnoremap <silent> <Leader>fb :Buffers<CR>

" Files
nnoremap <silent> <Leader>ff :Files<CR>

" Grep
nnoremap <silent> <Leader>fg :Rg<CR>

" Histories
nnoremap <silent> <Leader>f: :History:<CR>
nnoremap <silent> <Leader>f/ :History/<CR>

" Vim help tags
nnoremap <silent> <Leader>f? :Helptags<CR>

" }}}

" indent-blankline {{{

let g:indent_blankline_filetype_exclude = ['startify', 'help', 'markdown', 'json', 'jsonc', 'WhichKey']
let g:indent_blankline_buftype_exclude = ['terminal']
let g:indent_blankline_use_treesitter = v:true
let g:indent_blankline_show_current_context = v:true

" Toggle indent line
nnoremap yoi :IndentBlanklineToggle<CR>

" }}}

" minpac {{{

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
      \ OpenPluginUrl call PackInit() | silent exec "!open -a \"Safari\" " . minpac#getpluginfo(<q-args>).url

call utils#SetupCommandAbbrs('pu', 'PluginUpdate')
call utils#SetupCommandAbbrs('pd', 'PluginDelete')
call utils#SetupCommandAbbrs('pU', 'OpenPluginUrl')
call utils#SetupCommandAbbrs('pD', 'OpenPluginDir')

" }}}

" nvim-cmp {{{

lua require('plugin_config.cmp')

" }}}

" nvim-lspconfig {{{

lua require('plugin_config.lsp')

" }}}

" treesitter {{{

lua require('plugin_config.treesitter')

" }}}

" nvim-ts-rainbow {{{

lua require('plugin_config.nvim-ts-rainbow')

" }}}

" tcomment_vim {{{

" Disable the redundant preset map
let g:tcomment_mapleader2 = ''

" Javadoc comment (in kitty on macOS, use <C-/> to act as <C-_>)
nmap <C-_>j <C-_>2<C-_>b
imap <C-_>j <C-_>2<C-_>b

" }}}

" tabular {{{

nnoremap \a :Tabularize /
xnoremap \a :Tabularize /

" Find extra config at ./after/plugin/tabular.vim

" }}}

" undotree {{{

let g:undotree_WindowLayout = 2
let g:undotree_ShortIndicators = 1
let g:undotree_SetFocusWhenToggle = 1

" Toggle undotree
nnoremap you :UndotreeToggle<CR>

" }}}

" fugitive {{{

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

" gitgutter {{{

" Disable the preset mappings
let g:gitgutter_map_keys = 0

" Not to use floating window for hunk preview
let g:gitgutter_preview_win_floating = 0

" Jump between hunks
nmap [h <Plug>(GitGutterPrevHunk)
nmap ]h <Plug>(GitGutterNextHunk)

" Preview the hunk
nmap ghp <Plug>(GitGutterPreviewHunk)

" Fold/unfold all unchanged lines
nnoremap <silent> ghf :GitGutterFold<CR>

" Stage or undo hunks
nmap ghs <Plug>(GitGutterStageHunk)
xmap ghs <Plug>(GitGutterStageHunk)
nmap ghu <Plug>(GitGutterUndoHunk)

" Text object for hunk
omap ih <Plug>(GitGutterTextObjectInnerPending)
xmap ih <Plug>(GitGutterTextObjectInnerVisual)
omap ah <Plug>(GitGutterTextObjectOuterPending)
xmap ah <Plug>(GitGutterTextObjectOuterVisual)

" }}}

" gutentags {{{

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

" lualine {{{

lua require('plugin_config.lualine')

" }}}

" vim-hexokinase {{{

let g:Hexokinase_highlighters = ['backgroundfull']
let g:Hexokinase_optInPatterns = 'full_hex,rgb,rgba,hsl,hsla'

" Toggle
nnoremap yoc :HexokinaseToggle<CR>

" }}}

" vim-illuminate {{{

augroup illuminate_augroup
    autocmd!
    autocmd VimEnter * hi link illuminatedWord CursorLine
augroup END

" }}}

" vim-openbrowser.vim {{{

let g:netrw_nogx = 1
nmap gx <Plug>(openbrowser-smart-search)
vmap gx <Plug>(openbrowser-smart-search)

" ----}}}

" vim-rooter {{{

let g:rooter_pattern = ['.git/', 'package.json']

" Only change directory for the current tab
let g:rooter_cd_cmd = 'tcd'

" For non-project file, change to the file's directory
let g:rooter_change_directory_for_non_project_files = 'current'

" }}}

" startify {{{

" Make vim-rooter works when a file is opened from startify
let g:startify_change_to_dir = 0

function! StartifyEntryFormat()
  return 'WebDevIconsGetFileTypeSymbol(absolute_path) ." ". entry_path'
endfunction

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

" markdown {{{

" See ~/.config/nvim/after/ftplugin/markdown.vim

" }}}

" }}}
