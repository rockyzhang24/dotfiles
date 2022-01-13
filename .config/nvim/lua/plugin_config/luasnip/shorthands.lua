-- Put all the shorthands for defining snippets into the non-global environment of the caller of this module
-- Ref: https://github.com/L3MON4D3/Dotfiles/blob/master/.config/nvim/lua/plugins/luasnip/helpers.lua

local ls = require("luasnip")
local M = {}

local shorthands = {
  s = ls.snippet,
  sn = ls.snippet_node,
  isn = ls.indent_snippet_node,
  t = ls.text_node,
  i = ls.insert_node,
  f = ls.function_node,
  c = ls.choice_node,
  d = ls.dynamic_node,
  r = ls.restore_node,
  l = require("luasnip.extras").lambda,
  rep = require("luasnip.extras").rep,
  p = require("luasnip.extras").partial,
  m = require("luasnip.extras").match,
  n = require("luasnip.extras").nonempty,
  dl = require("luasnip.extras").dynamic_lambda,
  fmt = require("luasnip.extras.fmt").fmt,
  fmta = require("luasnip.extras.fmt").fmta,
  conds = require("luasnip.extras.expand_conditions"),
  parse = ls.parser.parse_snippet,
  ai = require("luasnip.nodes.absolute_indexer"),
}

function M.setup_shorthands()
	setfenv(2, vim.tbl_extend("force", _G, shorthands))
end

return M
