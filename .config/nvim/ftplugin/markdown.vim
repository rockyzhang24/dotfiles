" ===== Config for markdown-preview.nvim =====

packadd markdown-preview.nvim

" Open preview in a new Safari window
function OpenMarkdownPreview (url)
  execute "silent ! ~/.config/nvim/bin/md-preview " . a:url
endfunction
let g:mkdp_browserfunc = 'OpenMarkdownPreview'

nmap <buffer> <BS>p <Plug>MarkdownPreviewToggle
