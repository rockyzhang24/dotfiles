" Change indentation for the current buffer
" `:Reindent cur_indent new_indent`, E.g., `:Reindent 2 4` for changing the
" indentation from 2 to 4
command -nargs=+ Reindent call utils#Reindent(<f-args>)
