" ===== Config for markdown-preview.nvim =====

packadd markdown-preview.nvim

" Open preview in a new Safari window
" safari is executable defined in ~/.config/bin/safari
function OpenMarkdownPreview (url)
  execute "silent ! safari " . a:url
endfunction
let g:mkdp_browserfunc = 'OpenMarkdownPreview'

nmap \m <Plug>MarkdownPreviewToggle
