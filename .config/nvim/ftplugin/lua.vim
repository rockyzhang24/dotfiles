" Make lua module path can be recognized and be opened via `gf`
setlocal includeexpr=substitute(v:fname,'\\.','/','g')
setlocal suffixesadd^=.lua
setlocal suffixesadd^=init.lua
let &l:path .= ','.stdpath('config').'/lua'
