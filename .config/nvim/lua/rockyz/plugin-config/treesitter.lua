require 'nvim-treesitter.configs'.setup {

  ensure_installed = 'all',
  ignore_install = { 'phpdoc' },

  highlight = {
    enable = true,
    disable = { 'vim' },
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
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
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
  playground = {
    enable = true,
  },
  -- nvim-ts-rainbow
  rainbow = {
    enable = true,
    extended_mode = true,
    max_file_lines = 1000,
  }

}
