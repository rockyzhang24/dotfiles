" Wilder is activated by default but / and ? conflict with vm-regex-search (\\/) in
" vim-visual-multi. The optional workarounds are
" - Set enable_cmdline_enter = 0 to make wilder not activate automatically, and
"   then press <Tab> will actvate it.
" - Or actually I don't need wilder to take over / and ?, so I removed them from
"   modes.
" Set keymaps to be consitent with nvim-cmp
call wilder#setup({
      \ 'modes': [':'],
      \ 'enable_cmdline_enter': 1,
      \ 'accept_key': '<C-y>',
      \ 'reject_key': '<C-e>',
      \ })

" A helper function
function! s:shouldDisable(x)
  let l:cmd = wilder#cmdline#parse(a:x).cmd
  return l:cmd ==# 'Man' || a:x =~# 'Git fetch origin '
endfunction

" Use fuzzy matching instead of substring matching (file completion is supported
" as well)
" NOTE: The completion process for some commands like `Man` take a while and it
" is synchronously, so Neovim will block. We should check this and disable
" wilder for these commands, and Neovim's builtin wildmenu will be used as the
" fallback (Ref: https://github.com/gelguy/wilder.nvim/issues/107)
call wilder#set_option('pipeline', [
      \   wilder#branch(
      \     [
      \       wilder#check({-> getcmdtype() ==# ':'}),
      \       {ctx, x -> s:shouldDisable(x) ? v:true : v:false},
      \     ],
      \     wilder#python_file_finder_pipeline({
      \       'file_command': {_, arg -> arg[0] ==# '.' ? ['rg', '--files', '--hidden'] : ['rg', '--files']},
      \       'dir_command': {_, arg -> arg[0] ==# '.' ? ['fd', '-tf', '-H'] : ['fd', '-tf']},
      \       'filters': ['fuzzy_filter', 'difflib_sorter'],
      \     }),
      \     wilder#cmdline_pipeline({
      \       'language': 'python',
      \       'fuzzy': 1,
      \     }),
      \     wilder#python_search_pipeline({
      \       'pattern': wilder#python_fuzzy_pattern(),
      \       'sorter': wilder#python_difflib_sorter(),
      \       'engine': 're2',
      \     }),
      \   ),
      \ ])

" Customize the appearance
" Use popupmenu for command and wildmenu for search
call wilder#set_option('renderer', wilder#renderer_mux({
      \ ':': wilder#popupmenu_renderer(wilder#popupmenu_border_theme({
      \   'highlighter': wilder#basic_highlighter(),
      \   'border': 'rounded',
      \   'max_height': 15,
      \   'highlights': {
      \     'border': 'Normal',
      \     'default': 'Normal',
      \     'accent': wilder#make_hl('PopupmenuAccent', 'Normal', [{}, {}, {'foreground': '#f4468f'}]),
      \   },
      \   'left': [
      \     ' ', wilder#popupmenu_devicons(),
      \   ],
      \   'right': [
      \     ' ', wilder#popupmenu_scrollbar(),
      \   ],
      \ })),
      \
      \ '/': wilder#wildmenu_renderer({
      \   'highlighter': wilder#basic_highlighter(),
      \   'highlights': {
      \     'accent': wilder#make_hl('WildmenuAccent', 'StatusLine', [{}, {}, {'foreground': '#f4468f'}]),
      \   },
      \ }),
      \ }))
