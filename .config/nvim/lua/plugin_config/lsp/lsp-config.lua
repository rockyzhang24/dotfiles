local nvim_lsp = require("lspconfig")
local lsp = vim.lsp

-- Config diagnostic options globally
vim.diagnostic.config({
  virtual_text = {
    source = 'always',
    prefix = '■',
    severity = {
      min = vim.diagnostic.severity.ERROR,
    },
  },
  float = {
    source = 'always',
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

  -- Mappings
  -- Comma (,) key acts as a leader key for the lsp mappings

  local map_opts = { silent = true, buffer = bufnr }

  -- Declarations
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, map_opts)
  -- Definitions
  vim.keymap.set('n', 'gd',
      function() require("telescope.builtin").lsp_definitions(require("telescope.themes").get_dropdown({})) end,
      map_opts)
  -- Type definitions
  vim.keymap.set('n', 'gt',
      function() require("telescope.builtin").lsp_type_definitions(require("telescope.themes").get_dropdown({})) end,
      map_opts)
  -- Implementations
  vim.keymap.set('n', 'gi',
      function() require("telescope.builtin").lsp_implementations(require("telescope.themes").get_dropdown({})) end,
      map_opts)
  -- References
  vim.keymap.set('n', 'gr',
      function() require("telescope.builtin").lsp_references(require("telescope.themes").get_dropdown({})) end,
      map_opts)
  -- Rename
  vim.keymap.set('n', ',r', vim.lsp.buf.rename, map_opts)
  -- Code actions
  vim.keymap.set('n', ',a',
      function() require("telescope.builtin").lsp_code_actions(require("telescope.themes").get_cursor({})) end,
      map_opts)
  -- Show documentation
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, map_opts)
  -- Show signature hint
  vim.keymap.set('n', ',k', vim.lsp.buf.signature_help, map_opts)

  -- List symbols via telescope (<C-l> for filtering by type of symbol)
  -- For current buffer
  vim.keymap.set('n', ',s', function() require("telescope.builtin").lsp_document_symbols() end, map_opts)
  -- For all workspace
  vim.keymap.set('n', ',S', function() require("telescope.builtin").lsp_dynamic_workspace_symbols() end, map_opts)

  -- Workspace operations for creating a folder, deleting a folder, or listing
  -- folders
  vim.keymap.set('n', ',wa', vim.lsp.buf.add_workspace_folder, map_opts)
  vim.keymap.set('n', ',wr', vim.lsp.buf.remove_workspace_folder, map_opts)
  vim.keymap.set('n', ',wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, map_opts)

  -- Diagnostics
  -- Open a float window to show the complete diagnostic info
  vim.keymap.set('n', 'go', vim.diagnostic.open_float, map_opts)
  -- Navigate to the next/prev diagnostic
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, map_opts)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, map_opts)
  -- Add buffer diagnostics to the location list
  vim.keymap.set('n', ',l', vim.diagnostic.setloclist, map_opts)

  -- List diagnostics via telescope (<C-l> to filter by type of diagnostic)
  -- For current buffer
  vim.keymap.set('n', ',d', function() require("telescope.builtin").diagnostics({ bufnr = 0 }) end, map_opts)
  -- For all opened buffers
  vim.keymap.set('n', ',D', function() require("telescope.builtin").diagnostics() end, map_opts)

  -- Format
  -- For the whole buffer
  vim.keymap.set('n', ',F', vim.lsp.buf.formatting, map_opts)
  -- Range format with a motion
  vim.keymap.set('n', ',f', function() require("plugin_config.lsp.lsp-utils").format_range_operator() end, map_opts)
  -- For a range
  vim.keymap.set('x', ',f', function() require("plugin_config.lsp.lsp-utils").format_range_operator() end, map_opts)

  -- Toggle diagnostics
  vim.keymap.set('n', '\\d', function() require("plugin_config.lsp.lsp-utils").toggle_diagnostics() end, map_opts)

  -- Show diagnostics in float window when CursorHold
  vim.api.nvim_create_augroup("ShowDiagnosticInHover", { clear = true })
  vim.api.nvim_create_autocmd("CursorHold", {
    group = "ShowDiagnosticInHover",
    buffer = bufnr,
    callback = function()
      local opts = {
        focusable = false,
        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        border = 'rounded',
        source = 'always',
        prefix = ' ',
        scope = 'cursor',
      }
      vim.diagnostic.open_float(nil, opts)
    end
  })

  -- For Aerial.nvim to display symbols outline
  require("aerial").on_attach(client, bufnr)

  -- For vim-illuminate to highlight all the references of the current word
  require("illuminate").on_attach(client)

end

-- Update the capabilities (nvim-cmp supports) sent to the server
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

-- Border
lsp.handlers["textDocument/hover"] = lsp.with(lsp.handlers.hover, {
  border = "rounded",
})
lsp.handlers["textDocument/signatureHelp"] = lsp.with(lsp.handlers.signature_help, {
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
