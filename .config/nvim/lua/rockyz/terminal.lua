-- <M-`>: toggle
-- <Leader><M-n>: new a terminal
-- <Leader><M-d>: delete the current terminal
-- <Leader><M-o>: delete all terminals but the current one
-- <M-=>: jump to the next terminal
-- <M-->: jump to the previous terminal
-- <M-1> to <M-9>: jump to terminal #i
-- <Leader><M-Enter>: rename the current terminal
-- <M-,>: move the current terminal backwards
-- <M-.>: move the current terminal forwards
-- <Leader><M-t>: send the terminal to a new tabpage
-- <Leader><M-p>: send the terminal to the panel
-- <Leader><M-m>: toggle maximize
-- <Leader>ts: send the current line in NORMAL or selected lines in VISUAL to terminal
-- <Leader>tr: open a terminal running REPL based on the filetype

local M = {}

local icons = require('rockyz.icons')
local term_icon = icons.misc.term

---@class rocky.terminal.Terminal
---@field jobid integer
---@field bufnr integer The bufnr of the terminal buffer

---@class rockyz.terminal.State
---@field term_buf integer|nil The bufnr of the current terminal buffer
---@field term_win integer|nil The winid of the window having the terminal buffer
---@field term_height integer
---@field panel_buf integer|nil The bufnr of the side panel
---@field panel_win integer|nil The winid of the window having the side panel buffer
---@field panel_width integer
---@field terminals rocky.terminal.Terminal[]
---@field cur_index integer|nil The index of the current terminal
---@field count_to_delete integer
---@field maximized boolean

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
    count_to_delete = 0,

    maximized = false,
}

local win_opts = {
    number = false,
    relativenumber = false,
    foldcolumn = '0',
    signcolumn = 'auto', -- may use signcolumn to show the start of each prompt by OSC 133
    statuscolumn = '',
    spell = false,
    list = false,
    wrap = false,
}

local keymaps = {
    -- Keymaps defined in the terminal buffer
    term = {
        ['<Leader><M-n>'] = 'new',
        ['<Leader><M-d>'] = 'delete',
        ['<Leader><M-o>'] = 'only',
        ['<M-=>'] = 'next',
        ['<M-->'] = 'prev',
        ['<Leader><M-Enter>'] = 'rename',
        ['<M-.>'] = 'move_next',
        ['<M-,>'] = 'move_prev',
        ['<Leader><M-t>'] = 'to_tab',
        ['<Leader><M-m>'] = 'toggle_maximize',
        ['<M-1>'] = 'switch_1',
        ['<M-2>'] = 'switch_2',
        ['<M-3>'] = 'switch_3',
        ['<M-4>'] = 'switch_4',
        ['<M-5>'] = 'switch_5',
        ['<M-6>'] = 'switch_6',
        ['<M-7>'] = 'switch_7',
        ['<M-8>'] = 'switch_8',
        ['<M-9>'] = 'switch_9',
        ['<M-0>'] = 'switch_10',
    },
    global = {
        ['<M-`>'] = 'toggle',
        ['<Leader><M-p>'] = 'to_panel',
        ['<Leader>ts'] = {
            n = 'send_line',
            x = 'send_selection',
        },
        ['<Leader>tr'] = {
            n = 'repl',
        },
    },
}

---@type table<string, string> Map from filetype to its corresponding REPL program
local repls = {
    python = 'python3',
    lua = 'lua',
}

---@class rockyz.terminal.new.Opts
---@field index? integer The index where the new terminal is created. Defaults to the last.
---@field name? string The name of the terminal. Defaults to 'Terminal'.
---@field cmd? string The shell command to be run on launching the terminal

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

---Delete all buffers and windows, reset state
---@param keep_term_buf? boolean Whether keep (don't delete) the terminal buffer
local function reset(keep_term_buf)
    close_win(state.term_win)
    close_win(state.panel_win)
    if not keep_term_buf then
        delete_buf(state.term_buf)
    end
    delete_buf(state.panel_buf)
    state.term_win = nil
    state.term_buf = nil
    state.panel_win = nil
    state.panel_buf = nil
    state.terminals = {}
    state.count_to_delete = 0
    state.maximized = false
end

-- Swap any two items in a list
local function list_swap(list, i, j)
    if i >= 1 and i <= #list and j >= 1 and j <= #list and i ~= j then
        list[i], list[j] = list[j], list[i]
    end
end

local function get_index_by_jobid(jobid)
    for i, term in ipairs(state.terminals) do
        if term.jobid == jobid then
            return i
        end
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

---@param index integer The position at which to insert the entry
---@param name string The terminal name in this entry
local function insert_entry_in_side_panel(index, name)
    local lines = vim.api.nvim_buf_get_lines(state.panel_buf, index - 1, -1, false)
    for i, line in ipairs(lines) do
        lines[i] = line:gsub('^%[(%d+)%]', function(num)
            return '[' .. tostring(tonumber(num) + 1) .. ']'
        end)
    end
    local entry = string.format('[%s] %s %s', index, term_icon, name)
    vim.api.nvim_buf_set_lines(state.panel_buf, index , -1, false, lines)
    vim.api.nvim_buf_set_lines(state.panel_buf, index - 1, index, false, { entry })
end

---@param index integer
local function delete_entry_in_side_panel(index)
    local lines = vim.api.nvim_buf_get_lines(state.panel_buf, index, -1, false)
    for i, line in ipairs(lines) do
        lines[i] = line:gsub('^%[(%d+)%]', function(num)
            return '[' .. tostring(tonumber(num) - 1) .. ']'
        end)
    end
    vim.api.nvim_buf_set_lines(state.panel_buf, index - 1, -2, false, lines)
    vim.api.nvim_buf_set_lines(state.panel_buf, -2, -1, false, {})
end

---Delete the terminal given by its index
---@param index integer The index of the terminal to be removed
---@param keep_term_buf? boolean Whether keep the terminal buffer. If true, the terminal buffer
---won't be deleted, but it will be removed from the terminal list. It's useful when we move the
---terminal to a new tabpage.
local function delete_terminal(index, keep_term_buf)
    local bufnr = state.terminals[index].bufnr
    if #state.terminals == 1 then
        reset(keep_term_buf)
        return
    end

    table.remove(state.terminals, index)

    -- Remove the entry from the side panel
    delete_entry_in_side_panel(index)

    -- If the position of the deleted terminal is before the current one, we need to update the
    -- cursor line in side panel: move it up by one. If the deleted terminal is the current one,
    -- switch to the next terminal.
    if index < state.cur_index then
        state.cur_index = state.cur_index - 1
        vim.api.nvim_win_set_cursor(state.panel_win, { state.cur_index, 0 })
    elseif index == state.cur_index then
        local new_index = index > #state.terminals and index - 1 or index
        M.switch(new_index)
    end

    if not keep_term_buf then
        delete_buf(bufnr)
    end
end

local function set_term_keymaps()
    for key, action in pairs(keymaps.term) do
        vim.keymap.set({ 'n', 't' }, key, function()
            M[action]()
        end, { buffer = state.term_buf })
    end
end

local function delete_term_keymaps()
    for key, _ in pairs(keymaps.term) do
        vim.keymap.del({ 'n', 't' }, key, { buffer = state.term_buf })
    end
end

-- Set the window to minimal style
local function set_win_options(winid)
    for option, value in pairs(win_opts) do
        vim.wo[winid][0][option] = value
    end
end

local function on_exit(jobid)
    local index = get_index_by_jobid(jobid)

    -- If the terminal is one that was previously sent from the panel to the tabpage, exit directly.
    if not index then
        return
    end

    local bufnr = state.terminals[index].bufnr

    -- If deleting terminals in batch, e.g., M.only(), we only update the side panel
    -- once instead of deleting an entry each time.
    if state.count_to_delete > 0 then
        delete_buf(bufnr)
        state.count_to_delete = state.count_to_delete - 1
        if state.count_to_delete == 0 then
            state.terminals = { state.terminals[state.cur_index] }
            state.cur_index = 1
            state.count_to_delete = 0

            -- Update the side panel: keep only the current entry and remove all the others
            local line = vim.api.nvim_buf_get_lines(state.panel_buf, state.cur_index - 1, state.cur_index, false)[1]
            line = line:gsub('^%[%d+%]', '[1]')
            vim.api.nvim_buf_set_lines(state.panel_buf, 0, -1, false, {})
            vim.api.nvim_buf_set_lines(state.panel_buf, 0, 1, false, { line })
        end
        return
    end

    -- If deleting a single terminal, e.g., M.delete() or shell's <C-d>, we need to
    -- update the side panel upon each deletion and switch to alternative terminal if
    -- necessary.
    delete_terminal(index)
end

---Create term buffer and add the entry to side panel
---@param opts? rockyz.terminal.new.Opts
local function create_terminal(opts)
    opts = opts or {}
    local index = opts.index
    local name = opts.name or 'Terminal'
    local cmd = opts.cmd or vim.env.SHELL or 'sh'

    state.term_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_call(state.term_buf, function()
        local jobid = vim.fn.jobstart(cmd, {
            term = true,
            on_exit = on_exit,
        })
        table.insert(state.terminals, index or #state.terminals + 1, {
            jobid = jobid,
            bufnr = state.term_buf
        })
        state.cur_index = index or #state.terminals
        set_term_keymaps()
    end)
    vim.api.nvim_win_set_buf(state.term_win, state.term_buf)
    set_win_options(state.term_win)

    -- Add the entry to the side panel
    index = index or #state.terminals
    insert_entry_in_side_panel(index, name)
end

local function create_panel_buffer()
    if not state.panel_buf or not vim.api.nvim_buf_is_valid(state.panel_buf) then
        state.panel_buf = vim.api.nvim_create_buf(false, true)
        vim.bo[state.panel_buf].filetype = 'TerminalPanel'
    end
    vim.api.nvim_win_set_buf(state.panel_win, state.panel_buf)
    set_win_options(state.panel_win)
end

-- Open two split wins, one for terminal and another for the side panel
local function open_wins()
    -- Open terminal window
    vim.cmd('botright ' .. state.term_height .. 'split')
    state.term_win = vim.api.nvim_get_current_win()
    -- Open side panel window and create its buffer
    vim.cmd(state.panel_width .. 'vsplit')
    state.panel_win = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(state.term_win)
end

local function is_opened()
    return state.term_win and vim.api.nvim_win_is_valid(state.term_win)
end

---Create a new terminal
---@param opts? rockyz.terminal.new.Opts
M.new = function(opts)
    opts = opts or {}
    local index = opts.index

    if not is_opened() then
        open_wins()
        create_panel_buffer()
    end
    create_terminal(opts)
    vim.api.nvim_win_set_cursor(state.panel_win, { index or #state.terminals, 0 })
    vim.api.nvim_set_current_win(state.term_win)
end

---Delete the given terminal
---@param index? integer The index of the terminal to delete. Defaults to the current one.
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
end

-- Switch to the i-th terminal
M.switch = function(index)
    if index > #state.terminals then
        return
    end
    local bufnr = state.terminals[index].bufnr
    state.term_buf = bufnr
    state.cur_index = index
    vim.api.nvim_win_set_buf(state.term_win, state.term_buf)
    vim.api.nvim_win_set_cursor(state.panel_win, { index, 0 })
end

local function generate_switch_func()
    for i = 1, 10 do
        M['switch_' .. i] = function()
            M.switch(i)
        end
    end
end
generate_switch_func()

---Jump to the previous or next terminal
---@param direction integer 1 for forwards and -1 for backwards
local function jump(direction)
    local cur_index = state.cur_index
    if direction == -1 and cur_index ~= 1 then
        M.switch(cur_index - 1)
    elseif direction == 1 and cur_index ~= vim.tbl_count(state.terminals) then
        M.switch(cur_index + 1)
    end
end

M.prev = function()
    jump(-1)
end

M.next = function()
    jump(1)
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

---Move the current terminal to the previous or next position in the list
---@param direction integer -1 or 1
local function move(direction)
    local new_index = state.cur_index + direction
    if new_index > #state.terminals or new_index < 1 then
        return
    end
    panel_lines_swap(state.cur_index, new_index)
    list_swap(state.terminals, state.cur_index, new_index)
    state.cur_index = new_index
    M.switch(new_index)
end

M.move_prev = function()
    move(-1)
end

M.move_next = function()
    move(1)
end

local function set_autocmd()
    vim.api.nvim_create_augroup('rockyz.terminal', { clear = true })
    -- Remember its size if terminal window gets resized
    vim.api.nvim_create_autocmd({ 'WinResized' }, {
        group = 'rockyz.terminal',
        callback = function()
            for _, win in ipairs(vim.v.event.windows) do
                if win == state.term_win then
                    state.term_height = vim.api.nvim_win_get_height(state.term_win)
                end
                if win == state.panel_win then
                    state.panel_width = vim.api.nvim_win_get_width(state.panel_win)
                end
            end
        end,
    })
    -- Make the terminal window and the side panel can be closed together
    vim.api.nvim_create_autocmd({ 'WinClosed' }, {
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

-- Send current terminal to a new tabpage
M.to_tab = function()
    vim.cmd('tab split')
    delete_term_keymaps()
    delete_terminal(state.cur_index, true)
end

-- Close the terminal window along with the side panel
M.close = function()
    close_win(state.term_win)
    close_win(state.panel_win)
end

-- Open the window with a terminal executing command cmd
M.open = function(cmd)
    if is_opened() then
        return
    end
    open_wins()
    create_panel_buffer()
    if not state.term_buf or not vim.api.nvim_buf_is_valid(state.term_buf) then
        create_terminal({ cmd = cmd })
    else
        vim.api.nvim_win_set_buf(state.term_win, state.term_buf)
    end
end

M.toggle = function(cmd)
    if is_opened() then
        if vim.api.nvim_win_get_tabpage(state.term_win) ~= vim.api.nvim_get_current_tabpage() then
            -- If the terminal is already open in a different tabpage, open it in the current one.
            M.close()
            M.open(cmd)
        else
            M.close()
            vim.api.nvim_clear_autocmds({ group = 'rockyz.terminal' })
        end
    else
        M.open(cmd)
        set_autocmd()
    end
end

M.to_panel = function()
    if vim.bo.buftype ~= 'terminal' then
        return
    end
    local jobid = vim.bo.channel
    local bufnr = vim.api.nvim_get_current_buf()
    table.insert(state.terminals, {
        jobid = jobid,
        bufnr = bufnr,
    })
    state.cur_index = #state.terminals
    state.term_buf = bufnr
    set_term_keymaps()

    vim.cmd('tabclose')

    if not is_opened() then
        open_wins()
        create_panel_buffer()
        set_autocmd()
    end

    vim.api.nvim_win_set_buf(state.term_win, state.term_buf)
    set_win_options(state.term_win)

    insert_entry_in_side_panel(#state.terminals, 'Terminal')
    vim.api.nvim_win_set_cursor(state.panel_win, { #state.terminals, 0 })
end

M.toggle_maximize = function()
    if not state.maximized then
        state.prev_height = state.term_height
        vim.api.nvim_win_set_height(state.term_win, vim.o.lines)
    else
        vim.api.nvim_win_set_height(state.term_win, state.prev_height)
    end
    state.maximized = not state.maximized
    state.term_height = vim.api.nvim_win_get_height(state.term_win)
end

-- In NORMAL mode, send the current line to terminal
M.send_line = function()
    local line = vim.fn.getline('.')
    if not is_opened() then
        M.open()
    end
    local jobid = state.terminals[state.cur_index].jobid
    vim.api.nvim_chan_send(jobid, line .. '\n')
end

-- In VISUAL mode, send the selected lines to terminal
M.send_selection = function()
    vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes('<Esc>', true, false, true),
        'n',
        false
    )
    vim.schedule(function()
        local pos1 = vim.fn.getpos("'<")
        local pos2 = vim.fn.getpos("'>")
        local type = vim.fn.visualmode()
        if type == 'V' then
            pos2[3] = #vim.fn.getline(pos2[2])
        end
        local lines = vim.fn.getregion(pos1, pos2, { type = type })
        local indent = math.huge
        for _, line in ipairs(lines) do
            indent = math.min(line:find("[^ ]") or math.huge, indent)
        end
        indent = indent == math.huge and 0 or indent

        if not is_opened() then
            M.open()
        end
        local jobid = state.terminals[state.cur_index].jobid
        for _, line in ipairs(lines) do
            vim.fn.chansend(jobid, line:sub(indent) .. '\n')
        end
    end)
end

M.repl = function()
    local cmd = repls[vim.bo.filetype]
    if not is_opened() then
        M.open(cmd)
    else
        M.new({ cmd = cmd })
    end
end

local function set_global_keymaps()
    for key, action in pairs(keymaps.global) do
        if type(action) == 'table' then
            for _mode, _action in pairs(action) do
                vim.keymap.set(_mode, key, function()
                    M[_action]()
                end)
            end
        else
            vim.keymap.set({ 'n', 't' }, key, function()
                M[action]()
            end)
        end
    end
end
set_global_keymaps()

return M
