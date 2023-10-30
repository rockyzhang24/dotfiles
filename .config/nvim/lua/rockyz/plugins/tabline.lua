-- Configuration for rockyzhang24/tabline.nvim forked from mg979/tabline.nvim

vim.o.showtabline = 2

local tabline = require('tabline.setup')
local g = tabline.global

local settings = {
  modes = { 'tabs', 'buffers', 'args' },
  mode_badge = { tabs = 'TABS', buffers = 'BUFS', args = 'ARGS', auto = '' },
  tabs_badge = {
    visibility = { 'tabs', 'buffers', 'args' },
    left = true,
    fraction = true,
  },
  label_style = 'order',
  show_full_path = true,
  mapleader = '',
  theme = false, -- use the highlight groups defined in the colorscheme
  overflow_arrows = true,
  default_mappings = false,
  cd_mappings = true,
  fzf_layout = vim.g.fzf_layout,
}

tabline.setup(settings)
tabline.mappings()

-- Tabline mappings
vim.keymap.set('n', '<Leader>tb', '<Cmd>Tabline mode buffers<CR>')
vim.keymap.set('n', '<Leader>tt', '<Cmd>Tabline mode tabs<CR>')
vim.keymap.set('n', '<Leader>ta', '<Cmd>Tabline mode args<CR>')
vim.keymap.set('n', '<Leader>tf', '<Cmd>Tabline filtering!<CR>')
vim.keymap.set('n', '<Leader>tp', '<Cmd>Tabline pin!<CR>')
vim.keymap.set('n', '<Leader>tu', '<Cmd>Tabline reopen<CR>')
vim.keymap.set('n', '<Leader>tU', '<Cmd>Tabline closedtabs<CR>')
-- Session mappings
vim.keymap.set('n', '<Leader>sn', '<Cmd>Tabline session new<CR>')
vim.keymap.set('n', '<Leader>ss', '<Cmd>Tabline session save<CR>')
vim.keymap.set('n', '<Leader>sl', '<Cmd>Tabline session load<CR>')
vim.keymap.set('n', '<Leader>sd', '<Cmd>Tabline session delete<CR>')
vim.keymap.set('n', '<Leader>sp', function()
  if not g.persist then
    vim.cmd('Tabline persist')
    if g.persist then
      print('Session persistance is enabled')
    end
  else
    vim.cmd('Tabline persist!')
    print('Session persistance is disabled')
  end
end)
