let g:startify_lists = [
      \ { 'type': 'files',     'header': ['   MRU']            },
      \ { 'type': 'dir',       'header': ['   MRU '. getcwd()] },
      \ { 'type': 'sessions',  'header': ['   Sessions']       },
      \ { 'type': 'bookmarks', 'header': ['   Bookmarks']      },
      \ { 'type': 'commands',  'header': ['   Commands']       },
      \ ]

" Make vim-rooter works when a file is opened from startify
let g:startify_change_to_dir = 0

" Filter MRU files
let g:startify_skiplist = [
      \ 'tmp\..*',
      \ 'COMMIT_EDITMSG',
      \ ]

let g:startify_update_oldfiles = 1

" Devicons
lua << EOF
function _G.webDevIcons(path)
  local filename = vim.fn.fnamemodify(path, ':t')
  local extension = vim.fn.fnamemodify(path, ':e')
  return require'nvim-web-devicons'.get_icon(filename, extension, { default = true })
end
EOF

function! StartifyEntryFormat() abort
  return 'v:lua.webDevIcons(absolute_path) . " " . entry_path'
endfunction

" Header
let g:ascii = [
      \ ' _____  ___    _______    ______  ___      ___  __     ___      ___ ',
      \ '(\"   \|"  \  /"     "|  /    " \|"  \    /"  ||" \   |"  \    /"  |',
      \ '|.\\   \    |(: ______) // ____  \\   \  //  / ||  |   \   \  //   |',
      \ '|: \.   \\  | \/    |  /  /    ) :)\\  \/. ./  |:  |   /\\  \/.    |',
      \ '|.  \    \. | // ___)_(: (____/ //  \.    //   |.  |  |: \.        |',
      \ '|    \    \ |(:      "|\        /    \\   /    /\  |\ |.  \    /:  |',
      \ ' \___|\____\) \_______) \"_____/      \__/    (__\_|_)|___|\__/|___|',
      \ ]

let g:startify_custom_header = 'startify#pad(g:ascii + startify#fortune#boxed())'

" Enable cursorline
augroup starity
  autocmd User Startified setlocal cursorline
augroup END

" Go to the Startify buffer
nnoremap <silent> <Leader>bh :Startify<CR>

" Session management
nnoremap <silent> <Leader>Ss :SSave<CR>
nnoremap <silent> <Leader>Sl :SLoad<CR>
nnoremap <silent> <Leader>Sc :SClose<CR>
nnoremap <silent> <Leader>Sd :SDelete<CR>
