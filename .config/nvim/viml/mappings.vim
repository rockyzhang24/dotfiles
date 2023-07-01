" Misc {{{

let mapleader=" "
noremap <Space> <NOP>

" `,` is used as a leader key for git, so use `<Leader>,` instead.
nnoremap <Leader>, ,

" Save
nnoremap <C-s> <Cmd>update<CR>

" Black hole register
nnoremap - "_
xnoremap - "_

" Smarter j and k navigation
nnoremap <expr> j v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj'
nnoremap <expr> k v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk'

" Go to the start and end of the line easier
noremap H ^
noremap L $

" Move the current line or selections up and down with corresponding indentation
nnoremap <silent> <M-j> :m .+1<CR>==
nnoremap <silent> <M-k> :m .-2<CR>==
inoremap <silent> <M-j> <Esc>:m .+1<CR>==a
inoremap <silent> <M-k> <Esc>:m .-2<CR>==a
xnoremap <silent> J :m '>+1<CR>gv=gv
xnoremap <silent> K :m '<-2<CR>gv=gv

" Join lines but retain the cursor position
nnoremap J mzJ`z

" Indent
xnoremap < <gv
xnoremap > >gv

" Make dot work over visual line selections
xnoremap <silent> . :norm.<CR>

" Clone current paragraph
nnoremap cp yap<S-}>p

" Remove the trailing whitespaces in the whole buffer or just the selected lines
nnoremap <silent> _$ :<C-u>call utils#Preserve("%s/\\s\\+$//e")<CR>;
xnoremap <silent> _$ :<C-u>call utils#Preserve("s/\\s\\+$//e", visualmode())<CR>;

" Format the whole file
nnoremap <silent> _= :<C-u>call utils#Preserve("normal gg=G")<CR>;

" Insert blank lines above or below the current line and preserve the cursor position
nnoremap <expr> [<Space> 'm`' . v:count . 'O<Esc>``'
nnoremap <expr> ]<Space> 'm`' . v:count . 'o<Esc>``'

" Move the view horizontally when nowrap is set
nnoremap zl 10zl
nnoremap zh 10zh

nnoremap U <Cmd>execute 'earlier ' . v:count1 . 'f'<CR>
nnoremap <M-r> <Cmd>execute 'later ' . v:count1 . 'f'<CR>

nnoremap <C-g> 2<C-g>
nnoremap <M-a> VggoG
nnoremap <Leader>i <Cmd>silent! normal! `^<CR>

" }}}

" Buffer {{{

" Delete the current buffer and switch back to the previous one
nnoremap <silent> <Leader>bd :<C-u>bprevious <Bar> bdelete #<CR>

" Delete all the other unmodified buffers
nnoremap <silent> <Leader>bD :call utils#BufsDel()<CR>

" }}}

" Copy and paste {{{

" Copy
nnoremap Y y$
nnoremap <Leader>y "+y
vnoremap <Leader>y "+y
nmap <Leader>Y "+Y

" Paste and then format
nnoremap p p=`]

" Paste over the selected text
xnoremap p "_c<Esc>p

" Select the last changed (or pasted) text
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

" Paste non-linewise text above or below current cursor and format
nnoremap <Leader>p m`o<Esc>p==``
nnoremap <Leader>P m`O<Esc>p==``

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
cnoremap <C-d> <Del>
cnoremap <C-k> <C-\>egetcmdline()[:getcmdpos() - 2]<CR>

" Ctrl-o to open command-line window
set cedit=\<C-o>

" }}}

" Navigation {{{

" Use [x and ]x to move the the previous/next misspelled word
" [s and ]s has been used for navigating among symbols
nnoremap [x [s
nnoremap ]x ]s

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

" Make section-jump work if '{' or '}' are not in the first column (see :h [[)
map <silent> [[ :<C-u>eval search('{', 'b')<CR>w99[{
map <silent> [] k$][%:<C-u>silent! eval search('}', 'b')<CR>
map <silent> ]] j0[[%:<C-u>silent! eval search('{')<CR>
map <silent> ][ :<C-u>silent! eval search('}')<CR>b99]}

" }}}

" Search {{{

" Clean search highlighting and update diff if needed
nnoremap <expr> <Leader>l {-> v:hlsearch ? ":<C-U>nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>" : "\<CR>"}()

" Substitute all the occurrance of the current word
nnoremap <Leader>S :%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>

xnoremap / <Esc>/\%V

" Grep operator (now using vim-grepper instead)
" nnoremap <silent> \g :<C-u>set operatorfunc=utils#GrepOperator<CR>g@
" xnoremap <silent> \g :<C-u>call utils#GrepOperator(visualmode())<CR>

" }}}

" Tab {{{

" Open a new tab with an empty window
nnoremap <silent> <Leader>tn :$tabnew<CR>

" Close all other tabs
nnoremap <silent> <Leader>to :tabonly<CR>

" Move the current tab to the left or right
nnoremap <silent> <Leader>t, :-tabmove<CR>
nnoremap <silent> <Leader>t. :+tabmove<CR>

" }}}

" Toggle {{{

" Toggle spell checking
nnoremap <silent> <Leader><Leader>s :setlocal spell! spelllang=en_us<CR>:set spell?<CR>

" Toggle wrap
nnoremap <silent> <Leader><Leader>r :set wrap!<CR>:set wrap?<CR>

" }}}

" Terminal {{{

" Back to normal mode in the terminal buffer
tnoremap <C-BS> <C-\><C-n>

" In terminal mode, use <M-r> to simulate <C-r> in insert mode for inserting the content of a register
" Reference: http://vimcasts.org/episodes/neovim-terminal-paste/
tnoremap <expr> <M-r> '<C-\><C-n>"' . nr2char(getchar()) . 'pi'

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
nnoremap <Leader>wp <C-w>p

" Create a split window
nnoremap <silent> <Leader>- :split<CR>
nnoremap <silent> <Leader><BS> :vsplit<CR>

" Move current window to new tab
nnoremap <Leader>wt <C-w>T

" Duplicate the current window in a new tab
nnoremap <Leader>wT <Cmd>tab split<CR>

" Close all other windows (not including float windows)
nnoremap <expr> <Leader>wo len(filter(nvim_tabpage_list_wins(0), { k,v -> nvim_win_get_config(v).relative == "" })) > 1 ? '<C-w>o' : ''

" Sizing
nnoremap <Leader><Down> <C-w>5-
nnoremap <Leader><Up> <C-w>5+
nnoremap <Leader><Left> <C-w>5<
nnoremap <Leader><Right> <C-w>5>

" Balance size
nnoremap <Leader>w= <C-w>=

" Close windows by giving the window numbers
nnoremap <Leader>wc :CloseWin<Space>

" }}}
