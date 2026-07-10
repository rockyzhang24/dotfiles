local M = {}

local notify = require('rockyz.utils.notify')

local maximizer_augroup = vim.api.nvim_create_augroup('rockyz.win_maximizer', { clear = true })

local function is_floating_window(winid)
    return vim.api.nvim_win_get_config(winid).relative ~= ''
end

---Close all floating windows
function M.close_all_floating_wins()
    for _, winid in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_is_valid(winid) and is_floating_window(winid) then
            vim.api.nvim_win_close(winid, false)
        end
    end
end

---Close windows specified by window numbers
---@param win_numbers string
function M.close_wins(win_numbers)
    local winids = {}
    local seen_winids = {}

    for winnr in string.gmatch(win_numbers, '%d+') do
        local winid = vim.fn.win_getid(tonumber(winnr))
        if winid ~= 0 and not seen_winids[winid] and vim.api.nvim_win_is_valid(winid) then
            table.insert(winids, winid)
            seen_winids[winid] = true
        end
    end

    for _, winid in ipairs(winids) do
        if vim.api.nvim_win_is_valid(winid) then
            vim.api.nvim_win_close(winid, false)
        end
    end
end

---Close all but one diff window in the current tabpage
function M.close_diff()
    local diff_winids = vim.tbl_filter(function(winid)
        return vim.wo[winid].diff
    end, vim.api.nvim_tabpage_list_wins(0))

    if #diff_winids <= 1 then
        return
    end

    for _, winid in ipairs(diff_winids) do
        local closed, err = pcall(vim.api.nvim_win_close, winid, false)
        -- Handle the last diff window, which nvim_win_close cannot close
        if not closed and type(err) == 'string' and err:match('^Vim:E444:') then
            -- Exit Neovim completely when this command runs from a script such as `ngd`
            if vim.g.from_script then
                vim.cmd('quit')
                return
            end
            local current_buffer_name = vim.api.nvim_buf_get_name(0)
            if current_buffer_name:match('^fugitive://') then
                vim.cmd('Gedit')
            end
        end
    end
end

---Toggle the layout between horizontal and vertical splits
function M.switch_layout()
    local normal_winids = vim.tbl_filter(function(winid)
        return not is_floating_window(winid)
    end, vim.api.nvim_tabpage_list_wins(0))

    if #normal_winids ~= 2 then
        notify.warn('Layout switching requires exactly two normal windows in the current tabpage')
        return
    end

    local current_winid = vim.api.nvim_get_current_win()

    -- Positions are {row, col}
    local first_position = vim.api.nvim_win_get_position(normal_winids[1])
    local second_position = vim.api.nvim_win_get_position(normal_winids[2])

    local layout_keys
    if first_position[1] == second_position[1] then
        layout_keys = vim.api.nvim_replace_termcodes('<C-w>t<C-w>K', true, false, true)
    else
        layout_keys = vim.api.nvim_replace_termcodes('<C-w>t<C-w>H', true, false, true)
    end

    vim.api.nvim_feedkeys(layout_keys, 'm', false)

    -- nvim_feedkeys is a blocking call and nvim_set_current_win doesn't work when textlock is active,
    -- so vim.schedule is necessary.
    vim.schedule(function()
        if vim.api.nvim_win_is_valid(current_winid) then
            vim.api.nvim_set_current_win(current_winid)
        end
    end)
end

--
-- Maximizes and restores the current window
-- Ref: https://github.com/szw/vim-maximizer
--

local function set_other_scrollbars_enabled(enabled)
    local current_winid = vim.api.nvim_get_current_win()
    local scrollbar = require('rockyz.scrollbar')
    local set_scrollbar_enabled = enabled and scrollbar.enable or scrollbar.disable

    for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if
            winid ~= current_winid
            and vim.api.nvim_win_is_valid(winid)
            and not is_floating_window(winid)
        then
            local scrollbar_state = vim.w[winid].scrollbar_state
            if scrollbar_state and (enabled or scrollbar_state.is_enabled) then
                set_scrollbar_enabled(winid)
            end
        end
    end
end

local function clear_maximizer_state()
    local maximized_winid = vim.t.maximized_winid
    if maximized_winid and vim.api.nvim_win_is_valid(maximized_winid) then
        vim.w[maximized_winid].maximized = nil
    end

    vim.t.maximizer_sizes = nil
    vim.t.maximized_winid = nil
end

local function maximize_current_window()
    local current_winid = vim.api.nvim_get_current_win()
    vim.t.maximizer_sizes = {
        before = vim.fn.winrestcmd(),
    }

    vim.cmd('wincmd |')
    vim.cmd('wincmd _')
    vim.cmd('normal! ze')

    -- Store the maximized window so winbar can display its maximized status
    vim.w.maximized = true
    vim.t.maximized_winid = current_winid
    set_other_scrollbars_enabled(false)
end

local function restore_window_layout()
    local maximizer_sizes = vim.t.maximizer_sizes
    if not maximizer_sizes then
        return
    end

    vim.cmd('silent! execute ' .. maximizer_sizes.before)

    if maximizer_sizes.before ~= vim.fn.winrestcmd() then
        vim.cmd('wincmd =')
    end

    vim.cmd('normal! ze')
    clear_maximizer_state()
    set_other_scrollbars_enabled(true)
end

local function delete_restore_autocmd()
    local autocmd_id = vim.t.restore_maximized_window_autocmd_id
    if autocmd_id then
        vim.api.nvim_del_autocmd(autocmd_id)
        vim.t.restore_maximized_window_autocmd_id = nil
    end
end

local function create_restore_autocmd()
    local tabpage = vim.api.nvim_get_current_tabpage()

    -- Clear maximizer state and balance remaining windows when a normal window closes
    local autocmd_id = vim.api.nvim_create_autocmd('WinClosed', {
        group = maximizer_augroup,
        callback = function(event)
            local closed_winid = tonumber(event.match)
            if vim.api.nvim_get_current_tabpage() ~= tabpage or is_floating_window(closed_winid) then
                return
            end

            clear_maximizer_state()
            set_other_scrollbars_enabled(true)

            -- Balance windows
            vim.schedule(function()
                if vim.api.nvim_tabpage_is_valid(tabpage) then
                    local tabpage_winid = vim.api.nvim_tabpage_get_win(tabpage)
                    vim.api.nvim_win_call(tabpage_winid, function()
                        if #vim.api.nvim_tabpage_list_wins(0) > 1 then
                            vim.cmd('wincmd =')
                        end
                    end)
                end
            end)

            delete_restore_autocmd()
        end,
    })

    vim.t.restore_maximized_window_autocmd_id = autocmd_id
end

---Toggle maximization of the current window
function M.win_maximize_toggle()
    -- Clear stale state when the maximized window was closed
    if vim.t.maximized_winid and not vim.api.nvim_win_is_valid(vim.t.maximized_winid) then
        clear_maximizer_state()
        set_other_scrollbars_enabled(true)
        delete_restore_autocmd()
    end

    if vim.t.maximizer_sizes ~= nil then
        restore_window_layout()
        delete_restore_autocmd()
    else
        local normal_win_count = #vim.tbl_filter(function(winid)
            return not is_floating_window(winid)
        end, vim.api.nvim_tabpage_list_wins(0))

        if normal_win_count > 1 then
            maximize_current_window()
            create_restore_autocmd()
        end
    end
end

---Create a split and close the current floating window
---@param split_command 'split'|'vsplit'
local function split_and_close_floating_window(split_command)
    local current_winid = vim.api.nvim_get_current_win()
    local current_window_is_floating = is_floating_window(current_winid)

    local command = split_command
    if vim.v.count > 0 then
        command = vim.v.count .. split_command
    end
    vim.cmd(command)

    if current_window_is_floating and vim.api.nvim_win_is_valid(current_winid) then
        vim.api.nvim_win_close(current_winid, true)
    end
end

---Create a horizontal split
function M.split()
    split_and_close_floating_window('split')
end

---Create a vertical split
function M.vsplit()
    split_and_close_floating_window('vsplit')
end

return M
