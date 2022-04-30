" Reference: http://vimcasts.org/episodes/fugitive-vim-browsing-the-git-object-database/
augroup fugitiveautocmd
  autocmd!

  " Use .. to go up to the parent directory if the buffer containing a git blob or tree
  autocmd User fugitive
        \ if fugitive#buffer().type() =~# '^\%(tree\|blob\)$' |
        \   nnoremap <buffer> .. :edit %:h<CR> |
        \ endif

  " Make bufferlist clean
  autocmd BufReadPost fugitive://* set bufhidden=delete

augroup END

" Mappings
" Use , as the leader key for git related stuff
nnoremap <silent> ,gs :Git<CR>
