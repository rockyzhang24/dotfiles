" Author: Rocky Zhang <yanzhang0219@gmail.com>
" GitHub: https://github.com/rockyzhang24

" ---------- [ General ] ---------- {{{

set nocompatible
set number
set relativenumber
set cursorline
set cursorlineopt=number,screenline
" set foldcolumn=1
set hidden  " Allow buffer switch without saving
set wrap
set autoindent
" set clipboard+=unnamedplus
set scrolloff=5
set sidescrolloff=5
set autoread
set noshowmode
set showcmd
set wildmenu
set wildmode=longest:full,full
set textwidth=80
set colorcolumn=80
set list
set listchars=tab:›\ ,trail:•,extends:#,nbsp:.,precedes:❮,extends:❯
set fillchars=fold:\ ,eob:\ ,msgsep:‾,
set foldenable
set foldmethod=indent
set foldlevel=99
" set foldmethod=expr
" set foldexpr=nvim_treesitter#foldexpr() " treesitter based folding
set completeopt=menu,menuone,noselect
set ttimeoutlen=50
set timeoutlen=500
set shortmess+=a shortmess+=c shortmess+=I
set inccommand=split
set updatetime=200
set laststatus=3
set showtabline=2
set matchpairs+=<:>
set splitbelow
set splitright
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=-1 " use the value of 'shiftwidth'
set shiftround
set hlsearch
set incsearch
set ignorecase
set smartcase
set title
set titlestring=%t%(\ %M%)%<%(\ (%{expand(\"%:~:.:h\")})%)%(\ %a%)
set titlelen=15
set diffopt+=vertical diffopt+=algorithm:patience
set noswapfile
set signcolumn=yes:3
set spelllang=en_us
set pumblend=5
set pumheight=20
set winblend=5
set winminwidth=10
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
set undofile " presistent undo (use set undodir=... to change the undodir, default is ~/.local/share/nvim/undo)
set nrformats=octal,bin,hex,unsigned,alpha
set sessionoptions+=terminal,globals,winpos
set isfname-==

" Avoid highlighting the last search when sourcing vimrc
exec "nohlsearch"

" Terminal
let g:neoterm_autoscroll = '1'

" Dress up quickfix window
lua require('qf')

" Set winbar
lua require('winbar')

" Use filetype.lua instead of filetype.vim
let g:do_filetype_lua = 1
let g:did_load_filetypes = 0

" }}}

" ---------- [ Colors ] ---------- {{{

set termguicolors
set background=dark

" let g:gruvbox_material_palette = 'original'
" let g:gruvbox_material_enable_bold = 1
" let g:gruvbox_material_enable_italic = 1
" let g:gruvbox_material_visual = 'blue background'
" let g:gruvbox_material_diagnostic_virtual_text = 'colored'
" let g:gruvbox_material_statusline_style = 'original'
" let g:gruvbox_material_better_performance = 1

" colorscheme gruvbox-material

lua require('plugin.nightfox')

" }}}

" ---------- [ Autocommands ] ---------- {{{

augroup general
  autocmd!
  " Jump to the position when you last quit
  autocmd BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line("$") && &filetype !~# 'commit' |
        \   exe "normal! g'\"" |
        \ endif
  " Automatically equalize splits when Vim is resized
  autocmd VimResized * wincmd =
  " Make it not be overwritten by the default setting of neovim
  autocmd FileType * set formatoptions-=t formatoptions-=o formatoptions-=r textwidth=80
augroup END

" Highlight selection on yank
augroup highlight_yank
  autocmd!
  autocmd TextYankPost * silent! lua vim.highlight.on_yank({higroup="Substitute", timeout=300})
augroup END

" Neovim builtin terminal
augroup nvim_terminal
  autocmd!
  " Automatically start insert mode when enter terminal, and disable line number and indentline
  autocmd TermOpen term://* startinsert |
        \ setlocal nonumber norelativenumber signcolumn=no |
        \ IndentBlanklineDisable
  autocmd BufWinEnter,WinEnter term://* startinsert
augroup END

" Automatic toggling between 'hybrid' and absolute line numbers
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
augroup END

" Disable syntax highlighting for some filetypes if they are too long
augroup syntax_off
  autocmd!
  autocmd FileType yaml if line('$') > 500 | setlocal syntax=OFF | endif
augroup END

" Quit vim (or close the tab) automatically if all buffers left are auxiliary
function! s:AutoQuit() abort
  let l:filetypes = ['aerial', 'NvimTree', 'neo-tree', 'tsplayground', 'query']
  let l:tabwins = nvim_tabpage_list_wins(0)
  for w in l:tabwins
    let l:buf = nvim_win_get_buf(w)
    let l:buf_ft = getbufvar(l:buf, '&filetype')
    if index(l:filetypes, buf_ft) == -1
      return
    endif
  endfor
  call s:Quit()
endfunction

function! s:Quit() abort
  if tabpagenr('$') > 1
    tabclose
  else
    qall
  endif
endfunction

augroup auto_quit
  autocmd!
  autocmd BufEnter * call s:AutoQuit()
augroup END

" I manage my dotfiles using a bare repository. To make Vim recognize them and git related plugins
" work on them, the environment variables should be set to indicate the locations of git-dir and
" work-tree when we enter the dotfile buffer. Don't forget to reset them when we enter other buffers,
" otherwise the normal repository will not be recognized.
function! s:SetGitEnv() abort
  let cur_file = expand('%')
  " Only set the Git env for the buffer containing a real file
  if !filereadable(cur_file)
    return
  endif
  let git_dir = expand('~/dotfiles')
  let work_tree = expand('~')
  let jib = jobstart(["git", "--git-dir", git_dir, "--work-tree", work_tree, "ls-files", "--error-unmatch", cur_file])
  let ret = jobwait([jib])[0]
  if ret == 0
    let $GIT_DIR = git_dir
    let $GIT_WORK_TREE = work_tree
  else
    unlet $GIT_DIR
    unlet $GIT_WORK_TREE
  endif
endfunction

augroup personal
  autocmd!
  autocmd BufNewFile,BufRead,BufEnter * call s:SetGitEnv()
augroup END

" }}}

" ---------- [ Commands ] ---------- {{{

" Change indentation for the current buffer
" `:Reindent cur_indent new_indent`, E.g., `:Reindent 2 4` for changing the
" indentation from 2 to 4
command -nargs=+ Reindent call utils#Reindent(<f-args>)

" }}}

" ---------- [ Abbreviation ] ---------- {{{

call abbr#SetupCommandAbbrs('T', 'tabedit')

" }}}

" ---------- [ Mappings ] ---------- {{{

" Misc {{{

let mapleader=" "
nnoremap <Space> <NOP>

" The normal `,` is used as a leader key for lsp mappings
nnoremap <Leader>, ,

" Save and quit
nnoremap <silent> <Leader>ww :<C-u>update<CR>
nnoremap <silent> <Leader>q :<C-u>x<CR>
nnoremap <silent> <Leader>Q :<C-u>q!<CR>

" Smarter j and k navigation
nnoremap <expr> j v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj'
nnoremap <expr> k v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk'

" Go to the start and end of the line easier
noremap H ^
noremap L $

" Move the selections up and down with corresponding indentation
xnoremap J :m '>+1<CR>gv=gv
xnoremap K :m '<-2<CR>gv=gv
inoremap <M-j> <Esc>:m .+1<CR>==a
inoremap <M-k> <Esc>:m .-2<CR>==a

" Fast insert a place holder
inoremap ,p <++>

" Placeholder
inoremap ,, <++> 
nnoremap <silent> <Leader><Leader> <Esc>/<++><CR>:nohlsearch<CR>c4l
inoremap <silent> ,f <Esc>/<++><CR>:nohlsearch<CR>"_c4l

" Indent
xnoremap < <gv
xnoremap > >gv

" Delete but not save to a register
nnoremap <Leader>d "_d
xnoremap <Leader>d "_d
nnoremap <Leader>D "_D
nnoremap <Leader>dd "_dd
nnoremap c "_c
xnoremap c "_c
nnoremap C "_C
nnoremap cc "_cc

" Make dot work over visual line selections
xnoremap . :norm.<CR>

" Execute a macro over visual line selections
xnoremap Q :'<,'>:normal @q<CR>

" Clone current paragraph
nnoremap cp yap<S-}>p

" Remove the trailing whitespaces in the whole buffer or just the selected lines
nnoremap <silent> _$ :<C-u>call utils#Preserve("%s/\\s\\+$//e")<CR>;
xnoremap <silent> _$ :<C-u>call utils#Preserve("s/\\s\\+$//e", visualmode())<CR>;

" Format the whole file
nnoremap <silent> _= :<C-u>call utils#Preserve("normal gg=G")<CR>;

" When navigating, center the cursor
nnoremap {  {zz
nnoremap }  }zz
nnoremap ]c ]czz
nnoremap [c [czz
nnoremap [j <C-o>zz
nnoremap ]j <C-i>zz
nnoremap ]x ]szz
nnoremap [x [szz

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
nnoremap <silent> [q :<C-u>cprevious<CR>zv
nnoremap <silent> ]q :<C-u>cnext<CR>zv
nnoremap <silent> [Q :<C-u>cfirst<CR>zv
nnoremap <silent> ]Q :<C-u>clast<CR>zv

" Navigation in the location list
nnoremap <silent> [l :<C-u>lprevious<CR>zv
nnoremap <silent> ]l :<C-u>lnext<CR>zv
nnoremap <silent> [L :<C-u>lfirst<CR>zv
nnoremap <silent> ]L :<C-u>llast<CR>zv

" Navigate in the tabs
nnoremap <silent> [t :<C-u>tabprevious<CR>
nnoremap <silent> ]t :<C-u>tabnext<CR>
nnoremap <silent> [T :<C-u>tabfirst<CR>
nnoremap <silent> ]T :<C-u>tablast<CR>

" Toggle spell checking
nnoremap <silent> \S :setlocal spell! spelllang=en_us<CR>:set spell?<CR>

" Toggle wrap
nnoremap <silent> \w :set wrap!<CR>:set wrap?<CR>

" Toggle relativenumber
nnoremap <silent> \r :call toggle#ToggleRelativeNum()<CR>

" Toggle quickfix window
nnoremap <silent> \q :call toggle#ToggleQuickFix()<CR>
nnoremap <silent> \l :call toggle#ToggleLocationList()<CR>

" Insert blank lines above or below the current line and preserve the cursor position
nnoremap <expr> [<Space> 'm`' . v:count . 'O<Esc>``'
nnoremap <expr> ]<Space> 'm`' . v:count . 'o<Esc>``'

" Open a line above or below the current line
inoremap <C-CR> <C-o>O
inoremap <S-CR> <C-o>o

" Move the view horizontally when nowrap is set
nnoremap zl 10zl
nnoremap zh 10zh

" }}}

" Copy and paste {{{

" Copy
nnoremap Y y$
nnoremap <Leader>y "+y
vnoremap <Leader>y "+y
nnoremap <Leader>Y "+Y

" Copy the entire buffer
nnoremap <silent> y% :<C-u>%y<CR>
nnoremap <silent> Y% :<C-u>%y +<CR>

" Paste and then format
nnoremap p p=`]

" Paste over the selected text
xnoremap p "_c<Esc>p

" Select the last changed (or pasted) text
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

" " Paste non-linewise text above or below current cursor
nnoremap <Leader>p m`o<Esc>p``
nnoremap <Leader>P m`O<Esc>p``

" }}}

" Buffer {{{

" Switch between the current and the last buffer
nnoremap <Backspace> <C-^>

" Delete the current buffer and switch back to the previous one
nnoremap <silent> <Leader>bd :<C-u>bprevious <Bar> bdelete #<CR>

" Delete all the other unmodified buffers
nnoremap <silent> <Leader>bD :call utils#BufsDel()<CR>

" }}}

" Window {{{

" Move cursor to one of the windows in four directions
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Move cursor to the window 1 to 9
let i = 1
while i <= 9
  execute 'nnoremap <silent> <Leader>' . i . ' :' . i . 'wincmd w<CR>'
  let i = i + 1
endwhile

" Scroll the other window
nnoremap <M-d> <C-w>w<C-d><C-w>w
nnoremap <M-u> <C-w>w<C-u><C-w>w
inoremap <M-d> <Esc><C-w>w<C-d><C-w>wa
inoremap <M-u> <Esc><C-w>w<C-u><C-w>wa

" Go to the previous window
nnoremap <C-p> <C-w>p

" Create a split window
nnoremap <silent> <Leader>- :split<CR>
nnoremap <silent> <Leader>\ :vsplit<CR>

" Change vertical to horizontal
nnoremap <Leader>w- <C-w>t<C-w>K

" Change horizontal to vertical
nnoremap <Leader>w\ <C-w>t<C-w>H

" Move current window to new tab
nnoremap <Leader>wt <C-w>T

" Close all other windows (not including float windows)
nnoremap <expr> <Leader>wo len(filter(nvim_tabpage_list_wins(0), { k,v -> nvim_win_get_config(v).relative == "" })) > 1 ? '<C-w>o' : ''

" Sizing
nnoremap <Leader><Down> <C-w>5-
nnoremap <Leader><Up> <C-w>5+
nnoremap <Leader><Left> <C-w>5<
nnoremap <Leader><Right> <C-w>5>

" Balance size
nnoremap <Leader>= <C-w>=

" }}}

" Tab {{{

" Open a new tab with an empty window
nnoremap <silent> <Leader>tn :$tabnew<CR>

" Close the current tab
nnoremap <silent> <Leader>tc :tabclose<CR>

" Close all other tabs
nnoremap <silent> <Leader>to :tabonly<CR>

" Move the current tab to the left or right
nnoremap <silent> <Leader>t, :-tabmove<CR>
nnoremap <silent> <Leader>t. :+tabmove<CR>

" }}}

" Searching {{{

" Clean search highlighting
nnoremap <silent> <C-/> :<C-U>nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>

" n for searching forward and N for searching backward regardless of / or ?
nnoremap <expr> n (v:searchforward ? 'nzzzv' : 'Nzzzv')
nnoremap <expr> N (v:searchforward ? 'Nzzzv' : 'nzzzv')

" Make * and # search for the current selection
xnoremap * :<C-u>call utils#VSetSearch('/')<CR>/<C-R>=@/<CR><CR>
xnoremap # :<C-u>call utils#VSetSearch('?')<CR>?<C-R>=@/<CR><CR>

" Grep operator (now using vim-grepper instead)
" nnoremap <silent> \g :<C-u>set operatorfunc=utils#GrepOperator<CR>g@
" xnoremap <silent> \g :<C-u>call utils#GrepOperator(visualmode())<CR>

" Find and replace
nnoremap <Leader>r :%s/
xnoremap <Leader>r :s/

" }}}

" Command-line {{{

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

" }}}

" Terminal {{{

" Close the current terminal window
tnoremap <M-c> <C-\><C-n>:quit<CR>

" Close and delete the current terminal buffer
tnoremap <M-d> <C-\><C-n>:bdelete!<CR>

" Back to normal mode in the terminal buffer
tnoremap <Esc> <C-\><C-n>

" Switching between split windows
tnoremap <M-h> <C-\><C-n><C-w>h
tnoremap <M-j> <C-\><C-n><C-w>j
tnoremap <M-k> <C-\><C-n><C-w>k
tnoremap <M-l> <C-\><C-n><C-w>l

" In terminal mode, use <M-r> to simulate <C-r> in insert mode for inserting the content of a register
" Reference: http://vimcasts.org/episodes/neovim-terminal-paste/
tnoremap <expr> <M-r> '<C-\><C-n>"' . nr2char(getchar()) . 'pi'

" }}}

" }}}

" ---------- [ Plugins ] ---------- {{{

" Minpac plugin manager (load minpac on demand)
function! PackInit() abort
  packadd minpac
  call minpac#init({'progress_open': 'vertical', 'status_open': 'vertical', 'status_auto': 'TRUE'})

  call minpac#add('k-takata/minpac', {'type': 'opt'})

  call minpac#add('nvim-lua/plenary.nvim')  " lua library used by other lua plugins
  call minpac#add('tami5/sqlite.lua')
  call minpac#add('numToStr/Comment.nvim')
  call minpac#add('tpope/vim-surround')
  call minpac#add('tpope/vim-repeat')
  call minpac#add('RRethy/vim-illuminate')
  call minpac#add('RRethy/vim-hexokinase', { 'do': 'make hexokinase' })
  call minpac#add('AndrewRadev/splitjoin.vim')  " gS and gJ for split and join
  call minpac#add('godlygeek/tabular')
  call minpac#add('lukas-reineke/indent-blankline.nvim')
  call minpac#add('mbbill/undotree')
  call minpac#add('mhinz/vim-startify')
  call minpac#add('tyru/open-browser.vim')
  call minpac#add('yanzhang0219/lualine.nvim')
  call minpac#add('akinsho/bufferline.nvim')
  call minpac#add('kevinhwang91/nvim-bqf')
  call minpac#add('junegunn/fzf', { 'do': 'packloadall! | call fzf#install()' })  " as a filter for bqf
  call minpac#add('mhinz/vim-grepper')
  call minpac#add('kevinhwang91/nvim-hlslens')
  call minpac#add('tommcdo/vim-exchange') " cx{motion}, cxx (line), X (visual), cxc (clear), `.` is supported
  call minpac#add('lewis6991/foldsigns.nvim')
  call minpac#add('gelguy/wilder.nvim', { 'do': 'let &rtp=&rtp | UpdateRemotePlugins' })
  call minpac#add('tversteeg/registers.nvim')
  call minpac#add('ThePrimeagen/harpoon')
  call minpac#add('akinsho/toggleterm.nvim')
  call minpac#add('mg979/vim-visual-multi')
  call minpac#add('dstein64/nvim-scrollview')
  call minpac#add('phaazon/hop.nvim')
  call minpac#add('kevinhwang91/nvim-fFHighlight')
  call minpac#add('ahmedkhalf/project.nvim')
  call minpac#add('nvim-neo-tree/neo-tree.nvim', { 'branch': 'main' })
  call minpac#add('MunifTanjim/nui.nvim') " required by neo-tree.nvim
  call minpac#add('s1n7ax/nvim-window-picker') " required by neo-tree.nvim

  " Telescope
  call minpac#add('nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' })  " sorter for telescope
  call minpac#add('nvim-telescope/telescope.nvim')

  " Text object
  call minpac#add('junegunn/vim-after-object')
  call minpac#add('michaeljsmith/vim-indent-object')
  call minpac#add('wellle/targets.vim')

  " LSP
  call minpac#add('neovim/nvim-lspconfig')
  call minpac#add('stevearc/aerial.nvim')
  call minpac#add('kosayoda/nvim-lightbulb')
  call minpac#add('ray-x/lsp_signature.nvim')
  call minpac#add('j-hui/fidget.nvim')

  " Autocomplete
  call minpac#add('hrsh7th/nvim-cmp')
  call minpac#add('hrsh7th/cmp-nvim-lsp')
  call minpac#add('hrsh7th/cmp-buffer')
  call minpac#add('hrsh7th/cmp-path')
  call minpac#add('hrsh7th/cmp-cmdline')
  call minpac#add('hrsh7th/cmp-nvim-lua')
  call minpac#add('onsails/lspkind.nvim')

  " Snippets
  call minpac#add('L3MON4D3/LuaSnip')
  call minpac#add('saadparwaiz1/cmp_luasnip')

  " Tree-sitter
  call minpac#add('nvim-treesitter/nvim-treesitter', {'do': 'TSUpdate'})
  call minpac#add('nvim-treesitter/playground')
  call minpac#add('nvim-treesitter/nvim-treesitter-textobjects')
  call minpac#add('JoosepAlviste/nvim-ts-context-commentstring')
  call minpac#add('mizlan/iswap.nvim')
  call minpac#add('p00f/nvim-ts-rainbow')
  call minpac#add('nvim-treesitter/nvim-treesitter-context')
  call minpac#add('lewis6991/spellsitter.nvim')

  " Tags
  " call minpac#add('ludovicchabant/vim-gutentags')
  " call minpac#add('skywind3000/gutentags_plus')

  " Git
  call minpac#add('tpope/vim-fugitive')
  call minpac#add('tpope/vim-rhubarb')  " vim-fugitive's companion for :GBrowse
  call minpac#add('lewis6991/gitsigns.nvim')
  call minpac#add('rbong/vim-flog')
  call minpac#add('ruanyl/vim-gh-line')

  " Markdown
  call minpac#add('instant-markdown/vim-instant-markdown')

  " Icons
  call minpac#add('kyazdani42/nvim-web-devicons')

  " Color schemes
  call minpac#add('folke/tokyonight.nvim')
  call minpac#add('dracula/vim', { 'name': 'dracula' })
  call minpac#add('sainnhe/gruvbox-material')
  call minpac#add('EdenEast/nightfox.nvim')
  call minpac#add('rebelot/kanagawa.nvim')
  call minpac#add('bluz71/vim-nightfly-guicolors')
  call minpac#add('catppuccin/nvim', { 'name': 'catppuccin' })

endfunction

" Load lua plugin configs
lua require('plugin')

" }}}
