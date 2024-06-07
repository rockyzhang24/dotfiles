-- For seeking behavior: prefer multiline targets around cursor over distant targets within cursor
-- line
vim.g.targets_seekRanges = 'cc cr cb cB lc ac Ac lr lb ar ab lB Ar aB Ab AB rr ll rb al rB Al bb aa bB Aa BB AA'

-- Add the previous cursor position to the jump list if the cursor was not inside the target
vim.g.targets_jumpRanges = 'rr rb rB bb bB BB ll al Al aa Aa AA'

vim.api.nvim_create_autocmd({ 'User' }, {
  group = vim.api.nvim_create_augroup('targets_mappings_control', { clear = true }),
  pattern = 'targets#mappings#user',
  callback = function()
    -- Remove the mapping for argument text objects.
    -- I use nvim-treesitter-textobjects to handle that.
    vim.cmd([[
      call targets#mappings#extend({
        \ 'a': {},
        \ })
    ]])
  end,
})
