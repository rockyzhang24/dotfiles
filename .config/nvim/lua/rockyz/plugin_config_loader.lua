-- Load lua configs
local modules = {
  "aerial",
  "bqf",
  "cmp",
  "comment",
  "ffhighlight",
  "foldsigns",
  "gitsigns",
  "hop",
  "hlslens",
  "harpoon",
  "iswap",
  "indent-blankline",
  "lualine",
  "luasnip",
  "lsp.lsp-config",
  "nvim-ufo",
  "project",
  "treesitter",
  "telescope.telescope-config",
}
for _, module in ipairs(modules) do
  require("rockyz.plugin-config." .. module)
end

-- Load viml configs
local viml_plugins = {
  "fugitive",
  "hexokinase",
  "minpac",
  "netrw",
  "registers",
  "tabular",
  "targets",
  "undotree",
  "vim-grepper",
  "vim-after-object",
  "vim-illuminate",
  "vim-gh-line",
  "vim-flog",
  "vim-visual-multi",
  "vim-asterisk",
}
for _, plugin in ipairs(viml_plugins) do
  vim.cmd("source ~/.config/nvim/viml/plugin-config/" .. plugin .. ".vim")
end
