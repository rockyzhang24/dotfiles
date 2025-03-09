local treesj = require('treesj')
treesj.setup({
    use_default_keymaps = false,
})

vim.keymap.set('n', '\\j', treesj.toggle)
