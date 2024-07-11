local function pack_init()
  local plugins = {
    {
      'k-takata/minpac',
      { type = 'opt' },
    },
    'nvim-lua/plenary.nvim',
    'kyazdani42/nvim-web-devicons',
    'dstein64/vim-startuptime',
    'tpope/vim-surround',
    'tpope/vim-sleuth',
    'tpope/vim-repeat',
    'RRethy/vim-illuminate',
    'uga-rosa/ccc.nvim',
    'godlygeek/tabular',
    'mbbill/undotree',
    'mhinz/vim-grepper',
    'haya14busa/vim-asterisk',
    'tommcdo/vim-exchange',
      -- cx{motion}, cxx (line), X (visual), cxc (clear), and `.` is supported
    'othree/eregex.vim',
    'wellle/targets.vim',
    'unblevable/quick-scope',
    'danymat/neogen',
    'stevearc/conform.nvim',
    'Wansmer/treesj',
    'willothy/flatten.nvim',
    'michaeljsmith/vim-indent-object',
      -- ii for inner indentation, ai for indentation and one line above, aI for indentation and
      -- lines above and below
    'preservim/tagbar',

    -- Fuzzy Finder
    {
      'junegunn/fzf',
      { ['do'] = 'packloadall! | call fzf#install()' },
    },
    'junegunn/fzf.vim',
    'nvim-telescope/telescope.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      { ['do'] = 'make' },
    },
    'ibhagwan/fzf-lua',

    -- LSP
    'neovim/nvim-lspconfig',
    'SmiteshP/nvim-navic',
    'smjonas/inc-rename.nvim',
    'b0o/SchemaStore.nvim',
    'stevearc/aerial.nvim',

    -- Autocomplete
    'hrsh7th/nvim-cmp',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',

    -- Snippets
    {
      'L3MON4D3/LuaSnip',
      { ['do'] = 'make install_jsregexp' },
    },
    'saadparwaiz1/cmp_luasnip',

    -- Treesitter
    {
      'nvim-treesitter/nvim-treesitter',
      { ['do'] = 'TSUpdate' },
    },
    'nvim-treesitter/nvim-treesitter-textobjects',
    'mizlan/iswap.nvim',
    'm-demare/hlargs.nvim',

    -- Git
    'lewis6991/gitsigns.nvim',
    'tpope/vim-fugitive',
    'tpope/vim-rhubarb', -- :GBrowse
    'rbong/vim-flog',
  }

  vim.cmd.packadd('minpac')
  vim.fn['minpac#init']({
    progress_open = 'vertical',
    status_open = 'vertical',
    status_auto = true,
  })

  for _, plugin in ipairs(plugins) do
    if type(plugin) == 'string' then
      vim.fn['minpac#add'](plugin)
    else
      vim.fn['minpac#add'](unpack(plugin))
    end
  end
end

local old_git_dir = nil
local old_work_tree = nil

local function store_old_envs()
  old_git_dir = vim.env.GIT_DIR
  old_work_tree = vim.env.GIT_WORK_TREE
  vim.env.GIT_DIR = nil
  vim.env.GIT_WORK_TREE = nil
end

local function restore_envs()
  vim.env.GIT_DIR = old_git_dir
  vim.env.GIT_WORK_TREE = old_work_tree
end

-- Install/update plugins
vim.api.nvim_create_user_command('PluginUpdate', function()
  store_old_envs()
  pack_init()
  vim.fn['minpac#update']('', {
    ['do'] = function()
      restore_envs()
    end
  })
end, { bang = true })

-- Delete plugins
vim.api.nvim_create_user_command('PluginDelete', function()
  store_old_envs()
  pack_init()
  vim.fn['minpac#clean']()
  restore_envs()
end, { bang = true })
