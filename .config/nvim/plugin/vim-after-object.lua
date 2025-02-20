-- Usage:
--
-- foo = b|ar = foobar      `|` denotes the cursor
--
-- va= selects `foobar` (forward search)
-- vaa= selects `bar = foobar` (backward search)
--

vim.api.nvim_create_autocmd('VimEnter', {
    group = vim.api.nvim_create_augroup('rockyz.vim-after-object', { clear = true }),
    callback = function()
        vim.fn['after_object#enable']({ 'r', 'R' }, '=', ':', '-', '#', ' ', '/', ';', '(', ')')
    end,
})
