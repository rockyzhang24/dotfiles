local M = {}

---This is the get_lines() function from https://github.com/neovim/neovim/blob/master/runtime/lua/vim/lsp/util.lua
---
---Gets the zero-indexed lines from abuffer.
---Works on unloaded buffers by reading the file and bypass buf reading events.
---Falls back to loading the buffer and nvim_buf_get_lines for buffers with non-file URI.
---
---@param buf integer buffer handle to get the lines from
---@param rows integer[] zero-indexed line numbers
---@return table<integer, string>|string # A table mapping rows to lines
function M.get_lines(buf, rows)
    local function buf_lines()
        local row_line = {} --- @type table<integer,string>
        for _, row in ipairs(rows) do
            row_line[row] = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ''
        end
        return row_line
    end

    -- Use loaded buffer if available
    if vim.fn.bufloaded(buf) == 1 then
        return buf_lines()
    end

    -- Load the buffer if this is not a file URI.
    -- Custom language server protocol extensions can result in servers sending
    -- URIs with custom schemes. Plugins are able to load these via `BufReadCmd` autocmds.
    if not vim.startswith(vim.uri_from_bufnr(buf), 'file://') then
        vim.fn.bufload(buf)
        return buf_lines()
    end

    local row_line = {} --- @type table<integer, string>
    for _, row in pairs(rows) do
        row_line[row] = ''
    end

    -- Get the data from the file.
    local success, data = pcall(vim.fn.readblob, vim.api.nvim_buf_get_name(buf))
    if not success then
        return row_line
    end

    local need = vim.tbl_count(row_line)
    local row = 0
    for line in string.gmatch(data, '([^\n]*)\n?') do
        if row_line[row] then
            row_line[row] = line
            need = need - 1
            if need == 0 then
                break
            end
        end
        row = row + 1
    end
    return row_line
end

return M
