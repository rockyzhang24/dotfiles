local M = {}

local io_utils = require('rockyz.utils.io')
local debounce = require('rockyz.utils.debounce')

local mru_db = vim.fs.joinpath(vim.env.HOME, '.mru_file')
local db_stat = vim.uv.fs_stat(mru_db)
if not db_stat then
    local fd = assert(io.open(mru_db, 'w'))
    fd:close()
end

local max_entries = 1000
local flush_threshold = 10
local flush_delay_ms = 50
local pending_buffers = {}
local tmp_dir = vim.uv.os_tmpdir()
local last_stored_bufnr
local pending_buffer_count = 0

local ignored_filetypes = {
    gitcommit = true,
}

local function build_mru_list(db_file)
    local mru_files = {}
    local seen_files = { [''] = true }

    local function should_add_file(filename)
        if seen_files[filename] then
            return false
        end

        seen_files[filename] = true
        local file_stat = vim.uv.fs_stat(filename)
        return file_stat ~= nil and file_stat.type ~= 'directory' and #mru_files < max_entries
    end

    while #pending_buffers > 0 do
        local bufnr = table.remove(pending_buffers)
        if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buftype == '' then
            local filename = vim.api.nvim_buf_get_name(bufnr)
            if not vim.startswith(filename, tmp_dir) and should_add_file(filename) then
                table.insert(mru_files, filename)
            end
        end
    end

    local fd = assert(io.open(db_file, 'r'))
    for filename in fd:lines() do
        if should_add_file(filename) then
            table.insert(mru_files, filename)
        end
    end
    fd:close()

    return mru_files
end

local function update_mru_file(write_file)
    local mru_files = build_mru_list(mru_db)
    pending_buffer_count = 0
    write_file(mru_db, table.concat(mru_files, '\n'))
    return mru_files
end

-- Update the MRU database and return the MRU list
function M.list()
    return update_mru_file(io_utils.write_file_async)
end

local debounced_flush

function M.flush(force)
    last_stored_bufnr = nil

    if force then
        update_mru_file(io_utils.write_file)
        return
    end

    if not debounced_flush then
        debounced_flush = debounce(function()
            update_mru_file(io_utils.write_file_async)
        end, flush_delay_ms, false, true)
    end
    debounced_flush()
end

function M.store_buf(bufnr)
    bufnr = bufnr or tonumber(vim.fn.expand('<abuf>', true)) or vim.api.nvim_get_current_buf()

    if not vim.api.nvim_buf_is_valid(bufnr) then
        return
    end

    if vim.api.nvim_buf_get_name(bufnr) == '' then
        return
    end

    local buftype = vim.bo[bufnr].buftype
    local is_supported_buftype = buftype == '' or buftype == 'acwrite'
    if not is_supported_buftype or last_stored_bufnr == bufnr then
        return
    end

    local filetype = vim.bo[bufnr].filetype
    if ignored_filetypes[filetype] then
        return
    end

    -- Skip buffers displayed in a diff window, such as those opened by `ngd`
    vim.api.nvim_buf_call(bufnr, function()
        local winid = vim.api.nvim_get_current_win()
        -- `diff` may be set after BufEnter, so defer the check
        vim.schedule(function()
            if vim.api.nvim_win_is_valid(winid) and not vim.wo[winid].diff then
                table.insert(pending_buffers, bufnr)
                last_stored_bufnr = bufnr
                pending_buffer_count = pending_buffer_count + 1
                if pending_buffer_count >= flush_threshold then
                    M.list()
                end
            end
        end)
    end)
end

local mru_augroup = vim.api.nvim_create_augroup('rockyz.mru', { clear = true })

vim.api.nvim_create_autocmd({ 'BufEnter', 'FocusGained' }, {
    group = mru_augroup,
    callback = function(ev)
        M.store_buf(ev.buf)
    end,
})

vim.api.nvim_create_autocmd('VimLeavePre', {
    group = mru_augroup,
    callback = function()
        M.flush(true)
    end,
})

vim.api.nvim_create_autocmd({ 'VimSuspend', 'FocusLost' }, {
    group = mru_augroup,
    callback = function()
        M.flush()
    end,
})

return M
