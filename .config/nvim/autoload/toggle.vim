" Toggle quickfix window
function! toggle#ToggleQuickFix() abort
  if getqflist({'winid' : 0}).winid
    cclose
  else
    copen
  endif
endfunction

" Toggle location list window
function! toggle#ToggleLocationList() abort
  if getloclist(0, {'winid' : 0}).winid
    lclose
  else
    lopen
  endif
endfunction

" Toggle relativenumber
function! toggle#ToggleRelativeNum() abort
  if &relativenumber
    set norelativenumber
  else
    set relativenumber
  endif
endfunction
