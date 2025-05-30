local M = {}

---Read a file synchronously
---Taken from fzf-lua
function M.read_file(filepath)
    local fd = vim.uv.fs_open(filepath, 'r', 438)
    if fd == nil then
        return ''
    end
    local stat = assert(vim.uv.fs_stat(filepath))
    if stat.type ~= 'file' then
        return ''
    end
    local data = assert(vim.uv.fs_read(fd, stat.size, 0))
    assert(vim.uv.fs_close(fd))
    return data
end

---Read a file asynchronously
---Taken from fzf-lua
---@param callback fun(data: string) The callback accepts the read data as its argument
function M.read_file_async(filepath, callback)
    vim.uv.fs_open(filepath, 'r', 438, function(err_open, fd)
        if err_open then
            -- we must schedule this or we get
            -- E5560: nvim_exec must not be called in a lua loop callback
            vim.schedule(function()
                vim.notify(
                    string.format('Unable to open file %s, error: %s', filepath, err_open),
                    vim.log.levels.WARN
                )
            end)
        end
        vim.uv.fs_fstat(fd, function(err_fstat, stat)
            assert(not err_fstat, err_fstat)
            assert(stat)
            if stat.type ~= 'file' then
                return callback('')
            end
            vim.uv.fs_read(fd, stat.size, 0, function(err_read, data)
                assert(not err_read, err_read)
                vim.uv.fs_close(fd, function(err_close)
                    assert(not err_close, err_close)
                    callback(data)
                end)
            end)
        end)
    end)
end

---Write data to a file synchronously
function M.write_file(filepath, contents)
    local fd = assert(vim.uv.fs_open(filepath, 'w', 438))
    assert(vim.uv.fs_write(fd, contents, -1))
    assert(vim.uv.fs_close(fd))
end

---Write data to a file asynchronously
function M.write_file_async(filepath, contents)
    vim.uv.fs_open(filepath, 'w', 438, function(err_open, fd)
        if err_open then
            vim.schedule(function()
                vim.notify(
                    string.format('Unable to open file %s, error: %s', filepath, err_open),
                    vim.log.levels.WARN
                )
            end)
        end
        vim.uv.fs_write(fd, contents, -1, function(err_write, _)
            assert(not err_write, err_write)
            vim.uv.fs_close(fd, function(err_close)
                assert(not err_close, err_close)
            end)
        end)
    end)
end

return M
