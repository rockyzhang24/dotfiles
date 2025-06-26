-- Highly inspired by folke/snackes.nvim
-- https://github.com/folke/snacks.nvim/blob/main/lua/snacks/bufdelete.lua

local M = {}

---@class rockyz.bufdelete.Opts
---@field bufnr number? Buffer to delete. Defaults to the current buffer
---@field wipe boolean? Wipe the buffer instead of deleting it

---Delete a buffer without disrupting window layout
--- - either the current buffer if `bufnr` is not provided
--- - or the buffer `bufnr`
---@param opts rockyz.bufdelete.Opts
function M.bufdelete(opts)
    opts = opts or {}
    local bufnr = opts.bufnr or 0
    bufnr = bufnr == 0 and vim.api.nvim_get_current_buf() or bufnr

    if vim.bo[bufnr].modified then
        local ok, choice = pcall(vim.fn.confirm, ("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
        if not ok or choice == 0 or choice == 3 then -- 0 for <Esc>/<C-c> and 3 for Cancel
            return
        end
        if choice == 1 then -- yes
            vim.cmd.write()
        end
    end

    for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
        vim.api.nvim_win_call(win, function()
            if not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_buf(win) ~= bufnr then
                return
            end
            -- Try using alternative buffer
            local alt = vim.fn.bufnr('#')
            if alt ~= bufnr and vim.fn.buflisted(alt) == 1 then
                vim.api.nvim_win_set_buf(win, alt)
                return
            end
            -- Try using previous buffer
            local has_previous = pcall(vim.cmd, 'bprevious')
            if has_previous and bufnr ~= vim.api.nvim_win_get_buf(win) then
                return
            end
            -- Create new listed buffer
            local new_buf = vim.api.nvim_create_buf(true, false)
            vim.api.nvim_win_set_buf(win, new_buf)
        end)
    end

    if vim.api.nvim_buf_is_valid(bufnr) then
        pcall(vim.cmd, (opts.wipe and 'bwipeout! ' or 'bdelete! ') .. bufnr)
    end
end

-- Delete all buffers
function M.bufdelete_all()
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[b].buflisted then
            M.bufdelete({ bufnr = b, wipe = true })
        end
    end
end

-- Delete all buffers except the current one
function M.bufdelete_other()
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if b ~= vim.api.nvim_get_current_buf() and vim.bo[b].buflisted then
            M.bufdelete({ bufnr = b, wipe = true })
        end
    end
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
