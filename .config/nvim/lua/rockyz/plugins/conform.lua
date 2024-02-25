-- Use conform for gq
vim.o.formatexpr = "v:lua.require('conform').formatexpr()"

local conform = require('conform')

conform.setup({
  formatters_by_ft = {
    lua = { 'stylua' },
    c = { 'clang_format' },
    cpp = { 'clang_format' },
    sh = { 'shfmt' },
  },
  formatters = {
    shfmt = {
      -- Use 2 spaces as indentation
      prepend_args = { '-i', '2' },
    },
  },
})
