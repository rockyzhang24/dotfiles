" Do something and preserve the state (i.e., not change the search history and cursor position)
" Ref: http://vimcasts.org/episodes/tidying-whitespace/
" @Param: command - the cmdline command to be executed
" @Param: ... - visual mode type, i.e., the return of visualmode()
function! utils#Preserve(command, ...) abort
    " Pre-processing: save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")
    " Do the business:
    if a:0 == 1
        if a:1 ==# 'V'
            execute "normal! `<V`>:" . a:command . "\<CR>"
        elseif a:1 ==# 'v'
            execute "normal! `<v`>:" . a:command . "\<CR>"
        endif
    else
        execute a:command
    endif
    " Clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
endfunction

" Grep operator
" Ref: https://learnvimscriptthehardway.stevelosh.com/chapters/32.html
function! utils#GrepOperator(type) abort
    let saved_unnamed_register = @@
    if a:type ==# 'v'
        normal! `<v`>y
    elseif a:type ==# 'char'
        normal! `[v`]y
    else
        return
    endif
    silent execute "grep! " . shellescape(@@) . " ."
    copen
    let @@ = saved_unnamed_register
endfunction
