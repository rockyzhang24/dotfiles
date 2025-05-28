local M = {}

local toggle_term = {
    bufnr = -1,
    winid = -1,
    jobid = -1,
}

-- Toggle a terminal at the bottom
function M.toggle()
    if vim.api.nvim_win_is_valid(toggle_term.winid) then
        vim.api.nvim_win_hide(toggle_term.winid)
    else
        if not vim.api.nvim_buf_is_valid(toggle_term.bufnr) then
            toggle_term.bufnr = vim.api.nvim_create_buf(true, true)
            vim.api.nvim_buf_call(toggle_term.bufnr, function()
                vim.bo.buflisted = false
                toggle_term.jobid = vim.fn.jobstart(vim.o.shell, {
                    term = true,
                    on_exit = function()
                        toggle_term.jobid = -1
                    end,
                })
            end)
        end
        toggle_term.winid = vim.api.nvim_open_win(toggle_term.bufnr, true, {
            split = 'below',
            style = 'minimal',
            height = math.floor(vim.o.lines / 3),
        })
        vim.wo[toggle_term.winid][0].winfixheight = true
    end
end

-- Run current file
-- Inspired by @mfussenegger's config
function M.run()
    local filepath = vim.api.nvim_buf_get_name(0)
    local lines = vim.api.nvim_buf_get_lines(0, 0, 1, true)
    local cmd = filepath
    local filetype = vim.bo.filetype
    local skipchmod = false
    if not vim.startswith(lines[1], '#!/usr/bin/env') then
        skipchmod = true
        if filetype == 'cpp' then
            -- C++: compile, run and remove the executable
            local fname = vim.fn.fnamemodify(filepath, ':t:r')
            cmd = string.format('clang++ -std=c++20 -o %s %s && ./%s; [[ -e %s ]] && rm %s', fname, filepath, fname, fname, fname)
        elseif filetype == 'lua' then
            -- Lua
            cmd = 'luajit ' .. filepath
        elseif filetype == 'python' then
            -- Python
            cmd = 'python3 ' .. filetype
        elseif filetype == 'sh' then
            -- Bash
            cmd = 'bash ' .. filepath
        else
            skipchmod = false
            local choice = vim.fn.confirm('File has no shebang, sure you want to execute it?', '&Yes\n&No')
            if choice ~= 1 then
                return
            end
        end
    end
    local stat = vim.uv.fs_stat(filepath)
    if stat and not skipchmod then
        local user_execute = tonumber('00100', 8) -- 100 means user executable
        if bit.band(stat.mode, user_execute) ~= user_execute then
            local newmode = bit.bor(stat.mode, user_execute)
            vim.uv.fs_chmod(filepath, newmode)
        end
    end
    local win_height = math.floor(vim.o.lines / 3)
    vim.cmd(string.format('%ssplit | term %s', win_height, cmd))
end

return M
