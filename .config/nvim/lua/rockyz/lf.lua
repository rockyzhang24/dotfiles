-- _ to toggle lf
-- q to quit
-- <C-x>, <C-v>, <C-t> to open the selected files in split, vsplit or tab
-- <C-Enter> to open the files in the previous window
-- <C-q> to change nvim's cwd to the current directory of lf

local M = {}

local io_utils = require('rockyz.utils.io')

local config = {
    keymaps = {
        ['<C-x>'] = 'split',
        ['<C-v>'] = 'vsplit',
        ['<C-t>'] = 'tab',
        ['<C-Enter>'] = 'edit',
        ['<C-q>'] = 'cd',
    }
}

local state = {
    winid = -1,
    bufnr = -1,
    jobid = -1,
    pid = -1, -- pid of lf
}

local prev_FZF_DEFAULT_OPTS

local function create_keymaps()
    vim.keymap.set('t', '_', function()
        M.close()
    end, { buffer = state.bufnr })

    vim.keymap.set('n', 'q', '<Cmd>q<CR>', { buffer = state.bufnr, nowait = true })

    for key, action in pairs(config.keymaps) do
        vim.keymap.set('t', key, function()
            M[action]()
        end, { buffer = state.buffer })
    end
end

---Generate lf remote command that tells the parent Nvim (i.e., the remote server) to run the
---function from lf.lua module via Nvim's RPC.
---Example: tell the parent Nvim to run a function foobar() with the selected files as the argument
---lf -remote 'send lf_pid $nvim --server "$NVIM" --remote-expr "v:lua.require(\'rockyz.lf\').foobar(\'$fx\')"'
---@param fn_name string Function name
---@param args? string A string representation of the argument list passed to the funcion, e.g., "'foo', 'bar'"
local function build_remote_expr_cmd(fn_name, args)
    args = args or ''
    return {
        'lf',
        '-remote',
        string.format(
            'send %s $nvim --server "$NVIM" --remote-expr "v:lua.require(\'rockyz.lf\').%s(%s)"',
            state.pid,
            fn_name,
            args
        ),
    }
end

---@param command string Vim's Ex command to open file, e.g., vsplit
local function open_file(command)
    local cmd = build_remote_expr_cmd('remote_open_file', string.format("'$fx', '%s'", command))
    M.close()
    vim.system(cmd, { text = true })
end

function M.split()
    open_file('belowright split')
end

function M.vsplit()
    open_file('belowright vsplit')
end

function M.tab()
    open_file('tab split')
end

function M.edit()
    open_file('edit')
end

function M.cd()
    local cmd = build_remote_expr_cmd('remote_cd', "'$PWD'")
    M.close()
    vim.system(cmd, { text = true })
end

local function calculate_win_pos()

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

-- Open a floating window running lf
function M.open()
    prev_FZF_DEFAULT_OPTS = vim.env.FZF_DEFAULT_OPTS
    vim.env.FZF_DEFAULT_OPTS = vim.env.FZF_DEFAULT_OPTS:gsub('%-%-tmux%s+%S+', '')

    local bufname = vim.api.nvim_buf_get_name(0)
    local tmpfile = vim.env.TMPDIR .. '/nvim-lf-bufname'
    io_utils.write_file_async(tmpfile, bufname)

    if not vim.api.nvim_buf_is_valid(state.bufnr) then
        state.bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_call(state.bufnr, function()
            state.jobid = vim.fn.jobstart({ 'lf' }, {
                term = true,
                on_exit = function()
                    -- Immediately close the buffer and window to avoid the redundant message "[Process
                    -- exited 0]"
                    vim.api.nvim_buf_delete(state.bufnr, { force = true })
                end,
            })
        end)
        state.pid = vim.fn.jobpid(state.jobid)
        create_keymaps()
    end

    state.winid = vim.api.nvim_open_win(state.bufnr, true, calculate_win_pos())
    vim.cmd.startinsert()
end

-- Close the window
function M.close()
    vim.api.nvim_win_hide(state.winid)
    vim.env.FZF_DEFAULT_OPTS = prev_FZF_DEFAULT_OPTS
end

-- Toggle lf window
function M.toggle()
    if vim.api.nvim_win_is_valid(state.winid) then
        M.close()
    else
        M.open()
    end
end

vim.keymap.set('n', '_', function()
    M.toggle()
end)

---------------------------------------------------------------
-- Functions invoked by lf's remote commands through Nvim's RPC
---------------------------------------------------------------

---@param selection string Selected files that delimited by "\n"
---@param command string Vim's Ex command to open file
function M.remote_open_file(selection, command)
    command = command or 'edit'
    local files = vim.split(selection, '\n')
    for _, f in ipairs(files) do
        local stat = vim.uv.fs_stat(f)
        if stat and stat.type == 'file' then
            vim.cmd(command .. ' ' .. f)
        else
            vim.notify(string.format('[lf] %s is not a file', f), vim.log.levels.WARN)
        end
    end
end

---@param pwd string The present working directory of lf, i.e., lf's $PWD
function M.remote_cd(pwd)
    local stat = vim.uv.fs_stat(pwd)
    if not stat or stat.type ~= 'directory' then
        vim.notify(string.format('[lf] %s is not a directory', pwd), vim.log.levels.WARN)
        return
    end
    vim.cmd.cd(pwd)
end

return M
