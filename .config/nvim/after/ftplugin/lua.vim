" Make lua module path can be recognized and be opened via `gf`
setlocal includeexpr=substitute(v:fname,'\\.','/','g')
setlocal suffixesadd^=.lua
setlocal suffixesadd^=init.lua
let &l:path .= ','.stdpath('config').'/lua'

" Omnifunc for completing lua values similar to the builtin completion for :lua
" command (introduced in Neovim v0.9)
setlocal omnifunc=v:lua.vim.lua_omnifunc
