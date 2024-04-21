-- Load plugin configs
local modules = {
  'bqf',
  'cmp',
  'conform',
  'eregex',
  'flatten',
  'fugitive',
  'fzf',
  'gitsigns',
  'hlargs',
  'harpoon',
  'inc-rename',
  'iswap',
  'lualine',
  'luasnip',
  'lspconfig',
  'neogen',
  'nvim-colorizer',
  'nvim-navic',
  'nvim-navbuddy',
  'project',
  'quick-scope',
  'targets',
  'treesitter',
  'treesitter-textobjects',
  'treesj',
  'telescope',
  'undotree',
  'vim-asterisk',
  'vim-flog',
  'vim-grepper',
  'vim-illuminate',
}

for _, module in ipairs(modules) do
  require('rockyz.plugins.' .. module)
end
