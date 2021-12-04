" Toggle the preview window (supported by vim-instant-markdown)
let s:isOpen = 0
function! markdown#TogglePreview() abort
  if !s:isOpen
    InstantMarkdownPreview
  else
    InstantMarkdownStop
  endif
  let s:isOpen = !s:isOpen
endfunction
