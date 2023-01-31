require("aerial").setup {

  -- Mappings
  on_attach = function(bufnr)
    local map_opts = { buffer = bufnr, silent = true }
    -- Toggle aerial window
    vim.keymap.set('n', '<BS>s', '<Cmd>AerialToggle!<CR>', map_opts)
    -- Focus aerial window
    vim.keymap.set('n', '<Leader>ss', '<Cmd>AerialOpen<CR>', map_opts)
    -- Jump forwards/backwards
    vim.keymap.set('n', '[s', '<cmd>AerialPrev<CR>', map_opts)
    vim.keymap.set('n', ']s', '<cmd>AerialNext<CR>', map_opts)
    -- Jump up the tree
    vim.keymap.set('n', '[S', '<cmd>AerialPrevUp<CR>', map_opts)
    vim.keymap.set('n', ']S', '<cmd>AerialNextUp<CR>', map_opts)
  end,

  backends = { 'lsp', 'treesitter', 'markdown' },
  layout = {
    min_width = 40,
    max_width = 40,
    default_direction = "right",
  },
  show_guides = true,
  -- A list of all symbols to display.
  -- This can be a filetype map (see :help aerial-filetype-map).
  filter_kind = {
    "Class",
    "Constructor",
    "Enum",
    "Function",
    "Interface",
    "Method",
    "Module",
    "Struct",
  },
}
