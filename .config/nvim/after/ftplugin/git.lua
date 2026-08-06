vim.opt_local.foldmethod = 'manual'
vim.opt_local.foldlevel = 1
vim.opt_local.foldcolumn = '1'
vim.opt_local.signcolumn = 'no'
vim.opt_local.colorcolumn = ''

-- Delete keymaps J, K defined in vim-fugitive, which are duplicates of ]c and
-- [c.
if string.match(vim.fn.maparg('J'), 'NextHunk') then
    vim.keymap.del({ 'n', 'x', 'o' }, 'J', { buffer = 0 })
end
if string.match(vim.fn.maparg('K'), 'PreviousHunk') then
    vim.keymap.del({ 'n', 'x', 'o' }, 'K', { buffer = 0 })
end

-- For the `:Git log` buffer opened by the `Ul` mapping (vim-fugitive)
if vim.b.fugitive_type == 'temp' then
    vim.keymap.set(
        'n',
        '<C-n>',
        [[<C-\><C-n>0j:call feedkeys('p')<CR>]],
        { buffer = 0, nowait = true, silent = true }
    )

    vim.keymap.set(
        'n',
        '<C-p>',
        [[<C-\><C-n>0k:call feedkeys('p')<CR>]],
        { buffer = 0, nowait = true, silent = true }
    )

    vim.keymap.set('n', 'q', '<C-w>q', { buffer = 0, nowait = true })

    vim.cmd([[match Comment /  \S\+ ([^)]\+)$/]])
end
