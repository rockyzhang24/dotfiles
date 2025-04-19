vim.g.mw_no_mappings = 1

vim.keymap.set({ 'n', 'x' }, 'm*', '<Plug>MarkSet')
vim.keymap.set('n', 'm?', '<Plug>MarkToggle')
vim.keymap.set('n', 'm<BS>', '<Plug>MarkClear')

vim.keymap.set('n', '[m', '<Plug>MarkSearchCurrentPrev')
vim.keymap.set('n', ']m', '<Plug>MarkSearchCurrentNext')
