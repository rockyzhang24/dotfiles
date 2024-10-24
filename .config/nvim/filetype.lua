vim.filetype.add({
    pattern = {
        -- Borrowed from LazyVim. Set filetype to bigfile in order to later disable features that
        -- don't perform well with big files.
        ['.*'] = function(path, bufnr)
            return vim.bo[bufnr]
                    and vim.bo[bufnr].filetype ~= 'bigfile'
                    and path
                    and vim.fn.getfsize(path) > vim.g.bigfile_size
                    and 'bigfile'
                or nil
        end,
    },
})
