function! s:PackInit() abort
  packadd minpac
  call minpac#init({'progress_open': 'vertical', 'status_open': 'vertical', 'status_auto': 'TRUE'})

  call minpac#add('k-takata/minpac', {'type': 'opt'})
  call minpac#add('editorconfig/editorconfig-vim')
  call minpac#add('dstein64/vim-startuptime')
  call minpac#add('nvim-lua/plenary.nvim')  " lua library required by other plugins
  call minpac#add('rockyzhang24/harpoon')
  call minpac#add('tpope/vim-surround')
  call minpac#add('tpope/vim-sleuth')
  call minpac#add('tpope/vim-repeat')
  call minpac#add('RRethy/vim-illuminate')
  call minpac#add('uga-rosa/ccc.nvim')
  call minpac#add('godlygeek/tabular')
  call minpac#add('mbbill/undotree')
  call minpac#add('mhinz/vim-grepper')
  call minpac#add('haya14busa/vim-asterisk')
  call minpac#add('tommcdo/vim-exchange') " cx{motion}, cxx (line), X (visual), cxc (clear), and `.` is supported
  call minpac#add('kevinhwang91/nvim-bqf')
  call minpac#add('othree/eregex.vim')
  call minpac#add('wellle/targets.vim')
  call minpac#add('unblevable/quick-scope')
  call minpac#add('danymat/neogen')
  call minpac#add('stevearc/conform.nvim')
  call minpac#add('Wansmer/treesj')
  call minpac#add('willothy/flatten.nvim')

  " Fuzzy Finder
  call minpac#add('junegunn/fzf', { 'do': 'packloadall! | call fzf#install()' })
  call minpac#add('junegunn/fzf.vim')
  call minpac#add('nvim-telescope/telescope.nvim')
  call minpac#add('nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' })  " sorter for telescope
  call minpac#add('ahmedkhalf/project.nvim')

  " LSP
  call minpac#add('neovim/nvim-lspconfig')
  call minpac#add('SmiteshP/nvim-navic')
  call minpac#add('smjonas/inc-rename.nvim')
  call minpac#add('b0o/SchemaStore.nvim')

  " Autocomplete
  call minpac#add('hrsh7th/nvim-cmp')
  call minpac#add('hrsh7th/cmp-nvim-lsp')
  call minpac#add('hrsh7th/cmp-buffer')
  call minpac#add('hrsh7th/cmp-path')
  call minpac#add('hrsh7th/cmp-cmdline')

  " Snippets
  call minpac#add('L3MON4D3/LuaSnip', { 'do': 'make install_jsregexp' })
  call minpac#add('saadparwaiz1/cmp_luasnip')

  " Treesitter
  call minpac#add('nvim-treesitter/nvim-treesitter', { 'do': 'TSUpdate' })
  call minpac#add('nvim-treesitter/nvim-treesitter-textobjects')
  call minpac#add('mizlan/iswap.nvim')
  call minpac#add('m-demare/hlargs.nvim')

  " Git
  call minpac#add('lewis6991/gitsigns.nvim')
  call minpac#add('tpope/vim-fugitive')
  call minpac#add('tpope/vim-rhubarb')  " vim-fugitive's companion for :GBrowse
  call minpac#add('rbong/vim-flog')

  " Icons
  call minpac#add('kyazdani42/nvim-web-devicons')

endfunction

" Config for minpac
function! s:PluginUpdate() abort
  unlet $GIT_DIR
  unlet $GIT_WORK_TREE
  call minpac#update()
endfunction

command! PluginUpdate source $MYVIMRC | call s:PackInit() | call s:PluginUpdate()
command! PluginDelete source $MYVIMRC | call s:PackInit() | call minpac#clean()
