-- Keep cursor position across matches
vim.g['asterisk#keeppos'] = 1

vim.keymap.set({ 'n', 'x' }, '*', '<Plug>(asterisk-z*)')
vim.keymap.set({ 'n', 'x' }, '#', '<Plug>(asterisk-z#)')
vim.keymap.set({ 'n', 'x' }, 'g*', '<Plug>(asterisk-gz*)')
vim.keymap.set({ 'n', 'x' }, 'g#', '<Plug>(asterisk-gz#)')
