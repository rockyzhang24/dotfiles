-- Load plugins config
local modules = {
  "aerial",
  "bqf",
  "bufferline",
  "cmp",
  "comment",
  "fidget",
  "ffhighlight",
  "foldsigns",
  "gitsigns",
  "hop",
  "indent",
  "lualine",
  "luasnip",
  "lightbulb",
  "lsp-signature",
  "hlslens",
  "lsp.lsp-config",
  "nvim-ts-rainbow",
  "nvim-tree",
  "scrollbar",
  "treesitter",
  "treesitter-context",
  "nvim-gps",
  "telescope.telescope-config",
  "spellsitter",
  "toggleterm",
}

for _, module in ipairs(modules) do
  require("plugin_config." .. module)
end
