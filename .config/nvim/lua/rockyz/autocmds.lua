local notify = require('rockyz.utils.notify')

-- Dotfiles setup
local function update_git_env()
    local cwd = vim.fn.getcwd()
    local config_home = vim.env.XDG_CONFIG_HOME
    local home = vim.env.HOME

    if not config_home or not home then
        return
    end

    local ok, inside_config = pcall(vim.startswith, cwd, config_home)
    if not ok or not inside_config then
        return
    end

    local nvim_pack_dir = vim.fs.joinpath(config_home, 'nvim', 'pack')
    local pack_ok, inside_pack = pcall(vim.startswith, cwd, nvim_pack_dir)
    if not pack_ok or inside_pack then
        return
    end

    vim.env.GIT_DIR = vim.fs.joinpath(home, 'dotfiles')
    vim.env.GIT_WORK_TREE = home
end

vim.api.nvim_create_autocmd('VimEnter', {
    group = vim.api.nvim_create_augroup('rockyz.dotfiles', {}),
    callback = function()
        update_git_env()
    end,
})

-- Karabiner-Elements maps CTRL-[ to ESC system wide except in Neovim

local karabiner_cli = '/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli'

local function set_karabiner_in_nvim(enabled)
    local value = enabled and '{"in_nvim":1}' or '{"in_nvim":0}'
    vim.system({ karabiner_cli, '--set-variables', value })
end

vim.api.nvim_create_autocmd('FocusGained', {
    group = vim.api.nvim_create_augroup('rockyz.karabiner', { clear = true }),
    callback = function()
        set_karabiner_in_nvim(true)
    end,
})

vim.api.nvim_create_autocmd({ 'FocusLost', 'VimLeave' }, {
    group = 'rockyz.karabiner',
    callback = function(ev)
        if ev.event ~= 'VimLeave' or not vim.env.NVIM then
            -- If it occurs in VimLeave, ensure it's not the terminal nested nvim
            set_karabiner_in_nvim(false)
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

-- Treesitter highlight
vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('rockyz.treesitter.highlight', { clear = true }),
    callback = function(ev)
        local bufnr = ev.buf
        local filetype = ev.match
        local lang = vim.treesitter.language.get_lang(filetype)
        if not lang or not vim.treesitter.language.add(lang) then
            return
        end
        vim.treesitter.start(bufnr, lang)
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
                local last_pos_line = vim.fn.line('\'"')
                local last_line = vim.fn.line('$')
                local filetype = vim.bo.filetype
                if
                    last_pos_line >= 1
                    and last_pos_line <= last_line
                    and not filetype:find('commit')
                    and not vim.tbl_contains({ 'xxd', 'gitrebase' }, filetype)
                    and not vim.o.diff
                then
                    vim.cmd([[normal! g`"]])
                end
            end,
        })
    end,
})

-- Auto-create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = '*',
    group = vim.api.nvim_create_augroup('rockyz.auto_create_dir', {}),
    callback = function(ctx)
        -- Prevent oil.nvim from creating an extra oil:/ dir when we create a file/dir
        if vim.bo[ctx.buf].filetype == 'oil' then
            return
        end
        local target_dir = vim.fn.fnamemodify(ctx.file, ':p:h')
        if vim.fn.isdirectory(target_dir) == 0 then
            vim.fn.mkdir(target_dir, 'p')
        end
    end,
})

-- Highlight the selections on yank and put
vim.api.nvim_create_autocmd({ 'TextYankPost', 'TextPutPost' }, {
    group = vim.api.nvim_create_augroup('rockyz.highlight_yank', {}),
    callback = function()
        vim.hl.hl_op({ timeout = 300, priority = 65535 })
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

local relative_number_excluded_filetypes = {
    'qf',
}

local relative_number_augroup = vim.api.nvim_create_augroup('rockyz.toggle_relative_number', {})

-- Toggle relative number on
vim.api.nvim_create_autocmd({ 'BufEnter', 'FocusGained', 'InsertLeave', 'CmdlineLeave', 'WinEnter' }, {
    group = relative_number_augroup,
    callback = function()
        if vim.tbl_contains(relative_number_excluded_filetypes, vim.bo.filetype) then
            return
        end
        if vim.wo.nu and not vim.startswith(vim.api.nvim_get_mode().mode, 'i') then
            vim.wo.relativenumber = true
        end
    end,
})

-- Toggle relative number off
vim.api.nvim_create_autocmd({ 'BufLeave', 'FocusLost', 'InsertEnter', 'CmdlineEnter', 'WinLeave' }, {
    group = relative_number_augroup,
    callback = function(ev)
        if vim.tbl_contains(relative_number_excluded_filetypes, vim.bo.filetype) then
            return
        end
        if vim.wo.nu then
            vim.wo.relativenumber = false
        end
        -- Redraw here to avoid having to first write something for the line numbers to update.
        if ev.event == 'CmdlineEnter' then
            if not vim.tbl_contains({ '@', '-' }, vim.v.event.cmdtype) then
                vim.cmd.redraw()
            end
        end
    end,
})

-- Command-line window
vim.api.nvim_create_autocmd('CmdwinEnter', {
    group = vim.api.nvim_create_augroup('rockyz.cmdwin', {}),
    callback = function(ev)
        -- Execute command and stay in the command-line window
        vim.keymap.set({ 'n', 'i' }, '<S-CR>', '<CR>q:', { buffer = ev.buf })
        vim.keymap.set('n', 'q', ':q<CR>', { buffer = ev.buf, nowait = true, silent = true })
    end,
})

-- Disable WezTerm shell integration if Vim is launched in tmux in WezTerm
-- Ref: https://github.com/wez/wezterm/issues/5986
vim.api.nvim_create_autocmd('VimEnter', {
    group = vim.api.nvim_create_augroup('rockyz.wezterm.shell_integration_disable', {}),
    callback = function()
        if vim.env.WEZTERM_PANE and (vim.env.TERM or ''):match('tmux') then
            vim.env.WEZTERM_SHELL_SKIP_ALL = 1
        end
    end,
})

-- Show colorcolumn in INSERT mode
-- vim.api.nvim_create_augroup('rockyz.colorcol', {})
-- vim.api.nvim_create_autocmd('InsertEnter', {
--     group = 'rockyz.colorcol',
--     callback = function()
--         vim.o.colorcolumn = '80,120'
--     end,
-- })
-- vim.api.nvim_create_autocmd('InsertLeave', {
--     group = 'rockyz.colorcol',
--     callback = function()
--         vim.o.colorcolumn = ''
--     end,
-- })

-- Set CursorLineNC in inactive windows
local cursorline_nc_augroup = vim.api.nvim_create_augroup('rockyz.cursorlinenc', {})

vim.api.nvim_create_autocmd({ 'VimEnter', 'WinEnter', 'TabEnter', 'BufEnter' }, {
    group = cursorline_nc_augroup,
    callback = function()
        vim.opt_local.winhighlight:remove('CursorLine')
    end,
})
vim.api.nvim_create_autocmd('WinLeave', {
    group = cursorline_nc_augroup,
    callback = function()
        vim.opt_local.winhighlight:append({ CursorLine = 'CursorLineNC' })
    end,
})

-- In big files, only use Vim syntax highlighting
-- LSP semantic highlighting and Treesitter highlighting are disabled
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
-- template file in the following order and reads it into the buffer.
-- foo.lua.tpl      --> template exact matching the file name
-- lua.tpl          --> template matching the file extension
-- foo.lua.stpl     --> template with snippets matching the file name
-- lua.stpl         --> template with snippets matching the file extension
vim.api.nvim_create_autocmd('BufNewFile', {
    group = vim.api.nvim_create_augroup('rockyz.templates', { clear = true }),
    desc = 'Load template file',
    callback = function(ev)
        if not vim.bo[ev.buf].modifiable then
            return
        end

        local template_dir = vim.fs.joinpath(vim.fn.stdpath('config'), 'templates')
        local filename = vim.fn.fnamemodify(ev.file, ':t')
        local extension = vim.fn.fnamemodify(ev.file, ':e')
        local candidates = { filename, extension }

        for _, candidate in ipairs(candidates) do
            local tmpl = vim.fs.joinpath(template_dir, candidate .. '.tpl')
            if vim.uv.fs_stat(tmpl) then
                vim.cmd('0r ' .. vim.fn.fnameescape(tmpl))
                return
            end
        end

        for _, candidate in ipairs(candidates) do
            local tmpl = vim.fs.joinpath(template_dir, candidate .. '.stpl')
            local f = io.open(tmpl, 'r')
            if f then
                local content = f:read('*a')
                f:close()
                vim.snippet.expand(content)
                return
            end
        end
    end,
})
