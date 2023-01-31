require("indent_blankline").setup {
  char = '▏',
  char_priority = 50,
  filetype_exclude = {
    'aerial',
    'checkhealth',
    'help',
    'json',
    'jsonc',
    'lspinfo',
    'man',
    'minpac',
    'minpacprgs',
    'markdown',
    'NvimTree',
    'neo-tree',
    'startify',
    'TelescopePrompt',
    'WhichKey',
    '',
  },
  buftype_exclude = {
    'nofile',
    'quickfix',
    'terminal',
  },
  use_treesitter = true,
  show_trailing_blankline_indent = false,
  show_foldtext = false,

  -- Showing context via treesitter
  -- With showing context enabled, it will be slow in large file

  -- show_current_context = true,
  -- show_current_context_start = true,
  -- use_treesitter_scope = true,
  -- https://github.com/lukas-reineke/indent-blankline.nvim/issues/374
  -- viewport_buffer = 50,
}

-- Toggle indent line
vim.keymap.set('n', '<BS>i', '<Cmd>IndentBlanklineToggle<CR>')
