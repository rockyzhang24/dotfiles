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
    require('rockyz.utils.win_utils').close_wins(opts.args)
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
vim.api.nvim_create_user_command('Redir', function()
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

-- Toggle a variable to switch autoformat (format-on-save)
vim.api.nvim_create_user_command('ToggleAutoFormat', function()
    vim.g.autoformat = not vim.g.autoformat
    vim.notify(string.format('Autoformat (format-on-save) is %s', vim.g.autoformat and 'enabled' or 'disabled'), vim.log.levels.INFO)
end, { nargs = 0 })
