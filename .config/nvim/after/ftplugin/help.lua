vim.treesitter.start()

vim.keymap.set('n', 'q', ':q<CR>', { buffer = true, silent = true, nowait = true })

vim.cmd([[
    " Use default 'iskeyword' which is much nicer for "*", etc.
    " Since "K" (and 'keywordprg') uses ":help!" there is no need to screw up 'iskeyword'.
    set iskeyword&
]])
