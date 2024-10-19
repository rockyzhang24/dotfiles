-- Configs specific to fugitive buffer can be found at ~/.config/nvim/ftplugin/fugitive.vim

vim.api.nvim_create_augroup('fugitive_user_autocmd', { clear = true })
vim.api.nvim_create_autocmd({ 'User' }, {
    group = 'fugitive_user_autocmd',
    pattern = 'FugitiveIndex,FugitiveCommit',
    callback = function()
        vim.keymap.set(
            'n',
            'dt',
            ':Gtabedit <Plug><cfile><Bar>Gdiffsplit! @<CR>',
            { buffer = 0, remap = true, silent = true }
        )
    end,
})

vim.keymap.set('n', ',s', '<Cmd>tab Git<CR>')
vim.keymap.set('n', ',ds', ':tab Gdiffsplit<Space>')
vim.keymap.set('n', ',dt', ':Git difftool -y<Space>')
vim.keymap.set('n', ',c', ':Git commit<Space>')
vim.keymap.set('n', ',C', ':Git commit --amend<Space>')
vim.keymap.set('n', ',e', '<Cmd>Gedit<CR>')
vim.keymap.set('n', ',r', '<Cmd>Gread<CR>')
vim.keymap.set('n', ',w', '<Cmd>Gwrite<CR>')
vim.keymap.set('n', ',b', '<Cmd>Git blame -w<Bar>wincmd p<CR>')
vim.keymap.set({ 'n', 'x' }, ',B', ':GBrowse')

vim.keymap.set('n', ',,', '<Cmd>diffget //2<CR>')
vim.keymap.set('n', ',.', '<Cmd>diffget //3<CR>')
