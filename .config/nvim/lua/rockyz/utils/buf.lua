-- Buffer deletion is inspired by folke/snacks.nvim.
-- https://github.com/folke/snacks.nvim/blob/main/lua/snacks/bufdelete.lua @914c900 (Oct 13, 2025).

local M = {}

---@alias rockyz.bufdelete.Filter fun(bufnr: integer): boolean

---@class rockyz.bufdelete.Opts
---@field bufnr? integer Buffer to delete. Defaults to the current buffer.
---@field file? string Delete the buffer for this file. If provided, `bufnr` is ignored.
---@field force? boolean Delete the buffer even if it is modified
---@field filter? rockyz.bufdelete.Filter Return true for each buffer to delete
---@field wipe? boolean Wipe the buffer instead of deleting it

---Delete a buffer:
--- - either the current buffer if `bufnr` is not provided
--- - or the buffer `bufnr` if it is a number
--- - or every buffer for which the filter returns true
---@param opts? integer|rockyz.bufdelete.Filter|rockyz.bufdelete.Opts
function M.bufdelete(opts)
    if type(opts) == 'number' then
        opts = { bufnr = opts }
    elseif type(opts) == 'function' then
        opts = { filter = opts }
    else
        opts = opts or {}
    end

    if type(opts.filter) == 'function' then
        for _, candidate_bufnr in ipairs(vim.tbl_filter(opts.filter, vim.api.nvim_list_bufs())) do
            if vim.api.nvim_buf_is_valid(candidate_bufnr) and vim.bo[candidate_bufnr].buflisted then
                local child_opts = vim.tbl_extend('force', {}, opts, { bufnr = candidate_bufnr })
                child_opts.filter = nil
                child_opts.file = nil
                M.bufdelete(child_opts)
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
    local buffer_info = vim.fn.getbufinfo({ buflisted = 1 })

    ---@param buffer vim.fn.getbufinfo.ret.item
    buffer_info = vim.tbl_filter(function(buffer)
        return buffer.bufnr ~= bufnr
    end, buffer_info)

    table.sort(buffer_info, function(first, second)
        return first.lastused > second.lastused
    end)

    local replacement_bufnr = buffer_info[1] and buffer_info[1].bufnr or vim.api.nvim_create_buf(true, false)

    -- Replace the buffer in every window showing it, preferring the alternate buffer.
    for _, winid in ipairs(vim.fn.win_findbuf(bufnr)) do
        if vim.api.nvim_win_is_valid(winid) then
            local replacement_for_window = replacement_bufnr

            -- Prefer the alternate buffer for this window
            vim.api.nvim_win_call(winid, function()
                local alternate_bufnr = vim.fn.bufnr('#')
                local has_alternate_buffer = alternate_bufnr > 0
                    and alternate_bufnr ~= bufnr
                    and vim.api.nvim_buf_is_valid(alternate_bufnr)
                    and vim.bo[alternate_bufnr].buflisted

                if has_alternate_buffer then
                    replacement_for_window = alternate_bufnr
                end
            end)

            vim.api.nvim_win_set_buf(winid, replacement_for_window)
        end
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
        filter = function(candidate_bufnr)
            return candidate_bufnr ~= vim.api.nvim_get_current_buf()
        end,
        wipe = true,
    }))
end

-- Switch to the alternate buffer or the first available MRU file
function M.switch_last_buf()
    local alternate_bufnr = vim.fn.bufnr('#')
    local current_bufnr = vim.api.nvim_get_current_buf()

    local has_alternate_buffer = alternate_bufnr > 0
        and alternate_bufnr ~= current_bufnr
        and vim.api.nvim_buf_is_valid(alternate_bufnr)

    if has_alternate_buffer then
        vim.cmd('buffer #')
    else
        local mru_files = require('rockyz.mru').list()
        local current_buffer_name = vim.api.nvim_buf_get_name(current_bufnr)

        for _, filename in ipairs(mru_files) do
            if current_buffer_name ~= filename then
                vim.cmd('edit ' .. vim.fn.fnameescape(filename))
                vim.cmd('silent! normal! `"')
                break
            end
        end
    end
end

return M
