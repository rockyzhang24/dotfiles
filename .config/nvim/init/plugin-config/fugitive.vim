" Reference: http://vimcasts.org/episodes/fugitive-vim-browsing-the-git-object-database/
augroup fugitiveCustom
  autocmd!

  " Use .. to go up to the parent directory if the buffer containing a git blob or tree
  autocmd User fugitive
        \ if fugitive#buffer().type() =~# '^\%(tree\|blob\)$' |
        \   nnoremap <buffer> .. :edit %:h<CR> |
        \ endif

  " Make bufferlist clean
  autocmd BufReadPost fugitive://* set bufhidden=delete

  autocmd User FugitiveIndex,FugitiveCommit nmap <silent><buffer> dt :Gtabedit <Plug><cfile><Bar>Gdiffsplit! @<CR>

augroup END

" Mappings
nnoremap <silent> ,gs :Git<CR>
nnoremap <silent> ,gd :Gdiffsplit<CR>
nnoremap <silent> ,gc :Git commit<CR>
nnoremap <silent> ,ge :Gedit<CR>
nnoremap <silent> ,gr :Gread<CR>
nnoremap <silent> ,gw :Gwrite<CR>
nnoremap <silent> ,gb :Git blame<CR>
nnoremap <silent> ,g, :diffget //2<CR>
nnoremap <silent> ,g. :diffget //3<CR>
