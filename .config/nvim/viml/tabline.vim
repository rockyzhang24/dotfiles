function! Tabline()
  let s = ''
  for i in range(tabpagenr('$'))
    let tab = i + 1
    let s .= (tab == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#')
    let s .= '%' . tab . 'T'
    let s .= ' ' . tab . ':'

    let buflist = tabpagebuflist(tab)
    let winnr = tabpagewinnr(tab)
    let bufnr = buflist[winnr - 1]
    let bufname = bufname(bufnr)
    let s .= (bufname != '' ? '['. fnamemodify(bufname, ':t') . '] ' : '[No Name] ')

    let bufmodified = getbufvar(bufnr, "&mod")
    if bufmodified
      let s .= '[+] '
    endif
  endfor

  let s .= '%#TabLineFill#'
  return s
endfunction

set tabline=%!Tabline()
