" I want the filetype "term" for terminal windows
augroup nvim_terminal
  autocmd!
  autocmd TermOpen term://*  set filetype=term
augroup END
