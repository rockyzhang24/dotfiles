-- Make gq use conform to format lines
vim.o.formatexpr = "v:lua.require('conform').formatexpr()"

local conform = require('conform')

conform.setup({
    formatters_by_ft = {
        c = { 'clang_format' },
        cpp = { 'clang_format' },
        lua = { 'stylua' },
        sh = { 'shfmt' },
        -- For filetypes without a formatter
        ['_'] = { 'trim_whitespace', 'trim_newlines' },
    },
    formatters = {
        shfmt = {
            -- Use 2 spaces as indentation
            prepend_args = { '-i', '4' },
        },
        -- prettier = {
        --     -- Require a Prettier configuration file to format
        --     require_cwd = true,
        -- },
    },
    -- Autoformat (format-on-save) can be toggled via the custom :ToggleFormat[!] command.
    -- Toggle buffer-local autoformat without [!]; Global autoformat with [!].
    format_on_save = function(bufnr)
        if not vim.g.autoformat and not vim.b[bufnr].autoformat then
            return nil
        end
        return {}
    end,
})

-- NOTE:
-- For the difference between formatters_by_ft and the table returned by format_on_save, see
-- https://github.com/stevearc/conform.nvim/issues/565#issuecomment-2453047201
