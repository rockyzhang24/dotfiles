let g:Hexokinase_highlighters = ['backgroundfull']
let g:Hexokinase_optInPatterns = 'full_hex,triple_hex,rgb,rgba,hsl,hsla'
let g:Hexokinase_ftOptInPatterns = {
      \ 'css': 'full_hex,triple_hex,rgb,rgba,hsl,hsla,colour_names',
      \ 'html': 'full_hex,triple_hex,rgb,rgba,hsl,hsla,colour_names'
      \ }
let g:Hexokinase_ftDisabled = ['minpac']

" Toggle
nnoremap <BS>C :HexokinaseToggle<CR>
