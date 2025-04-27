-- Use <C-/> to toggle the floating window running lf
-- Use lf's builtin q to quit

local term_bufnr
local term_winid
local job_id

local editor_width = vim.o.columns
local editor_height = vim.o.lines

local win_width = math.floor(editor_width * 0.8)
local win_height = math.floor(editor_height * 0.8)

local row = math.floor((editor_height - win_height) / 2)
local col = math.floor((editor_width - win_width) / 2)

local prev_FZF_DEFAULT_OPTS

-- Open a floating window running lf
local function open()
    prev_FZF_DEFAULT_OPTS = vim.env.FZF_DEFAULT_OPTS
    vim.env.FZF_DEFAULT_OPTS = vim.env.FZF_DEFAULT_OPTS:gsub('%-%-tmux%s+%S+', '')

    if not term_bufnr then
        term_bufnr = vim.api.nvim_create_buf(false, true)
    end
    term_winid = vim.api.nvim_open_win(term_bufnr, true, {
        relative = 'editor',
        row = row,
        col = col,
        width = win_width,
        height = win_height,
        border = vim.g.border_style,
        style = 'minimal',
    })
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
end

-- Close the window
local function close()
    if term_winid then
        vim.api.nvim_win_close(term_winid, true)
        term_winid = nil
        vim.env.FZF_DEFAULT_OPTS = prev_FZF_DEFAULT_OPTS
    end
end

-- Toggle lf window
local function toggle()
    if term_winid then
        close()
    else
        open()
    end
end

vim.keymap.set('n', '<C-_>', function()
    toggle()
end)

vim.keymap.set('t', '<C-_>', function()
    close()
end, { buffer = term_bufnr })
