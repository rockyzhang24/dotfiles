require('nvim-treesitter.configs').setup({
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['av'] = '@call.outer', -- v for invoke
        ['iv'] = '@call.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = {
        [']f'] = '@function.outer',
        [']a'] = '@parameter.inner',
        [']v'] = '@call.outer',
      },
      goto_next_end = {
      },
      goto_previous_start = {
        ['[f'] = '@function.outer',
        ['[a'] = '@parameter.inner',
        ['[v'] = '@call.outer',
      },
      goto_previous_end = {
      },
    },
  },
})
