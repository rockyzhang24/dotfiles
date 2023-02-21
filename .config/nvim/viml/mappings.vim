" Misc {{{

let mapleader=" "

" The normal `,` is used as a leader key for lsp mappings
nnoremap <Leader>, ,

" Smarter j and k navigation
" nnoremap <expr> j v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj'
" nnoremap <expr> k v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk'

" Go to the start and end of the line easier
noremap H ^
noremap L $

" Move the selections up and down with corresponding indentation
xnoremap J :m '>+1<CR>gv=gv
xnoremap K :m '<-2<CR>gv=gv
inoremap <M-j> <Esc>:m .+1<CR>==a
inoremap <M-k> <Esc>:m .-2<CR>==a

" Join lines but retain the cursor position
nnoremap J mzJ`z

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

" Increment/Decrement
nnoremap + <C-a>
nnoremap - <C-x>
vnoremap g+ g<C-a>
vnoremap g- g<C-x>

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

" Insert blank lines above or below the current line and preserve the cursor position
nnoremap <expr> [<Space> 'm`' . v:count . 'O<Esc>``'
nnoremap <expr> ]<Space> 'm`' . v:count . 'o<Esc>``'

" Move the view horizontally when nowrap is set
nnoremap zl 10zl
nnoremap zh 10zh

" chmod
nnoremap <Leader>x :silent !chmod +x %<CR>

" Tmux (only available for neovim in tmux)
nnoremap <C-s> <Cmd>silent !tmux neww tmux-sessionizer<CR>

" Simulate the multiple cursors feature
" Ref: https://www.kevinli.co/posts/2017-01-19-multiple-cursors-in-500-bytes-of-vimscript/
let g:mc = "y/\\V\<C-r>=escape(@\", '/')\<CR>\<CR>"
" Changing a word
nnoremap <Leader>cn *``cgn
nnoremap <Leader>cN *``cgN
" Changing a selection
vnoremap <expr> <Leader>cn g:mc . "``cgn"
vnoremap <expr> <Leader>cN g:mc . "``cgN"
function! SetupCR()
  nnoremap <Enter> :nnoremap <lt>Enter> n@z<CR>q:<C-u>let @z=strpart(@z,0,strlen(@z)-1)<CR>n@z
endfunction
" Playing a macro on searches
nnoremap <Leader>cq :call SetupCR()<CR>*``qz
nnoremap <Leader>cQ :call SetupCR()<CR>#``qz
vnoremap <expr> <Leader>cq ":\<C-u>call SetupCR()\<CR>" . "gv" . g:mc . "``qz"
vnoremap <expr> <Leader>cQ ":\<C-u>call SetupCR()\<CR>" . "gv" . substitute(g:mc, '/', '?', 'g') . "``qz"

" }}}

" Buffer {{{

" Delete the current buffer and switch back to the previous one
nnoremap <silent> <Leader>bd :<C-u>bprevious <Bar> bdelete #<CR>

" Delete all the other unmodified buffers
nnoremap <silent> <Leader>bD :call utils#BufsDel()<CR>

" Search the current WORD in the current buffer
nnoremap <Leader>bs /<C-R>=escape(expand("<cWORD>"), "/")<CR><CR>

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

" Paste non-linewise text above or below current cursor
nnoremap <Leader>p m`o<Esc>p``
nnoremap <Leader>P m`O<Esc>p``

" Paste text and replace the selection
xnoremap <Leader>p "_dP

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

" Navigation {{{

" s has been used for navigating among symbols
nnoremap ]x ]s
nnoremap [x [s

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

" Make section-jump work if '{' or '}' are not in the first column (ref :h [[)
map <silent> [[ :<C-u>eval search('{', 'b')<CR>w99[{
map <silent> [] k$][%:<C-u>silent! eval search('}', 'b')<CR>
map <silent> ]] j0[[%:<C-u>silent! eval search('{')<CR>
map <silent> ][ :<C-u>silent! eval search('}')<CR>b99]}

" }}}

" Search {{{

" Clean search highlighting
nnoremap <expr> <C-BS> {-> v:hlsearch ? ":<C-U>nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>" : "\<CR>"}()

" Substitute (replace)
nnoremap <Leader>r :%s/
xnoremap <Leader>r :s/
nnoremap <Leader>R :%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>

" Make * and # search for the current selection (now using vim-asterisk instead)
" xnoremap * :<C-u>call utils#VSetSearch('/')<CR>/<C-R>=@/<CR><CR>
" xnoremap # :<C-u>call utils#VSetSearch('?')<CR>?<C-R>=@/<CR><CR>

" Grep operator (now using vim-grepper instead)
" nnoremap <silent> \g :<C-u>set operatorfunc=utils#GrepOperator<CR>g@
" xnoremap <silent> \g :<C-u>call utils#GrepOperator(visualmode())<CR>

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

" Toggle {{{

" Toggle spell checking
nnoremap <silent> <BS>S :setlocal spell! spelllang=en_us<CR>:set spell?<CR>

" Toggle wrap
nnoremap <silent> <BS>r :set wrap!<CR>:set wrap?<CR>

" Toggle relativenumber
nnoremap <silent> <BS>n :call toggle#ToggleRelativeNum()<CR>

" Toggle quickfix window
nnoremap <silent> <BS>q :call toggle#ToggleQuickFix()<CR>
nnoremap <silent> <BS>l :call toggle#ToggleLocationList()<CR>

" }}}

" Terminal {{{

" Back to normal mode in the terminal buffer
tnoremap <Esc> <C-\><C-n>

" Switching between split windows
tnoremap <C-h> <C-\><C-n><C-w>h
tnoremap <C-j> <C-\><C-n><C-w>j
tnoremap <C-k> <C-\><C-n><C-w>k
tnoremap <C-l> <C-\><C-n><C-w>l

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

" Close windows by giving the window numbers
nnoremap <Leader>wc :CloseWin<Space>

" }}}
