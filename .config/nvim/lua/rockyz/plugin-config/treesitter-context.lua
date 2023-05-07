require('treesitter-context').setup {
  enable = true,
  max_lines = 0,
  -- https://github.com/nvim-treesitter/nvim-treesitter-context/commit/27a0e2a8eeea7887b5584c0b041f3d72e448fcc1
  multiline_threshold = 20,
  trim_scope = 'outer',
  mode = 'topline',
}
