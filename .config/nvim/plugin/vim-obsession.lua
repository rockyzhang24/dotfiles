-- Load session.vim if it exists; otherwise start recording to this session file.
vim.api.nvim_create_user_command('Session', function()
    local session_file = vim.fn.stdpath('data') .. '/session.vim'
    local stat = vim.uv.fs_stat(session_file)
    if stat and stat.type == 'file' then
        vim.cmd.source(session_file)
    else
        vim.cmd('Obsession ' .. session_file)
    end
end, {})

-- Disable saving the session on BufEnter, improving performance at the expense of safety.
vim.g.obsession_no_bufenter = true
