local lspconfig = require('lspconfig')
local util = require('lspconfig/util')
local navic = require('nvim-navic')
local navbuddy = require('nvim-navbuddy')

-- Enable border for LspInfo window
require('lspconfig.ui.windows').default_options.border = vim.g.border_style

-- Config diagnostic globally
vim.diagnostic.config({
  float = {
    source = 'always',
    severity_sort = true,
    border = vim.g.border_style,
  },
  -- To change the signs displayed in the sign column, tweak the text field in signs, see :h
  -- vim.diagnostic.config for details
  signs = false,
  underline = true,
  virtual_text = {
    prefix = '',
  },
  update_in_insert = false,
  severity_sort = true,
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local bufnr = ev.buf
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
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
    vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, opts)
    -- Diagnostics
    vim.keymap.set('n', 'go', vim.diagnostic.open_float, opts)
    vim.keymap.set('n', '[d', function()
      vim.diagnostic.goto_prev({ float = { scope = 'cursor' } })
    end, opts)
    vim.keymap.set('n', ']d', function()
      vim.diagnostic.goto_next({ float = { scope = 'cursor' } })
    end, opts)
    -- Feed all diagnostics to quickfix list, or buffer diagnostics to location
    -- list
    vim.keymap.set('n', '<Leader>dq', vim.diagnostic.setqflist, opts)
    vim.keymap.set('n', '<Leader>dl', vim.diagnostic.setloclist, opts)
    -- Format
    -- vim.keymap.set({ 'n', 'x' }, '<leader>F', function()
    --   vim.lsp.buf.format { async = true }
    -- end, opts)
    -- Toggle LSP inlay hints
    if client and client.server_capabilities.inlayHintProvider then
      vim.keymap.set('n', '<BS>h', function()
        if vim.lsp.inlay_hint.is_enabled() then
          vim.lsp.inlay_hint.enable(0, false)
        else
          vim.lsp.inlay_hint.enable(0, true)
        end
      end, opts)
    end

    -- Lsp progress
    require('rockyz.lsp.progress')

    -- Show a lightbulb when code actions are available under the cursor
    require('rockyz.lsp.lightbulb')

    -- Use nvim-navic to get the code context, i.e., the breadcrumbs in winbar
    -- Use nvim-navbuddy for navigation
    if client and client.server_capabilities.documentSymbolProvider then
      navic.attach(client, bufnr)
      navbuddy.attach(client, bufnr)
    end

    -- Enable code lens
    -- if client and client.server_capabilities.codeLensProvider then
    --   vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
    --     buffer = bufnr,
    --     callback = function()
    --       vim.lsp.codelens.refresh()
    --     end,
    --   })
    -- end
  end,
})

-- Update the capabilities (nvim-cmp supports) sent to the server
local capabilities = require('cmp_nvim_lsp').default_capabilities()
capabilities.textDocument.foldingRange = { -- for nvim-ufo
  dynamicRegistration = false,
  lineFoldingOnly = true,
}
capabilities.textDocument.completion.completionItem.snippetSupport = true -- for jsonls

-- Vimscript
lspconfig.vimls.setup({
  capabilities = capabilities,
})

-- Lua
lspconfig.lua_ls.setup({
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      -- Inlay hints
      hint = {
        enable = true,
        setType = true,
        arrayIndex = 'Disable',
      },
      codeLens = {
        enable = true,
      },
      completion = {
        callSnippet = 'Replace',
        postfix = '.',
        displayContext = 50,
      },
      -- workspace = {
      -- },
      telemetry = {
        enable = false,
      },
      -- Lua LS offers a code formatter
      -- Ref: https://github.com/LuaLS/lua-language-server/wiki/Formatter
      -- format = {
      --   enable = true,
      --   defaultConfig = {
      --     indent_size = "2",
      --     max_line_length = "80",
      --     continuation_indent = "4",
      --   },
      -- },
      diagnostics = {
        -- Code style checking offered by the Lua LS code formatter
        -- neededFileStatus = {
        --   ["codestyle-check"] = "Any",
        -- },
      },
    },
  },
})

-- C++
lspconfig.clangd.setup({
  capabilities = capabilities,
})

-- TypeScript/JavaScript
lspconfig.tsserver.setup({
  capabilities = capabilities,
})

-- Golang
lspconfig.gopls.setup({
  capabilities = capabilities,
  root_dir = util.root_pattern('go.work', 'go.mod', '.git'),
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
    },
  },
})

-- Python
lspconfig.pylsp.setup({
  capabilities = capabilities,
  settings = {
    --
    -- Pylsp configuration doc: https://github.com/python-lsp/python-lsp-server.
    --
    -- To config the formatter and linter, we can use a specific configuration
    -- file (e.g., pyproject.toml) in the project dir. To find all the available
    -- configuration options for the formatter and linter, check the specific
    -- repo.
    -- 1) To config black, see https://black.readthedocs.io/en/stable/usage_and_configuration/the_basics.html
    -- 2) To config ruff, see https://beta.ruff.rs/docs/configuration/
    pylsp = {
      plugins = {
        -- Formatter
        black = { enabled = true },
        autopep8 = { enabled = false },
        yapf = { enabled = false },
        -- Linter
        ruff = { enabled = true },
        pyflakes = { enabled = false },
        pycodestyle = { enabled = false },
        mccabe = { enabled = false },
        -- type checker
        pylsp_mypy = { enabled = true },
        -- Autocomplete
        jedi_comletion = { fuzzy = true },
      },
    },
  },
})

-- Rust
lspconfig.rust_analyzer.setup({
  capabilities = capabilities,
})

-- Json/Jsonc
lspconfig.jsonls.setup({
  capabilities = capabilities,
  settings = {
    json = {
      -- Use JSON Schema Store (SchemaStore.nvim)
      schemas = require('schemastore').json.schemas(),
      validate = { enable = true },
    }
  },
})

-- Yaml
lspconfig.yamlls.setup({
  capabilities = capabilities,
  settings = {
    yaml = {
      schemaStore = {
        -- You must disable built-in schemaStore support if you want to use
        -- this plugin (SchemaStore.nvim) and its advanced options like `ignore`.
        enable = false,
        -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
        url = '',
      },
      schemas = require('schemastore').yaml.schemas(),
    },
  },
})

-- TOML
lspconfig.taplo.setup({
  capabilities = capabilities,
})
