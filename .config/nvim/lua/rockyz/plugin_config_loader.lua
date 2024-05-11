-- Load plugin configs
local modules = {
  'bqf',
  'ccc',
  'cmp',
  'conform',
  'eregex',
  'flatten',
  'fugitive',
  'fzf',
  'gitsigns',
  'harpoon',
  'hlargs',
  'inc-rename',
  'iswap',
  'luasnip',
  'lspconfig',
  'neogen',
  'nvim-navic',
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
