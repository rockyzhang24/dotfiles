local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node

-- Mappings
vim.cmd [[
  imap <silent><expr> <C-j> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '' 
  inoremap <silent> <C-k> <cmd>lua require'luasnip'.jump(-1)<Cr>
  imap <silent><expr> <C-l> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-l>'

  snoremap <silent> <C-j> <cmd>lua require('luasnip').jump(1)<Cr>
  snoremap <silent> <C-k> <cmd>lua require('luasnip').jump(-1)<Cr>
]]

-- Snippets
ls.snippets = {

  -- All
  all = {

  },

  -- Filetypes
  java = {

  },
}
