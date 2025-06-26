-- CloseWin 1 2 3
-- DiffSplit file1 file2
-- ProfileStart, ProfileStop
-- Scratch
-- RedirMsg
-- CopyCodeBlock
-- ReorderList
-- Reindent 4 8
-- ToggleAutoFormat[!]
-- CopyPath [nameonly|relative|absolute]

local function scratch_buf_init()
    for name, value in pairs({
        filetype = 'scratch',
        buftype = 'nofile',
        bufhidden = 'hide',
        swapfile = false,
        modifiable = true,
    }) do
        vim.api.nvim_set_option_value(name, value, { scope = 'local' })
    end
end

-- Close windows by giving window numbers, e.g., :CloseWin 1 2 3
vim.api.nvim_create_user_command('CloseWin', function(opts)
    require('rockyz.utils.win').close_wins(opts.args)
end, { nargs = '+' })

-- Diff two files side by side in a new tabpage
-- :DiffSplit <file1> <file2>
vim.api.nvim_create_user_command('DiffSplit', function(opts)
    if #opts.fargs ~= 2 then
        vim.api.nvim_echo({
            { 'ERROR: Require two file names.', 'ErrorMsg' },
        }, true, {})
    else
        vim.cmd('tabedit ' .. vim.fn.fnameescape(opts.fargs[1]))
        vim.cmd('rightbelow vert diffsplit ' .. vim.fn.fnameescape(opts.fargs[2]))
        vim.cmd('wincmd p')
        vim.cmd('normal! gg]c')
    end
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
    scratch_buf_init()
end, { nargs = 0 })

-- Redirect message output to a split window
vim.api.nvim_create_user_command('RedirMsg', function()
    vim.cmd('vertical new')
    scratch_buf_init()
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
    local result = string.format('```%s\n%s\n```', vim.bo.filetype, content)
    vim.fn.setreg('+', result)
    vim.notify('Text copied to clipboard')
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
-- Usage: `:Reindent cur_indent new_indent`
vim.api.nvim_create_user_command('Reindent', function(opts)
    if #opts.fargs < 2 then
        vim.notify('Two arguments are required!')
        return
    end
    local cur_indent, new_indent = tonumber(opts.fargs[1]), tonumber(opts.fargs[2])
    local prev_et = vim.o.expandtab
    vim.o.expandtab = false
    vim.o.tabstop = cur_indent
    vim.cmd('retab!')
    vim.o.tabstop = new_indent
    if prev_et then
        vim.o.expandtab = true
        vim.cmd('retab!')
    end
    vim.o.shiftwidth = new_indent
end, { nargs = '+' })

-- Toggle variable to switch autoformat (format-on-save)
-- If [!] is not given, toggle buffer-local autoformat; Use [!] to toggle autoformat globally.
vim.api.nvim_create_user_command('ToggleAutoFormat', function(opts)
    local msg = ''
    if opts.bang then
        vim.g.autoformat = not vim.g.autoformat
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            vim.b[buf].autoformat = false
        end
        msg = 'Global autoformat (format-on-save) is ' .. (vim.g.autoformat and 'enabled' or 'disabled')
    else
        vim.b.autoformat = not vim.b.autoformat
        msg = 'Buffer-local autoformat (format-on-save) is ' .. (vim.b.autoformat and 'enabled' or 'disabled')
    end
    vim.notify(msg, vim.log.levels.INFO)
end, { nargs = 0, bang = true })

-- Copy file path to clipboard. Support absolute, relative (default) or nameonly.
-- Ref: https://github.com/jdhao/nvim-config/blob/main/plugin/command.lua
vim.api.nvim_create_user_command('CopyPath', function(context)
    local full_path = vim.fn.glob('%:p')
    local file_path = nil
    if context['args'] == 'nameonly' then
        file_path = vim.fn.fnamemodify(full_path, ':t')
    end
    if context['args'] == 'relative' or not context['args'] then
        local project_marker = { '.git' }
        local project_root = vim.fs.root(0, project_marker)
        if project_root == nil then
            vim.print('Can not find project root!')
            return
        end
        project_root = project_root .. '/'
        file_path = string.gsub(full_path, project_root, '')
    end
    if context['args'] == 'absolute' then
        file_path = full_path
    end
    vim.fn.setreg('+', file_path)
    vim.notify('Filepath copied to clipboard: ' .. file_path, vim.log.levels.INFO)
end, {
    bang = false,
    nargs = 1,
    complete = function()
        return { 'nameonly', 'relative', 'absolute' }
    end,
})

-- Diff for the current buffer and the file it was loaded from
-- :help :DiffOrig
vim.cmd([[
command! DiffOrig leftabove vnew | set bt=nofile | r ++edit # | 0d_ | diffthis | wincmd p | diffthis
]])
