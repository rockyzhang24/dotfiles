-- Use _ to toggle lf
-- Use lf's builtin q to quit
-- <C-x>, <C-v>, <C-t> to open the selected files in split, vsplit or tab
-- <M-Enter> to open the files in the previous window
-- <C-q> to change nvim's cwd to the current directory of lf
-- q in NORMAL to close lf window

local M = {}

local io_utils = require('rockyz.utils.io')
local notify = require('rockyz.utils.notify')

local term = {
    winid = -1,
    bufnr = -1,
}

local prev_FZF_DEFAULT_OPTS

local actions = {
    ['<C-x>'] = 'belowright split',
    ['<C-v>'] = 'belowright vsplit',
    ['<C-t>'] = 'tab split',
    ['<M-Enter>'] = 'edit',
}

local function create_keymaps()
    for k, act in pairs(actions) do
        vim.keymap.set('t', k, function()
            local key = vim.api.nvim_replace_termcodes('<A-S-e>', true, false, true)
            vim.api.nvim_feedkeys(key, 'n', false)
            vim.defer_fn(function()
                M.close()
                local filepath = io_utils.read_file(vim.env.TMPDIR .. '/lf-filepath'):gsub('\n', '')
                for _, f in ipairs(vim.split(filepath, ' ')) do
                    vim.cmd(act .. ' ' .. f)
                end
            end, 100)
        end, { buffer = term.bufnr })
    end

    vim.keymap.set('t', '_', function()
        M.close()
    end, { buffer = term.bufnr })

    vim.keymap.set('t', '<C-q>', function()
        local key = vim.api.nvim_replace_termcodes('<A-S-q>', true, false, true)
        vim.api.nvim_feedkeys(key, 'n', false)
        vim.defer_fn(function()
            M.close()
            local path = io_utils.read_file(vim.env.TMPDIR .. '/lf-pwd'):gsub('\n', '')
            vim.cmd.cd(path)
            notify.info('Current directory is changed to ' .. path)
        end, 100)
    end, { buffer = term.bufnr })

    vim.keymap.set('n', 'q', '<Cmd>q<CR>', { buffer = term.bufnr, nowait = true })
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

    if not vim.api.nvim_buf_is_valid(term.bufnr) then
        term.bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_call(term.bufnr, function()
            vim.fn.jobstart({ vim.o.shell, '-c', 'lf' }, {
                term = true,
                on_exit = function()
                    -- Immediately close the buffer and window to avoid the redundant message "[Process
                    -- exited 0]"
                    vim.api.nvim_buf_delete(term.bufnr, { force = true })
                end,
            })
        end)
    end

    term.winid = vim.api.nvim_open_win(term.bufnr, true, calculate_win_pos())
    vim.cmd.startinsert()

    create_keymaps()
end

-- Close the window
function M.close()
    vim.api.nvim_win_hide(term.winid)
    vim.env.FZF_DEFAULT_OPTS = prev_FZF_DEFAULT_OPTS
end

-- Toggle lf window
function M.toggle()
    if vim.api.nvim_win_is_valid(term.winid) then
        M.close()
    else
        M.open()
    end
end

vim.keymap.set('n', '_', function()
    M.toggle()
end)
