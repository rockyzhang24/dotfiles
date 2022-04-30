require("aerial").setup {

  -- Mappings
  on_attach = function(bufnr)
    local map_opts = { buffer = bufnr, silent = true }
    -- Toggle aerial window
    vim.keymap.set('n', '\\s', '<Cmd>AerialToggle!<CR>', map_opts)
    -- Jump forwards/backwards
    vim.keymap.set('n', '[s', '<cmd>AerialPrev<CR>', map_opts)
    vim.keymap.set('n', ']s', '<cmd>AerialNext<CR>', map_opts)
    -- Jump up the tree
    vim.keymap.set('n', '[S', '<cmd>AerialPrevUp<CR>', map_opts)
    vim.keymap.set('n', ']S', '<cmd>AerialNextUp<CR>', map_opts)
    -- Fuzzy finding symbols (it respects backends and filter_kind)
    vim.keymap.set('n', '<Leader>fs', '<cmd>Telescope aerial<CR>', map_opts)
  end,

  backends = { 'lsp', 'treesitter', 'markdown' },
  close_behavior = "auto",
  min_width = 40,
  max_width = 40,
  show_guides = true,
  default_direction = "right",

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
