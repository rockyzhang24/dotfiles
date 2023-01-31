-- An offcial example to demo the basic config and how to create snippets:
-- https://github.com/L3MON4D3/LuaSnip/blob/master/Examples/snippets.lua

local ls = require("luasnip")
local types = require("luasnip.util.types")

-- Configurations
ls.config.setup({
  history = true,
  delete_check_events = "TextChanged",
  updateevents = "TextChanged, TextChangedI",
  region_check_events = "CursorHold",
  enable_autosnippets = true,
  store_selection_keys = "<TAB>",
  ext_opts = {
    [types.choiceNode] = {
      active = {
        virt_text = { { "●", "Comment" } }
      }
    },
  },
  -- Use treesitter for getting the current filetype. This allows correctly resolving
  -- the current filetype in eg. a markdown-code block or `vim.cmd()`.
  ft_func = require("luasnip.extras.filetype_functions").from_cursor
})

-- Mappings (vim.keymap requires Neovim 0.7)

local function map(mode, l, r, opts)
  opts = opts or {}
  opts.silent = true
  vim.keymap.set(mode, l, r, opts)
end

-- <C-j> is my expansion key
-- This will expand the current item or jump to the next item within the snippet.
map({ "i", "s" }, "<C-j>", function()
  if ls.expand_or_jumpable() then
    ls.expand_or_jump()
  end
end)

-- <C-k> is my jump backwards key.
-- This always moves to the previous item within the snippet
map({ "i", "s" }, "<C-k>", function()
  if ls.jumpable(-1) then
    ls.jump(-1)
  end
end)

-- <C-l> and <C-h> for changing choices in choiceNodes
map({ "i", "s" }, "<C-l>", function()
  if ls.choice_active() then
    ls.change_choice(1)
  end
end)
map({ "i", "s" }, "<C-h>", function()
  if ls.choice_active() then
    ls.change_choice(-1)
  end
end)


-- Snippets are stored in separate files.
-- Ref: https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md#lua
require("luasnip.loaders.from_lua").lazy_load({ paths = "~/.config/nvim/lua/rockyz/snippets" })

-- Create a command to edit the snippet file associated with the current
-- filetype type
vim.api.nvim_create_user_command('LuaSnipEdit', ':lua require("luasnip.loaders.from_lua").edit_snippet_files()', {})
