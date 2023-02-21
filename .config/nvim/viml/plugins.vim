" Minpac plugin manager
function! PackInit() abort
  packadd minpac
  call minpac#init({'progress_open': 'vertical', 'status_open': 'vertical', 'status_auto': 'TRUE'})

  call minpac#add('k-takata/minpac', {'type': 'opt'})
  call minpac#add('nvim-lua/plenary.nvim')  " lua library used by other lua plugins
  call minpac#add('numToStr/Comment.nvim')
  call minpac#add('tpope/vim-surround')
  call minpac#add('tpope/vim-sleuth')
  call minpac#add('tpope/vim-repeat')
  call minpac#add('RRethy/vim-illuminate')
  call minpac#add('NvChad/nvim-colorizer.lua')
  call minpac#add('godlygeek/tabular')
  call minpac#add('mbbill/undotree')
  call minpac#add('yanzhang0219/lualine.nvim')
  call minpac#add('junegunn/fzf', { 'do': 'packloadall! | call fzf#install()' })  " as a filter for bqf
  call minpac#add('mhinz/vim-grepper')
  call minpac#add('haya14busa/vim-asterisk')
  call minpac#add('tommcdo/vim-exchange') " cx{motion}, cxx (line), X (visual), cxc (clear), `.` is supported
  call minpac#add('tversteeg/registers.nvim')
  call minpac#add('ThePrimeagen/harpoon')
  call minpac#add('ahmedkhalf/project.nvim')
  call minpac#add('kevinhwang91/nvim-fFHighlight')
  call minpac#add('kevinhwang91/nvim-hlslens')
  call minpac#add('kevinhwang91/nvim-bqf')
  call minpac#add('kevinhwang91/nvim-ufo')
  call minpac#add('kevinhwang91/promise-async') " required by kevin's plugins
  call minpac#add('lukas-reineke/indent-blankline.nvim')

  " Telescope
  call minpac#add('nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' })  " sorter for telescope
  call minpac#add('nvim-telescope/telescope.nvim')

  " Text object
  call minpac#add('junegunn/vim-after-object')
  call minpac#add('michaeljsmith/vim-indent-object')
  call minpac#add('wellle/targets.vim')

  " LSP
  call minpac#add('neovim/nvim-lspconfig')

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
  call minpac#add('nvim-treesitter/playground')
  call minpac#add('nvim-treesitter/nvim-treesitter-textobjects')
  call minpac#add('JoosepAlviste/nvim-ts-context-commentstring')
  call minpac#add('mizlan/iswap.nvim')

  " Git
  call minpac#add('lewis6991/gitsigns.nvim')
  call minpac#add('tpope/vim-fugitive')
  call minpac#add('tpope/vim-rhubarb')  " vim-fugitive's companion for :GBrowse
  call minpac#add('ruanyl/vim-gh-line')

  " Markdown
  call minpac#add('iamcco/markdown-preview.nvim', {'type': 'opt', 'do': 'packadd markdown-preview.nvim | call mkdp#util#install()'}) " config at ftplugin/markdown.vim

  " Icons
  call minpac#add('kyazdani42/nvim-web-devicons')

  " Color schemes
  call minpac#add('rktjmp/lush.nvim')
  call minpac#add('rockyzhang24/arctic.nvim')
  call minpac#add('folke/tokyonight.nvim')
  call minpac#add('dracula/vim', { 'name': 'dracula' })
  call minpac#add('EdenEast/nightfox.nvim')

  " Test

endfunction
