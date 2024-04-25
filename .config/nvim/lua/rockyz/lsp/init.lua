local diagnostic_icons = require('rockyz.icons').diagnostics

local M = {}

-- Config diagnostic globally
vim.diagnostic.config({
  float = {
    source = 'always',
    border = vim.g.border_style,
    severity_sort = true,
    prefix = function(diag)
      local level = vim.diagnostic.severity[diag.severity]
      local prefix = string.format(' %s ', diagnostic_icons[level])
      return prefix, 'Diagnostic' .. level:gsub('^%l', string.upper)
    end,
  },
  virtual_text = {
    prefix = '',
    spacing = 2,
    format = function(diagnostic)
      local icon = diagnostic_icons[vim.diagnostic.severity[diagnostic.severity]]
      return string.format('%s %s ', icon, diagnostic.message)
    end,
  },
  signs = false,
  severity_sort = true,
})

M.client_capabilities = function()
  local capabilities = vim.tbl_deep_extend(
    'force',
    vim.lsp.protocol.make_client_capabilities(),
    require('cmp_nvim_lsp').default_capabilities()
  )
  capabilities.textDocument.completion.completionItem.snippetSupport = true -- for jsonls
  return capabilities
end

local function on_attach(client, bufnr)
  -- Config border of float windows
  if vim.g.border_enabled then
    vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {
      border = vim.g.border_style,
    })
    vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
      border = vim.g.border_style,
    })
  end
  -- Mappings
  local opts = { buffer = bufnr }
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition, opts)
  vim.keymap.set('n', 'gI', vim.lsp.buf.implementation, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', '<Leader>rn', vim.lsp.buf.rename, opts)
  -- Code actions under the cursor
  -- TODO: so far vim.lsp.buf.code_action() returns code actions on the entire cursor line, not
  -- just right under the cursor. So I extracted only those diagnostics overlapping the cursor and
  -- use them to get code actions. Once this issue https://github.com/neovim/neovim/issues/21985
  -- is solved, we just need to directly call vim.lsp.buf.code_action().
  vim.keymap.set({ 'n', 'x' }, '<Leader>ca', function()
    vim.lsp.buf.code_action({
      context = {
        diagnostics = require('rockyz.lsp.utils').get_diagnostics_under_cursor(),
      },
    })
  end, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('i', '<C-s>', vim.lsp.buf.signature_help, opts)
  -- Diagnostics
  vim.keymap.set('n', 'go', vim.diagnostic.open_float, opts)
  vim.keymap.set('n', '[d', function()
    vim.diagnostic.goto_prev({
      float = { scope = 'cursor' },
      severity = { min = vim.diagnostic.severity.HINT },
    })
  end, opts)
  vim.keymap.set('n', ']d', function()
    vim.diagnostic.goto_next({
      float = { scope = 'cursor' },
      severity = { min = vim.diagnostic.severity.HINT },
    })
  end, opts)
  vim.keymap.set('n', '[e', function()
    vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
  end, opts)
  vim.keymap.set('n', ']e', function()
    vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
  end, opts)
  -- Feed all diagnostics to quickfix list, or buffer diagnostics to location
  -- list
  vim.keymap.set('n', '<Leader>dq', vim.diagnostic.setqflist, opts)
  vim.keymap.set('n', '<Leader>dl', vim.diagnostic.setloclist, opts)
  -- Format
  -- vim.keymap.set({ 'n', 'x' }, '<leader>F', function()
  --   vim.lsp.buf.format { async = true }
  -- end, opts)
  -- Toggle inlay hints
  if client and client.server_capabilities.inlayHintProvider then
    vim.keymap.set('n', '<BS>h', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
    end, opts)
  end

  -- Lsp progress
  require('rockyz.lsp.progress')

  -- Show a lightbulb when code actions are available under the cursor
  require('rockyz.lsp.lightbulb')

  -- Enable code lens
  -- if client and client.server_capabilities.codeLensProvider then
  --   vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
  --     buffer = bufnr,
  --     callback = function()
  --       vim.lsp.codelens.refresh({ bufnr = 0})
  --     end,
  --   })
  -- end
end

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    on_attach(client, bufnr)
  end,
})

return M
