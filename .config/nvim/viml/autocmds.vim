augroup general
  autocmd!
  " Jump to the position when you last quit
  autocmd BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line("$") && &filetype !~# 'commit\|rebase' |
        \   exe "normal! g'\"" |
        \ endif
  " Automatically equalize splits when Vim is resized
  autocmd VimResized * wincmd =
  " Make it not be overwritten by the default setting of neovim
  autocmd FileType * set formatoptions-=t formatoptions-=o formatoptions-=r textwidth=80
  " Command-line window
  autocmd CmdWinEnter * setlocal colorcolumn=
augroup END

" Highlight selection on yank
augroup highlight_yank
  autocmd!
  autocmd TextYankPost * silent! lua vim.highlight.on_yank({higroup="Substitute", timeout=300})
augroup END

" Disable syntax highlighting for some filetypes if they are too long
augroup syntax_off
  autocmd!
  autocmd FileType yaml if line('$') > 500 | setlocal syntax=OFF | endif
augroup END

" Quit vim (or close the tab) automatically if all buffers left are auxiliary
function! s:AutoQuit() abort
  let l:filetypes = ['aerial', 'NvimTree', 'neo-tree', 'tsplayground', 'query']
  let l:tabwins = nvim_tabpage_list_wins(0)
  for w in l:tabwins
    let l:buf = nvim_win_get_buf(w)
    let l:buf_ft = getbufvar(l:buf, '&filetype')
    if index(l:filetypes, buf_ft) == -1
      return
    endif
  endfor
  call s:Quit()
endfunction

function! s:Quit() abort
  if tabpagenr('$') > 1
    tabclose
  else
    qall
  endif
endfunction

augroup auto_quit
  autocmd!
  autocmd BufEnter * call s:AutoQuit()
augroup END

" Builtin terminal
augroup terminal
  autocmd!
  autocmd TermOpen term://* startinsert
  autocmd BufWinEnter,WinEnter term://* startinsert
augroup END

" I manage my dotfiles using a bare repository. To make Vim recognize them and git related plugins
" work on them, the environment variables should be set to indicate the locations of git-dir and
" work-tree when we enter the dotfile buffer. Don't forget to reset them when we enter other buffers,
" otherwise the normal repository will not be recognized.
function! s:SetGitEnv() abort
  let cur_file = expand('%')
  " Only set the Git env for the buffer containing a real file
  if !filereadable(cur_file)
    return
  endif
  let git_dir = expand('~/dotfiles')
  let work_tree = expand('~')
  let jib = jobstart(["git", "--git-dir", git_dir, "--work-tree", work_tree, "ls-files", "--error-unmatch", cur_file])
  let ret = jobwait([jib])[0]
  if ret == 0
    let $GIT_DIR = git_dir
    let $GIT_WORK_TREE = work_tree
  else
    unlet $GIT_DIR
    unlet $GIT_WORK_TREE
  endif
endfunction

augroup personal
  autocmd!
  autocmd BufNewFile,BufRead,BufEnter * call s:SetGitEnv()
augroup END
