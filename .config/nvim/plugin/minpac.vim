function! s:PluginUpdate() abort
  " Unset the Git env to avoid git errors caused by minpac#update()
  unlet $GIT_DIR
  unlet $GIT_WORK_TREE
  call minpac#update()
endfunction

command! PluginUpdate source $MYVIMRC | call PackInit() | call s:PluginUpdate()
command! PluginDelete source $MYVIMRC | call PackInit() | call minpac#clean()

call abbr#SetupCommandAbbrs('pu', 'PluginUpdate')
call abbr#SetupCommandAbbrs('pd', 'PluginDelete')
