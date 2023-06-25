local lspconfig = require("lspconfig")
local util = require("lspconfig/util")
local navic = require("nvim-navic")
local navbuddy = require("nvim-navbuddy")
local my_lsp_utils = require('rockyz.plugin-config.lsp.lsp-utils')
local map = require('rockyz.keymap').map
local cmd = vim.cmd
local lsp = vim.lsp
local api = vim.api
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
    lsp.handlers['textDocument/signatureHelp'] = lsp.with(
      lsp.handlers.signature_help, {
        border = 'single',
      }
    )
    lsp.handlers['textDocument/hover'] = lsp.with(
      lsp.handlers.hover, {
        border = 'single',
      }
    )
  end

  -- Mappings
  local buf_map = function(mode, lhs, rhs)
    map(mode, lhs, rhs, { buffer = bufnr })
  end

  -- Open a floating window with a prompt for users to select whether to dump
  -- all diagnostics into quickfix list or just buffer diagnostics into loation
  -- list
  local dump_diagnostic_to_list = function()
    local prompt = ' [q]uickfix, [l]ocation ? '
    local actions = {
      q = vim.diagnostic.setqflist,
      l = vim.diagnostic.setloclist,
    }
    require('rockyz.utils').prompt_for_actions(prompt, actions)
  end

  buf_map('n', 'gd', lsp.buf.definition)
  buf_map('n', 'gD', lsp.buf.declaration)
  buf_map('n', 'gy', lsp.buf.type_definition)
  buf_map('n', 'gi', lsp.buf.implementation)
  buf_map('n', 'gr', lsp.buf.references)
  buf_map('n', '<Leader>rn', lsp.buf.rename)
  buf_map({ 'n', 'x' }, '<Leader>ca', my_lsp_utils.code_action_at_cursor)
  -- The keymap for showing documentation is defined in nvim-ufo's config
  -- together with fold preview
  -- buf_map('n', 'K', vim.lsp.buf.hover)
  buf_map('i', '<C-s>', lsp.buf.signature_help)
  -- List symbols via telescope
  local function telescope_lsp_picker(picker)
    local themes = require("telescope.themes")
    local ivy = themes.get_ivy {
      results_title = false,
      prompt_title = false,
      preview_title = "Preview",
      layout_config = {
        height = 40,
      },
    }
    require("telescope.builtin")[picker](ivy)
  end
  buf_map('n', '<Leader>fs', function() telescope_lsp_picker("lsp_document_symbols") end)
  buf_map('n', '<Leader>fS', function() telescope_lsp_picker("lsp_workspace_symbols") end)
  -- Diagnostics
  buf_map('n', 'go', vim.diagnostic.open_float)
  buf_map('n', '[d', function()
    vim.diagnostic.goto_prev({ float = { scope = 'cursor' }, })
    cmd('normal! zz')
  end)
  buf_map('n', ']d', function()
    vim.diagnostic.goto_next({ float = { scope = 'cursor' }, })
    cmd('normal! zz')
  end)
  -- Feed all diagnostics to quickfix list, or buffer diagnostics to location
  -- list
  buf_map('n', '<Leader>qd', dump_diagnostic_to_list)
  -- Format
  buf_map({ 'n', 'x' }, '<leader>gq', function() lsp.buf.format { async = true } end)
  -- Toggle diagnostics
  buf_map('n', '<Leader><Leader>d', my_lsp_utils.toggle_diagnostics)

  -- Show a lightbulb when code actions are available
  api.nvim_create_augroup('code_action', { clear = true })
  api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI', 'WinScrolled' }, {
    group = 'code_action',
    pattern = '*',
    callback = my_lsp_utils.show_lightbulb,
  })

  -- Use nvim-navic to get the code context, i.e., the breadcrumbs in winbar
  -- Use nvim-navbuddy for navigation
  if client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr)
    navbuddy.attach(client, bufnr)
  end

  -- LSP inlay hints
  -- if client.server_capabilities.inlayHintProvider then
  --   vim.lsp.buf.inlay_hint(bufnr, true)
  -- end
end

-- Update the capabilities (nvim-cmp supports) sent to the server
local capabilities = require('cmp_nvim_lsp').default_capabilities()
capabilities.textDocument.foldingRange = { -- for nvim-ufo
  dynamicRegistration = false,
  lineFoldingOnly = true
}

-- Vimscript
lspconfig.vimls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

-- Lua
lspconfig.lua_ls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      -- Inlay hints
      -- hint = {
      --   enable = true,
      --   setType = true,
      --   arrayIndex = "Disable",
      -- },
      diagnostics = {
        -- neededFileStatus = {
        --   ["codestyle-check"] = "Any",
        -- },
      },
      completion = {
        callSnippet = 'Replace',
        displayContext = 50,
        postfix = '.',
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        -- library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
      format = {
        enable = true,
        defaultConfig = {
          indent_size = "2",
          max_line_length = "80",
          continuation_indent = "4",
        },
      },
    },
  },
}

-- Golang
lspconfig.gopls.setup {
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
-- Two options:
-- 1. pyright: We need to use a separate formatter (black) and a linter
-- (flake8). Plugin like null-ls is a good pal.
-- 2. pylsp: It has builtin formatter and linters.
lspconfig.pyright.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  single_file_support = true,
  -- All setting options are here: https://github.com/microsoft/pyright/blob/main/docs/settings.md
  settings = {
    python = {
      analysis = {
        autoImportCompletions = true,
        autoSearchPaths = true,
        diagnosticMode = "workspace", -- openFilesOnly, workspace
        typeCheckingMode = "basic", -- off, basic, strict
        useLibraryCodeForTypes = true
      },
    }
  },
}
-- lspconfig.pylsp.setup {
--   on_attach = on_attach,
--   capabilities = capabilities,
--   -- For further configuration: https://github.com/python-lsp/python-lsp-server/blob/develop/CONFIGURATION.md
--   settings = {
--     pylsp = {
--       configurationSources = "flake8",
--       plugins = {
--         flake8 = { enabled = true, indentSize = 4 }, -- linter
--         pylsp_black = { enabled = true }, -- formatter
--         yapf = { enabled = false }, -- formatter
--         autopep8 = { enabled = false }, -- formatter
--         pyls_isort = { enabled = true }, -- sort the imports
--         pycodestyle = { enabled = false }, -- linter for style checking
--         mccabe = { enabled = false }, -- linter for code complexity checking
--         pyflakes = { enabled = false }, -- linter to detect various errors
--       },
--     },
--   },
-- }

-- Rust
lspconfig.rust_analyzer.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

-- TypeScript/JavaScript
lspconfig.tsserver.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

-- Json/Jsonc
lspconfig.jsonls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

-- C++
lspconfig.clangd.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}
