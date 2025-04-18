-- Configs specific to fugitive buffer can be found at ~/.config/nvim/ftplugin/fugitive.vim

local group = vim.api.nvim_create_augroup('rockyz.fugitive.tab_diff_cfile', { clear = true })
vim.api.nvim_create_autocmd({ 'User' }, {
    group = group,
    pattern = 'FugitiveIndex,FugitiveCommit',
    callback = function()
        vim.keymap.set('n', 'dt', ':Gtabedit <Plug><cfile><Bar>Gdiffsplit! @<CR>', { buffer = 0, remap = true, silent = true })
    end,
})

vim.keymap.set('n', ',s', '<Cmd>tab Git<CR>')
vim.keymap.set('n', ',ds', ':tab Gdiffsplit<Space>')
vim.keymap.set('n', ',dt', ':Git difftool -y<Space>')
vim.keymap.set('n', ',c', ':Git commit -v<CR>')
vim.keymap.set('n', ',C', ':Git commit --amend -v<CR>')
vim.keymap.set('n', ',e', '<Cmd>Gedit<CR>')
vim.keymap.set('n', ',r', '<Cmd>Gread<CR>')
vim.keymap.set('n', ',w', '<Cmd>Gwrite<CR>')
vim.keymap.set('n', ',b', '<Cmd>Git blame -w<Bar>wincmd p<CR>')
vim.keymap.set({ 'n', 'x' }, ',B', ':GBrowse')

vim.keymap.set('n', ',,', '<Cmd>diffget //2<CR>')
vim.keymap.set('n', ',.', '<Cmd>diffget //3<CR>')
