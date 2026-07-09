-- CloseWin {winid_1} {winid_2} ...
-- DiffSplit {file1} {file2}
-- ProfileStart, ProfileStop
-- Scratch
-- RedirMsg
-- CopyCodeBlock
-- ReorderList
-- Reindent {current_indent} {new_indent}
-- ToggleAutoFormat[!]
-- CopyPath [nameonly|relative|absolute]
-- DiffOrig
-- Count {pattern}
-- Root
-- LspInfo
-- LspLog
-- LspRestart

local notify = require('rockyz.utils.notify')
local win_utils = require('rockyz.utils.win')

local function init_scratch_buffer(buf)
    for name, value in pairs({
        filetype = 'scratch',
        buftype = 'nofile',
        bufhidden = 'hide',
        swapfile = false,
        modifiable = true,
    }) do
        vim.api.nvim_set_option_value(name, value, { buf = buf })
    end
end

-- Close windows by giving window numbers, e.g., :CloseWin 1 2 3
vim.api.nvim_create_user_command('CloseWin', function(opts)
    win_utils.close_wins(opts.args)
end, { nargs = '+' })

-- Diff two files side by side in a new tabpage
-- :DiffSplit <file1> <file2>
vim.api.nvim_create_user_command('DiffSplit', function(opts)
    if #opts.fargs ~= 2 then
        notify.warn('DiffSplit requires two file names')
        return
    end

    vim.cmd('tabedit ' .. vim.fn.fnameescape(opts.fargs[1]))
    vim.cmd('rightbelow vert diffsplit ' .. vim.fn.fnameescape(opts.fargs[2]))
    vim.cmd('wincmd p')
    vim.cmd('normal! gg]c')
end, { nargs = '+', complete = 'file' })

-- Profiler
vim.api.nvim_create_user_command('ProfileStart', function()
    require('plenary.profile').start('profile.log', { flame = true })
end, {})
vim.api.nvim_create_user_command('ProfileStop', function()
    require('plenary.profile').stop()
end, {})

-- Open a scratch buffer
vim.api.nvim_create_user_command('Scratch', function()
    vim.cmd('belowright 10new')
    init_scratch_buffer(0)
end, { nargs = 0 })

-- Redirect message output to a split window
vim.api.nvim_create_user_command('RedirMsg', function()
    vim.cmd('vertical new')
    init_scratch_buffer(0)
    vim.cmd('redir => msg_output | silent messages | redir END')
    local output = vim.fn.split(vim.g.msg_output, '\n')
    vim.api.nvim_buf_set_lines(0, 0, 0, false, output)
end, {})

-- Copy text to clipboard using code block format, i.e.,
-- ```{ft}
-- {content}
-- ```
vim.api.nvim_create_user_command('CopyCodeBlock', function(opts)
    local lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, true)
    local content = table.concat(lines, '\n')
    local filetype = vim.bo.filetype ~= '' and vim.bo.filetype or 'text'
    local code_block = string.format('```%s\n%s\n```', filetype, content)

    vim.fn.setreg('+', code_block)
    notify.info('Text copied to clipboard')
end, { range = true })

-- Reorder numbered list
-- Works for the list where the numbers are followed by ". ", "). ", or "]. "
-- '<,'>s/\d\+\(\(\.\|)\.\|\]\.\)\s\)\@=/\=line('.')-line("'<")+1/
--                             ^
--                             |
--                             ----- add more cases here
--                             E.g., "\|>\." for the list like "1>. foobar"
vim.api.nvim_create_user_command(
    'ReorderList',
    [['<,'>s/\d\+\(\(\.\|)\.\|\]\.\)\s\)\@=/\=line('.')-line("'<")+1/]],
    { range = true }
)

-- Change indentation of the current buffer
-- Usage: `:Reindent current_indent new_indent`
vim.api.nvim_create_user_command('Reindent', function(opts)
    if #opts.fargs ~= 2 then
        notify.warn('Reindent requires exactly two arguments')
        return
    end

    local current_indent = tonumber(opts.fargs[1])
    local new_indent = tonumber(opts.fargs[2])

    if not current_indent or not new_indent then
        notify.warn('Reindent requires two numeric arguments')
        return
    end

    local original_expandtab = vim.o.expandtab

    vim.o.expandtab = false
    vim.o.tabstop = current_indent
    vim.cmd('retab!')
    vim.o.tabstop = new_indent

    if original_expandtab then
        vim.o.expandtab = true
        vim.cmd('retab!')
    end

    vim.o.shiftwidth = new_indent
end, { nargs = '+' })

-- Toggle variable to switch autoformat (format-on-save)
-- If [!] is not given, toggle buffer-local autoformat; Use [!] to toggle autoformat globally.
vim.api.nvim_create_user_command('ToggleAutoFormat', function(opts)
    local message
    if opts.bang then
        vim.g.autoformat = not vim.g.autoformat
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            vim.b[buf].autoformat = false
        end
        message = 'Global autoformat (format-on-save) is ' .. (vim.g.autoformat and 'enabled' or 'disabled')
    else
        vim.b.autoformat = not vim.b.autoformat
        message = 'Buffer-local autoformat (format-on-save) is ' .. (vim.b.autoformat and 'enabled' or 'disabled')
    end
    notify.info(message)
end, { nargs = 0, bang = true })

-- Copy the current buffer path to clipboard
-- Supports nameonly, relative (default), and absolute
-- Reference: https://github.com/jdhao/nvim-config/blob/main/plugin/command.lua
vim.api.nvim_create_user_command('CopyPath', function(opts)
    local path_type = opts.args ~= '' and opts.args or 'relative'
    local full_path = vim.api.nvim_buf_get_name(0)

    if full_path == '' then
        notify.warn('Current buffer has no file path')
        return
    end

    local file_path = ''

    if path_type == 'nameonly' then
        file_path = vim.fn.fnamemodify(full_path, ':t')
    elseif path_type == 'relative' then
        local project_root = vim.fs.root(0, { '.git' })
        if not project_root then
            notify.warn('Cannot find project root')
            return
        end
        file_path = vim.fs.relpath(project_root, full_path) or full_path
    elseif path_type == 'absolute' then
        file_path = full_path
    else
        notify.warn('Unsupported path type: ' .. path_type)
        return
    end

    vim.fn.setreg('+', file_path)
    notify.info('File path copied to clipboard: ' .. file_path)
end, {
    nargs = '?',
    complete = function()
        return { 'nameonly', 'relative', 'absolute' }
    end,
})

-- Diff for the current buffer and the file it was loaded from
-- :help :DiffOrig
vim.cmd([[
command! DiffOrig leftabove vnew | set bt=nofile | r ++edit # | 0d_ | diffthis | wincmd p | diffthis
]])

-- Count pattern matches without modifying the buffer
-- Usage: `:Count {pattern}`
vim.api.nvim_create_user_command('Count', function(opts)
    local pattern = vim.fn.escape(opts.args, '/')
    local cmd = string.format('%%s/%s//gn', pattern)
    local view = vim.fn.winsaveview()

    local ok, err = pcall(vim.cmd, cmd)
    vim.fn.winrestview(view)

    if not ok then
        error(err, 0)
    end
end, {
    nargs = 1,
})

-- Change directory to the root of the git repository
vim.api.nvim_create_user_command('Root', function()
    vim.system({ 'git', 'rev-parse', '--show-toplevel' }, { text = true }, function(obj)
        if obj.code ~= 0 then
            notify.error({ obj.stderr, obj.stdout })
            return
        end
        local root = obj.stdout:gsub('\n$', '')
        vim.schedule(function()
            vim.cmd('lcd ' .. vim.fn.fnameescape(root))
            notify.info('Changed directory to: ' .. root)
        end)
    end)
end, {})

-- LSP commands
vim.api.nvim_create_user_command('LspInfo', 'checkhealth vim.lsp', {
    desc = 'Show LSP info',
})
vim.api.nvim_create_user_command('LspLog', function(_)
    local state_path = vim.fn.stdpath('state')
    local log_path = vim.fs.joinpath(state_path, 'lsp.log')

    vim.cmd('edit ' .. vim.fn.fnameescape(log_path))
end, {
    desc = 'Show LSP log',
})
vim.api.nvim_create_user_command('LspRestart', 'lsp restart', {
    desc = 'Restart LSP',
})
