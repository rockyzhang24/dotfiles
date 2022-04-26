-- Load plugins config
local modules = {
  "aerial",
  "bqf",
  "bufferline",
  "cmp",
  "comment",
  -- "fidget",
  -- "ffhighlight",
  "foldsigns",
  "gitsigns",
  "hop",
  "hlslens",
  "indent",
  "lualine",
  "luasnip",
  "lightbulb",
  "lsp-signature",
  "lsp.lsp-config",
  "nvim-ts-rainbow",
  "nvim-tree",
  "nvim-gps",
  "project",
  "scrollbar",
  "spellsitter",
  "treesitter",
  "treesitter-context",
  "telescope.telescope-config",
  "toggleterm",
}

for _, module in ipairs(modules) do
  require("plugin_config." .. module)
end
