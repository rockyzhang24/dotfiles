local nvim_lsp = require("lspconfig")
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
local signs = { Error = ' ', Warn = ' ', Info = ' ', Hint = ' ' }
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

  local opts = { noremap = true, silent = true }

  -- Declarations
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  -- Definitions
  buf_set_keymap('n', 'gd',
    '<cmd>lua require("telescope.builtin").lsp_definitions(require("telescope.themes").get_dropdown({}))<CR>',
    opts)
  -- Type definitions
  buf_set_keymap('n', 'gt',
    '<cmd>lua require("telescope.builtin").lsp_type_definitions(require("telescope.themes").get_dropdown({}))<CR>',
    opts)
  -- Implementations
  buf_set_keymap('n', 'gi',
    '<cmd>lua require("telescope.builtin").lsp_implementations(require("telescope.themes").get_dropdown({}))<CR>',
    opts)
  -- References
  buf_set_keymap('n', 'gr',
    '<cmd>lua require("telescope.builtin").lsp_references(require("telescope.themes").get_dropdown({}))<CR>',
    opts)
  -- Rename
  buf_set_keymap('n', ',r', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  -- Code actions
  buf_set_keymap('n', ',a',
    '<cmd>lua require("telescope.builtin").lsp_code_actions(require("telescope.themes").get_cursor({}))<CR>',
    opts)
  -- Show documentation
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  -- Show signature hint
  buf_set_keymap('n', ',k', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)

  -- Symbols (<C-l> for filtering by type of symbol)
  -- For current buffer
  buf_set_keymap('n', ',s', '<cmd>lua require("telescope.builtin").lsp_document_symbols()<CR>', opts)
  -- For all workspace
  buf_set_keymap('n', ',S', '<cmd>lua require("telescope.builtin").lsp_dynamic_workspace_symbols()<CR>', opts)

  -- Workspace operations for creating a folder, deleting a folder, or listing
  -- folders
  buf_set_keymap('n', ',wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', ',wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', ',wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)

  -- Diagnostics
  -- Open a float window to show the complete diagnostic info
  buf_set_keymap('n', ',e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  -- Navigate to the next/prev diagnostic
  buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  -- Add buffer diagnostics to the location list
  buf_set_keymap('n', ',q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

  -- List diagnostics (<C-l> to filter by type of diagnostic)
  -- For current buffer
  buf_set_keymap('n', ',d', '<cmd>lua require("telescope.builtin").diagnostics({bufnr = 0})<CR>', opts)
  -- For all opened buffers
  buf_set_keymap('n', ',D', '<cmd>lua require("telescope.builtin").diagnostics()<CR>', opts)

  -- Format
  -- For the whole buffer
  buf_set_keymap('n', ',F', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
  -- Range format with a motion
  buf_set_keymap('n', ',f', '<cmd>lua require("plugin_config.lsp.lsp-utils").format_range_operator()<CR>', opts)
  -- For a range
  buf_set_keymap('x', ',f', '<cmd>lua require("plugin_config.lsp.lsp-utils").format_range_operator()<CR>', opts)

  -- Toggle diagnostics
  buf_set_keymap('n', '\\d', '<cmd>lua require("plugin_config.lsp.lsp-utils").toggle_diagnostics()<CR>', opts)

  -- For Aerial.nvim to display symbols outline
  require("aerial").on_attach(client, bufnr)

  -- For vim-illuminate to highlight all the references of the current word
  require("illuminate").on_attach(client)

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
  -- Support formatter since 2.6.6 (ref:
  -- https://github.com/sumneko/lua-language-server/issues/960)
  cmd = { "lua-language-server", "--preview" },
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
        -- Setup your lua path
        path = runtime_path,
      },
      completion = {
        callSnippet = "Replace",
        displayContext = 50,
        keywordSnippet = "Disable",
        postfix = ".",
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
        neededFileStatus = {
          ["codestyle-check"] = "Any",
        },
      },
      -- Config the format style options. Or use a file .editorconfig under the
      -- project root directory. Ref:
      -- https://github.com/sumneko/lua-language-server/wiki/Code-Formatter
      format = {
        enable = true,
        defaultConfig = {
          indent_style = "space",
          indent_size = "2",
          -- quote_style = "double",
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
