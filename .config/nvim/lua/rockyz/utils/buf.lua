-- Buffer-delete is highly inspired by folke/snackes.nvim's bufdelete
-- https://github.com/folke/snacks.nvim/blob/main/lua/snacks/bufdelete.lua @914c900 on Oct 13 2025

local M = {}

---@class rockyz.bufdelete.Opts
---@field bufnr number? Buffer to delete. Defaults to the current buffer
---@field file string? Delete buffer by file name. If provided, `buf` is ignored
---@field force boolean? Delete the buffer even if it is modified
---@field filter fun(buf: number): boolean? Filter buffers to delete
---@field wipe boolean? Wipe the buffer instead of deleting it

---Delete a buffer:
--- - either the current buffer if `bufnr` is not provided
--- - or the buffer `bufnr` if it is a number
--- - or every buffer filtered out by the filter
---@param opts number|rockyz.bufdelete.Opts
function M.bufdelete(opts)
    opts = opts or {}
    opts = type(opts) == 'number' and { bufnr = opts } or opts
    opts = type(opts) == 'function' and { filter = opts } or opts

    if type(opts.filter) == 'function' then
        for _, b in ipairs(vim.tbl_filter(opts.filter, vim.api.nvim_list_bufs())) do
            if vim.bo[b].buflisted then
                M.bufdelete(vim.tbl_extend('force', {}, opts, { bufnr = b, filter = false }))
            end
        end
        return
    end

    local bufnr = opts.bufnr or 0
    if opts.file then
        bufnr = vim.fn.bufnr(opts.file)
        if bufnr == -1 then
            return
        end
    end
    bufnr = bufnr == 0 and vim.api.nvim_get_current_buf() or bufnr

    if not vim.api.nvim_buf_is_valid(bufnr) then
        return
    end

    -- Check if the buffer is modified
    if vim.bo[bufnr].modified and not opts.force then
        local ok, choice = pcall(vim.fn.confirm, ("Save changes to %q?"):format(vim.fn.bufname(bufnr)), "&Yes\n&No\n&Cancel")
        if not ok or choice == 0 or choice == 3 then -- 0 for <Esc>/<C-c> and 3 for Cancel
            return
        elseif choice == 1 then -- yes
            vim.api.nvim_buf_call(bufnr, vim.cmd.write)
        end
    end

    -- Get the most recently used listed buffer that is not the one being deleted
    local info = vim.fn.getbufinfo({ buflisted = 1 })
    ---@param b vim.fn.getbufinfo.ret.item
    info = vim.tbl_filter(function(b)
        return b.bufnr ~= bufnr
    end, info)
    table.sort(info, function(a, b)
        return a.lastused > b.lastused
    end)

    local new_bufnr = info[1] and info[1].bufnr or vim.api.nvim_create_buf(true, false)

    -- replace the buffer in all windows showing it, trying to use the alternate buffer if possible
    for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
        local win_bufnr = new_bufnr
        vim.api.nvim_win_call(win, function() -- Try using alternative buffer
            local alt = vim.fn.bufnr('#')
            win_bufnr = alt >= 0 and alt ~= bufnr and vim.bo[alt].buflisted and alt or win_bufnr
        end)
        vim.api.nvim_win_set_buf(win, win_bufnr)
    end

    if vim.api.nvim_buf_is_valid(bufnr) then
        pcall(vim.cmd, (opts.wipe and 'bwipeout! ' or 'bdelete! ') .. bufnr)
    end
end

---Delete all buffers
---@param opts rockyz.bufdelete.Opts?
function M.bufdelete_all(opts)
    M.bufdelete(vim.tbl_extend('force', {}, opts or {}, {
        filter = function()
            return true
        end,
        wipe = true,
    }))
end

---Delete all buffers except the current one
---@param opts rockyz.bufdelete.Opts?
function M.bufdelete_other(opts)
    M.bufdelete(vim.tbl_extend('force', {}, opts or {}, {
        filter = function(b)
            return b ~= vim.api.nvim_get_current_buf()
        end,
        wipe = true,
    }))
end

-- Switch to the alternate buffer or the first available file in MRU list
function M.switch_last_buf()
    local alt_bufnr = vim.fn.bufnr('#')
    local curr_bufnr = vim.api.nvim_get_current_buf()
    if alt_bufnr ~= -1 and alt_bufnr ~= curr_bufnr then
        vim.cmd('buffer #')
    else
        local mru_list = require('rockyz.mru').list()
        local cur_bufname = vim.api.nvim_buf_get_name(curr_bufnr)
        for _, f in ipairs(mru_list) do
            if cur_bufname ~= f then
                vim.cmd('edit ' .. vim.fn.fnameescape(f))
                vim.cmd('silent! normal! `"')
                break
            end
        end
    end
end

return M
