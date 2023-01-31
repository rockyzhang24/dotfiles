let g:colorscheme = "arctic"
let g:transparent = 1

set termguicolors
set background=dark

if g:colorscheme ==# 'tokyonight'
  let g:tokyonight_style = 'night'
  augroup custom
    autocmd!
    autocmd ColorScheme tokyonight highlight WinSeparator guifg=#565f89
    autocmd ColorScheme tokyonight highlight FloatBorder guibg=#1a1b26
    autocmd ColorScheme tokyonight highlight Folded guibg=#342e4f
  augroup END

elseif g:colorscheme ==# 'nightfox'
  lua require('rockyz.plugin-config.nightfox')
endif

execute 'colorscheme ' . g:colorscheme

if g:transparent && $WEZTERM_CONFIG_DIR != ""
  highlight Normal guibg=NONE
endif
