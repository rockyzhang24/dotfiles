local nvim_lsp = require("lspconfig")
local lsp = vim.lsp

-- Config diagnostic options globally
vim.diagnostic.config({
  virtual_text = {
    source = 'always',
    prefix = '■',
    -- severity = {
    --   min = vim.diagnostic.severity.ERROR,
    -- },
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
-- local signs = { Error = " ", Warn = " ", Info = " ", Hint = "" }
-- local signs = { Error = ' ', Warn = ' ', Info = ' ', Hint = ' ' }
-- for type, icon in pairs(signs) do
--   local hl = "DiagnosticSign" .. type
--   vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
-- end

local on_attach = function(client, bufnr)

  -- Mappings
  -- Comma (,) key acts as a leader key for the lsp mappings

  local map_opts = { silent = true, buffer = bufnr }

  -- Wrapper function to call telescope LSP picker
  local function telescope_lsp_picker(picker, picker_opts)
    local opts = {
      layout_strategy = "vertical",
      layout_config = {
        prompt_position = "top",
      },
      sorting_strategy = "ascending",
      ignore_filename = false,
    }
    for k, v in pairs(picker_opts) do
      opts[k] = v
    end
    require("telescope.builtin")[picker](opts)
  end

  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, map_opts)
  vim.keymap.set('n', 'gd', function() telescope_lsp_picker("lsp_definitions", {}) end, map_opts)
  vim.keymap.set('n', 'gt', function() telescope_lsp_picker("lsp_type_definitions", {}) end, map_opts)
  vim.keymap.set('n', 'gi', function() telescope_lsp_picker("lsp_implementations", {}) end, map_opts)
  vim.keymap.set('n', 'gr', function() telescope_lsp_picker("lsp_references", {}) end, map_opts)
  vim.keymap.set('n', ',r', vim.lsp.buf.rename, map_opts)
  vim.keymap.set('n', ',a', vim.lsp.buf.code_action, map_opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, map_opts)
  vim.keymap.set('n', ',k', vim.lsp.buf.signature_help, map_opts)

  -- List symbols via telescope (<C-l> for filtering by type of symbol)
  vim.keymap.set('n', ',s', function() telescope_lsp_picker("lsp_document_symbols", {}) end, map_opts)
  vim.keymap.set('n', ',S', function() telescope_lsp_picker("lsp_dynamic_workspace_symbols", {}) end, map_opts)

  -- Workspace operations (creat/delete a folder and list folders)
  vim.keymap.set('n', ',wa', vim.lsp.buf.add_workspace_folder, map_opts)
  vim.keymap.set('n', ',wr', vim.lsp.buf.remove_workspace_folder, map_opts)
  vim.keymap.set('n', ',wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, map_opts)

  -- Diagnostics
  vim.keymap.set('n', 'go', vim.diagnostic.open_float, map_opts)
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, map_opts)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, map_opts)
  vim.keymap.set('n', ',l', vim.diagnostic.setloclist, map_opts)

  -- List diagnostics via telescope (<C-l> to filter by type of diagnostic)
  vim.keymap.set('n', ',d', function() telescope_lsp_picker("diagnostics", { bufnr = 0 }) end, map_opts) -- current buffer
  vim.keymap.set('n', ',D', function() telescope_lsp_picker("diagnostics", {}) end, map_opts) -- all opened buffers

  -- Format
  vim.keymap.set('n', ',F', function() vim.lsp.buf.format { async = true } end, map_opts) -- whole buffer
  vim.keymap.set({ 'n', 'x' }, ',f', function() require("rockyz.plugin-config.lsp.lsp-utils").format_range_operator() end, map_opts) -- range

  -- Toggle diagnostics
  vim.keymap.set('n', '\\d', function() require("rockyz.plugin-config.lsp.lsp-utils").toggle_diagnostics() end, map_opts)

  -- For Aerial.nvim to display symbols outline
  require("aerial").on_attach(client, bufnr)

  -- For vim-illuminate to highlight all the references of the current word
  require("illuminate").on_attach(client)

end

-- Update the capabilities (nvim-cmp supports) sent to the server
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
capabilities.textDocument.foldingRange = { -- for nvim-ufo
    dynamicRegistration = false,
    lineFoldingOnly = true
}

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
        keywordSnippet = "Replace",
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
          max_line_length = "unset",
          -- statement_inline_comment_space = "2",
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
