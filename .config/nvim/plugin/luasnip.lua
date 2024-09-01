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
      -- active = {
      --   virt_text = { { '|', 'Operator' } },
      --   virt_text_pos = 'inline',
      -- },
      unvisited = {
        virt_text = { { '|', 'Conceal' } },
        virt_text_pos = 'inline',
      },
    },
    [types.insertNode] = {
    --   active = {
    --     virt_text = { { '|', 'Keyword' } },
    --     virt_text_pos = 'inline',
    --   },
      unvisited = {
        virt_text = { { '|', 'Conceal' } },
        virt_text_pos = 'inline',
      },
    },
    [types.exitNode] = {
      unvisited = {
        virt_text = { { '|', 'Conceal' } },
        virt_text_pos = 'inline',
      },
    },
  },
})

-- Expand the current item or jump to the next item within the snippet.
vim.keymap.set({ 'i', 's' }, '<C-j>', function()
  if luasnip.expand_or_jumpable() then
    luasnip.expand_or_jump()
  end
end)

-- Jump to the previous item within the snippet
vim.keymap.set({ 'i', 's' }, '<C-k>', function()
  if luasnip.jumpable(-1) then
    luasnip.jump(-1)
  end
end)

-- Change the choice in current choiceNode
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
-- Open a picker to select a choice in current choiceNode
vim.keymap.set({ 'i', 's' }, '<C-c>', function()
  if luasnip.choice_active() then
    require('luasnip.extras.select_choice')()
  end
end)

-- Insert on-the-fly snippet previously stored in register s
vim.keymap.set('i', '<C-r>s', function()
  require('luasnip.extras.otf').on_the_fly('s')
end)

-- Cancel the snippet session when leaving insert mode
-- Ref: https://github.com/L3MON4D3/LuaSnip/issues/656#issuecomment-1313310146
vim.api.nvim_create_autocmd('ModeChanged', {
  group = vim.api.nvim_create_augroup('unlink_snippet', { clear = true }),
  pattern = { 's:n', 'i:*' },
  callback = function(args)
    if
      luasnip.session
      and luasnip.session.current_nodes[args.buf]
      and not luasnip.session.jump_active
      and not luasnip.choice_active()
    then
      luasnip.unlink_current()
    end
  end,
})

-- Load my custom snippets
require('luasnip.loaders.from_lua').lazy_load({ paths = vim.fn.stdpath('config') .. '/luasnippets' })
require('luasnip.loaders.from_vscode').lazy_load({ paths = vim.fn.stdpath('config') .. '/codesnippets' })

-- Create a command to edit the snippet file associated with the current
-- filetype type
vim.api.nvim_create_user_command(
  'SnipEdit',
  ':lua require("luasnip.loaders").edit_snippet_files()',
  {}
)
