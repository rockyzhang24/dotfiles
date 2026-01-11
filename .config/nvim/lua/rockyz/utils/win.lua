local M = {}

-- Close all the floating windows
function M.close_all_floating_wins()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local config = vim.api.nvim_win_get_config(win)
        if config.relative ~= '' then
            vim.api.nvim_win_close(win, false)
            -- print('Closing window', win)
        end
    end
end

-- Close windows by giving window numbers
function M.close_wins(win_nums)
    local winids = {}
    for win_num in string.gmatch(win_nums, '%d+') do
        local winid = vim.fn.win_getid(tonumber(win_num))
        table.insert(winids, winid)
    end
    for _, winid in ipairs(winids) do
        vim.api.nvim_win_close(winid, false)
    end
end

-- Close the diff windows in the current tab
function M.close_diff()
    local winids = vim.tbl_filter(function(winid)
        return vim.wo[winid].diff
    end, vim.api.nvim_tabpage_list_wins(0))

    if #winids > 1 then
        for _, winid in ipairs(winids) do
            local ok, msg = pcall(vim.api.nvim_win_close, winid, false)
            -- Handle the last window that cannot be closed by nvim_win_close
            if not ok and msg:match('^Vim:E444:') then
                -- If we run a script like `ngd` in the terminal, we should fully exit
                -- nvim
                if vim.g.from_script then
                    vim.cmd('quit')
                    return
                end
                if vim.api.nvim_buf_get_name(0):match('^fugitive://') then
                    vim.cmd('Gedit')
                end
            end
        end
    end
end

-- Switch window layout between horizontal and vertical (only works in a tab page with two windows)
function M.switch_layout()
    local wins = vim.api.nvim_tabpage_list_wins(0)
    -- Filter out the floating windows
    local norm_wins = {}
    for _, win in ipairs(wins) do
        if vim.api.nvim_win_get_config(win).relative == '' then
            table.insert(norm_wins, win)
        end
    end
    if #norm_wins ~= 2 then
        print('Layout switching only works for a tab page with TWO open windows.')
        return
    end
    local cur_win = vim.api.nvim_get_current_win()
    -- pos is {row, col}
    local pos1 = vim.api.nvim_win_get_position(norm_wins[1])
    local pos2 = vim.api.nvim_win_get_position(norm_wins[2])
    local keys = ''
    if pos1[1] == pos2[1] then
        keys = vim.api.nvim_replace_termcodes('<C-w>t<C-w>K', true, false, true)
    else
        keys = vim.api.nvim_replace_termcodes('<C-w>t<C-w>H', true, false, true)
    end
    vim.api.nvim_feedkeys(keys, 'm', false)
    -- nvim_feedkeys is a blocking call and nvim_set_current_win doesn't work when textlock is active,
    -- so vim.schedule is necessary.
    vim.schedule(function()
        vim.api.nvim_set_current_win(cur_win)
    end)
end

--
-- Maximizes and restores the current window
-- Ref: https://github.com/szw/vim-maximizer
--

local function win_maximize()
    local cur_win = vim.api.nvim_get_current_win()
    vim.t.maximizer_sizes = {
        before = vim.fn.winrestcmd(),
    }
    vim.cmd('wincmd |')
    vim.cmd('wincmd _')
    vim.cmd('normal! ze')
    -- Record whetehr the current window is maximized. This is used to display the "maximized"
    -- status in winbar.
    vim.w.maximized = 1
    vim.t.maximized_win = cur_win
    -- Disable scrollbars of other windows
    for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if winid ~= cur_win and vim.api.nvim_win_is_valid(winid) and vim.api.nvim_win_get_config(winid).relative == '' then
            require('rockyz.scrollbar').disable(winid)
        end
    end
end

local function win_restore()
    if vim.t.maximizer_sizes ~= nil then
        vim.cmd('silent! execute ' .. vim.t.maximizer_sizes.before)
        if vim.t.maximizer_sizes.before ~= vim.fn.winrestcmd() then
            vim.cmd('wincmd =')
        end
        vim.t.maximizer_sizes = nil
        vim.cmd('normal! ze')
        vim.w[vim.t.maximized_win].maximized = 0
        -- Enable scrollbars of other windows
        local cur_win = vim.api.nvim_get_current_win()
        for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if winid ~= cur_win and vim.api.nvim_win_is_valid(winid) and vim.api.nvim_win_get_config(winid).relative == '' then
                require('rockyz.scrollbar').enable(winid)
            end
        end
    end
end

function M.win_maximize_toggle()
    -- The maximized window may be closed before it gets restored
    if vim.t.maximized_win and not vim.api.nvim_win_is_valid(vim.t.maximized_win) then
        vim.t.maximizer_sizes = nil
        vim.t.maximized_win = nil
    end
    if vim.t.maximizer_sizes ~= nil then
        win_restore()
    else
        -- The current window can be maximized only if there are more than one non-floating windows in
        -- the tab
        local win_cnt = 0
        for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if vim.api.nvim_win_get_config(winid).relative == '' then
                win_cnt = win_cnt + 1
            end
            if win_cnt > 1 then
                win_maximize()
                return
            end
        end
    end
end

-- New a window and close the current window if it's a floating one
local function close_float_and_new(cmd)
    local winnr = vim.api.nvim_get_current_win()
    local config = vim.api.nvim_win_get_config(winnr)
    vim.cmd(vim.v.count ~= 0 and vim.v.count .. cmd or cmd)
    if config.relative and config.relative ~= '' then
        vim.api.nvim_win_close(winnr, true)
    end
end

function M.split()
    close_float_and_new('split')
end

function M.vsplit()
    close_float_and_new('vsplit')
end

return M
