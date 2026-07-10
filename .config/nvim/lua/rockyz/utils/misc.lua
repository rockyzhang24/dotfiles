local M = {}

---Show an action prompt below the cursor.
---Pressing a bracketed key runs the corresponding action.
---
---For example, for a prompt "[q]uickfix, [l]ocation ?" and an actions table { q = action_1,
---l = action_2 }, users could press q to execute action_1.
---
---@param prompt_text string
---@param actions_by_key table<string, fun()|string>
function M.prompt_for_actions(prompt_text, actions_by_key)
    local bufnr = vim.api.nvim_create_buf(false, true)

    local winid = vim.api.nvim_open_win(bufnr, false, {
        relative = 'cursor',
        width = #prompt_text,
        height = 1,
        row = 1,
        col = 1,
        style = 'minimal',
        border = vim.g.border_style,
        noautocmd = true,
    })

    vim.wo[winid].winhl = 'Normal:Normal'

    vim.api.nvim_buf_set_lines(bufnr, 0, 1, false, { prompt_text })

    -- Highlight the initial character that is enclosed in each pair of square brackets
    --
    -- Here I convert (?<=\[)[^\[\]](?=\]) to \%(\[\)\@<=[^[\]]\%(\]\)\@= by eregex.vim's E2v
    -- function. I know \zs and \ze also work, but I prefer PCRE than vim regex.
    --
    -- Use long brackets because the Vim regex contains literal square brackets. [=[ ... ]=] is
    -- a long brackets of level 1.
    --
    -- Reference: http://lua-users.org/wiki/StringsTutorial
    vim.fn.matchadd('Hint', [=[\%(\[\)\@<=[^[\]]\%(\]\)\@=]=], 10, -1, { window = winid })

    vim.schedule(function()
        local input = vim.fn.getchar()
        local key = type(input) == 'number' and vim.fn.nr2char(input) or nil
        local action = key and actions_by_key[key]

        if vim.api.nvim_buf_is_valid(bufnr) then
            vim.cmd(('noautocmd bwipeout %d'):format(bufnr))
        end

        if type(action) == 'function' then
            action()
        elseif type(action) == 'string' then
            vim.cmd(action)
        end
    end)
end

---Align the current Markdown table with tabular.vim.
---Reference: https://gist.github.com/tpope/287147
function M.align_markdown_table()
    local table_pattern = '^%s*|%s.*%s|%s*$'
    local current_line_number = vim.fn.current_line_number('.')
    local previous_line = vim.fn.getline(current_line_number - 1)
    local current_line = vim.fn.getline('.')
    local next_line = vim.fn.getline(current_line_number + 1)
    local cursor_column = vim.fn.col('.')
    if
        vim.fn.exists(':Tabularize')
        and current_line:match('^%s*|')
        and (previous_line:match(table_pattern) or next_line:match(table_pattern))
    then
        local bar_count = #current_line:sub(1, cursor_column):gsub('[^|]', '')
        local cell_offset = #vim.fn.matchstr(current_line:sub(1, cursor_column), '.*|\\s*\\zs.*')
        vim.cmd('Tabularize/|/l1')
        vim.cmd('normal! 0')
        vim.fn.search(('[^|]*|'):rep(bar_count) .. ('\\s\\{-\\}'):rep(cell_offset), 'ce', current_line_number)
    end
end

---Paste the active register as a line above or below the current line.
---@param put_command string For example, `]p` puts below and `[p` puts above
function M.put_linewise(put_command)
    local register_contents, register_type = vim.fn.getreg(vim.v.register), vim.fn.getregtype(vim.v.register)
    if register_type == 'V' then
        vim.cmd('normal! "' .. vim.v.register .. put_command)
    else
        vim.fn.setreg(vim.v.register, register_contents, 'l')
        local ok, err = pcall(vim.cmd, 'normal! "' .. vim.v.register .. put_command)
        vim.fn.setreg(vim.v.register, register_contents, register_type)
        if not ok then
            error(err)
        end
    end
end

return M
