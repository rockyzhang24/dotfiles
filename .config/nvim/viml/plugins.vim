function! s:PackInit() abort
  packadd minpac
  call minpac#init({'progress_open': 'vertical', 'status_open': 'vertical', 'status_auto': 'TRUE'})

  call minpac#add('k-takata/minpac', {'type': 'opt'})
  call minpac#add('dstein64/vim-startuptime')
  call minpac#add('nvim-lua/plenary.nvim')  " lua library required by other plugins
  call minpac#add('rockyzhang24/lualine.nvim')
  call minpac#add('rockyzhang24/harpoon')
  call minpac#add('numToStr/Comment.nvim')
  call minpac#add('tpope/vim-surround')
  call minpac#add('tpope/vim-sleuth')
  call minpac#add('tpope/vim-repeat')
  call minpac#add('RRethy/vim-illuminate')
  call minpac#add('NvChad/nvim-colorizer.lua')
  call minpac#add('godlygeek/tabular')
  call minpac#add('mbbill/undotree')
  call minpac#add('mhinz/vim-grepper')
  call minpac#add('haya14busa/vim-asterisk')
  call minpac#add('tommcdo/vim-exchange') " cx{motion}, cxx (line), X (visual), cxc (clear), and `.` is supported
  call minpac#add('tversteeg/registers.nvim')
  call minpac#add('kevinhwang91/nvim-hlslens')
  call minpac#add('kevinhwang91/nvim-bqf')
  call minpac#add('kevinhwang91/nvim-ufo')
  call minpac#add('kevinhwang91/nvim-fundo')
  call minpac#add('kevinhwang91/promise-async') " required by kevin's plugins
  call minpac#add('lukas-reineke/indent-blankline.nvim')
  call minpac#add('othree/eregex.vim')
  call minpac#add('MunifTanjim/nui.nvim') " required by other plugins like nvim-navbuddy
  call minpac#add('andymass/vim-matchup')
  call minpac#add('wellle/targets.vim')
  call minpac#add('unblevable/quick-scope')
  call minpac#add('danymat/neogen')
  call minpac#add('stevearc/oil.nvim')
  call minpac#add('stevearc/conform.nvim')
  call minpac#add('stevearc/dressing.nvim')
  call minpac#add('Wansmer/treesj')
  call minpac#add('willothy/flatten.nvim')

  " Fuzzy Finder
  call minpac#add('junegunn/fzf', { 'do': 'packloadall! | call fzf#install()' })
  call minpac#add('junegunn/fzf.vim')
  call minpac#add('nvim-telescope/telescope.nvim')
  call minpac#add('nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' })  " sorter for telescope
  call minpac#add('ahmedkhalf/project.nvim')
  call minpac#add('LukasPietzschmann/telescope-tabs')

  " LSP
  call minpac#add('neovim/nvim-lspconfig')
  call minpac#add('SmiteshP/nvim-navic')
  call minpac#add('SmiteshP/nvim-navbuddy')
  call minpac#add('smjonas/inc-rename.nvim')
  call minpac#add('b0o/SchemaStore.nvim')

  " Autocomplete
  call minpac#add('hrsh7th/nvim-cmp')
  call minpac#add('hrsh7th/cmp-nvim-lsp')
  call minpac#add('hrsh7th/cmp-buffer')
  call minpac#add('hrsh7th/cmp-path')
  call minpac#add('hrsh7th/cmp-cmdline')
  call minpac#add('hrsh7th/cmp-nvim-lua')
  call minpac#add('onsails/lspkind.nvim')

  " Snippets
  call minpac#add('L3MON4D3/LuaSnip')
  call minpac#add('saadparwaiz1/cmp_luasnip')

  " Treesitter
  call minpac#add('nvim-treesitter/nvim-treesitter', {'do': 'TSUpdate'})
  call minpac#add('nvim-treesitter/nvim-treesitter-textobjects')
  call minpac#add('JoosepAlviste/nvim-ts-context-commentstring')
  call minpac#add('mizlan/iswap.nvim')
  call minpac#add('m-demare/hlargs.nvim')
  call minpac#add('nvim-treesitter/nvim-treesitter-context')

  " Git
  call minpac#add('lewis6991/gitsigns.nvim')
  call minpac#add('tpope/vim-fugitive')
  call minpac#add('tpope/vim-rhubarb')  " vim-fugitive's companion for :GBrowse
  call minpac#add('ruanyl/vim-gh-line')
  call minpac#add('rbong/vim-flog')

  " Icons
  call minpac#add('kyazdani42/nvim-web-devicons')

  " Color schemes
  call minpac#add('folke/tokyonight.nvim')
  call minpac#add('dracula/vim', { 'name': 'dracula' })
  call minpac#add('EdenEast/nightfox.nvim')

endfunction

" Config for minpac
function! s:PluginUpdate() abort
  unlet $GIT_DIR
  unlet $GIT_WORK_TREE
  call minpac#update()
endfunction

command! PluginUpdate source $MYVIMRC | call s:PackInit() | call s:PluginUpdate()
command! PluginDelete source $MYVIMRC | call s:PackInit() | call minpac#clean()
