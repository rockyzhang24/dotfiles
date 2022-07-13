-- Load plugins config
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
  "maximize",
  "nvim-ufo",
  "project",
  "treesitter",
  "telescope.telescope-config",
}

for _, module in ipairs(modules) do
  require("rockyz.plugin-config." .. module)
end
