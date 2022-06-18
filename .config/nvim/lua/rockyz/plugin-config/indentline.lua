require("indent_blankline").setup {
  char = '│',
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
  show_current_context = true,
  show_current_context_start = false,
  use_treesitter_scope = true,
  show_trailing_blankline_indent = false,
  show_foldtext = false,

  -- https://github.com/lukas-reineke/indent-blankline.nvim/issues/374
  viewport_buffer = 100,
}

-- Toggle indent line
vim.keymap.set('n', '\\i', '<Cmd>IndentBlanklineToggle<CR>')
