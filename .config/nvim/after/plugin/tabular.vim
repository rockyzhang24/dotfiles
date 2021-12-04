if !exists(':Tabularize')
  finish
endif

" Some predefined pattern for "the first comma", "the first colon", "the first equal"
AddTabularPattern! f, /^[^,]*\zs,/
AddTabularPattern! f: /^[^:]*\zs:/
AddTabularPattern! f= /^[^=]*\zs=/
