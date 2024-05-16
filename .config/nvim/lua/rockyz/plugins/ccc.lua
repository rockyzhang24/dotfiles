local ccc = require('ccc')

ccc.setup({
  highlighter = {
    auto_enable = true,
    filetypes = {
      'css',
      'lua',
      'scss',
    },
  },
})

-- Use uppercase for hex colors
ccc.output.hex.setup({ uppercase = true })
ccc.output.hex_short.setup({ uppercase = true })
