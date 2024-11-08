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

-- NOTE:
-- For the difference between formatters_by_ft and the table returned by format_on_save, see
-- https://github.com/stevearc/conform.nvim/issues/565#issuecomment-2453047201
