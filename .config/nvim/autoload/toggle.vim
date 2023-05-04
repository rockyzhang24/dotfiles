" Toggle relativenumber
function! toggle#ToggleRelativeNum() abort
  if &relativenumber
    set norelativenumber
  else
    set relativenumber
  endif
endfunction
