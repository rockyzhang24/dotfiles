if !exists(':Tabularize')
  finish
endif

" Some predefined pattern for "the first comma", "the first colon", "the first equal"
" E.g., `:Tabularize f:`
AddTabularPattern! f, /^[^,]*\zs,/
AddTabularPattern! f: /^[^:]*\zs:/
AddTabularPattern! f= /^[^=]*\zs=/
