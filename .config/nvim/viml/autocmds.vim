augroup general
  autocmd!
  " Automatically equalize splits when Vim is resized
  autocmd VimResized * wincmd =
  " Make it not be overwritten by the default setting in runtime/ftplugin
  autocmd FileType * set formatoptions-=t formatoptions-=o formatoptions+=r formatoptions+=n
  " Command-line window
  autocmd CmdWinEnter * setlocal colorcolumn=
augroup END

" Jump to the position when you last quit (:h last-position-jump)
augroup restore_cursor
  autocmd!
  autocmd BufRead * autocmd FileType <buffer> ++once
    \ let s:line = line("'\"")
    \ | if s:line >= 1 && s:line <= line("$") && &filetype !~# 'commit'
    \      && index(['xxd', 'gitrebase'], &filetype) == -1
    \ |   execute "normal! g`\""
    \ | endif
augroup END

" Disable syntax highlighting for some filetypes if they are too long
augroup syntax_off
  autocmd!
  autocmd FileType yaml if line('$') > 500 | setlocal syntax=OFF | endif
augroup END

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

" Quit vim (or close the tab) automatically if all buffers left are auxiliary
augroup auto_quit
  autocmd!
  autocmd BufEnter * call s:AutoQuit()
augroup END

" Builtin terminal
augroup terminal
  autocmd!
  autocmd TermOpen term://* startinsert
  autocmd BufWinEnter,WinEnter term://* startinsert
augroup END
