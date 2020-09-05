" Implement a Grep Operator which can be used with any of Vim's built-in or custom motions to
" select the text you want to search for.

" Reference: https://learnvimscriptthehardway.stevelosh.com/chapters/32.html

nnoremap <leader>G :set operatorfunc=<SID>GrepOperator<cr>g@
vnoremap <leader>G :<c-u>call <SID>GrepOperator(visualmode())<cr>

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
