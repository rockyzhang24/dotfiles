if g:colorscheme ==# 'tokyonight'
  let g:tokyonight_style = 'night'
  autocmd ColorScheme tokyonight highlight WinSeparator guifg=#565f89
  autocmd ColorScheme tokyonight highlight FloatBorder guibg=#1a1b26
  autocmd ColorScheme tokyonight highlight Folded guibg=#342e4f

elseif g:colorscheme ==# 'nightfox'
  lua require('rockyz.plugin-config.nightfox')
endif

execute 'colorscheme ' . g:colorscheme
