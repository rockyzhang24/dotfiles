-- Make gq use conform to format lines
vim.o.formatexpr = "v:lua.require('conform').formatexpr()"

local conform = require('conform')

conform.setup({
  formatters_by_ft = {
    c = { 'clang_format' },
    cpp = { 'clang_format' },
    lua = { 'stylua' },
    sh = { 'shfmt' },
  },
  formatters = {
    shfmt = {
      -- Use 2 spaces as indentation
      prepend_args = { '-i', '2' },
    },
  },
})
