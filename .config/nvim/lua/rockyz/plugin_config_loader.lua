-- Load lua configs
local modules = {
  "bqf",
  "cmp",
  "comment",
  "ffhighlight",
  "gitsigns",
  "hlslens",
  "harpoon",
  "iswap",
  "indent-blankline",
  "lualine",
  "luasnip",
  "lsp.lsp-config",
  "nvim-ufo",
  "nvim-colorizer",
  "project",
  "registers",
  "treesitter",
  "telescope.telescope-config",
  "test",
  "vim-illuminate",
}
for _, module in ipairs(modules) do
  require("rockyz.plugin-config." .. module)
end

-- Load viml configs
local viml_plugins = {
  "fugitive",
  "minpac",
  "netrw",
  "tabular",
  "targets",
  "undotree",
  "vim-grepper",
  "vim-after-object",
  "vim-gh-line",
  "vim-asterisk",
}
for _, plugin in ipairs(viml_plugins) do
  vim.cmd("source ~/.config/nvim/viml/plugin-config/" .. plugin .. ".vim")
end
