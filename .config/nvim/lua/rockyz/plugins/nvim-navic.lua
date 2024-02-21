local navic = require('nvim-navic')
local codicon = require('rockyz.icons').codicon

navic.setup({
  -- Use codicon (VSCode like icons)
  icons = codicon,
  highlight = true,
  separator = '  ',
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('attach_navic', { clear = true }),
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.server_capabilities.documentSymbolProvider then
      navic.attach(client, bufnr)
    end
  end,
})
