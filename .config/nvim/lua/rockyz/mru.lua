local M = {}

local io_utils = require('rockyz.utils.io_utils')

local db = vim.env.HOME .. '/.mru_file'
local stat = vim.uv.fs_stat(db)
if not stat then
    io.open(db, 'w'):close()
end

local max = 1000
local bufs = {}
local tmp_prefix = vim.uv.os_tmpdir()
local last_bufnr

local ignored_filetypes = {
    'gitcommit',
    'netrw',
}

local function list(db_file)
    local mru_list = {}
    local fname_set = { [''] = true }

    local should_add_list = function(fname)
        if not fname_set[fname] then
            fname_set[fname] = true
            if vim.uv.fs_stat(fname) then
                return #mru_list < max
            end
        end
        return false
    end

    while #bufs > 0 do
        local bufnr = table.remove(bufs)
        if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buftype == '' then
            local fname = vim.api.nvim_buf_get_name(bufnr)
            if not fname:match(tmp_prefix) then
                if should_add_list(fname) then
                    table.insert(mru_list, fname)
                end
            end
        end
    end

    local fd = assert(io.open(db_file, 'r'))
    for fname in fd:lines() do
        if should_add_list(fname) then
            table.insert(mru_list, fname)
        end
    end
    fd:close()
    return mru_list
end

-- Update the mru database and output the mru list
function M.list()
    local mru_list = list(db)
    io_utils.write_file_async(db, table.concat(mru_list, '\n'))
    return mru_list
end

local debounced
function M.flush(force)
    last_bufnr = nil
    if force then
        io_utils.write_file(db, table.concat(list(db), '\n'))
    else
        if not debounced then
            debounced = require('rockyz.utils.debounce')(function()
                io_utils.write_file_async(db, table.concat(list(db), '\n'))
            end, 50, false, true)
        end
        debounced()
    end
end

local count = 0
function M.store_buf(bufnr)
    bufnr = bufnr or tonumber(vim.fn.expand('<abuf>', true)) or vim.api.nvim_get_current_buf()
    if vim.api.nvim_buf_get_name(bufnr) == '' then
        return
    end
    local buftype = vim.bo[bufnr].buftype
    if buftype ~= '' and buftype ~= 'acwrite' or last_bufnr == bufnr then
        return
    end
    local filetype = vim.bo[bufnr].filetype
    if vim.list_contains(ignored_filetypes, filetype) then
        return
    end
    table.insert(bufs, bufnr)
    last_bufnr = bufnr
    count = (count + 1) % 10
    if count == 0 then
        M.list()
    end
end

vim.api.nvim_create_augroup('rockyz.mru', { clear = true })
vim.api.nvim_create_autocmd({ 'BufEnter', 'FocusGained' }, {
    group = 'rockyz.mru',
    callback = function(args)
        require('rockyz.mru').store_buf(args.buf)
    end,
})
vim.api.nvim_create_autocmd('VimLeavePre', {
    group = 'rockyz.mru',
    callback = function()
        require('rockyz.mru').flush(true)
    end,
})
vim.api.nvim_create_autocmd({ 'VimSuspend', 'FocusLost' }, {
    group = 'rockyz.mru',
    callback = function()
        require('rockyz.mru').flush()
    end,
})

return M
