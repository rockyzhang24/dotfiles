-- Kitty's scrollback pager.
-- It colorizes ANSI escape codes.
-- References:
-- Folke's config: https://github.com/folke/dot/blob/master/nvim/lua/util/init.lua
-- Maria's config: https://github.com/MariaSolOs/dotfiles/tree/main/.config/nvim
-- https://gist.github.com/galaxia4Eva/9e91c4f275554b4bd844b6feece16b3d

return function(INPUT_LINE_NUMBER, CURSOR_LINE, CURSOR_COLUMN)
    vim.wo.number = false
    vim.wo.relativenumber = false
    vim.wo.statuscolumn = ''
    vim.wo.signcolumn = 'no'
    vim.wo.foldcolumn = '0'
    vim.opt.listchars = { space = ' ' }
    vim.wo.scrolloff = 0

    local buf = vim.api.nvim_get_current_buf()

    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    while #lines > 0 and vim.trim(lines[#lines]) == '' do
        lines[#lines] = nil
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})

    vim.api.nvim_chan_send(vim.api.nvim_open_term(buf, {}), table.concat(lines, '\r\n'))

    vim.keymap.set('n', 'q', '<cmd>qa!<cr>', { silent = true, buffer = buf })

    local set_cursor = function()
        vim.api.nvim_feedkeys(tostring(INPUT_LINE_NUMBER) .. [[ggzt]], 'n', true)
        if CURSOR_LINE ~= 0 and CURSOR_COLUMN ~= 0 then
            vim.api.nvim_feedkeys(tostring(CURSOR_LINE - 1) .. [[j]], 'n', true)
            vim.api.nvim_feedkeys([[0]], 'n', true)
            vim.api.nvim_feedkeys(tostring(CURSOR_COLUMN - 1) .. [[l]], 'n', true)
        end
    end

    local group = vim.api.nvim_create_augroup('rockyz.kitty.scrollback', {})
    vim.api.nvim_create_autocmd('ModeChanged', {
        group = group,
        buffer = buf,
        callback = function()
            local mode = vim.fn.mode()
            if mode == 't' then
                vim.cmd.stopinsert()
            end
        end,
    })

    vim.schedule(function()
        set_cursor()
        vim.bo.filetype = 'kitty_scrollback'
    end)

    vim.bo.modifiable = false
    vim.bo.readonly = true
    vim.o.write = false
end
