require'nvim-treesitter.configs'.setup {

  -- nvim-treesitter config

  ensure_installed = "maintained",
  ignore_install = {},  -- List of parsers to ignore installing

  -- Modules

  highlight = {
    enable = true,
    disable = {}  -- List of language that will be disabled
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
      },
    },
    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = {
        ["]f"] = "@function.outer",
        ["]a"] = "@parameter.inner",
      },
      goto_next_end = {
        ["]F"] = "@function.outer",
      },
      goto_previous_start = {
        ["[f"] = "@function.outer",
        ["[a"] = "@parameter.inner",
      },
      goto_previous_end = {
        ["[F"] = "@function.outer",
      },
    },
  },
  context_commentstring = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<M-w>",
      node_incremental = "<M-w>",
      node_decremental = "<M-C-w>",
      scope_incremental = "<M-e>",
    },
  },
}
