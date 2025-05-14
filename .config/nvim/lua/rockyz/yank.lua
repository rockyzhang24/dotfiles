-- Highly inspired by @kevinhwang91's nvim config

local M = {}

local saved_win_view
local winid
local bufnr
local report

function M.save_win_view()
    saved_win_view = vim.fn.winsaveview()
    winid = vim.api.nvim_get_current_win()
    bufnr = vim.api.nvim_get_current_buf()
    report = vim.o.report
    vim.o.report = 65535
end

function M.clear_win_view()
    saved_win_view = nil
    winid = nil
    bufnr = nil
    if report then
        vim.o.report = report
        report = nil
    end
end

function M.restore()
    if vim.v.operator == 'y' and saved_win_view and vim.api.nvim_get_current_win() == winid and vim.api.nvim_get_current_buf() == bufnr then
        vim.fn.winrestview(saved_win_view)
    end
    M.clear_win_view()
end

vim.api.nvim_create_autocmd('TextYankPost', {
    group = vim.api.nvim_create_augroup('rockyz.yank_restore_view', { clear = true }),
    callback = function()
        require('rockyz.yank').restore()
    end,
})

return M
