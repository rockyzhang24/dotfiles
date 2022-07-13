let g:VM_highlight_matches = ''
let g:VM_maps = {}
let g:VM_maps["Undo"] = 'u'
let g:VM_maps["Redo"] = '<C-r>'

" Integration with nvim-hlslens
augroup VMlens
  autocmd!
  autocmd User visual_multi_start lua require('rockyz.plugin-config.vim-visual-multi').start()
  autocmd User visual_multi_exit lua require('rockyz.plugin-config.vim-visual-multi').exit()
augroup END
