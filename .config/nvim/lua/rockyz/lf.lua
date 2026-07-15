-- _ to toggle lf
-- q to quit
-- <C-x>, <C-v>, <C-t> to open the selected files in split, vsplit or tab
-- <C-Enter> to open the files in the previous window
-- <C-q> to change nvim's cwd to the current directory of lf

local notify = require('rockyz.utils.notify')

local M = {}

--------------------------------------------------------------------------------
-- Configuration
--------------------------------------------------------------------------------

local config = {
    keymaps = {
        ['<C-x>'] = 'split',
        ['<C-v>'] = 'vsplit',
        ['<C-t>'] = 'tab',
        ['<C-Enter>'] = 'edit',
        ['<C-q>'] = 'cd',
    },
}

local open_modes = {
    split = 'belowright split',
    vsplit = 'belowright vsplit',
    tab = 'tab split',
    edit = 'edit',
}

---@class LfState
---@field winid integer Floating window id
---@field bufnr integer Terminal buffer id
---@field jobid integer Terminal job id
---@field lf_pid integer Process id of the lf instance

---@type LfState
local state = {
    winid = -1,
    bufnr = -1,
    jobid = -1,
    lf_pid = -1,
}

local previous_fzf_default_opts
local is_hiding = false

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

local function window_config()
    local win_width = math.floor(vim.o.columns * 0.8)
    local win_height = math.floor(vim.o.lines * 0.8)

    local row = math.floor((vim.o.lines - win_height) / 2) - 2
    local col = math.floor((vim.o.columns - win_width) / 2)

    return {
        relative = 'editor',
        border = vim.g.border_style,
        style = 'minimal',
        row = row,
        col = col,
        width = win_width,
        height = win_height,
    }
end

---@param value string
---@return string
local function lua_string(value)
    return "'" .. value:gsub("\\", "\\\\"):gsub("'", "\\'") .. "'"
end

---@param ... string
---@return string
local function format_lua_args(...)
    local args = { ... }
    for i, arg in ipairs(args) do
        args[i] = lua_string(arg)
    end
    return table.concat(args, ', ')
end

---Generate lf remote command that tells the parent Nvim (i.e., the remote server) to run the
---function from lf.lua module via Nvim's RPC.
---
---Example: tell the parent Nvim to run a function foobar() with the selected files as the argument
---lf -remote 'send lf_pid $nvim --server "$NVIM" --remote-expr "v:lua.require(\'rockyz.lf\').foobar(\'$fx\')"'
---@param function_name string Name of the exported Lua function
---@param lua_args? string Lua source code representing the function arguments, e.g., "'foo', 'bar'"
---@return string[] # Command passed to `vim.system()`
local function build_remote_expr_cmd(function_name, lua_args)
    lua_args = lua_args or ''
    return {
        'lf',
        '-remote',
        string.format(
            'send %s $nvim --server "$NVIM" --remote-expr "v:lua.require(\'rockyz.lf\').%s(%s)"',
            state.lf_pid,
            function_name,
            lua_args
        ),
    }
end

---@param function_name string
---@param lua_args? string Lua source code representing the function arguments
local function send_remote_command(function_name, lua_args)
    vim.system(build_remote_expr_cmd(function_name, lua_args), { text = true })
end

---@param command string Vim Ex command used to open the selected files
local function open_selection(command)
    send_remote_command('remote_open_selection', format_lua_args('$fx', command))
end

---@param bufnr integer
local function create_keymaps(bufnr)
    vim.keymap.set('t', '_', function()
        M.hide()
    end, { buffer = bufnr })

    vim.keymap.set('n', 'q', '<Cmd>q<CR>', { buffer = bufnr, nowait = true })

    for key, action in pairs(config.keymaps) do
        vim.keymap.set('t', key, function()
            M[action]()
        end, { buffer = bufnr })
    end
end

---@param bufnr integer
local function cleanup_terminal(bufnr)
    vim.env.FZF_DEFAULT_OPTS = previous_fzf_default_opts

    if vim.api.nvim_buf_is_valid(bufnr) then
        vim.api.nvim_buf_delete(bufnr, { force = true })
    end

    if state.bufnr == bufnr then
        state.bufnr = -1
        state.jobid = -1
        state.lf_pid = -1
    end
end

---@param bufnr integer
local function create_autocmds(bufnr)
    local augroup = vim.api.nvim_create_augroup('rockyz.lf', { clear = true })

    vim.api.nvim_create_autocmd('WinClosed', {
        group = augroup,
        buffer = bufnr,
        callback = function()
            if is_hiding then
                return
            end
            cleanup_terminal(bufnr)
        end,
    })
end

---Create the terminal buffer, start lf, and initialize terminal-local keymaps
---@return boolean
local function create_terminal()
    state.bufnr = vim.api.nvim_create_buf(false, true)
    local bufnr = state.bufnr

    local ok, jobid = pcall(vim.api.nvim_buf_call, bufnr, function()
        return vim.fn.jobstart({ 'lf' }, {
            term = true,
            on_exit = function()
                cleanup_terminal(bufnr)
            end,
        })
    end)

    if not ok or jobid <= 0 then
        vim.api.nvim_buf_delete(bufnr, { force = true })
        state.bufnr = -1
        state.jobid = -1
        state.lf_pid = -1
        notify.error('[lf] Failed to start lf')
        return false
    end

    state.jobid = jobid
    state.lf_pid = vim.fn.jobpid(state.jobid)
    create_keymaps(bufnr)
    create_autocmds(bufnr)
    return true
end

--------------------------------------------------------------------------------
-- Public APIs
--------------------------------------------------------------------------------

function M.split()
    open_selection(open_modes.split)
end

function M.vsplit()
    open_selection(open_modes.vsplit)
end

function M.tab()
    open_selection(open_modes.tab)
end

function M.edit()
    open_selection(open_modes.edit)
end

function M.cd()
    send_remote_command('remote_cd', format_lua_args('$PWD'))
end

-- Open a floating window running lf
function M.open()
    if vim.api.nvim_win_is_valid(state.winid) then
        return
    end

    previous_fzf_default_opts = vim.env.FZF_DEFAULT_OPTS

    if vim.env.FZF_DEFAULT_OPTS then
        vim.env.FZF_DEFAULT_OPTS = vim.env.FZF_DEFAULT_OPTS:gsub('%-%-tmux%s+%S+', '')
    end

    if not vim.api.nvim_buf_is_valid(state.bufnr) and not create_terminal() then
        return
    end

    state.winid = vim.api.nvim_open_win(state.bufnr, true, window_config())
    vim.cmd.startinsert()
end

-- Hide the window
function M.hide()
    if vim.api.nvim_win_is_valid(state.winid) then
        is_hiding = true
        vim.api.nvim_win_hide(state.winid)
        is_hiding = false
    end
    vim.env.FZF_DEFAULT_OPTS = previous_fzf_default_opts
end

-- Toggle lf window
function M.toggle()
    if vim.api.nvim_win_is_valid(state.winid) then
        M.hide()
    else
        M.open()
    end
end

--------------------------------------------------------------------------------
-- Functions invoked by lf's remote commands through Nvim's RPC
--------------------------------------------------------------------------------

---@param selection string Selected files, delimited by "\n"
---@param command? string Vim's Ex command used to open each selected file
function M.remote_open_selection(selection, command)
    M.hide()
    command = command or 'edit'
    local files = vim.split(selection, '\n', { trimempty = true })

    for _, file_path in ipairs(files) do
        local stat = vim.uv.fs_stat(file_path)
        if stat and stat.type == 'file' then
            vim.cmd(command .. ' ' .. vim.fn.fnameescape(file_path))
        else
            vim.notify(string.format('[lf] %s is not a file', file_path), vim.log.levels.WARN)
        end
    end
end

---@param pwd string The present working directory of lf, i.e., lf's $PWD
function M.remote_cd(pwd)
    M.hide()
    local stat = vim.uv.fs_stat(pwd)
    if not stat or stat.type ~= 'directory' then
        vim.notify(string.format('[lf] %s is not a directory', pwd), vim.log.levels.WARN)
        return
    end
    vim.cmd.cd(pwd)
    vim.notify('CWD is changed to: ' .. pwd, vim.log.levels.INFO)
end

--------------------------------------------------------------------------------
-- Global keymaps
--------------------------------------------------------------------------------

vim.keymap.set('n', '_', function()
    M.toggle()
end)

return M
