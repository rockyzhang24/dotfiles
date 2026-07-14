local M = {}

local file_mode = 438

---@param operation string
---@param filepath string
---@param err string
local function notify_file_error(operation, filepath, err)
    -- Schedule this to avoid E5560: nvim_exec must not be called in a lua loop callback
    vim.schedule(function()
        vim.notify(
            string.format('Unable to %s file %s, error: %s', operation, filepath, err),
            vim.log.levels.WARN
        )
    end)
end

---@param fd integer
---@param filepath string
---@param callback? fun(err?: string)
local function close_file_async(fd, filepath, callback)
    vim.uv.fs_close(fd, function(err_close)
        if err_close then
            notify_file_error('close', filepath, err_close)
        end
        if callback then
            callback(err_close)
        end
    end)
end

---Read a file synchronously
---Taken from fzf-lua
---@param filepath string
---@return string
function M.read_file(filepath)
    local fd = vim.uv.fs_open(filepath, 'r', file_mode)
    if not fd then
        return ''
    end

    local file_stat = vim.uv.fs_fstat(fd)
    if not file_stat or file_stat.type ~= 'file' then
        assert(vim.uv.fs_close(fd))
        return ''
    end

    local contents, err_read = vim.uv.fs_read(fd, file_stat.size, 0)
    local closed, err_close = vim.uv.fs_close(fd)
    assert(contents, err_read)
    assert(closed, err_close)
    return contents
end

---Read a file asynchronously
---Taken from fzf-lua
---@param filepath string
---@param callback fun(data: string)
function M.read_file_async(filepath, callback)
    vim.uv.fs_open(filepath, 'r', file_mode, function(err_open, fd)
        if err_open or not fd then
            notify_file_error('open', filepath, err_open or 'unknown error')
            callback('')
            return
        end

        vim.uv.fs_fstat(fd, function(err_fstat, file_stat)
            if err_fstat or not file_stat then
                notify_file_error('inspect', filepath, err_fstat or 'unknown error')
                close_file_async(fd, filepath, function()
                    callback('')
                end)
                return
            end

            if file_stat.type ~= 'file' then
                close_file_async(fd, filepath, function()
                    callback('')
                end)
                return
            end

            vim.uv.fs_read(fd, file_stat.size, 0, function(err_read, contents)
                if err_read then
                    notify_file_error('read', filepath, err_read)
                    contents = ''
                end

                close_file_async(fd, filepath, function()
                    callback(contents or '')
                end)
            end)
        end)
    end)
end

---Write data to a file synchronously
---@param filepath string
---@param contents string
function M.write_file(filepath, contents)
    local fd = assert(vim.uv.fs_open(filepath, 'w', file_mode))
    local written, err_write = vim.uv.fs_write(fd, contents, -1)
    local closed, err_close = vim.uv.fs_close(fd)
    assert(written, err_write)
    assert(closed, err_close)
end

---Write data to a file asynchronously
---@param filepath string
---@param contents string
---@param callback? fun(err?: string)
function M.write_file_async(filepath, contents, callback)
    vim.uv.fs_open(filepath, 'w', file_mode, function(err_open, fd)
        if err_open or not fd then
            local err = err_open or 'unknown error'
            notify_file_error('open', filepath, err)
            if callback then
                callback(err)
            end
            return
        end

        vim.uv.fs_write(fd, contents, -1, function(err_write)
            if err_write then
                notify_file_error('write', filepath, err_write)
            end

            close_file_async(fd, filepath, function(err_close)
                if callback then
                    callback(err_write or err_close)
                end
            end)
        end)
    end)
end

return M
