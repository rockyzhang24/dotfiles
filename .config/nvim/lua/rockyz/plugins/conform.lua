local conform = require('conform')

conform.setup({
  formatters_by_ft = {
    lua = { 'stylua' },
    c = { 'clang_format' },
    cpp = { 'clang_format' },
    python = { 'isort', 'black' },
    go = { 'gofumpt', 'goimports' },
    html = { 'prettier' },
    css = { 'prettier' },
    less = { 'prettier' },
    scss = { 'prettier' },
    javascript = { 'prettier' },
    typescript = { 'prettier' },
    javascriptreact = { 'prettier' },
    typescriptreact = { 'prettier' },
    json = { 'prettier' },
    yaml = { 'prettier' },
  },
})

vim.keymap.set({ 'n', 'x' }, '<Leader>F', function()
  conform.format({ lsp_fallback = true })
end)
