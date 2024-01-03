-- k for class (c, l, a and s have been occupied already)
-- a for parameter (argument)
-- i for condition (if)
-- o for loop

require('nvim-treesitter.configs').setup({
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ['ak'] = '@class.outer',
        ['ik'] = '@class.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['ai'] = '@conditional.outer',
        ['ii'] = '@conditional.inner',
        ['ao'] = '@loop.outer',
        ['io'] = '@loop.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = {
        [']k'] = '@class.outer',
        [']f'] = '@function.outer',
        [']a'] = '@parameter.inner',
        [']i'] = '@conditional.outer',
        [']o'] = '@loop.outer',
      },
      goto_next_end = {
        [']K'] = '@class.outer',
        [']F'] = '@function.outer',
        [']A'] = '@parameter.inner',
        [']I'] = '@conditional.outer',
        [']O'] = '@loop.outer',
      },
      goto_previous_start = {
        ['[k'] = '@class.outer',
        ['[f'] = '@function.outer',
        ['[a'] = '@parameter.inner',
        ['[i'] = '@conditional.outer',
        ['[o'] = '@loop.outer',
      },
      goto_previous_end = {
        ['[K'] = '@class.outer',
        ['[F'] = '@function.outer',
        ['[A'] = '@parameter.inner',
        ['[I'] = '@conditional.outer',
        ['[O'] = '@loop.outer',
      },
    },
  },
})
