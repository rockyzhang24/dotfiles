-- Highly inspired by @kevinhwang91's nvim config

local M = {}

local saved_view
local saved_winid
local saved_bufnr
local saved_report

function M.save_win_view()
    saved_view = vim.fn.winsaveview()
    saved_winid = vim.api.nvim_get_current_win()
    saved_bufnr = vim.api.nvim_get_current_buf()
    saved_report = vim.o.report
    vim.o.report = 65535
end

function M.clear_saved_state()
    saved_view = nil
    saved_winid = nil
    saved_bufnr = nil
    if saved_report ~= nil then
        vim.o.report = saved_report
        saved_report = nil
    end
end

function M.restore()
    local is_yank = vim.v.operator == 'y'
    local is_same_win = vim.api.nvim_get_current_win() == saved_winid
    local is_same_buf = vim.api.nvim_get_current_buf() == saved_bufnr

    if is_yank and saved_view and is_same_win and is_same_buf then
        vim.fn.winrestview(saved_view)
    end

    M.clear_saved_state()
end

vim.api.nvim_create_autocmd('TextYankPost', {
    group = vim.api.nvim_create_augroup('rockyz.yank_restore_view', { clear = true }),
    callback = M.restore,
})

return M
