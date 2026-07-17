-- Kitty's scrollback pager.
-- It renders ANSI escape sequences.
--
-- References:
-- Folke's config: https://github.com/folke/dot/blob/master/nvim/lua/util/init.lua
-- Maria's config: https://github.com/MariaSolOs/dotfiles/tree/main/.config/nvim
-- https://gist.github.com/galaxia4Eva/9e91c4f275554b4bd844b6feece16b3d

---@param input_line_number integer
---@param cursor_line integer
---@param cursor_column integer
return function(input_line_number, cursor_line, cursor_column)
    vim.wo.number = false
    vim.wo.relativenumber = false
    vim.wo.statuscolumn = ''
    vim.wo.signcolumn = 'no'
    vim.wo.foldcolumn = '0'
    vim.opt.listchars = { space = ' ' }
    vim.wo.scrolloff = 0

    local bufnr = vim.api.nvim_get_current_buf()

    local scrollback_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    while #scrollback_lines > 0 and vim.trim(scrollback_lines[#scrollback_lines]) == '' do
        scrollback_lines[#scrollback_lines] = nil
    end
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})

    local terminal_channel = vim.api.nvim_open_term(bufnr, {})
    vim.api.nvim_chan_send(terminal_channel, table.concat(scrollback_lines, '\r\n'))

    vim.keymap.set('n', 'q', '<cmd>qa!<cr>', { silent = true, buffer = bufnr })

    local set_initial_cursor = function()
        vim.api.nvim_feedkeys(tostring(input_line_number) .. [[ggzt]], 'n', true)
        if cursor_line ~= 0 and cursor_column ~= 0 then
            vim.api.nvim_feedkeys(tostring(cursor_line - 1) .. [[j]], 'n', true)
            vim.api.nvim_feedkeys([[0]], 'n', true)
            vim.api.nvim_feedkeys(tostring(cursor_column - 1) .. [[l]], 'n', true)
        end
    end

    local augroup = vim.api.nvim_create_augroup('rockyz.kitty.scrollback', { clear = true })

    -- Keep Kitty scrollback pager out of terminal mode
    vim.api.nvim_create_autocmd('ModeChanged', {
        group = augroup,
        buffer = bufnr,
        callback = function()
            local mode = vim.fn.mode()
            if mode == 't' then
                vim.cmd.stopinsert()
            end
        end,
    })

    vim.schedule(function()
        set_initial_cursor()
        vim.bo.filetype = 'kitty_scrollback'
    end)

    vim.bo.modifiable = false
    vim.bo.readonly = true
    vim.o.write = false
end
