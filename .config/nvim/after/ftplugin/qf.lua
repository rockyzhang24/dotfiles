vim.wo.colorcolumn = ''
vim.wo.statusline = ''

-- Run substitute for each entry
vim.keymap.set('n', 'r', ':cdo s///gc<Left><Left><Left>', { buffer = true })
