--
-- <M-`>: toggle
-- <M-n>: new a terminal
-- <M-d>: delete the current terminal
-- <M-o>: delete all terminals but the current one
-- <M-j>: jump to the next terminal
-- <M-k>: jump to the previous terminal
-- <M-1> ... <M-9>: jump to terminal #i
-- <M-Enter>: rename the current terminal
-- <M-,>: move the current terminal backwards
-- <M-.>: move the current terminal forwards
--

local M = {}

local ok, icons = pcall(require, 'rockyz.icons')

local term_icon = ok and icons.misc.term or ''

local state = {
    -- Terminal window
    term_buf = nil,
    term_win = nil,
    term_height = math.floor(vim.o.lines / 3),

    -- Side panel showing the list of terminals
    panel_buf = nil,
    panel_win = nil,
    panel_width = math.floor(vim.o.columns / 10),

    terminals = {},
    cur_index = nil,

    -- Used by the case where we need to delete terminals in batch, e.g., M.only().
    -- When we delete terminals in batch, we don't need to update the side panel and switch to the
    -- alternative terminal upon each deletion as we do when deleting a single terminal. Instead, we
    -- just need to update the side panel once and there's no need to switch terminal.
    count_to_delete = nil,
}

local minimal_win_opts = {
    number = false,
    relativenumber = false,
    foldcolumn = '0',
    signcolumn = 'no',
    statuscolumn = '',
    spell = false,
    list = false,
}

local function close_win(winid)
    if winid and vim.api.nvim_win_is_valid(winid) then
        vim.api.nvim_win_close(winid, true)
    end
end

local function delete_buf(bufnr)
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
        vim.api.nvim_buf_delete(bufnr, { force = true })
    end
end

-- Delete all buffers and windows, reset state
local function reset()
    close_win(state.term_win)
    close_win(state.panel_win)
    delete_buf(state.term_buf)
    delete_buf(state.panel_buf)
    state.term_win = nil
    state.term_buf = nil
    state.panel_win = nil
    state.panel_buf = nil
    state.terminals = {}
    state.count_to_delete = nil
end

-- Swap any two items in a list
local function list_swap(list, i, j)
    if i >= 1 and i <= #list and j >= 1 and j <= #list and i ~= j then
        list[i], list[j] = list[j], list[i]
    end
end

-- Swap any two lines in the side panel
local function panel_lines_swap(i, j)
    local i_line = vim.api.nvim_buf_get_lines(state.panel_buf, i - 1, i, false)[1]
    local j_line = vim.api.nvim_buf_get_lines(state.panel_buf, j - 1, j, false)[1]
    i_line = i_line:gsub('^%[(%d+)%]', '[' .. j .. ']')
    j_line = j_line:gsub('^%[(%d+)%]', '[' .. i .. ']')
    vim.api.nvim_buf_set_lines(state.panel_buf, i - 1, i, false, { j_line })
    vim.api.nvim_buf_set_lines(state.panel_buf, j - 1, j, false, { i_line })
end

local function get_index_by_jobid(jobid)
    for i, term in ipairs(state.terminals) do
        if term.jobid == jobid then
            return i
        end
    end
end

local function set_autocmd()
    vim.api.nvim_create_augroup('rockyz.terminal', { clear = true })
    -- Remember its size if terminal window gets resized
    vim.api.nvim_create_autocmd('WinResized', {
        group = 'rockyz.terminal',
        callback = function()
            for _, win in ipairs(vim.v.event.windows) do
                if win == state.term_win then
                    state.term_height = vim.api.nvim_win_get_height(state.term_win)
                end
            end
        end,
    })
    -- Make the terminal window and the side panel can be closed together
    vim.api.nvim_create_autocmd('WinClosed', {
        group = 'rockyz.terminal',
        pattern = table.concat({ state.term_win, state.panel_win }, ','),
        callback = function(args)
            local closed_win = tonumber(args.match)
            if closed_win == state.term_win then
                close_win(state.panel_win)
            elseif closed_win == state.panel_win then
                close_win(state.term_win)
            end
        end,
    })
end

local function set_buf_keymaps()
    local function map(mode, lhs, rhs)
        vim.keymap.set(mode, lhs, rhs, { buffer = state.term_buf })
    end

    -- New terminal
    map({ 'n', 't' }, '<M-n>', function()
        require('rockyz.terminal').new()
    end)

    -- Delete the current terminal
    map({ 'n', 't' }, '<M-d>', function()
        require('rockyz.terminal').delete()
    end)

    -- Delete all terminals but the current one
    map({ 'n', 't' }, '<M-o>', function()
        require('rockyz.terminal').only()
    end)

    -- Jump to the next or previous
    map({ 'n', 't' }, '<M-j>', function()
        require('rockyz.terminal').jump(1)
    end)
    map({ 'n', 't' }, '<M-k>', function()
        require('rockyz.terminal').jump(-1)
    end)

    -- Jump to terminal #i
    for i = 1, 10 do
        local lhs = '<M-' .. i .. '>'
        map({ 'n', 't' }, lhs, function()
            require('rockyz.terminal').switch(i)
        end)
    end

    -- Rename
    map({ 'n', 't' }, '<M-Enter>', function()
        require('rockyz.terminal').rename()
    end)

    -- Move the current terminal backwards or forwards
    map({ 'n', 't' }, '<M-,>', function()
        require('rockyz.terminal').move(-1)
    end)
    map({ 'n', 't' }, '<M-.>', function()
        require('rockyz.terminal').move(1)
    end)
end

-- Set the window to minimal style
local function set_win_minimal(winid)
    for option, value in pairs(minimal_win_opts) do
        vim.wo[winid][0][option] = value
    end
end

local function create_terminal()
    state.term_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_call(state.term_buf, function()
        local jobid = vim.fn.jobstart(vim.o.shell, {
            term = true,
            on_exit = function(jobid)
                local index = get_index_by_jobid(jobid)
                local bufnr = state.terminals[index].bufnr

                --
                -- If deleting terminals in batch, e.g., M.only(), we only update the side panel
                -- once.
                --

                if state.count_to_delete then
                    delete_buf(bufnr)
                    state.count_to_delete = state.count_to_delete - 1
                    if state.count_to_delete == 0 then
                        state.terminals = { state.terminals[state.cur_index] }
                        state.cur_index = 1
                        state.count_to_delete = nil
                    end
                    return
                end

                --
                -- If deleting a single terminal, e.g., M.delete() or shell's <C-d>, we need to
                -- update the side panel upon each deletion and switch to alternative terminal if
                -- necessary.
                --

                if #state.terminals == 1 then
                    reset()
                    return
                end
                -- Update the side panel
                local lines = vim.api.nvim_buf_get_lines(state.panel_buf, index, -1, false)
                for i, line in ipairs(lines) do
                    lines[i] = line:gsub('^%[(%d+)%]', function(num)
                        return '[' .. tostring(tonumber(num) - 1) .. ']'
                    end)
                end
                vim.api.nvim_buf_set_lines(state.panel_buf, index - 1, -2, false, lines)
                vim.api.nvim_buf_set_lines(state.panel_buf, -2, -1, false, {})

                table.remove(state.terminals, index)

                if index < state.cur_index then
                    state.cur_index = state.cur_index - 1
                    vim.api.nvim_win_set_cursor(state.panel_win, { state.cur_index, 0 })
                elseif index == state.cur_index then
                    local target_index = index > #state.terminals and index - 1 or index
                    M.switch(target_index)
                end

                delete_buf(bufnr)
            end,
        })
        state.terminals[#state.terminals + 1] = {
            jobid = jobid,
            bufnr = state.term_buf
        }
        state.cur_index = #state.terminals
        set_buf_keymaps()
    end)
    vim.api.nvim_win_set_buf(state.term_win, state.term_buf)
    set_win_minimal(state.term_win)
    -- Update the panel
    local count = #state.terminals
    vim.api.nvim_buf_set_lines(
        state.panel_buf,
        count - 1,
        count,
        false,
        { '[' .. count .. '] ' .. term_icon .. ' Terminal'}
    )
end

local function open_wins()
    -- Window for terminal
    vim.cmd('botright ' .. state.term_height .. 'split')
    state.term_win = vim.api.nvim_get_current_win()
    -- Window for panel
    vim.cmd(state.panel_width .. 'vsplit')
    state.panel_win = vim.api.nvim_get_current_win()
    if not state.panel_buf or not vim.api.nvim_buf_is_valid(state.panel_buf) then
        state.panel_buf = vim.api.nvim_create_buf(false, true)
        vim.bo[state.panel_buf].filetype = 'TerminalPanel'
    end
    vim.api.nvim_win_set_buf(state.panel_win, state.panel_buf)

    set_win_minimal(state.panel_win)
    vim.api.nvim_set_current_win(state.term_win)
end

local function is_opened()
    return state.term_win and vim.api.nvim_win_is_valid(state.term_win)
end

-- Create a new terminal
M.new = function()
    if not is_opened() then
        open_wins()
    end
    create_terminal()
    vim.api.nvim_win_set_cursor(state.panel_win, { #state.terminals, 0 })
    vim.api.nvim_set_current_win(state.term_win)
end

-- Delete the given terminal
M.delete = function(index)
    index = index or state.cur_index
    local jobid = state.terminals[index].jobid
    vim.fn.jobstop(jobid)
end

-- Delete all terminals but the current one
M.only = function()
    state.count_to_delete = #state.terminals - 1
    for idx = 1, #state.terminals do
        if idx ~= state.cur_index then
            M.delete(idx)
        end
    end
    -- Update the side panel
    local line = vim.api.nvim_buf_get_lines(state.panel_buf, state.cur_index - 1, state.cur_index, false)[1]
    line = line:gsub('^%[%d+%]', '[1]')
    vim.api.nvim_buf_set_lines(state.panel_buf, 0, -1, false, {})
    vim.api.nvim_buf_set_lines(state.panel_buf, 0, 1, false, { line })
end

-- Switch to the i-th terminal
M.switch = function(index)
    local bufnr = state.terminals[index].bufnr
    state.term_buf = bufnr
    state.cur_index = index
    vim.api.nvim_win_set_buf(state.term_win, state.term_buf)
    vim.api.nvim_win_set_cursor(state.panel_win, { index, 0 })
end

-- Jump to the previous or next terminal
M.jump = function(direction)
    local cur_index = state.cur_index
    if direction == -1 and cur_index ~= 1 then
        M.switch(cur_index - 1)
    elseif direction == 1 and cur_index ~= vim.tbl_count(state.terminals) then
        M.switch(cur_index + 1)
    end
end

-- Rename the current terminal
M.rename = function()
    vim.ui.input({ prompt = "[Terminal] Enter name: " }, function(input)
        local cur_index = state.cur_index
        vim.api.nvim_buf_set_lines(state.panel_buf, cur_index - 1, cur_index, false, {
            '[' .. cur_index .. '] ' .. term_icon .. ' ' .. input
        })
    end)
end

-- Move the current terminal to the previous or next position in the list
M.move = function(direction)
    local target_index = state.cur_index + direction
    if target_index > #state.terminals or target_index < 1 then
        return
    end
    panel_lines_swap(state.cur_index, target_index)
    list_swap(state.terminals, state.cur_index, target_index)
    state.cur_index = target_index
    M.switch(target_index)
end

-- Close the terminal window along with the side panel
M.close = function()
    close_win(state.term_win)
    close_win(state.panel_win)
    vim.api.nvim_clear_autocmds({ group = 'rockyz.terminal' })
end

M.open = function()
    open_wins()
    if not state.term_buf or not vim.api.nvim_buf_is_valid(state.term_buf) then
        create_terminal()
    else
        vim.api.nvim_win_set_buf(state.term_win, state.term_buf)
    end
    set_autocmd()
end

M.toggle = function()
    if is_opened() then
        M.close()
    else
        M.open()
    end
end

-- Toggle
vim.keymap.set({ 'n', 't' }, '<M-`>', function()
    require('rockyz.terminal').toggle()
end)

return M
