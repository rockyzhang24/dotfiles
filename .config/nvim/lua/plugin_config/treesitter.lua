require'nvim-treesitter.configs'.setup {

  -- Config

  ensure_installed = "maintained",
  ignore_install = {},  -- List of parsers to ignore installing

  -- Modules

  highlight = {
    enable = true,
    disable = {"vim", }  -- List of language that will be disabled
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gsj",
      node_incremental = "gsj",
      scope_incremental = "gsJ",
      node_decremental = "gsk",
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,

      -- Builtin textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects#built-in-textobjects
      keymaps = {
        ["if"] = "@function.inner",
        ["af"] = "@function.outer",
        ["ia"] = "@parameter.inner",
        ["aa"] = "@parameter.outer",
        ["il"] = "@loop.inner",
        ["al"] = "@loop.outer",
        ["ic"] = "@conditional.inner",
        ["ac"] = "@conditional.outer",
      },
    },
    move = {
      enable = true,
      set_jump = true,
      goto_next_start = {
        ["]f"] = "@function.outer",
      },
      goto_next_end = {
        ["]F"] = "@function.outer",
      },
      goto_previous_start = {
        ["[f"] = "@function.outer",
      },
      goto_previous_end = {
        ["[F"] = "@function.outer",
      },
    },
  },
}
