require('nvim-treesitter.configs').setup({
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = {
        [']c'] = '@class.outer',
        [']f'] = '@function.outer',
        [']a'] = '@parameter.inner',
      },
      goto_next_end = {
        [']C'] = '@class.outer',
        [']F'] = '@function.outer',
        [']A'] = '@parameter.inner',
      },
      goto_previous_start = {
        ['[c'] = '@class.outer',
        ['[f'] = '@function.outer',
        ['[a'] = '@parameter.inner',
      },
      goto_previous_end = {
        ['[C'] = '@class.outer',
        ['[F'] = '@function.outer',
        ['[A'] = '@parameter.inner',
      },
    },
  },
})
