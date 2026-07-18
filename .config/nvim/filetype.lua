vim.filetype.add({
    pattern = {
        ---Detect large files early and assign the `bigfile` filetype to disable expensive features.
        ---Based on the large-file detection in folke/snacks.nvim.
        ---@param path? string
        ---@param bufnr? integer
        ---@return string?
        ['.*'] = function(path, bufnr)
            if not path or not bufnr or vim.bo[bufnr].filetype == 'bigfile' then
                return
            end

            if path ~= vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr)) then
                return
            end

            local file_size = vim.fn.getfsize(path)
            if file_size <= 0 then
                return
            end

            if file_size > vim.g.bigfile_size_threshold then
                return 'bigfile'
            end

            local line_count = vim.api.nvim_buf_line_count(bufnr)

            -- (file_size - line_count) / line_count: This gives the average length (i.e., average
            -- bytes) of the content per line, excluding the newline character
            return (file_size - line_count) / line_count > vim.g.bigfile_line_length_threshold and 'bigfile' or nil
        end,
    },
})
