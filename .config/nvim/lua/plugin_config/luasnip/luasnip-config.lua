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
        virt_text = {{"●", "Orange"}}
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


-- Split up snippets by filetype, load on demand and reload after change
-- Snippets for each filetype are saved as modules in ~/.config/nvim/lua/snippets/<filetype>.lua

-- Ref: https://github.com/L3MON4D3/LuaSnip/wiki/Nice-Configs#split-up-snippets-by-filetype-load-on-demand-and-reload-after-change-first-iteration

function _G.snippets_clear()
  for m, _ in pairs(ls.snippets) do
    package.loaded["snippets."..m] = nil
  end
  ls.snippets = setmetatable({}, {
    __index = function(t, k)
      local ok, m = pcall(require, "snippets." .. k)
      if not ok and not string.match(m, "^module.*not found:") then
        error(m)
      end
      t[k] = ok and m or {}
      return t[k]
    end
  })
end

_G.snippets_clear()

-- Reload after change
vim.cmd [[
augroup snippets_clear
autocmd!
autocmd BufWritePost ~/.config/nvim/lua/snippets/*.lua lua _G.snippets_clear()
augroup END
]]

function _G.edit_ft()
  -- returns table like {"lua", "all"}
  local fts = require("luasnip.util.util").get_snippet_filetypes()
  vim.ui.select(fts, {
    prompt = "Select which filetype to edit:"
  }, function(item, idx)
    -- selection aborted -> idx == nil
    if idx then
      vim.cmd("edit ~/.config/nvim/lua/snippets/"..item..".lua")
    end
  end)
end

-- A command to edit the snippet file
vim.cmd [[command! LuaSnipEdit :lua _G.edit_ft()]]
