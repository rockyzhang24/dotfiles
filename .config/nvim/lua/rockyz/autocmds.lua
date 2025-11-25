local notify = require('rockyz.utils.notify')

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

-- Karabiner Element maps CTRL-[ to ESC system wide except we're in Neovim. We need a variable to
-- tell if we're in Neovim or not.
vim.api.nvim_create_autocmd({ 'FocusGained' }, {
    group = vim.api.nvim_create_augroup('rockyz.karabiner', { clear = true }),
    callback = function()
        vim.system({'/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli', '--set-variables', '{"in_nvim":1}'})
    end,
})
vim.api.nvim_create_autocmd({ 'FocusLost', 'VimLeave' }, {
    group = 'rockyz.karabiner',
    callback = function(ev)
        if ev.event ~= 'VimLeave' or not vim.env.NVIM then
            -- If it occurs in VimLeave, ensure it's not the terminal nested nvim.
            vim.system({'/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli', '--set-variables', '{"in_nvim":0}'})
        end
    end,
})

-- Overwrite default settings in runtime/ftplugin
vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('rockyz.overwrite_defaults', {}),
    pattern = '*',
    callback = function()
        vim.opt.formatoptions:append('rn1l')
        vim.opt.formatoptions:remove('o')
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
        vim.hl.on_yank({ timeout = 300, priority = 65535 })
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

-- In large file, only use vim syntax (LSP semantic highlight and treesitter highlight will be
-- disabled).
vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('rockyz.big_file', { clear = true }),
    pattern = 'bigfile',
    callback = function(ev)
        local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(ev.buf), ':p:~:.')
        notify.warn(
            ('Big file detected: %s.\nSome Neovim features such as Treesitter highlighting have been disabled.'):format(path)
        )
        vim.schedule(function()
            vim.bo[ev.buf].syntax = vim.filetype.match({ buf = ev.buf }) or ''
        end)
    end,
})

-- Templates
-- Source: https://zignar.net/2024/11/20/template-files-for-nvim/
-- Examples: https://codeberg.org/mfussenegger/dotfiles/src/branch/master/vim/dot-config/nvim/templates
--
-- For example, we run :edit foo.lua to edit a new file. It tries to find the first existing
-- template file in the following order and read it into the buffer.
-- foo.lua.tpl      --> template exact matching the file name
-- lua.tpl          --> template matching the file extension
-- foo.lua.stpl     --> template with snippets matching the file name
-- lua.stpl         --> template with snippets matching the file extension
vim.api.nvim_create_autocmd('BufNewFile', {
    group = vim.api.nvim_create_augroup('rockyz.templates', { clear = true }),
    desc = 'Load template file',
    callback = function(args)
        if not vim.bo[args.buf].modifiable then
            return
        end
        local home = os.getenv('HOME')
        local fname = vim.fn.fnamemodify(args.file, ':t')
        local ext = vim.fn.fnamemodify(args.file, ':e')
        local candidates = { fname, ext }
        for _, candidate in ipairs(candidates) do
            local tmpl = table.concat({ home, '/.config/nvim/templates/', candidate, '.tpl' })
            if vim.uv.fs_stat(tmpl) then
                vim.cmd('0r ' .. tmpl)
                return
            end
        end
        for _, candidate in ipairs(candidates) do
            local tmpl = table.concat({ home, '/.config/nvim/templates/', candidate, '.stpl' })
            local f = io.open(tmpl, 'r')
            if f then
                local content = f:read('*a')
                vim.snippet.expand(content)
                return
            end
        end
    end,
})
