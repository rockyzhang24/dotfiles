vim.opt_local.foldmethod = 'manual'
vim.opt_local.foldlevel = 1
vim.opt_local.foldcolumn = '1'
vim.opt_local.signcolumn = 'no'
vim.opt_local.colorcolumn = ''

local bufnr = vim.api.nvim_get_current_buf()

-- Delete keymaps J, K defined in vim-fugitive, which are duplicates of ]c and
-- [c.
if string.match(vim.fn.maparg('J'), 'NextHunk') then
    vim.keymap.del({ 'n', 'x', 'o' }, 'J', { buffer = bufnr })
end
if string.match(vim.fn.maparg('K'), 'PreviousHunk') then
    vim.keymap.del({ 'n', 'x', 'o' }, 'K', { buffer = bufnr })
end
