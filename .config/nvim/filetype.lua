vim.filetype.add({
    pattern = {
        -- Borrowed from folke/snacks.nvim. Set filetype to bigfile in order to disable some
        -- features due to performance issues.
        ['.*'] = function(path, bufnr)
            if not path or not bufnr or vim.bo[bufnr].filetype == 'bigfile' then
                return
            end
            if path ~= vim.api.nvim_buf_get_name(bufnr) then
                return
            end
            local size = vim.fn.getfsize(path)
            if size <= 0 then
                return
            end
            if size > vim.g.bigfile_size then
                return 'bigfile'
            end
            local lines = vim.api.nvim_buf_line_count(bufnr)
            -- (size - lines) / lines: This gives the average length (i.e., average bytes) of the
            -- content per line, excluding the newline character
            return (size - lines) / lines > vim.g.bigfile_line_length and 'bigfile' or nil
        end,
    },
})
