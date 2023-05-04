-- Configs specific to fugitive buffer can be found at ~/.config/nvim/ftplugin/fugitive.vim

local M = {}
local cmd = vim.cmd
local fn = vim.fn
local api = vim.api
local map = require('rockyz.keymap').map

api.nvim_create_augroup('fugitive_user_autocmd', { clear = true })
api.nvim_create_autocmd({ 'User' }, {
  group = 'fugitive_user_autocmd',
  pattern = 'FugitiveIndex,FugitiveCommit',
  callback = function()
    map('n',
        'dt',
        ':Gtabedit <Plug><cfile><Bar>Gdiffsplit! @<CR>',
        { buffer = 0, remap = true, silent = true })
  end,
})

function M.git_status()
  local bufName = api.nvim_buf_get_name(0)
  if fn.winnr('$') == 1 and bufName == '' then
    cmd('Git')
  else
    cmd('tab Git')
  end
  if bufName == '' then
    cmd('silent! noautocmd bwipeout #')
  end
end

map('n', ',s', M.git_status)
map('n', ',d', ':tab Gdiffsplit<Space>', {silent = false})
map('n', ',t', ':Git difftool -y<Space>', {silent = false})
map('n', ',c', ':Git commit<Space>', {silent = false})
map('n', ',C', ':Git commit --amend<Space>', {silent = false})
map('n', ',e', ':Gedit<CR>')
map('n', ',r', ':Gread<CR>')
map('n', ',w', ':Gwrite<CR>')
map('n', ',b', ':Git blame -w<Bar>wincmd p<CR>')
map('n', ',,', ':diffget //2<CR>')
map('n', ',.', ':diffget //3<CR>')

return M
