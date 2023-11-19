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
        ['aa'] = '@parameter.outer',  -- a for argument
        ['ia'] = '@parameter.inner',
        ['ai'] = '@conditional.outer',  -- i for if
        ['ii'] = '@conditional.inner',
        ['ao'] = '@loop.outer',  -- o for loop
        ['io'] = '@loop.inner',
        ['av'] = '@call.outer',  -- v for invoke
        ['iv'] = '@call.inner',
        ['a='] = '@assignment.outer',
        ['i='] = '@assignment.inner',
        ['[='] = '@assignment.lhs',
        [']='] = '@assignment.rhs',
      },
    },
    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = {
        [']c'] = '@class.outer',
        [']f'] = '@function.outer',
        [']a'] = '@parameter.inner',
        [']i'] = '@conditional.outer',
        [']o'] = '@loop.outer',
        [']v'] = '@call.outer',
      },
      goto_next_end = {
        [']C'] = '@class.outer',
        [']F'] = '@function.outer',
        [']A'] = '@parameter.inner',
        [']I'] = '@conditional.outer',
        [']O'] = '@loop.outer',
        [']V'] = '@call.outer',
      },
      goto_previous_start = {
        ['[c'] = '@class.outer',
        ['[f'] = '@function.outer',
        ['[a'] = '@parameter.inner',
        ['[i'] = '@conditional.outer',
        ['[o'] = '@loop.outer',
        ['[v'] = '@call.outer',
      },
      goto_previous_end = {
        ['[C'] = '@class.outer',
        ['[F'] = '@function.outer',
        ['[A'] = '@parameter.inner',
        ['[I'] = '@conditional.outer',
        ['[O'] = '@loop.outer',
        ['[V'] = '@call.outer',
      },
    },
  },
})
