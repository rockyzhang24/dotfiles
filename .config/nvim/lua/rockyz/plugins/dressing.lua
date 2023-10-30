require('dressing').setup({
  input = {
    border = vim.g.border_style,
    win_options = {
      winblend = 0,
    },
    mappings = {
      i = {
        ['<C-p>'] = 'HistoryPrev',
        ['<C-n>'] = 'HistoryNext',
      },
    },
  },
  select = {
    get_config = function(opts)
      if opts.kind == 'codeaction' then
        return {
          backend = { 'builtin' },
          builtin = {
            border = vim.g.border_style,
            relative = 'cursor',
            win_options = {
              winblend = 0,
            },
            min_height = 5,
          },
        }
      else
        return {
          enabled = false,
        }
      end
    end,
  },
})
