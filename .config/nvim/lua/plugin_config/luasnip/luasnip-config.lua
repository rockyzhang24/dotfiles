local ls = require("luasnip")
local types = require("luasnip.util.types")

-- Configurations
ls.config.setup({
  history = true,
  delete_check_events = "TextChanged",
  updateevents = "InsertLeave",
  region_check_events = "CursorHold",
  enable_autosnippets = false,
  store_selection_keys = "<TAB>",
  ext_opts = {
    [types.choiceNode] = {
      active = {
        virt_text = {{"●", "Orange"}}
      }
    },
  },
})

-- Mappings
vim.cmd [[
imap <silent><expr> <C-j> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : ''
inoremap <silent> <C-k> <cmd>lua require'luasnip'.jump(-1)<Cr>

imap <silent><expr> <C-l> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-l>'
smap <silent><expr> <C-l> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-l>'
imap <silent><expr> <C-h> luasnip#choice_active() ? '<Plug>luasnip-prev-choice' : '<C-h>'
smap <silent><expr> <C-h> luasnip#choice_active() ? '<Plug>luasnip-prev-choice' : '<C-h>'

snoremap <silent> <C-j> <cmd>lua require('luasnip').jump(1)<Cr>
snoremap <silent> <C-k> <cmd>lua require('luasnip').jump(-1)<Cr>
]]

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
