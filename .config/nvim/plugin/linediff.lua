-- Line-wise VISUAL mode D
vim.keymap.set('x', 'D', function()
    return vim.fn.mode() == 'V' and ':Linediff<CR>' or 'D'
end, { expr = true })
