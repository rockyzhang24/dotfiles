require("aerial").setup {

  -- Mappings
  on_attach = function(bufnr)
    -- Toggle aerial window
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '\\s', '<Cmd>AerialToggle!<CR>', {}) -- "s" for symbols
    -- Jump forwards/backwards
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>{', '<cmd>AerialPrev<CR>', {})
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>}', '<cmd>AerialNext<CR>', {})
    -- Jump up the tree
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>[[', '<cmd>AerialPrevUp<CR>', {})
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>]]', '<cmd>AerialNextUp<CR>', {})
    -- Fuzzy finding symbols (it respects backends and filter_kind)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>fs', '<cmd>Telescope aerial<CR>', {})
  end,

  backends = { "lsp", "treesitter", "markdown" },
  close_behavior = "auto",
  min_width = 40,
  max_width = 40,
  show_guides = true,

  -- Symbols to display (can be a filetype map)
  -- filter_kind = {
  --   -- "Array",
  --   -- "Boolean",
  --   "Class",
  --   -- "Constant",
  --   "Constructor",
  --   "Enum",
  --   -- "EnumMember",
  --   -- "Event",
  --   -- "Field",
  --   -- "File",
  --   "Function",
  --   "Interface",
  --   -- "Key",
  --   "Method",
  --   "Module",
  --   -- "Namespace",
  --   -- "Null",
  --   -- "Number",
  --   -- "Object",
  --   -- "Operator",
  --   -- "Package",
  --   -- "Property",
  --   -- "String",
  --   "Struct",
  --   -- "TypeParameter",
  --   -- "Variable",
  -- },
  -- Set it to false to display all symbols
  filter_kind = false,
}
