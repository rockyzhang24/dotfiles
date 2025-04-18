-- Dotfiles setup
local function update_git_env()
    local cwd = vim.fn.getcwd()
    local ok1, inside_config = pcall(vim.startswith, cwd, vim.env.XDG_CONFIG_HOME)
    if not ok1 or not inside_config then
        return
    end
    local ok2, inside_pack = pcall(vim.startswith, cwd, vim.env.XDG_CONFIG_HOME .. '/nvim/pack')
    if not ok2 or inside_pack then
        return
    end
    vim.env.GIT_DIR = vim.env.HOME .. '/dotfiles'
    vim.env.GIT_WORK_TREE = vim.env.HOME
end
vim.api.nvim_create_autocmd('VimEnter', {
    group = vim.api.nvim_create_augroup('rockyz.dotfiles', {}),
    callback = function()
        update_git_env()
    end,
})

-- Overwrite default settings in runtime/ftplugin
vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('rockyz.overwrite_defaults', {}),
    pattern = '*',
    callback = function()
        vim.opt.formatoptions:append('ron1l')
    end,
})

-- Jump to the position where you last quit (:h last-position-jump)
vim.api.nvim_create_autocmd('BufRead', {
    group = vim.api.nvim_create_augroup('rockyz.restore_last_pos', {}),
    callback = function()
        vim.api.nvim_create_autocmd('FileType', {
            buffer = 0,
            once = true,
            callback = function()
                local line = vim.fn.line('\'"')
                if
                    line >= 1
                    and line <= vim.fn.line('$')
                    and string.find(vim.bo.filetype, 'commit') == nil
                    and vim.fn.index({ 'xxd', 'gitrebase' }, vim.bo.filetype) == -1
                    and vim.o.diff == false
                then
                    vim.cmd([[normal! g`"]])
                end
            end,
        })
    end,
})

-- Auto-create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
    pattern = '*',
    group = vim.api.nvim_create_augroup('rockyz.auto_create_dir', {}),
    callback = function(ctx)
        -- Prevent oil.nivm from creating an extra oil:/ dir when we create a file/dir
        if vim.bo.ft == 'oil' then
            return
        end
        local dir = vim.fn.fnamemodify(ctx.file, ':p:h')
        local res = vim.fn.isdirectory(dir)
        if res == 0 then
            vim.fn.mkdir(dir, 'p')
        end
    end,
})

-- Highlight the selections on yank
vim.api.nvim_create_autocmd({ 'TextYankPost' }, {
    group = vim.api.nvim_create_augroup('rockyz.highlight_yank', {}),
    callback = function()
        vim.hl.on_yank({ timeout = 300 })
    end,
})

-- Reload buffer if it is modified outside neovim
vim.api.nvim_create_autocmd({
    'FocusGained',
    'BufEnter',
    'CursorHold',
}, {
    group = vim.api.nvim_create_augroup('rockyz.buffer_reload', {}),
    callback = function()
        if vim.fn.getcmdwintype() == '' then
            vim.cmd('checktime')
        end
    end,
})

-- Automatically toggle relative number
-- Ref: https://github.com/MariaSolOs/dotfiles
local exclude_ft = {
    'qf',
}
local function tbl_contains(t, value)
    for _, v in ipairs(t) do
        if v == value then
            return true
        end
    end
    return false
end
local rnu_augroup = vim.api.nvim_create_augroup('rockyz.toggle_relative_number', {})
-- Toggle relative number on
vim.api.nvim_create_autocmd({ 'BufEnter', 'FocusGained', 'InsertLeave', 'CmdlineLeave', 'WinEnter' }, {
    group = rnu_augroup,
    callback = function()
        if tbl_contains(exclude_ft, vim.bo.filetype) then
            return
        end
        if vim.wo.nu and not vim.startswith(vim.api.nvim_get_mode().mode, 'i') then
            vim.wo.relativenumber = true
        end
    end,
})
-- Toggle relative number off
vim.api.nvim_create_autocmd({ 'BufLeave', 'FocusLost', 'InsertEnter', 'CmdlineEnter', 'WinLeave' }, {
    group = rnu_augroup,
    callback = function(args)
        if tbl_contains(exclude_ft, vim.bo.filetype) then
            return
        end
        if vim.wo.nu then
            vim.wo.relativenumber = false
        end
        -- Redraw here to avoid having to first write something for the line numbers to update.
        if args.event == 'CmdlineEnter' then
            if not vim.tbl_contains({ '@', '-' }, vim.v.event.cmdtype) then
                vim.cmd.redraw()
            end
        end
    end,
})

-- Command-line window
vim.api.nvim_create_autocmd('CmdWinEnter', {
    group = vim.api.nvim_create_augroup('rockyz.cmdwin', {}),
    callback = function(args)
        -- Execute command and stay in the command-line window
        vim.keymap.set({ 'n', 'i' }, '<S-CR>', '<CR>q:', { buffer = args.buf })
        vim.keymap.set('n', 'q', ':q<CR>', { buffer = args.buf, nowait = true, silent = true })
    end,
})

-- Terminal
vim.api.nvim_create_autocmd({ 'TermOpen', 'BufWinEnter', 'WinEnter' }, {
    group = vim.api.nvim_create_augroup('rockyz.terminal.start_insert', {}),
    pattern = 'term://*',
    callback = function()
        vim.cmd.startinsert()
    end,
})

-- Disable wezterm shell integration if vim is launched in tmux in wezterm.
-- Ref: https://github.com/wez/wezterm/issues/5986
vim.api.nvim_create_autocmd('VimEnter', {
    group = vim.api.nvim_create_augroup('rockyz.wezterm.shell_integration_disable', {}),
    callback = function()
        if vim.env.WEZTERM_PANE and vim.env.TERM:match('tmux') then
            vim.env.WEZTERM_SHELL_SKIP_ALL = 1
        end
    end,
})

-- MRU windows
vim.api.nvim_create_autocmd('WinLeave', {
    group = vim.api.nvim_create_augroup('rockyz.mru_win', { clear = true }),
    callback = function()
        require('rockyz.utils.mru_win').record()
    end,
})

-- Reset maximize status
-- Close window by :quit will resize all windows so the maximization status should be reset
vim.api.nvim_create_autocmd('QuitPre', {
    group = vim.api.nvim_create_augroup('rockyz.reset_win_maximize', { clear = true }),
    callback = function(args)
        local tab = vim.api.nvim_get_current_tabpage()
        vim.t[tab].maximized_win = nil
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
            if vim.w[win].maximized then
                vim.w[win].maximized = nil
            end
        end
    end,
})

-- Show colorcolumn in INSERT mode
vim.api.nvim_create_augroup('rockyz.colorcol', {})
vim.api.nvim_create_autocmd('InsertEnter', {
    group = 'rockyz.colorcol',
    callback = function()
        vim.o.colorcolumn = '80,120'
    end,
})
vim.api.nvim_create_autocmd('InsertLeave', {
    group = 'rockyz.colorcol',
    callback = function()
        vim.o.colorcolumn = ''
    end,
})

-- Set CursorLine of not-current windows
vim.api.nvim_create_augroup('rockyz.cursorlinenc', {})
vim.api.nvim_create_autocmd({ 'VimEnter', 'WinEnter', 'TabEnter', 'BufEnter' }, {
    group = 'rockyz.cursorlinenc',
    callback = function()
        vim.opt_local.winhighlight:remove('CursorLine')
    end,
})
vim.api.nvim_create_autocmd('WinLeave', {
    group = 'rockyz.cursorlinenc',
    callback = function()
        vim.opt_local.winhighlight:append({ CursorLine = 'CursorLineNC' })
    end,
})
