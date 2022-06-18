let g:targets_seekRanges = 'cc cr cb cB lc ac Ac lr lb ar ab lB Ar aB Ab AB rr ll rb al rB Al bb aa bB Aa BB AA'
let g:targets_jumpRanges = g:targets_seekRanges

augroup define_object
  autocmd User targets#mappings#user call targets#mappings#extend({
        \ 'a': {},
        \ })
augroup END
