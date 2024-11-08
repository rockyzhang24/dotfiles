require('nvim-treesitter.configs').setup({
    ensure_installed = {
        'bash',
        'c',
        'cpp',
        'cmake',
        'css',
        'gitcommit',
        'go',
        'graphql',
        'html',
        'java',
        'javascript',
        'json',
        'jsonc',
        'json5',
        'lua',
        'make',
        'markdown',
        'markdown_inline',
        'python',
        'query', -- treesitter query
        'rust',
        'scss',
        'sql',
        'toml',
        'tsx',
        'typescript',
        'vim',
        'vimdoc',
        'yaml',
    },
    ignore_install = {},
    highlight = {
        enable = true,
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = '<Enter>',
            node_incremental = '<Enter>',
            node_decremental = '<BS>',
            scope_incremental = '<S-Enter>',
        },
    },
})

-- Use treesitter based folding if the current buffer has a parser
vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('rockyz/treesitter_folding', { clear = true }),
    callback = function()
        if require('nvim-treesitter.parsers').get_parser() then
            vim.wo.foldmethod = 'expr'
            vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        end
    end,
})
