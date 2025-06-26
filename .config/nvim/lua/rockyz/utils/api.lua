local M = {}

---This is the get_lines() function from https://github.com/neovim/neovim/blob/master/runtime/lua/vim/lsp/util.lua
---
---Gets the zero-indexed lines from the given buffer.
---Works on unloaded buffers by reading the file using libuv to bypass buf reading events.
---Falls back to loading the buffer and nvim_buf_get_lines for buffers with non-file URI.
---
---@param bufnr integer bufnr to get lines from
---@param rows integer[] zero-indexed line numbers
---@return table<integer, string>|string # A table mapping rows to lines
function M.get_lines(bufnr, rows)
    if bufnr == nil or bufnr == 0 then
        bufnr = vim.api.nvim_get_current_buf()
    end

    local function buf_lines()
        local lines = {}
        for _, row in ipairs(rows) do
            lines[row] = (vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false) or { '' })[1]
        end
        return lines
    end

    if vim.fn.bufloaded(bufnr) == 1 then
        return buf_lines()
    end

    local uri = vim.uri_from_bufnr(bufnr)

    if uri:sub(1, 4) ~= 'file' then
        vim.fn.bufload(bufnr)
        return buf_lines()
    end

    local filename = vim.api.nvim_buf_get_name(bufnr)
    if vim.fn.isdirectory(filename) ~= 0 then
        return {}
    end

    -- get the data from the file
    local fd = vim.uv.fs_open(filename, 'r', 438)
    if not fd then
        return ''
    end
    local stat = assert(vim.uv.fs_fstat(fd))
    local data = assert(vim.uv.fs_read(fd, stat.size, 0))
    vim.uv.fs_close(fd)

    local lines = {}
    local need = 0
    for _, row in pairs(rows) do
        if not lines[row] then
            need = need + 1
        end
        lines[row] = true
    end

    local found = 0
    local lnum = 0

    for line in string.gmatch(data, '([^\n]*)\n?') do
        if lines[lnum] == true then
            lines[lnum] = line
            found = found + 1
            if found == need then
                break
            end
        end
        lnum = lnum + 1
    end

    for i, line in pairs(lines) do
        if line == true then
            lines[i] = ''
        end
    end
    return lines
end

return M
