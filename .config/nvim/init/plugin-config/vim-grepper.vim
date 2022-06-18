let g:grepper = {}
let g:grepper.dir = 'repo,file'
let g:grepper.repo = ['.git', '.hg', '.svn']
let g:grepper.tools = ['rg', 'git']
let g:grepper.searchreg = 1
let g:grepper.prompt_mapping_tool = '<Leader>G'
let g:grepper.rg = {
      \ 'grepprg': 'rg -H --no-heading --vimgrep --smart-case',
      \ 'grepformat': '%f:%l:%c:%m,%f',
      \ 'escape': '\^$.*+?()[]{}|'
      \ }

" Operator
nmap gs <Plug>(GrepperOperator)
xmap gs <Plug>(GrepperOperator)

nnoremap <Leader>G :Grepper<CR>
