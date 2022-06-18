-- Load plugins config
local modules = {
  "aerial",
  "bqf",
  "cmp",
  "comment",
  "fidget",
  "ffhighlight",
  "foldsigns",
  "gitsigns",
  "hop",
  "hlslens",
  "harpoon",
  "indentline",
  "iswap",
  "lualine",
  "luasnip",
  "lsp.lsp-config",
  "maximize",
  "nvim-ts-rainbow",
  "neo-tree",
  "project",
  "treesitter",
  "telescope.telescope-config",
}

for _, module in ipairs(modules) do
  require("rockyz.plugin-config." .. module)
end
