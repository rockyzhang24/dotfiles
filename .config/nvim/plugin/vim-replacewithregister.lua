-- Usage:
--
-- [count]["x]<Leader>r{motion}: replace {motion} text with the contents of register x
-- [count]["x]grr: replace [count] lines with the contents of register x
-- {visual}["x]gr: replace the selection with the contents of register x

vim.keymap.set('n', '<Leader>r', '<Plug>ReplaceWithRegisterOperator')
vim.keymap.set('n', '<Leader>rr', '<Plug>ReplaceWithRegisterLine')
vim.keymap.set('x', '<Leader>r', '<Plug>ReplaceWithRegisterVisual')
