local M = {}

local recent_windows = {}

---Record the current window as the most recently used window
function M.record_current_window()
    local current_winid = vim.api.nvim_get_current_win()
    local updated_recent_windows = {}
    local seen_windows = {}

    local function add_window(winid)
        if not seen_windows[winid] and vim.api.nvim_win_is_valid(winid) then
            table.insert(updated_recent_windows, winid)
            seen_windows[winid] = true
        end
    end

    add_window(current_winid)

    for _, winid in ipairs(recent_windows) do
        add_window(winid)
    end

    recent_windows = updated_recent_windows
end

---Go to the most recently used non-popup window
function M.goto_recent_window()
    local current_winid = vim.api.nvim_get_current_win()

    for _, winid in ipairs(recent_windows) do
        if current_winid ~= winid and vim.api.nvim_win_is_valid(winid) then
            local window_type = vim.fn.win_gettype(winid)
            if window_type ~= 'popup' then
                if vim.fn.win_gotoid(winid) == 1 then
                    return
                end
            end
        end
    end
end

local mru_win_augroup = vim.api.nvim_create_augroup('rockyz.mru_win', { clear = true })

vim.api.nvim_create_autocmd('WinLeave', {
    group = mru_win_augroup,
    callback = function()
        M.record_current_window()
    end,
})

return M
