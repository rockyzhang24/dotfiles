if !exists(':Tabularize')
    finish
endif

" Predefined patterns, e.g., `:Tabularize f:`
" f, first comma
" f: first colon
" f= first equal sign
AddTabularPattern! f, /^[^,]*\zs,/
AddTabularPattern! f: /^[^:]*\zs:/
AddTabularPattern! f= /^[^=]*\zs=/
