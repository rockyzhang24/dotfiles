-- Use <C-/> to toggle lf
-- Use lf's builtin q to quit
-- <C-x>, <C-v>, <C-t> to open the selected files in split, vsplit or tab
-- e to open the files in the previous window

local M = {}

local io_utils = require('rockyz.utils.io_utils')

local term_bufnr
local term_winid
local job_id


local prev_FZF_DEFAULT_OPTS

local win_opts = {
    relative = 'editor',
    border = vim.g.border_style,
    style = 'minimal',
}

local actions = {
    ['<C-x>'] = 'belowright split',
    ['<C-v>'] = 'belowright vsplit',
    ['<C-t>'] = 'tab split',
    e = 'edit',
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
        end, { buffer = term_bufnr })
    end

    vim.keymap.set('t', '<C-_>', function()
        M.close()
    end, { buffer = term_bufnr })
end

local function calculate_win_pos()
    local editor_width = vim.o.columns
    local editor_height = vim.o.lines

    local win_width = math.floor(editor_width * 0.8)
    local win_height = math.floor(editor_height * 0.8)

    local row = math.floor((editor_height - win_height) / 2)
    local col = math.floor((editor_width - win_width) / 2)

    return {
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

    if not term_bufnr then
        term_bufnr = vim.api.nvim_create_buf(false, true)
    end

    local opts = vim.tbl_extend('force', win_opts, calculate_win_pos())
    term_winid = vim.api.nvim_open_win(term_bufnr, true, opts)

    if not job_id then
        local shell = vim.o.shell
        local command = 'lf'
        job_id = vim.fn.jobstart({ shell, '-c', command }, {
            term = true,
            on_exit = function()
                -- Immediately close the buffer and window to avoid the redundant message "[Process
                -- exited 0]"
                vim.api.nvim_buf_delete(term_bufnr, { force = true })
                term_bufnr = nil
                term_winid = nil
                job_id = nil
            end,
        })
    end

    create_keymaps()
end

-- Close the window
function M.close()
    if term_winid then
        vim.api.nvim_win_close(term_winid, true)
        term_winid = nil
        vim.env.FZF_DEFAULT_OPTS = prev_FZF_DEFAULT_OPTS
    end
end

-- Toggle lf window
function M.toggle()
    if term_winid and vim.api.nvim_win_is_valid(term_winid) then
        M.close()
    else
        M.open()
    end
end

vim.keymap.set('n', '<C-_>', function()
    M.toggle()
end)
