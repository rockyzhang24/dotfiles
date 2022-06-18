let s:loaded_plugins = [
      \ 'fugitive',
      \ 'hexokinase',
      \ 'minpac',
      \ 'registers',
      \ 'startify',
      \ 'tabular',
      \ 'targets',
      \ 'undotree',
      \ 'vim-grepper',
      \ 'vim-after-object',
      \ 'vim-illuminate',
      \ 'vim-gh-line',
      \ 'vim-visual-multi',
      \ 'vim-openbrowser',
      \ ]

for s:plugin in s:loaded_plugins
  execute printf('source %s/init/plugin-config/%s.vim', stdpath('config'), s:plugin)
endfor
