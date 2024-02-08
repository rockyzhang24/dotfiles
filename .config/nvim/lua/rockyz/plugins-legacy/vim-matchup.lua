-- Avoid loading matchit
vim.g.loaded_matchit = 1

-- Treesitter integration
require('nvim-treesitter.configs').setup({
  matchup = {
    enable = true,
    disable_virtual_text = true,
  },
})
