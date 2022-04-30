" Text object surrounded by any opening and closing characters can be customized
" Ref: https://github.com/wellle/targets.vim#targetsmappingsextend
augroup define_object
  autocmd User targets#mappings#user call targets#mappings#extend({
        \ 'a': {'argument': [{'o':'(', 'c':')', 's': ','}]}
        \ })
augroup END
