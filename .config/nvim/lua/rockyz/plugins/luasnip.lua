-- An offcial example to demo the basic config and how to create snippets:
-- https://github.com/L3MON4D3/LuaSnip/blob/master/Examples/snippets.lua

local luasnip = require('luasnip')
local types = require('luasnip.util.types')

luasnip.setup({
  history = true,
  delete_check_events = 'TextChanged',
  update_events = 'TextChanged, TextChangedI',
  region_check_events = 'CursorHold',
  enable_autosnippets = true,
  store_selection_keys = '<TAB>',
  ext_opts = {
    [types.choiceNode] = {
      active = {
        virt_text = { { '●', 'Operator' } },
        virt_text_pos = 'inline',
      },
      unvisited = {
        virt_text = { { '●', 'Comment' } },
        virt_text_pos = 'inline',
      },
    },
    [types.insertNode] = {
      active = {
        virt_text = { { '●', 'Keyword' } },
        virt_text_pos = 'inline',
      },
      unvisited = {
        virt_text = { { '●', 'Comment' } },
        virt_text_pos = 'inline',
      },
    },
  },
  -- Use treesitter for getting the current filetype. This allows correctly resolving
  -- the current filetype in eg. a markdown-code block or `vim.cmd()`.
  ft_func = require('luasnip.extras.filetype_functions').from_cursor,
})

-- Expansion: this will expand the current item or jump to the next item within the snippet.
vim.keymap.set({ 'i', 's' }, '<C-j>', function()
  if luasnip.expand_or_jumpable() then
    luasnip.expand_or_jump()
  end
end)

-- Jump backwards: this always moves to the previous item within the snippet
vim.keymap.set({ 'i', 's' }, '<C-k>', function()
  if luasnip.jumpable(-1) then
    luasnip.jump(-1)
  end
end)

-- Changing choices in choiceNodes
vim.keymap.set({ 'i', 's' }, '<C-l>', function()
  if luasnip.choice_active() then
    luasnip.change_choice(1)
  end
end)
vim.keymap.set({ 'i', 's' }, '<C-h>', function()
  if luasnip.choice_active() then
    luasnip.change_choice(-1)
  end
end)

-- Snippets are stored in separate files.
-- Ref: https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md#lua
require('luasnip.loaders.from_lua').lazy_load({ paths = '~/.config/nvim/lua/rockyz/snippets' })

-- Create a command to edit the snippet file associated with the current
-- filetype type
vim.api.nvim_create_user_command(
  'SnipEdit',
  ':lua require("luasnip.loaders.from_lua").edit_snippet_files()',
  {}
)
