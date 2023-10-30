vim.opt_local.foldmethod = 'manual'
vim.opt_local.foldlevel = 1
vim.opt_local.foldcolumn = '1'
vim.opt_local.signcolumn = 'no'
vim.opt_local.colorcolumn = ''

local ok, ufo = pcall(require, 'ufo')
if not ok then
  return
end

local bufnr = vim.api.nvim_get_current_buf()
local ranges = require('rockyz.plugins.nvim-ufo').gitProvider(bufnr)
ufo.attach(bufnr)
if ufo.applyFolds(bufnr, ranges) then
  ufo.closeAllFolds()
end

-- Delete keymaps J, K defined in vim-fugitive, which are duplicates of ]c and
-- [c. Also, K is re-defined in the config of nvim-ufo for fold preview.
if string.match(vim.fn.maparg('J'), 'NextHunk') then
  vim.keymap.del({'n', 'x', 'o'}, 'J', { buffer = bufnr })
end
if string.match(vim.fn.maparg('K'), 'PreviousHunk') then
  vim.keymap.del({'n', 'x', 'o'}, 'K', { buffer = bufnr })
end
