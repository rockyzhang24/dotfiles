local lspconfig = require('lspconfig')
local util = require('lspconfig/util')
local capabilities = require('rockyz.lsp').client_capabilities

-- Set border for LspInfo window
require('lspconfig.ui.windows').default_options.border = vim.g.border_style

-- Bash
lspconfig.bashls.setup({
  capabilities = capabilities(),
})

-- C/C++
lspconfig.clangd.setup({
  capabilities = capabilities(),
  cmd = {
    'clangd',
    '--clang-tidy',
    '--header-insertion=iwyu',
    '--completion-style=detailed',
    '--function-arg-placeholders',
    '--fallback-style=none',
  },
})

-- Golang
lspconfig.gopls.setup({
  capabilities = capabilities(),
  root_dir = util.root_pattern('go.work', 'go.mod', '.git'),
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
      semanticTokens = true,
    },
  },
})

-- Json/Jsonc
lspconfig.jsonls.setup({
  capabilities = capabilities(),
  settings = {
    json = {
      -- Use JSON Schema Store (SchemaStore.nvim)
      schemas = require('schemastore').json.schemas(),
      validate = { enable = true },
    }
  },
})

-- Lua
lspconfig.lua_ls.setup({
  capabilities = capabilities(),
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
      --     max_line_length = "100",
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

-- Python
-- lspconfig.pylsp.setup({
--   capabilities = capabilities(),
--   settings = {
--     --
--     -- Pylsp configuration doc: https://github.com/python-lsp/python-lsp-server.
--     --
--     -- To config the formatter and linter, we can use a specific configuration
--     -- file (e.g., pyproject.toml) in the project dir. To find all the available
--     -- configuration options for the formatter and linter, check the specific
--     -- repo.
--     -- 1) To config black, see https://black.readthedocs.io/en/stable/usage_and_configuration/the_basics.html
--     -- 2) To config ruff, see https://beta.ruff.rs/docs/configuration/
--     pylsp = {
--       plugins = {
--         -- Formatter
--         black = { enabled = true },
--         autopep8 = { enabled = false },
--         yapf = { enabled = false },
--         -- Linter
--         ruff = { enabled = true },
--         pyflakes = { enabled = false },
--         pycodestyle = { enabled = false },
--         mccabe = { enabled = false },
--         -- type checker
--         pylsp_mypy = { enabled = true },
--         -- Autocomplete
--         jedi_comletion = { fuzzy = true },
--       },
--     },
--   },
-- })

lspconfig.pyright.setup({
  capabilities = capabilities(),
})

-- Rust
lspconfig.rust_analyzer.setup({
  capabilities = capabilities(),
})

-- TOML
lspconfig.taplo.setup({
  capabilities = capabilities(),
})

-- Vimscript
lspconfig.vimls.setup({
  capabilities = capabilities(),
})

-- Yaml
lspconfig.yamlls.setup({
  capabilities = capabilities(),
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
