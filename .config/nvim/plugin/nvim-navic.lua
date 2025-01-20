local navic = require('nvim-navic')
local symbol_kinds = require('rockyz.icons').symbol_kinds

navic.setup({
    icons = symbol_kinds,
    highlight = true,
    separator = '  ',
})

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('rockyz.navic.attach', { clear = true }),
    callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.server_capabilities.documentSymbolProvider then
            navic.attach(client, bufnr)
        end
    end,
})
