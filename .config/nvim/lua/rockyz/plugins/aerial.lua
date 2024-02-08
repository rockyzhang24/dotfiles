require('aerial').setup({
  -- Mappings (s for symbol)
  on_attach = function(bufnr)
    local buf_map = function(mode, lhs, rhs)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr })
    end
    -- Toggle aerial window (s for symbols)
    buf_map('n', '<BS>s', '<Cmd>AerialToggle!<CR>')
    -- Jump forwards/backwards
    buf_map('n', '[s', '<cmd>AerialPrev<CR>')
    buf_map('n', ']s', '<cmd>AerialNext<CR>')
  end,

  backends = { 'lsp', 'treesitter', 'markdown' },
  layout = {
    min_width = 40,
    max_width = 40,
    default_direction = 'right',
  },
  show_guides = true,
  -- A list of all symbols to display.
  -- This can be a filetype map (see :help aerial-filetype-map).
  filter_kind = {
    'Class',
    'Constructor',
    'Enum',
    'Function',
    'Interface',
    'Method',
    'Module',
    'Struct',
  },
})
