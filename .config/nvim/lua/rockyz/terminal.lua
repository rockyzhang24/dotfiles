-- <M-`>: toggle
--
-- <C-Space>n: create a terminal
-- <C-Space>d: delete the current terminal
-- <C-Space>o: delete all terminals but the current one
-- <M-=>: jump to the next terminal
-- <M-->: jump to the previous terminal
-- <C-Space>1 ... <C-Space>9: jump to terminal #i
-- <C-Space>r: rename the current terminal
-- <M-,>: move the current terminal backwards
-- <M-.>: move the current terminal forwards
-- <C-Space>t: send the terminal to a new tabpage
-- <C-Space>p: send the terminal to the panel
-- <C-Space>m: toggle maximize
--
-- <Leader>ts: send the current line in NORMAL or selected lines in VISUAL to terminal
-- <Leader>tr: open a terminal running REPL based on the filetype
-- <Leader>x: compile and run the current file

local M = {}

local icons = require('rockyz.icons')
local notify = require('rockyz.utils.notify')

local term_icon = icons.misc.term

---@class rockyz.terminal.TerminalInfo
---@field jobid integer
---@field bufnr integer The bufnr of the terminal buffer

---@class rockyz.terminal.State
---@field term_bufnr integer|nil The bufnr of the current terminal buffer
---@field term_winid integer|nil The winid of the window having the terminal buffer
---@field term_height integer
---@field panel_bufnr integer|nil The bufnr of the side panel
---@field panel_winid integer|nil The winid of the window having the side panel buffer
---@field panel_width integer
---@field terminals table<integer, rockyz.terminal.TerminalInfo> Map from terminal index to its info
---@field cur_index integer|nil The index of the current terminal
---@field count_to_delete integer
---@field maximized boolean
---@field prev_height integer|nil

local state = {
    -- Terminal window
    term_bufnr = nil,
    term_winid = nil,
    term_height = math.floor(vim.o.lines / 3),

    -- Side panel showing the list of terminals
    panel_bufnr = nil,
    panel_winid = nil,
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
        ['<C-Space>n'] = 'new',
        ['<C-Space>d'] = 'delete',
        ['<C-Space>o'] = 'only',
        ['<M-=>'] = 'next',
        ['<M-->'] = 'prev',
        ['<C-Space>r'] = 'rename',
        ['<M-.>'] = 'move_next',
        ['<M-,>'] = 'move_prev',
        ['<C-Space>t'] = 'to_tab',
        ['<C-Space>m'] = 'toggle_maximize',
        ['<C-Space>1'] = 'switch_1',
        ['<C-Space>2'] = 'switch_2',
        ['<C-Space>3'] = 'switch_3',
        ['<C-Space>4'] = 'switch_4',
        ['<C-Space>5'] = 'switch_5',
        ['<C-Space>6'] = 'switch_6',
        ['<C-Space>7'] = 'switch_7',
        ['<C-Space>8'] = 'switch_8',
        ['<C-Space>9'] = 'switch_9',
        ['<C-Space>0'] = 'switch_10',
    },
    global = {
        ['<M-`>'] = 'toggle',
        ['<C-Space>p'] = 'to_panel',
        ['<Leader>ts'] = {
            n = 'send_line',
            x = 'send_selection',
        },
        ['<Leader>tr'] = {
            n = 'repl',
        },
        ['<Leader>x'] = {
            n = 'run_file',
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
---@field cmd? string|string[] The shell command to be run on launching the terminal, same as cmd in
---vim.fn.jobstart()

---@param winid? integer
local function close_win(winid)
    if winid and vim.api.nvim_win_is_valid(winid) then
        vim.api.nvim_win_close(winid, true)
    end
end

---@param bufnr? integer
local function delete_buf(bufnr)
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
        vim.api.nvim_buf_delete(bufnr, { force = true })
    end
end

---Delete all buffers and windows, reset state
---@param keep_term_buf? boolean Whether keep (don't delete) the terminal buffer
local function reset(keep_term_buf)
    close_win(state.term_winid)
    close_win(state.panel_winid)
    if not keep_term_buf then
        delete_buf(state.term_bufnr)
    end
    delete_buf(state.panel_bufnr)

    state.term_winid = nil
    state.term_bufnr = nil
    state.panel_winid = nil
    state.panel_bufnr = nil
    state.terminals = {}
    state.cur_index = nil
    state.count_to_delete = 0
    state.prev_height = nil
    state.maximized = false
end

-- Swap any two items in a list
local function list_swap(list, i, j)
    if i >= 1 and i <= #list and j >= 1 and j <= #list and i ~= j then
        list[i], list[j] = list[j], list[i]
    end
end

---@param jobid integer
---@return integer? index
local function find_index_by_jobid(jobid)
    for i, term in ipairs(state.terminals) do
        if term.jobid == jobid then
            return i
        end
    end
end

-- Swap any two lines in the side panel
local function panel_lines_swap(i, j)
    local i_line = vim.api.nvim_buf_get_lines(state.panel_bufnr, i - 1, i, false)[1]
    local j_line = vim.api.nvim_buf_get_lines(state.panel_bufnr, j - 1, j, false)[1]
    i_line = i_line:gsub('^%[(%d+)%]', '[' .. j .. ']')
    j_line = j_line:gsub('^%[(%d+)%]', '[' .. i .. ']')
    vim.api.nvim_buf_set_lines(state.panel_bufnr, i - 1, i, false, { j_line })
    vim.api.nvim_buf_set_lines(state.panel_bufnr, j - 1, j, false, { i_line })
end

---@param index integer The position at which to insert the entry
---@param name string The terminal name in this entry
local function insert_entry_in_side_panel(index, name)
    local lines = vim.api.nvim_buf_get_lines(state.panel_bufnr, index - 1, -1, false)
    for i, line in ipairs(lines) do
        lines[i] = line:gsub('^%[(%d+)%]', function(num)
            return '[' .. tostring(tonumber(num) + 1) .. ']'
        end)
    end
    local entry = string.format('[%s] %s %s', index, term_icon, name)
    vim.api.nvim_buf_set_lines(state.panel_bufnr, index , -1, false, lines)
    vim.api.nvim_buf_set_lines(state.panel_bufnr, index - 1, index, false, { entry })
end

---@param index integer
local function delete_entry_in_side_panel(index)
    local lines = vim.api.nvim_buf_get_lines(state.panel_bufnr, index, -1, false)
    for i, line in ipairs(lines) do
        lines[i] = line:gsub('^%[(%d+)%]', function(num)
            return '[' .. tostring(tonumber(num) - 1) .. ']'
        end)
    end
    vim.api.nvim_buf_set_lines(state.panel_bufnr, index - 1, -2, false, lines)
    vim.api.nvim_buf_set_lines(state.panel_bufnr, -2, -1, false, {})
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
        if state.panel_winid and vim.api.nvim_win_is_valid(state.panel_winid) then
            vim.api.nvim_win_set_cursor(state.panel_winid, { state.cur_index, 0 })
        end
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
        end, { buffer = state.term_bufnr })
    end
end

local function delete_term_keymaps()
    for key in pairs(keymaps.term) do
        vim.keymap.del({ 'n', 't' }, key, { buffer = state.term_bufnr })
    end
end

---Set the window to minimal style
---@param winid integer
local function set_win_options(winid)
    for option, value in pairs(win_opts) do
        vim.wo[winid][0][option] = value
    end
end

local function set_termwin_autocmds()
    vim.api.nvim_create_augroup('rockyz.terminal', { clear = true })
    -- Remember its size if terminal window gets resized
    vim.api.nvim_create_autocmd({ 'WinResized' }, {
        group = 'rockyz.terminal',
        callback = function()
            for _, win in ipairs(vim.v.event.windows) do
                if win == state.term_winid then
                    state.term_height = vim.api.nvim_win_get_height(state.term_winid)
                end
                if win == state.panel_winid then
                    state.panel_width = vim.api.nvim_win_get_width(state.panel_winid)
                end
            end
        end,
    })
    -- Make the terminal window and the side panel can be closed together
    vim.api.nvim_create_autocmd({ 'WinClosed' }, {
        group = 'rockyz.terminal',
        pattern = table.concat({ state.term_winid, state.panel_winid }, ','),
        callback = function(ev)
            local closed_win = tonumber(ev.match)
            if closed_win == state.term_winid then
                close_win(state.panel_winid)
            elseif closed_win == state.panel_winid then
                close_win(state.term_winid)
            end
        end,
    })
end

local function on_exit(jobid)
    local index = find_index_by_jobid(jobid)

    -- If the terminal is one that was previously sent from the panel to the tabpage, exit directly.
    if not index then
        return
    end

    local bufnr = state.terminals[index].bufnr

    if state.count_to_delete > 0 then
        -- If deleting terminals in batch, e.g., M.only(), we only update the side panel
        -- once instead of deleting an entry each time.
        delete_buf(bufnr)
        state.count_to_delete = state.count_to_delete - 1
        if state.count_to_delete == 0 then
            state.terminals = { state.terminals[state.cur_index] }
            state.cur_index = 1
            state.count_to_delete = 0

            -- Update the side panel: keep only the current entry and remove all the others
            local line = vim.api.nvim_buf_get_lines(state.panel_bufnr, state.cur_index - 1, state.cur_index, false)[1]
            line = line:gsub('^%[%d+%]', '[1]')
            vim.api.nvim_buf_set_lines(state.panel_bufnr, 0, -1, false, {})
            vim.api.nvim_buf_set_lines(state.panel_bufnr, 0, 1, false, { line })
        end
    else
        -- If deleting a single terminal, e.g., M.delete() or shell's <C-d>, we need to
        -- update the side panel upon each deletion and switch to alternative terminal if
        -- necessary.
        delete_terminal(index)
    end
end

---Create term buffer and add the entry to side panel
---@param opts? rockyz.terminal.new.Opts
---@return boolean
local function create_terminal(opts)
    opts = opts or {}
    local index = opts.index
    local name = opts.name or 'Terminal'
    local cmd = opts.cmd or vim.env.SHELL or 'sh'
    local bufnr = vim.api.nvim_create_buf(false, true)

    local ok, jobid
    vim.api.nvim_buf_call(bufnr, function()
        ok, jobid = pcall(vim.fn.jobstart, cmd, {
            term = true,
            on_exit = on_exit,
        })
    end)

    if not ok or jobid <= 0 then
        if vim.api.nvim_buf_is_valid(bufnr) then
            delete_buf(bufnr)
        end
        notify.error('[Terminal] Failed to start terminal job')
        return false
    end

    state.term_bufnr = bufnr
    table.insert(state.terminals, index or #state.terminals + 1, {
        jobid = jobid,
        bufnr = bufnr,
    })
    state.cur_index = index or #state.terminals
    set_term_keymaps()

    vim.api.nvim_win_set_buf(state.term_winid, bufnr)
    set_win_options(state.term_winid)

    -- Add the entry to the side panel
    index = index or #state.terminals
    insert_entry_in_side_panel(index, name)

    return true
end

local function create_panel_buffer()
    if not state.panel_bufnr or not vim.api.nvim_buf_is_valid(state.panel_bufnr) then
        state.panel_bufnr = vim.api.nvim_create_buf(false, true)
        vim.bo[state.panel_bufnr].filetype = 'TerminalPanel'
    end
    vim.api.nvim_win_set_buf(state.panel_winid, state.panel_bufnr)
    set_win_options(state.panel_winid)
end

-- Open two split wins, one for terminal and another for the side panel
local function open_wins()
    -- Open terminal window
    vim.cmd('botright ' .. state.term_height .. 'split')
    state.term_winid = vim.api.nvim_get_current_win()
    -- Open side panel window and create its buffer
    vim.cmd(state.panel_width .. 'vsplit')
    state.panel_winid = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(state.term_winid)
    set_termwin_autocmds()
end

---@return boolean
local function is_opened()
    return state.term_winid ~= nil and vim.api.nvim_win_is_valid(state.term_winid)
end

---Create a new terminal
---@param opts? rockyz.terminal.new.Opts
function M.new(opts)
    opts = opts or {}
    local index = opts.index
    local was_opened = is_opened()

    if not was_opened then
        open_wins()
        create_panel_buffer()
    end

    if not create_terminal(opts) then
        if not was_opened then
            M.close()
        end
        return
    end

    vim.api.nvim_win_set_cursor(state.panel_winid, { index or #state.terminals, 0 })
    vim.api.nvim_set_current_win(state.term_winid)
end

---Delete the given terminal
---@param index? integer The index of the terminal to delete. Defaults to the current one.
function M.delete(index)
    index = index or state.cur_index
    local term = index and state.terminals[index]
    if not term then
        return
    end

    vim.fn.jobstop(term.jobid)
end

-- Delete all terminals but the current one
function M.only()
    if #state.terminals <= 1 then
        return
    end

    state.count_to_delete = #state.terminals - 1
    for idx = 1, #state.terminals do
        if idx ~= state.cur_index then
            M.delete(idx)
        end
    end
end

---Switch to the i-th terminal
---@param index integer
function M.switch(index)
    if index < 1 or index > #state.terminals then
        return
    end

    local bufnr = state.terminals[index].bufnr
    state.term_bufnr = bufnr
    state.cur_index = index

    if state.term_winid and vim.api.nvim_win_is_valid(state.term_winid) then
        vim.api.nvim_win_set_buf(state.term_winid, state.term_bufnr)
    end

    if state.panel_winid and vim.api.nvim_win_is_valid(state.panel_winid) then
        vim.api.nvim_win_set_cursor(state.panel_winid, { index, 0 })
    end
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
    if not cur_index then
        return
    end

    if direction == -1 and cur_index > 1 then
        M.switch(cur_index - 1)
    elseif direction == 1 and cur_index < #state.terminals then
        M.switch(cur_index + 1)
    end
end

function M.prev()
    jump(-1)
end

function M.next()
    jump(1)
end

-- Rename the current terminal
function M.rename()
    local target_index = state.cur_index
    if not target_index then
        return
    end

    vim.ui.input({ prompt = "[Terminal] Enter name: " }, function(input)
        if input == nil then
            return
        end
        vim.api.nvim_buf_set_lines(state.panel_bufnr, target_index - 1, target_index, false, {
            '[' .. target_index .. '] ' .. term_icon .. ' ' .. input
        })
    end)
end

---Move the current terminal to the previous or next position in the list
---@param direction integer -1 or 1
local function move(direction)
    local cur_index = state.cur_index
    if not cur_index then
        return
    end

    local new_index = cur_index + direction
    if new_index > #state.terminals or new_index < 1 then
        return
    end

    panel_lines_swap(cur_index, new_index)
    list_swap(state.terminals, cur_index, new_index)
    state.cur_index = new_index
    M.switch(new_index)
end

function M.move_prev()
    move(-1)
end

function M.move_next()
    move(1)
end

-- Send current terminal to a new tabpage
function M.to_tab()
    if not state.cur_index then
        return
    end

    vim.cmd('tab split')
    delete_term_keymaps()
    delete_terminal(state.cur_index, true)
end

-- Close the terminal window along with the side panel
function M.close()
    vim.api.nvim_clear_autocmds({ group = 'rockyz.terminal' })
    close_win(state.term_winid)
    close_win(state.panel_winid)
end

---Open the window with a terminal executing command cmd
---@param cmd? string|string[] See cmd in vim.fn.jobstart()
function M.open(cmd)
    if is_opened() then
        return
    end

    open_wins()
    create_panel_buffer()

    if not state.term_bufnr or not vim.api.nvim_buf_is_valid(state.term_bufnr) then
        if not create_terminal({ cmd = cmd }) then
            M.close()
            return
        end
    else
        vim.api.nvim_win_set_buf(state.term_winid, state.term_bufnr)
        set_win_options(state.term_winid)
    end

    vim.api.nvim_win_set_cursor(state.panel_winid, { state.cur_index, 0 })
end

---@param cmd? string|string[] See cmd in vim.fn.jobstart()
function M.toggle(cmd)
    if is_opened() then
        if vim.api.nvim_win_get_tabpage(state.term_winid) ~= vim.api.nvim_get_current_tabpage() then
            -- If the terminal is already open in a different tabpage, open it in the current one.
            M.close()
            M.open(cmd)
        else
            M.close()
        end
    else
        M.open(cmd)
    end
end

function M.to_panel()
    if vim.bo.buftype ~= 'terminal' then
        return
    end

    local jobid = vim.bo.channel
    if find_index_by_jobid(jobid) then
        return
    end

    local bufnr = vim.api.nvim_get_current_buf()

    table.insert(state.terminals, {
        jobid = jobid,
        bufnr = bufnr,
    })

    state.cur_index = #state.terminals
    state.term_bufnr = bufnr

    set_term_keymaps()

    if #vim.api.nvim_list_tabpages() > 1 then
        vim.cmd('tabclose')
    else
        vim.cmd('enew')
    end

    if not is_opened() then
        open_wins()
        create_panel_buffer()
    end

    vim.api.nvim_win_set_buf(state.term_winid, state.term_bufnr)
    set_win_options(state.term_winid)

    insert_entry_in_side_panel(#state.terminals, 'Terminal')
    vim.api.nvim_win_set_cursor(state.panel_winid, { #state.terminals, 0 })
end

function M.toggle_maximize()
    if not is_opened() then
        return
    end

    if not state.maximized then
        state.prev_height = state.term_height
        vim.api.nvim_win_set_height(state.term_winid, vim.o.lines)
    else
        vim.api.nvim_win_set_height(state.term_winid, state.prev_height)
    end

    state.maximized = not state.maximized
    state.term_height = vim.api.nvim_win_get_height(state.term_winid)
end

---In NORMAL mode, send the given line or the cursor line to terminal and run it.
---@param line? string
function M.send_line(line)
    line = line or vim.fn.getline('.')

    if not is_opened() then
        M.open()
    end

    local term = state.cur_index and state.terminals[state.cur_index]
    if not term then
        return
    end

    vim.api.nvim_chan_send(term.jobid, line .. '\n')
end

-- In VISUAL mode, send the selected lines to terminal
function M.send_selection()
    local visual_mode = vim.fn.mode()

    vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes('<Esc>', true, false, true),
        'n',
        false
    )

    vim.schedule(function()
        local start_pos = vim.fn.getpos("'<")
        local end_pos = vim.fn.getpos("'>")

        if visual_mode == 'V' then
            end_pos[3] = #vim.fn.getline(end_pos[2])
        end

        local lines = vim.fn.getregion(start_pos, end_pos, { type = visual_mode })
        local indent = math.huge
        for _, line in ipairs(lines) do
            indent = math.min(line:find("[^ ]") or math.huge, indent)
        end

        indent = indent == math.huge and 0 or indent

        if not is_opened() then
            M.open()
        end

        local term = state.cur_index and state.terminals[state.cur_index]
        if not term then
            return
        end

        for _, line in ipairs(lines) do
            vim.api.nvim_chan_send(term.jobid, line:sub(indent) .. '\n')
        end
    end)
end

---Execute the shell command in a new terminal
---@param cmd? string|string[] See cmd in vim.fn.jobstart()
local function execute_cmd(cmd)
    if not is_opened() then
        M.open(cmd)
    else
        M.new({ cmd = cmd })
    end
end

function M.repl()
    local cmd = repls[vim.bo.filetype]
    execute_cmd(cmd)
end

-- Run the current file
function M.run_file()
    local filepath = vim.api.nvim_buf_get_name(0)
    local escaped_filepath = vim.fn.shellescape(filepath)

    local lines = vim.api.nvim_buf_get_lines(0, 0, 1, true)
    local cmd = escaped_filepath
    local filetype = vim.bo.filetype
    local should_skip_chmod = false
    local has_shebang = vim.startswith(lines[1], '#!')

    if not has_shebang then
        should_skip_chmod = true

        if filetype == 'cpp' then
            -- C++: compile, run and remove the executable
            local executable_name = vim.fn.fnamemodify(filepath, ':t:r')
            local executable_path = vim.fs.joinpath(vim.fs.dirname(filepath), executable_name)
            local escaped_executable_path = vim.fn.shellescape(executable_path)
            cmd = string.format(
                'clang++ -std=c++20 -o %s %s && %s; [[ -e %s ]] && rm -- %s',
                escaped_executable_path,
                escaped_filepath,
                escaped_executable_path,
                escaped_executable_path,
                escaped_executable_path
            )
        elseif filetype == 'lua' then
            -- Lua
            cmd = 'luajit ' .. escaped_filepath
        elseif filetype == 'python' then
            -- Python
            cmd = 'python3 ' .. escaped_filepath
        elseif filetype == 'sh' then
            -- Bash
            cmd = 'bash ' .. escaped_filepath
        elseif filetype == 'zig' then
            -- Zig
            cmd = 'zig run ' .. escaped_filepath
        else
            should_skip_chmod = false
            local choice = vim.fn.confirm('File has no shebang, sure you want to execute it?', '&Yes\n&No')
            if choice ~= 1 then
                return
            end
        end
    end

    local stat = vim.uv.fs_stat(filepath)
    if stat and not should_skip_chmod then
        local user_execute = tonumber('00100', 8) -- 100 means user executable
        if bit.band(stat.mode, user_execute) ~= user_execute then
            local newmode = bit.bor(stat.mode, user_execute)
            vim.uv.fs_chmod(filepath, newmode)
        end
    end

    M.send_line(cmd)
end

local function set_global_keymaps()
    for key, action in pairs(keymaps.global) do
        if type(action) == 'table' then
            for mode, mode_action in pairs(action) do
                vim.keymap.set(mode, key, function()
                    M[mode_action]()
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
