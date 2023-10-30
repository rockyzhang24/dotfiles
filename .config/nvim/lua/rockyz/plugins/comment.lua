require('Comment').setup({
  -- Ignore blank lines
  ignore = '^%s*$',
  -- Toggle mappings in NORMAL + VISUAL mode
  toggler = {
    line = 'gcc',
    block = 'gbc',
  },
  -- Operator-pending mappings in NORMAL + VISUAL mode
  opleader = {
    line = 'gc',
    block = 'gb',
  },
  extra = {
    ---Add comment on the line above
    above = 'gcO',
    ---Add comment on the line below
    below = 'gco',
    ---Add comment at the end of line
    eol = 'gcA',
  },
  mappings = {
    -- Operator-pending mapping
    -- Includes `gcc`, `gbc`, `gc[count]{motion}` and `gb[count]{motion}`
    basic = true,
    -- Extra mapping
    -- Includes `gco`, `gcO`, `gcA`
    extra = true,
  },

  -- Integrate nvim-ts-context-commentstring
  pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
})
