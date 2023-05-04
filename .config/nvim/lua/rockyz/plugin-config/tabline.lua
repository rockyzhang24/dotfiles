local map = require('rockyz.keymap').map
local cmd = vim.cmd

vim.o.showtabline = 2

local tabline = require('tabline.setup')
local g = tabline.global

local settings = {
  modes = { 'tabs', 'buffers', 'args' },
  mode_badge = { tabs = 'T', buffers = 'B', args = 'A', auto = '' },
  tabs_badge = false,
  label_style = 'order',
  show_full_path = true,
  mapleader = '',
  theme = false,  -- use the highlight groups defined in the colorscheme
  overflow_arrows = true,
  default_mappings = false,
  cd_mappings = true,
}

tabline.setup(settings)
tabline.mappings()

-- Mappings
map('n', '<Leader>tb', '<Cmd>Tabline mode buffers<CR>')  -- change to buffers mode
map('n', '<Leader>tt', '<Cmd>Tabline mode tabs<CR>')  -- change to tabs mode
map('n', '<Leader>ta', '<Cmd>Tabline mode args<CR>')  -- change to arglist mode
map('n', '<Leader>tf', '<Cmd>Tabline filtering!<CR>')  -- toggle buffer filtering based on cwd
map('n', '<Leader>tp', '<Cmd>Tabline pin!<CR>')  -- toggle pin buffer
map('n', '<Leader>tu', '<Cmd>Tabline reopen<CR>')  -- reopen the last closed tab
map('n', '<Leader>tU', '<Cmd>Tabline closedtabs<CR>')  -- fzf choose closed tab to reopen
map('n', '<Leader>sn', '<Cmd>Tabline session new<CR>')  -- create a new session
map('n', '<Leader>ss', '<Cmd>Tabline session save<CR>')  -- save the session
map('n', '<Leader>sl', '<Cmd>Tabline session load<CR>')  -- list sessions via fzf and load the selected session
map('n', '<Leader>sd', '<Cmd>Tabline session delete<CR>')  -- list sessions via fzf and delete the selected session
map('n', 'gb', '<Plug>(TabSelect)', { remap = true })  -- gb followed by a number to select the buffer or tab
map('n', '<Leader>sp', function () -- toggle session persistance
  if not g.persist then
    cmd('Tabline persist')
    if g.persist then
      print('Session persistance is enabled')
    end
  else
    cmd('Tabline persist!')
    print('Session persistance is disabled')
  end
end)
