require('treesitter-context').setup({
    max_lines = 3,
    multiline_threshold = 1,
    trim_scope = 'inner',
    mode = 'topline',
})
