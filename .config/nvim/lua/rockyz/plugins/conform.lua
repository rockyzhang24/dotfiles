local conform = require('conform')

conform.setup({
  formatters_by_ft = {
    lua = { 'stylua' },
    c = { 'clang_format' },
    cpp = { 'clang_format' },
  },
})

vim.keymap.set({ 'n', 'x' }, '<Leader>F', function()
  conform.format({ lsp_fallback = true })
end)
