local ls = require("luasnip")

-- Shorthands
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local l = require("luasnip.extras").lambda
local rep = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
local m = require("luasnip.extras").match
local n = require("luasnip.extras").nonempty
local dl = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local types = require("luasnip.util.types")
local conds = require("luasnip.extras.expand_conditions")

-- Configurations
ls.config.set_config({
  history = true,
  updateevents = "TextChanged, TextChangedI",
  enable_autosnippets = true,
})

-- Mappings
vim.cmd [[
  imap <silent><expr> <C-j> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : ''
  inoremap <silent> <C-k> <cmd>lua require'luasnip'.jump(-1)<Cr>
  imap <silent><expr> <C-l> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-l>'
  smap <silent><expr> <C-l> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-l>'

  snoremap <silent> <C-j> <cmd>lua require('luasnip').jump(1)<Cr>
  snoremap <silent> <C-k> <cmd>lua require('luasnip').jump(-1)<Cr>
]]

-- Define snippets here
-- Find examples here: https://github.com/L3MON4D3/LuaSnip/blob/master/Examples/snippets.lua
ls.snippets = {

  -- All
  all = {

  },

  -- Filetypes
  java = {

  },
}

-- Autosnippets (will be expanded automatically after typing the trigger)
ls.autosnippets = {
	all = {

	},
}
