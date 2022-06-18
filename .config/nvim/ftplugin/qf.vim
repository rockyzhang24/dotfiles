setlocal scrolloff=2
setlocal colorcolumn=

" Run substitute for each entry
nnoremap <buffer> r :cdo s///gc<Left><Left><Left>
nnoremap <buffer> qa <Cmd>q<CR><Cmd>qa<CR>
