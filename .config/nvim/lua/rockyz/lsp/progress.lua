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
-- For work down progress, the value can be of three different forms:
-- (Ref:
-- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#workDoneProgress)
-- 1. Work down progress begin
-- {
--   kind = 'begin',
--   title = ...,
--   cancellable = ...,    -- optional
--   message = ...,    -- optional
--   percentage = ...,    -- optional
-- }
-- 2. Work down progress report
-- {
--   kind = 'report',
--   cancellable = ...,     -- optional
--   message = ...,    -- optional
--   percentage = ...,    -- optional
-- }
-- 3. Work down progress end
-- {
--   kind = 'end',
--   message = ...,    -- optional
-- }
--
-- When each progress notification sent by the server is received, $/process handler will be invoked
-- to process the notification. See its source code in runtime/lua/vim/lsp/handler.lua. The pramas
-- part will be passed to the handler function as the params. The handler pushes the params (i.e.,
-- the pramas) into the ring buffer of the corresponding client (i.e., client.progress) and then
-- trigger LspProgress autocmd event. When LspProgress is triggered, its callback will be invoked
-- with a table argument. The argument has a data table with two fields:
-- 1. data.client_id
-- 2. data.params: the pramas part
-- For details, see the source code `M[ms.dollar_progress]` in runtime/lua/vim/lsp/handler.lua
--
-- So we can use the callback function of LspProgress to get the progress information we need.
-- 1. Directly from the args passed into the callback such as args.data.params.value.title for the
--    the title of the progress notification. Each time we can print one progress message.
-- 2. Call vim.lsp.status() in the callback. It gets the progress message in the ring buffer and
--    emptys the ring buffer, and it is called for each arrived notification, so in each call of
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
-- iterator will be called and the returned value will be asigned to ele, and the loop will
-- terminate when the iterator returns nil.
-- Take `for k, v in pairs(t) do` as an example. When this for statement is executed, it first calls
-- pairs() to get an iterator, and then in each iteration this iterator will be called.
-- More about the iterator and generic for, see https://www.lua.org/pil/7.html
--
-- We know that client.progress is a ring buffer. A ring buffer actually is a table. The table not
-- only stores the items pushed in it (self._items) but also maintain necessary variables to keep
-- track of its own state (self._size, self._idx_read, self._idx_write, etc). In the metatable of
-- this table, we define __call to pop out the first item by self:pop(), so the table is callable. Back to that
-- tricky for loop `for progress in client.progress do`, in each iteration, client.progres as an
-- iterator will be called and it pops out the first item. The for loop terminates when the iterator
-- returns nil, i.e., no more items in the ring buffer of the client. So for each vim.lsp.status()
-- call, it will print all the items (i.e., the progress messages) in the ring buffers of all the
-- active clients, and all the ring buffers will be empty. This is what the **COMSUMES** means.
--
-- More about vim.ringbuf's definition and operations, see its source code
-- https://github.com/neovim/neovim/blob/master/runtime/lua/vim/shared.lua

--------------
-- More on LSP
--------------
--
-- There are three types of communication between the client (i.e., the development tool) and the
-- language server:
-- 1. The client sends a request, the server gets the request and return the corresponding response.
--    E.g., the textDocument/definition (Goto Definition) request.
-- 2. The server sends a request, the client gets the request and return the corresponding response.
--    E.g., the workspace/inlayHint/refresh (Inlay Hint Refresh) request.
-- 3. Both client and server can send a notification to each other, and must not send a response
--    back. E.g., the $/progress notification can be sent from the client or the server.
--
-- There is an diagram example illustrating how the client (development tool) and server
-- communicate, see https://microsoft.github.io/language-server-protocol/overviews/lsp/overview/
--
-- In Neovim, the client and server communicate through stdio. The process of establishing a
-- connection and communication bewteen the client and server is as follows:
-- * Call vim.lsp.start_client({config}). It will create a LSP client (:h vim.lsp.client). The
-- config parameter has a cmd field that is a command to launch a LSP server.
-- * In start_client, it calls vim.lsp.rpc.start(cmd). In rpc.start(), it first creates a RPC
-- client. NOTE: so far we have two kinds of clients, LSP client and RPC client. The LSP client
-- created in the first step above is upper level for exposing APIs such as
-- vim.lsp.buf_request_all() to uses. Actually it's just a wrapper of the RPC client. The LSP
-- operations such as sending request are performed through the underlying RPC client.
-- * Next, rpc.start() will call vim.system(cmd, {opts}) by passing a system command cmd and an
-- options {opts} containing three important fields, stdin, stdout and stderr. These three fields
-- will be explained below. vim.system() will run cmd to launch the LSP server and return a
-- vim.SystemObj object (:h vim.system). Under the hood, vim.system uses uv.spawn(cmd, stdio) to
-- initialize and start a process to run the server. stdio is used to communicate with the process
-- running the server.
--   1. stdin: set to true to create a pipe used to connect to stdin (stdin = uv.new_pipe()). A
--      request to LSP server is send through the stdin. When we send a request to the LSP server by
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
-- returned funtion to create a RPC client and connect to the server via tcp:connect(host, port).
-- When we send a request to the server, tcp:write() will be called. To handle the response, it's
-- almost the same with stdout. See the source code of vim.lsp.rpc.connect() function for details.
--
-- I use the args passed in the callback of LspProgress to get the progress message. If there are
-- multiple servers sending progress notifications at the same time, display the message from
-- different servers in a separate window. The windows are stacked from bottom to top above the
-- statusline in the bottom-right corner.

local icons = {
    spinner = { '⣾', '⣽', '⣻', '⢿', '⡿', '⣟', '⣯', '⣷' },
    done = ' ',
}

-- Maintain properties for each client receiving the progress notifications. It is indexed by the
-- client id and has these fields:
-- * is_done: whether the progress is finished
-- * spinner_idx: current index of the spinner
-- * winid: winid of the floating window
-- * bufnr: bufnr of the floating window
-- * message: the progress message that will be shown in the window
-- * pos: the position of this window counting from bottom to top
-- * timer: used to delay the closing of the window and handle window closure during textlock
local clients = {}
-- Maintain the total number of current windows
local total_wins = 0

-- Suppress errors that may occur while render windows. E.g., nvim_buf_set_lines() will throw E565
-- when textlock is active. I encounter this issue when I use quick-scope in visual mode and its
-- getchar() brings about textlock.
-- All other errors will be re-thrown.
-- Adapted from j-hui/fidget.nvim
---@param callable function
---@return boolean # If the callable executes successfully or not
local function guard(callable)
    local whitelist = {
        'E11: Invalid in command%-line window',
        'E523: Not allowed here',
        'E565: Not allowed to change',
    }
    local ok, err = pcall(callable)
    if ok then
        return true
    end
    if type(err) ~= 'string' then
        error(err)
    end
    for _, msg in ipairs(whitelist) do
        if string.find(err, msg) then
            return false
        end
    end
    error(err)
end

-- Initialize or reset the properties of the given client
local function init_or_reset(client)
    client.is_done = false
    client.spinner_idx = 0
    client.winid = nil
    client.bufnr = nil
    client.message = nil
    client.pos = total_wins + 1
    client.timer = nil
end

-- Get the row position of the current floating window. If it is the first one, it is placed just
-- right above the statuslien; if not, it is placed on top of others.
local function get_win_row(pos)
    return vim.o.lines - vim.o.cmdheight - 1 - pos * 3
end

-- Update the window config
local function win_update_config(client)
    vim.api.nvim_win_set_config(client.winid, {
        relative = 'editor',
        width = #client.message,
        height = 1,
        row = get_win_row(client.pos),
        col = vim.o.columns - #client.message,
    })
end

-- Close the window and delete the associated buffer
local function close_window(winid, bufnr)
    if vim.api.nvim_win_is_valid(winid) then
        vim.api.nvim_win_close(winid, true)
    end
    if vim.api.nvim_buf_is_valid(bufnr) then
        vim.api.nvim_buf_delete(bufnr, { force = true })
    end
end

-- Assemble the output progress message and set the flag to mark if it's completed.
-- * General: ⣾ [client_name] title: message ( 5%)
-- * Done:     [client_name] title: DONE!
local function process_message(client, name, params)
    local message = ''
    message = '[' .. name .. ']'
    local kind = params.value.kind
    local title = params.value.title
    if title then
        message = message .. ' ' .. title .. ':'
    end
    if kind == 'end' then
        client.is_done = true
        message = icons.done .. ' ' .. message .. ' DONE!'
    else
        client.is_done = false
        local raw_msg = params.value.message
        local pct = params.value.percentage
        if raw_msg then
            message = message .. ' ' .. raw_msg
        end
        if pct then
            message = string.format('%s (%3d%%)', message, pct)
        end
        -- Spinner
        local idx = client.spinner_idx
        idx = idx == #icons.spinner * 4 and 1 or idx + 1
        message = icons.spinner[math.ceil(idx / 4)] .. ' ' .. message
        client.spinner_idx = idx
    end
    return message
end

-- Show the progress message in floating window
local function show_message(client)
    local winid = client.winid
    -- Create a new window or update the existing one
    if
        winid == nil
        or not vim.api.nvim_win_is_valid(winid)
        or vim.api.nvim_win_get_tabpage(winid) ~= vim.api.nvim_get_current_tabpage() -- Switch to another tab
    then
        local success = guard(function()
            winid = vim.api.nvim_open_win(client.bufnr, false, {
                relative = 'editor',
                width = #client.message,
                height = 1,
                row = get_win_row(client.pos),
                col = vim.o.columns - #client.message,
                focusable = false,
                style = 'minimal',
                noautocmd = true,
                border = vim.g.border_style,
            })
        end)
        if not success then
            return
        end
        client.winid = winid
        total_wins = total_wins + 1
    else
        win_update_config(client)
    end
    -- Write the message into the buffer
    vim.wo[winid].winhl = 'Normal:Normal'
    guard(function()
        vim.api.nvim_buf_set_lines(client.bufnr, 0, 1, false, { client.message })
    end)
end

-- Display the progress message
local function handler(args)
    local client_id = args.data.client_id

    -- Initialize the properties
    if clients[client_id] == nil then
        clients[client_id] = {}
        init_or_reset(clients[client_id])
    end
    local cur_client = clients[client_id]

    -- Create buffer for the floating window showing the progress message and the timer used to close
    -- the window when progress report is done.
    if cur_client.bufnr == nil then
        cur_client.bufnr = vim.api.nvim_create_buf(false, true)
    end
    if cur_client.timer == nil then
        cur_client.timer = vim.uv.new_timer()
    end

    -- Get the formatted progress message
    cur_client.message = process_message(cur_client, vim.lsp.get_client_by_id(client_id).name, args.data.params)

    -- Show progress message in floating window
    show_message(cur_client)

    -- Close the window when finished and adjust the positions of other windows if they exist.
    -- Let the window stay briefly on the screen before closing it (say 2s). When closing, attempt to
    -- close at intervals (say 100ms) to handle the potential textlock. We can use uv.timer to
    -- implement it.
    --
    -- NOTE:
    -- During the waiting period, if it is set for a long duration like 3s, the same server may report
    -- another around of progress notification, and this window will continue to be used for
    -- displaying. When the period is over and an attempt is made to close the window, two possible
    -- scenarios may occur:
    -- 1. the new round of progress notification report has not yet finished, so this window
    --    should not be closed.
    -- 2. the new round of progress notification report has finished. We should avoid the window being
    --    closed twice. In the code below, timer:start() will be called again and it just resets the
    --    timer, so the window will not be closed twice.
    if cur_client.is_done then
        cur_client.timer:start(2000, 100, vim.schedule_wrap(function()
            -- To handle the scenario 1
            if not cur_client.is_done and cur_client.winid ~= nil then
                cur_client.timer:stop()
                return
            end
            local success = false
            -- Close the window if it has not been closed yet
            if cur_client.winid ~= nil and cur_client.bufnr ~= nil then
                success = guard(function()
                    close_window(cur_client.winid, cur_client.bufnr)
                end)
            end
            -- If the window is closed successfully, stop the timer, adjust the positions of other windows
            -- and reset properties of the client
            if success then
                cur_client.timer:stop()
                cur_client.timer:close()
                total_wins = total_wins - 1
                -- Move all windows above this closed window down by one position
                for _, c in ipairs(clients) do
                    if c.winid ~= nil and c.pos > cur_client.pos then
                        c.pos = c.pos - 1
                        win_update_config(c)
                    end
                end
                -- Reset the properties
                init_or_reset(cur_client)
            end
        end))
    end
end

-- Display the progress message when it comes
local group = vim.api.nvim_create_augroup('rockyz.lsp_progress', { clear = true })
vim.api.nvim_create_autocmd({ 'LspProgress' }, {
    group = group,
    pattern = '*',
    callback = function(args)
        handler(args)
    end,
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
        for _, c in ipairs(clients) do
            if c.is_done then
                win_update_config(c)
            end
        end
    end,
})
