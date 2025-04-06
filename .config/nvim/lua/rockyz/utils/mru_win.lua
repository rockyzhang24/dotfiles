local M = {}

local mru_list = {}

function M.record()
    local cur_winid = vim.api.nvim_get_current_win()
    local new_list = {}
    local win_set = {}

    local add_to_new = function(winid)
        if not win_set[winid] and vim.api.nvim_win_is_valid(winid) then
            table.insert(new_list, winid)
            win_set[winid] = true
        end
    end

    add_to_new(cur_winid)

    for _, winid in ipairs(mru_list) do
        add_to_new(winid)
    end

    mru_list = new_list
end

function M.goto_recent()
    local cur_winid = vim.api.nvim_get_current_win()
    for _, winid in ipairs(mru_list) do
        if cur_winid ~= winid and vim.api.nvim_win_is_valid(winid) then
            local wintype = vim.fn.win_gettype(winid)
            if wintype ~= 'popup' then
                vim.fn.win_gotoid(winid)
                break
            end
        end
    end
end

return M
