" Reference: https://gist.github.com/romainl/eae0a260ab9c135390c30cd370c20cd7

function! Redir(cmd = '', rng = 0, start = 1, end = 1, bang = '')
    let cmd = a:cmd->trim()
    for win in range(1, winnr('$'))
        if getwinvar(win, 'scratch')
            execute win . 'windo close'
        endif
    endfor
    if a:bang == '!' && cmd->empty()
        let cmd = expand(@:)->trim()
    endif
    if cmd =~ '^!'
        let ext_cmd = cmd =~' %'
            \ ? matchstr(substitute(cmd, ' %', ' ' . shellescape(escape(expand('%:p'), '\')), ''), '^!\zs.*')
            \ : matchstr(cmd, '^!\zs.*')
        if a:rng == 0
            let output = systemlist(ext_cmd)
        else
            let joined_lines = join(getline(a:start, a:end), '\n')
            let cleaned_lines = substitute(shellescape(joined_lines), "'\\\\''", "\\\\'", 'g')
            let output = systemlist(ext_cmd . " <<< $" . cleaned_lines)
        endif
    else
        redir => output
        execute a:cmd
        redir END
        let output = split(output, "\n")
    endif
    vnew
    let w:scratch = 1
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
    call setline(1, output)
endfunction

" This command definition includes -bar, so that it is possible to "chain" Vim commands.
" Side effect: double quotes can't be used in external commands
"command! -nargs=? -complete=command -bar -range -bang Redir silent call Redir(<q-args>, <range>, <line1>, <line2>, '<bang>')

" This command definition doesn't include -bar, so that it is possible to use double quotes in external commands.
" Side effect: Vim commands can't be "chained".
command! -nargs=? -complete=command -range -bang Redir silent call Redir(<q-args>, <range>, <line1>, <line2>, '<bang>')
