require 'treesitter-context'.setup {
  enable = true,
  throttle = true,
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
    -- rust = {
    --   'impl_item',
    -- },
  },
  exact_patterns = {
    -- Example for a specific filetype with Lua patterns
    -- Treat patterns.rust as a Lua pattern (i.e "^impl_item$" will
    -- exactly match "impl_item" only)
    -- rust = true,
  }
}
