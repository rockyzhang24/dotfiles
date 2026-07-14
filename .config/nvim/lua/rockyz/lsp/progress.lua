-----------------------------------------------
-- The underlying principle behind LSP progress
-----------------------------------------------
--
-- Each LSP client object (:h vim.lsp.client) has a member called progress. It's a ring buffer
-- (vim.ringbuf) to store the progress message sent from the server.
--
-- Progress is a kind of notification send by the server. A notification's structure defined by LSP
-- is shown as below. LSP is based on JSON-RPC protocol (https://www.jsonrpc.org/specification) that
-- uses JSON as data format for communication between the server and client. Neovim will encode
-- (vim.json.encode) and decode (vim.json.decode) to do the conversion between Lua table and JSON.
-- So here I use Lua table to describe the structure of the progress notification.
-- (Ref:
-- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#progress)
-- {
--   method = '$/progress',
--   params =  {
--     token = ...,
--     value = {
--       ...    -- see below
--     },
-- }
-- For work done progress, the value can be of three different forms:
-- (Ref:
-- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#workDoneProgress)
-- 1. Work done progress begin
-- {
--   kind = 'begin',
--   title = ...,
--   cancellable = ...,    -- optional
--   message = ...,    -- optional
--   percentage = ...,    -- optional
-- }
-- 2. Work done progress report
-- {
--   kind = 'report',
--   cancellable = ...,     -- optional
--   message = ...,    -- optional
--   percentage = ...,    -- optional
-- }
-- 3. Work done progress end
-- {
--   kind = 'end',
--   message = ...,    -- optional
-- }
--
-- When each progress notification sent by the server is received, $/progress handler will be invoked
-- to process the notification. See its source code in runtime/lua/vim/lsp/handler.lua. The params
-- part will be passed to the handler function as the params. The handler pushes the params (i.e.,
-- the params) into the ring buffer of the corresponding client (i.e., client.progress) and then
-- trigger LspProgress autocmd event. When LspProgress is triggered, its callback will be invoked
-- with a table argument. The argument has a data table with two fields:
-- 1. data.client_id
-- 2. data.params: the params part
-- For details, see the source code `M[ms.dollar_progress]` in runtime/lua/vim/lsp/handler.lua
--
-- So we can use the callback function of LspProgress to get the progress information we need.
-- 1. Directly from the args passed into the callback such as args.data.params.value.title for the
--    the title of the progress notification. Each time we can print one progress message.
-- 2. Call vim.lsp.status() in the callback. It gets the progress message in the ring buffer and
--    empties the ring buffer, and it is called for each arrived notification, so in each call of
--    status() only a single one message will be printed.

---------------------------
-- More on vim.lsp.status()
---------------------------
--
-- In each call of status() function, it will iterate all the active clients. In each client, it
-- **CONSUMES** all the progress messages in the ring buffer. Its implementation is very inspiring.
-- The trick is this line of code `for progress in client.progress do`. This is a generic for
-- statement.
--
-- Short explanation about the generic for statement:
-- (In Lua, for statement has two forms, numerical and generic)
-- In this generic for statement `for ele in xxx do`, xxx is an iterator (An iterator is a function
-- and each time when the function is called, it returns a "next" element from a collection and nil
-- when no more elements in the collection). When the for loop is executed, at each iteration, the
-- iterator will be called and the returned value will be assigned to ele, and the loop will
-- terminate when the iterator returns nil.
-- Take `for k, v in pairs(t) do` as an example. When this for statement is executed, it first calls
-- pairs() to get an iterator, and then in each iteration this iterator will be called.
-- More about the iterator and generic for, see https://www.lua.org/pil/7.html
--
-- We know that client.progress is a ring buffer. A ring buffer actually is a table. The table not
-- only stores the items pushed in it (self._items) but also maintain necessary variables to keep
-- track of its own state (self._size, self._idx_read, self._idx_write, etc). In the metatable of
-- this table, we define __call to pop out the first item by self:pop(), so the table is callable. Back to that
-- tricky for loop `for progress in client.progress do`, in each iteration, client.progress as an
-- iterator will be called and it pops out the first item. The for loop terminates when the iterator
-- returns nil, i.e., no more items in the ring buffer of the client. So for each vim.lsp.status()
-- call, it will print all the items (i.e., the progress messages) in the ring buffers of all the
-- active clients, and all the ring buffers will be empty. This is what the **CONSUMES** means.
--
-- More about vim.ringbuf's definition and operations, see its source code
-- https://github.com/neovim/neovim/blob/master/runtime/lua/vim/shared.lua

--------------
-- More on LSP
--------------
--
-- There are three types of communication between the client (i.e., the development tool) and the
-- language server:
-- 1. The client sends a request, the server gets the request and returns the corresponding response.
--    E.g., the textDocument/definition (Goto Definition) request.
-- 2. The server sends a request, the client gets the request and returns the corresponding response.
--    E.g., the workspace/inlayHint/refresh (Inlay Hint Refresh) request.
-- 3. Both client and server can send a notification to each other, and must not send a response
--    back. E.g., the $/progress notification can be sent from the client or the server.
--
-- There is an diagram example illustrating how the client (development tool) and server
-- communicate, see https://microsoft.github.io/language-server-protocol/overviews/lsp/overview/
--
-- In Neovim, the client and server communicate through stdio. The process of establishing a
-- connection and communication between the client and server is as follows:
-- * Call vim.lsp.start_client({config}). It will create a LSP client (:h vim.lsp.client). The
-- config parameter has a cmd field that is a command to launch a LSP server.
-- * In start_client, it calls vim.lsp.rpc.start(cmd). In rpc.start(), it first creates a RPC
-- client. NOTE: so far we have two kinds of clients, LSP client and RPC client. The LSP client
-- created in the first step above is upper level for exposing APIs such as
-- vim.lsp.buf_request_all() to users. Actually it's just a wrapper of the RPC client. The LSP
-- operations such as sending request are performed through the underlying RPC client.
-- * Next, rpc.start() will call vim.system(cmd, {opts}) by passing a system command cmd and an
-- options {opts} containing three important fields, stdin, stdout and stderr. These three fields
-- will be explained below. vim.system() will run cmd to launch the LSP server and return a
-- vim.SystemObj object (:h vim.system). Under the hood, vim.system uses uv.spawn(cmd, stdio) to
-- initialize and start a process to run the server. stdio is used to communicate with the process
-- running the server.
--   1. stdin: set to true to create a pipe used to connect to stdin (stdin = uv.new_pipe()). A
--      request to LSP server is sent through the stdin. When we send a request to the LSP server by
--      calling an APIs such as vim.lsp.buf_request_all(), it uses SystemObj's write() method (which
--      calls stdin:write(data)) to write the request data into the pipe.
--   2. stdout: a handler to handle the output from stdout. In vim.system, a pipe will be created
--      (uv.new_pipe) to connect to the stdout. The response sent by the server will be put to the
--      stdout. The stdout handler will get the response (it has two parts, header and content) and
--      pass the content part into the handle_body(content) function (check it out in
--      runtime/lua/vim/lsp/rpc.lua). handle_body() will call the corresponding handler of the
--      response (based on the request's method) with the result field in the response's content
--      part as the argument. For notification, it is handled in the same way as the response.
--   3. stderr: a handler to handle the output from stderr. In vim.system, a pipe will be created
--      and connect to the stderr.
--
-- Neovim also provides another option to support the communication between the client and server,
-- namely through TCP. For example, language server Godot only supports TCP. So we need to set the
-- cmd to vim.lsp.rpc.connect('127.0.0.1', os.getenv('GDScript_Port')) when we call
-- vim.lsp.start_client(). For details, see the source file (gdscript.lua) in nvim-lspconfig. The
-- method vim.lsp.rpc.connect() will return a function. vim.lsp.start_client() will call this
-- returned function to create a RPC client and connect to the server via tcp:connect(host, port).
-- When we send a request to the server, tcp:write() will be called. To handle the response, it's
-- almost the same with stdout. See the source code of vim.lsp.rpc.connect() function for details.
--
-- I use the args passed in the callback of LspProgress to get the progress message. If there are
-- multiple servers sending progress notifications at the same time, display the message from
-- different servers in a separate window. The windows are stacked from bottom to top above the
-- statusline in the bottom-right corner.

local M = {}

local config = {
    spinner_frame_repeats = 4,
    done_delay_ms = 2000,
    close_retry_interval_ms = 100,
    window_zindex = 30,
}

local icons = {
    spinner = { '⣾', '⣽', '⣻', '⢿', '⡿', '⣟', '⣯', '⣷' },
    done = '',
}

local expected_error_patterns = {
    'E11: Invalid in command%-line window',
    'E523: Not allowed here',
    'E565: Not allowed to change',
}

---@class ProgressState
---@field is_done boolean Whether the progress has finished
---@field spinner_idx integer Current spinner frame index
---@field winid integer|nil Floating window id
---@field bufnr integer|nil Floating window buffer id
---@field message string|nil Message currently shown in the floating window
---@field pos integer Stack position, counted from bottom to top. 0 before a stack slot is allocated.
---@field timer uv.uv_timer_t|nil Timer used to defer closing, especially during textlock

---Runtime state for each LSP client that reports progress, indexed by client id.
---@type table<integer, ProgressState>
local progress_states = {}

---Number of allocated progress float stack slots
local stack_size = 0

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

---Execute a Neovim API call while suppressing expected transient errors.
---
---Errors caused by temporary editor states (for example, textlock) are ignored, while all other
---errors are re-thrown.
---
---E.g., nvim_buf_set_lines() will throw E565 when textlock is active. I encounter this issue when
---I use quick-scope in visual mode and its getchar() brings about textlock.
---
---Adapted from j-hui/fidget.nvim
---@param callable function
---@return boolean # Whether the callable completed successfully
local function guard(callable)
    local ok, err = pcall(callable)
    if ok then
        return true
    end
    if type(err) ~= 'string' then
        error(err)
    end
    for _, pattern in ipairs(expected_error_patterns) do
        if string.find(err, pattern) then
            return false
        end
    end
    error(err)
end

---Reset a progress state to its initial state
---@param state ProgressState
local function reset_state(state)
    state.is_done = false
    state.spinner_idx = 0
    state.message = nil
    state.winid = nil
    state.bufnr = nil
    state.timer = nil
    state.pos = 0
end

---@param client_id integer
---@return ProgressState
local function get_state(client_id)
    local state = progress_states[client_id]
    if state == nil then
        ---@type ProgressState
        state = {}
        reset_state(state)
        progress_states[client_id] = state
    end

    -- Lazily create the floating window buffer
    if state.bufnr == nil then
        state.bufnr = vim.api.nvim_create_buf(false, true)
    end

    -- Lazily create the timer to delay window close when progress report is done
    if state.timer == nil then
        state.timer = vim.uv.new_timer()
    end

    return state
end

--------------------------------------------------------------------------------
-- Window management
--------------------------------------------------------------------------------

---Return the row for a floating window at the given stack position
---@param pos integer
---@return integer
local function get_win_row(pos)
    return vim.o.lines - vim.o.cmdheight - 1 - pos * (vim.g.border_enabled and 3 or 1)
end

---Return whether the progress float needs to be opened in the current tabpage
---@param state ProgressState
---@return boolean
local function need_new_window(state)
    local winid = state.winid
    return winid == nil
        or not vim.api.nvim_win_is_valid(winid)
        or vim.api.nvim_win_get_tabpage(winid) ~= vim.api.nvim_get_current_tabpage()
end

---@param state ProgressState
local function update_win_config(state)
    local winid = state.winid

    -- A tabpage switch can leave a stale winid until the float is recreated
    if winid == nil or not vim.api.nvim_win_is_valid(winid) then
        return
    end

    guard(function()
        local width = vim.fn.strdisplaywidth(state.message)
        vim.api.nvim_win_set_config(winid, {
            relative = 'editor',
            width = width,
            height = 1,
            row = get_win_row(state.pos),
            col = vim.o.columns - width,
        })
    end)
end

---@param state ProgressState
local function update_buffer(state)
    guard(function()
        vim.api.nvim_buf_set_lines(state.bufnr, 0, 1, false, { state.message })
    end)
end

---@param state ProgressState
---@return boolean
local function create_window(state)
    -- Reuse the stack position when recreating a float after a tabpage switch
    local is_new_state = state.pos == 0
    local pos = state.pos

    if is_new_state then
        pos = stack_size + 1
    end

    local winid

    local success = guard(function()
        local width = vim.fn.strdisplaywidth(state.message)
        winid = vim.api.nvim_open_win(state.bufnr, false, {
            relative = 'editor',
            width = width,
            height = 1,
            row = get_win_row(pos),
            col = vim.o.columns - width,
            focusable = false,
            style = 'minimal',
            noautocmd = true,
            border = vim.g.border_style,
            zindex = config.window_zindex,
        })
    end)

    if not success then
        return false
    end

    -- Record the opened window; a recorded float keeps its existing stack position
    state.winid = winid
    if is_new_state then
        state.pos = pos
        stack_size = stack_size + 1
    end

    return true
end

---Close the floating window but keep its associated buffer
---@param state ProgressState
---@return boolean
local function close_float(state)
    return guard(function()
        if state.winid and vim.api.nvim_win_is_valid(state.winid) then
            vim.api.nvim_win_close(state.winid, true)
        end
    end)
end

---Close the window and delete the associated buffer
---@param state ProgressState
---@return boolean
local function close_window(state)
    return guard(function()
        if state.winid and vim.api.nvim_win_is_valid(state.winid) then
            vim.api.nvim_win_close(state.winid, true)
        end
        if state.bufnr and vim.api.nvim_buf_is_valid(state.bufnr) then
            vim.api.nvim_buf_delete(state.bufnr, { force = true })
        end
    end)
end

---Best-effort render of the current progress message.
---Creates a floating window if needed, updates its layout, then writes the message.
---Failures caused by temporary Neovim states such as textlock are suppressed by `guard()`.
---@param state ProgressState
local function render_message(state)
    -- Float windows belong to a tabpage, so recreate an existing float in the current tabpage.
    if need_new_window(state) then
        if state.winid ~= nil and not close_float(state) then
            return
        end
        create_window(state)
    else
        update_win_config(state)
    end
    -- Write the message into the buffer
    update_buffer(state)
end

--------------------------------------------------------------------------------
-- Message formatting
--------------------------------------------------------------------------------

---@param state ProgressState
---@return string
local function next_spinner(state)
    local idx = state.spinner_idx + 1
    if idx > #icons.spinner * config.spinner_frame_repeats then
        idx = 1
    end
    state.spinner_idx = idx
    return icons.spinner[math.ceil(idx / config.spinner_frame_repeats)]
end

---@param lsp_client vim.lsp.Client
---@return string
local function build_base_message(lsp_client, value)
    local message = '[' .. lsp_client.name .. ']'
    if value.title then
        message = message .. ' ' .. value.title .. ':'
    end
    return message
end

---@param state ProgressState
---@param base_message string
---@return string
local function build_done_message(state, base_message)
    state.is_done = true
    return icons.done .. ' ' .. base_message .. ' DONE!'
end

---@param state ProgressState
---@param base_message string
---@return string
local function build_progress_message(state, base_message, value)
    state.is_done = false
    local message = base_message

    if value.message then
        message = message .. ' ' .. value.message
    end

    if value.percentage then
        message = string.format('%s (%3d%%)', message, value.percentage)
    end

    return next_spinner(state) .. ' ' .. message
end

---Assemble the output progress message and set the flag to mark if it's completed.
---  * General: ⣾ [client_name] title: message ( 5%)
---  * Done:     [client_name] title: DONE!
---@param state ProgressState
---@param lsp_client vim.lsp.Client
---@param params lsp.ProgressParams
---@return string
local function build_message(state, lsp_client, params)
    local value = params.value
    local message = build_base_message(lsp_client, value)

    if value.kind == 'end' then
        return build_done_message(state, message)
    end

    return build_progress_message(state, message, value)
end

--------------------------------------------------------------------------------
-- Progress lifecycle
--------------------------------------------------------------------------------

---@param state ProgressState
local function should_keep_window(state)
    return not state.is_done and state.winid ~= nil
end

---Reset a closed progress state while retaining it for future progress from the same client
---
---Stops and destroys its close timer, reflows remaining floats, then resets its fields
---@param state ProgressState
local function cleanup_state(state)
    local timer = state.timer
    -- A queued close callback may run after another path has reset the state
    if timer == nil then
        return
    end

    timer:stop()
    timer:close()

    if state.winid ~= nil then
        stack_size = stack_size - 1

        -- Move all windows above this closed window down by one position
        for _, s in pairs(progress_states) do
            if s.winid ~= nil and s.pos > state.pos then
                s.pos = s.pos - 1
                update_win_config(s)
            end
        end
    end

    reset_state(state)
end

---Dispose of a detached client's progress state and remove it from progress_states
---
---Retries if a transient editor state prevents the floating window from closing
---@param client_id integer
local function cleanup_client_state(client_id)
    local state = progress_states[client_id]
    if state == nil then
        return
    end

    if state.bufnr == nil then
        progress_states[client_id] = nil
        return
    end

    if close_window(state) then
        cleanup_state(state)
        progress_states[client_id] = nil
        return
    end

    vim.defer_fn(function()
        cleanup_client_state(client_id)
    end, config.close_retry_interval_ms)
end

---@param state ProgressState
local function close_window_if_done(state)
    -- A new progress notification arrived before the close timer fired
    if should_keep_window(state) then
        state.timer:stop()
        return
    end

    if state.bufnr == nil then
        cleanup_state(state)
        return
    end

    if close_window(state) then
        cleanup_state(state)
    end
end

---Schedule closing of a finished progress window
---@param state ProgressState
local function schedule_close(state)
    state.timer:start(
        config.done_delay_ms,
        config.close_retry_interval_ms,
        vim.schedule_wrap(function()
            close_window_if_done(state)
        end)
    )
end

---Callback of LspProgress autocmd: display the progress message
---@param event table The argument of the callback
local function handle_progress(event)
    local client_id = event.data.client_id

    ---@type vim.lsp.Client|nil
    local lsp_client = vim.lsp.get_client_by_id(client_id)
    if lsp_client == nil then
        return
    end

    ---@type ProgressState
    local state = get_state(client_id)

    state.message = build_message(state, lsp_client, event.data.params)

    -- Show progress message in the floating window
    render_message(state)

    -- Close the window when progress finishes and adjust the positions of other windows.
    -- Let the window stay briefly on the screen before closing it (say 2s). When closing, attempt
    -- to close at intervals (say 100ms) to handle the potential textlock.
    --
    -- NOTE:
    -- During the waiting period, if it is set for a long duration like 3s, the same server may
    -- report another around of progress notification, and this window will continue to be used for
    -- displaying. When the period is over and an attempt is made to close the window, two possible
    -- scenarios may occur:
    -- 1. the new round of progress notification report has not yet finished, so this window should
    --    not be closed.
    -- 2. the new round of progress notification report has finished. We should avoid the window
    --    being closed twice. In the code below, timer:start() will be called again and it just
    --    resets the timer, so the window will not be closed twice.
    if state.is_done then
        schedule_close(state)
    end
end

---Schedule progress-state cleanup after a client detaches from its last buffer
---@param event table
local function handle_lsp_detach(event)
    ---@type vim.event.lspdetach.data
    local data = event.data
    local client_id = data.client_id

    -- LspDetach fires before Neovim removes the buffer from client.attached_buffers
    vim.schedule(function()
        local client = vim.lsp.get_client_by_id(client_id)
        if client ~= nil and next(client.attached_buffers) ~= nil then
            return
        end

        cleanup_client_state(client_id)
    end)
end

--------------------------------------------------------------------------------
-- Autocmds
--------------------------------------------------------------------------------

local group = vim.api.nvim_create_augroup('rockyz.lsp_progress', { clear = true })

-- Display the progress message when it comes
vim.api.nvim_create_autocmd('LspProgress', {
    group = group,
    pattern = { 'begin', 'report', 'end' },
    callback = handle_progress,
})

vim.api.nvim_create_autocmd('LspDetach', {
    group = group,
    callback = handle_lsp_detach,
})

-- Update windows.
-- 1. VimResized: When the server finishes reporting the progress notification, I have the window
--    stayed on screen for a few seconds, however, the window (such as its position) won't be
--    updated any more in LspProgress event. When the terminal window is resized, windows of this
--    kind need to be updated.
-- 2. TermLeave: It's for fzf.vim and it's so weird. Take the golang server as an example, it only
--    send two progress notifications, 'begin' kind and 'end' kind. After we open a golang file,
--    firstly a floating window will be created showing the message of the first progress
--    notification (i.e., 'begin' kind). Let's say the window width is 53. Meanwhile, we open a
--    fzf.vim window. At this point, that floating window has already displayed the message of the
--    second progress notification (i.e., 'end' kind) and it will stay on the screen for a few
--    seconds before it is closed. Let's say its width is 35. Now we quite the fzf.vim window. We
--    can see that the width of the floating window is changed back to 53, i.e., reverting to the
--    width when displaying the first message before that fzf.vim window was opened. THIS IS SO
--    WEIRD! So use this autocmd to set the floating window back to 35.
vim.api.nvim_create_autocmd({ 'VimResized', 'TermLeave' }, {
    group = group,
    pattern = '*',
    callback = function()
        for _, s in pairs(progress_states) do
            if s.is_done and s.winid ~= nil and vim.api.nvim_win_is_valid(s.winid) then
                update_win_config(s)
            end
        end
    end,
})

-- Move the single global set of progress floats to the tabpage being entered
vim.api.nvim_create_autocmd('TabEnter', {
    group = group,
    callback = function()
        for _, state in pairs(progress_states) do
            -- A nonzero position means this state already owns a stack slot
            if state.pos > 0 then
                render_message(state)
            end
        end
    end,
})

return M
