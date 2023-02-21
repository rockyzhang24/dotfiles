local nvim_lsp = require("lspconfig")
local util = require("lspconfig/util")
local my_util = require('rockyz.plugin-config.lsp.lsp-utils')
local border_enabled = vim.g.border_enabled

-- Enable border for LspInfo window
require('lspconfig.ui.windows').default_options.border = 'single'

-- Config diagnostic options globally
vim.diagnostic.config({
  float = {
    source = 'always',
    border = border_enabled and 'single' or 'none',
  },
  signs = false,
  underline = true,
  virtual_text = false,
  update_in_insert = false,
  severity_sort = true,
})

local on_attach = function(client, bufnr)
  -- float window border
  if border_enabled then
    vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
    vim.lsp.handlers.signature_help, {
      border = 'single',
    }
    )

    vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
    vim.lsp.handlers.hover, {
      border = 'single',
    }
    )
  end

  -- Mappings
  local map_opts = { silent = true, buffer = bufnr }

  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, map_opts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, map_opts)
  vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, map_opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, map_opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, map_opts)
  vim.keymap.set('n', ',r', vim.lsp.buf.rename, map_opts)
  vim.keymap.set('n', ',a', vim.lsp.buf.code_action, map_opts)
  -- vim.keymap.set('n', 'K', vim.lsp.buf.hover, map_opts) -- Integrate this
  -- with ufo preview, see ufo config for detail
  vim.keymap.set('n', ',k', vim.lsp.buf.signature_help, map_opts)
  -- List symbols via telescope
  local function telescope_lsp_picker(picker)
    local themes = require("telescope.themes")
    local theme_opts = themes.get_ivy {
      results_title = false,
      prompt_title = false,
      preview_title = "Preview",
      layout_config = {
        height = 40,
      },
    }
    require("telescope.builtin")[picker](theme_opts)
  end
  vim.keymap.set('n', '<Leader>fs', function() telescope_lsp_picker("lsp_document_symbols") end, map_opts)
  vim.keymap.set('n', '<Leader>fS', function() telescope_lsp_picker("lsp_workspace_symbols") end, map_opts)
  -- Diagnostics
  vim.keymap.set('n', 'go', vim.diagnostic.open_float, map_opts)
  vim.keymap.set('n', '[d', function()
    vim.diagnostic.goto_prev({ float = true, })
    vim.cmd('normal! zz')
  end, map_opts)
  vim.keymap.set('n', ']d', function()
    vim.diagnostic.goto_next({ float = true, })
    vim.cmd('normal! zz')
  end, map_opts)
  -- Feed buffer diagnostics to location list, or all diagnostics to quickfix
  vim.keymap.set('n', '<Leader>qd', vim.diagnostic.setloclist, map_opts)
  vim.keymap.set('n', '<Leader>qD', vim.diagnostic.setqflist, map_opts)
  -- Format
  vim.keymap.set({ 'n', 'x' }, ',f', function() my_util.format_range_operator() end, map_opts) -- range
  vim.keymap.set('n', ',F', function() vim.lsp.buf.format { async = true } end, map_opts) -- whole buffer
  -- Toggle diagnostics
  vim.keymap.set('n', '<BS>d', function() my_util.toggle_diagnostics() end, map_opts)
end

-- Update the capabilities (nvim-cmp supports) sent to the server
local capabilities = require('cmp_nvim_lsp').default_capabilities()
capabilities.textDocument.foldingRange = { -- for nvim-ufo
    dynamicRegistration = false,
    lineFoldingOnly = true
}

-- Vimscript
nvim_lsp.vimls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

-- Lua
nvim_lsp.lua_ls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      -- diagnostics = {
      -- },
      completion = {
        callSnippet = 'Replace',
        displayContext = 50,
        postfix = '.',
      },
      workspace = {
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
}

-- Golang
nvim_lsp.gopls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  root_dir = util.root_pattern("go.work", "go.mod", ".git"),
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
    },
  },
}

-- Python
nvim_lsp.pylsp.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  -- For further configuration: https://github.com/python-lsp/python-lsp-server/blob/develop/CONFIGURATION.md
  settings = {
    pylsp = {
      configurationSources = "flake8",
      plugins = {
        flake8 = { enabled = true, indentSize = 4 },
        pylsp_black = { enabled = true },
        pyls_isort = { enabled = true },
        pycodestyle = { enabled = false },
        mccabe = { enabled = false },
        pyflakes = { enabled = false },
        yapf = { enabled = false },
        autopep8 = { enabled = false },
      },
    },
  },
}

-- Rust
nvim_lsp.rust_analyzer.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

-- TypeScript/JavaScript
nvim_lsp.tsserver.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

-- Json/Jsonc
nvim_lsp.jsonls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

-- C++
nvim_lsp.clangd.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}
