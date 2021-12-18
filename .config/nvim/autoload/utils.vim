" Do something and preserve the state (i.e., not change the search history and cursor position)
" Reference: http://vimcasts.org/episodes/tidying-whitespace/
function! utils#Preserve(command) abort
  " Preparation: save last search, and cursor position.
  let _s=@/
  let l = line(".")
  let c = col(".")
  " Do the business:
  execute a:command
  " Clean up: restore previous search history, and cursor position
  let @/=_s
  call cursor(l, c)
endfunction

" Search for the current selection
" Reference: http://vimcasts.org/episodes/search-for-the-selected-text/
function! utils#VSetSearch(cmdtype) abort
  let temp = @s
  norm! gv"sy
  let @/ = '\V' . substitute(escape(@s, a:cmdtype.'\'), '\n', '\\n', 'g')
  let @s = temp
endfunction

" Grep operator
" Reference: https://learnvimscriptthehardway.stevelosh.com/chapters/32.html
function! utils#GrepOperator(type) abort
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

" Define abbreviation
function! utils#SetupCommandAbbrs(from, to) abort
  exec 'cnoreabbrev <expr> '.a:from
        \ .' ((getcmdtype() ==# ":" && getcmdline() ==# "'.a:from.'")'
        \ .'? ("'.a:to.'") : ("'.a:from.'"))'
endfunction

" Toggle quickfix window
function! utils#ToggleQuickFix() abort
  if getqflist({'winid' : 0}).winid
    cclose
  else
    copen
  endif
endfunction

" Toggle location list window
function! utils#ToggleLocationList() abort
  if getloclist(0, {'winid' : 0}).winid
    lclose
  else
    lopen
  endif
endfunction
