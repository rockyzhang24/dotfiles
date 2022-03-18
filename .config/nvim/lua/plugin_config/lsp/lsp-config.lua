local nvim_lsp = require("lspconfig")
local aerial = require("aerial")
local lsp = vim.lsp

-- Config diagnostic options globally
vim.diagnostic.config({
  virtual_text = {
    source = 'if_many',
    prefix = '■',
  },
  float = {
    source = 'if_many',
    border = 'rounded',
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Diagnostic symbols in the sign column
-- local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
local signs = { Error = ' ', Warn = ' ', Info = ' ', Hint = ' '}
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

local on_attach = function(client, bufnr)

  local function buf_set_keymap(...)
    vim.api.nvim_buf_set_keymap(bufnr, ...)
  end

  -- Mappings
  -- Comma (,) key acts as a leader key for the lsp mappings
  local opts = { noremap=true, silent=true }

  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua require("telescope.builtin").lsp_definitions(require("telescope.themes").get_dropdown({}))<CR>', opts)  -- definitions
  buf_set_keymap('n', 'gt', '<cmd>lua require("telescope.builtin").lsp_type_definitions(require("telescope.themes").get_dropdown({}))<CR>', opts) -- type definitions
  buf_set_keymap('n', 'gi', '<cmd>lua require("telescope.builtin").lsp_implementations(require("telescope.themes").get_dropdown({}))<CR>', opts)  -- implementations
  buf_set_keymap('n', 'gr', '<cmd>lua require("telescope.builtin").lsp_references(require("telescope.themes").get_dropdown({}))<CR>', opts) -- references

  buf_set_keymap('n', ',r', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', ',a', '<cmd>lua require("telescope.builtin").lsp_code_actions(require("telescope.themes").get_cursor({}))<CR>', opts)

  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', ',k', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)

  -- Symbols (<C-l> for filtering by type of symbol)
  buf_set_keymap('n', ',s', '<cmd>lua require("telescope.builtin").lsp_document_symbols()<CR>', opts) -- current buffer
  buf_set_keymap('n', ',S', '<cmd>lua require("telescope.builtin").lsp_dynamic_workspace_symbols()<CR>', opts) -- all workspace symbols

  -- Workspace
  buf_set_keymap('n', ',wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', ',wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', ',wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)

  -- Diagnostics
  buf_set_keymap('n', ',e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', ',q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

  -- List diagnostics (<C-l> to filter by type of diagnostic)
  buf_set_keymap('n', ',d', '<cmd>lua require("telescope.builtin").diagnostics({bufnr = 0})<CR>', opts)  -- current buffer
  buf_set_keymap('n', ',D', '<cmd>lua require("telescope.builtin").diagnostics()<CR>', opts)  -- all opened buffers

  -- Format
  buf_set_keymap('n', ',F', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)  -- whole buffer
  buf_set_keymap('n', ',f', '<cmd>lua require("plugin_config.lsp.lsp-utils").format_range_operator()<CR>', opts)  -- range format with a motion
  buf_set_keymap('x', ',f', '<cmd>lua require("plugin_config.lsp.lsp-utils").format_range_operator()<CR>', opts)  -- format a given range

  -- Toggle diagnostics
  buf_set_keymap('n', '\\d', '<cmd>lua require("plugin_config.lsp.lsp-utils").toggle_diagnostics()<CR>', opts)

  -- For Aerial.nvim to display symbols outline
  aerial.on_attach(client, bufnr)

end

-- Update the capabilities (nvim-cmp supports) sent to the server
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

-- Border for hover window
lsp.handlers["textDocument/hover"] = lsp.with(vim.lsp.handlers.hover, {
  border = "rounded",
})

-- Vimscript
nvim_lsp.vimls.setup {
  on_attach = on_attach,
  flags = {
    debounce_text_changes = 150,
  },
  capabilities = capabilities,
}

-- Lua
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

nvim_lsp.sumneko_lua.setup {
  on_attach = on_attach,
  flags = {
    debounce_text_changes = 150,
  },
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
        -- Setup your lua path
        path = runtime_path,
      },
      diagnostics = {
        -- Get the language server to recognize global
        globals = {
          -- For vim
          'vim',
          -- For luasnip
          's',
          'sn',
          'isn',
          't',
          'i',
          'f',
          'c',
          'd',
          'r',
          'l',
          'rep',
          'p',
          'm',
          'n',
          'dl',
          'fmt',
          'fmta',
          'conds',
          'parse',
          'ai',
        },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
}

-- Golang
nvim_lsp.gopls.setup {
  on_attach = on_attach,
  flags = {
    debounce_text_changes = 150,
  },
  capabilities = capabilities,
}

-- Python
nvim_lsp.pylsp.setup {
  on_attach = on_attach,
  flags = {
    debounce_text_changes = 150,
  },
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
  flags = {
    debounce_text_changes = 150,
  },
  capabilities = capabilities,
}

-- TypeScript/JavaScript
nvim_lsp.tsserver.setup {
  on_attach = on_attach,
  flags = {
    debounce_text_changes = 150,
  },
  capabilities = capabilities,
}
