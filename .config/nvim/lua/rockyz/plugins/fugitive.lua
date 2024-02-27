-- Configs specific to fugitive buffer can be found at ~/.config/nvim/ftplugin/fugitive.vim

local M = {}

vim.api.nvim_create_augroup('fugitive_user_autocmd', { clear = true })
vim.api.nvim_create_autocmd({ 'User' }, {
  group = 'fugitive_user_autocmd',
  pattern = 'FugitiveIndex,FugitiveCommit',
  callback = function()
    vim.keymap.set(
      'n',
      'dt',
      ':Gtabedit <Plug><cfile><Bar>Gdiffsplit! @<CR>',
      { buffer = 0, remap = true, silent = true }
    )
  end,
})

function M.git_status()
  local bufName = vim.api.nvim_buf_get_name(0)
  if vim.fn.winnr('$') == 1 and bufName == '' then
    vim.cmd('Git')
  else
    vim.cmd('tab Git')
  end
  if bufName == '' then
    vim.cmd('silent! noautocmd bwipeout #')
  end
end

vim.keymap.set('n', ',s', M.git_status)
vim.keymap.set('n', ',ds', ':tab Gdiffsplit<Space>')
vim.keymap.set('n', ',dt', ':Git difftool -y<Space>')
vim.keymap.set('n', ',c', ':Git commit<Space>')
vim.keymap.set('n', ',C', ':Git commit --amend<Space>')
vim.keymap.set('n', ',e', ':Gedit<CR>', { silent = true })
vim.keymap.set('n', ',r', ':Gread<CR>', { silent = true })
vim.keymap.set('n', ',w', ':Gwrite<CR>', { silent = true })
vim.keymap.set('n', ',b', ':Git blame -w<Bar>wincmd p<CR>', { silent = true })
vim.keymap.set({ 'n', 'x' }, ',B', ':GBrowse')

vim.keymap.set('n', ',,', ':diffget //2<CR>', { silent = true })
vim.keymap.set('n', ',.', ':diffget //3<CR>', { silent = true })

return M
