require 'treesitter-context'.setup {
  enable = true,
  max_lines = 0,
  -- Match patterns for TS nodes.
  patterns = {
    default = {
      'class',
      'function',
      'method',
      'for',
      'while',
      'if',
      'switch',
      'case',
    },
    lua = {
      'table',
    },
    -- rust = {
    --   'impl_item',
    -- },
  },
  exact_patterns = {
    -- Example for a specific filetype with Lua patterns
    -- Treat patterns.rust as a Lua pattern (i.e "^impl_item$" will
    -- exactly match "impl_item" only)
    -- rust = true,
  },

  -- https://github.com/nvim-treesitter/nvim-treesitter-context/commit/27a0e2a8eeea7887b5584c0b041f3d72e448fcc1
  multiline_threshold = 20,

  mode = 'cursor',
}
