vim.wo.colorcolumn = ''
vim.wo.statusline = ''

-- Add the cfilter plugin (see :Cfilter)
vim.cmd.packadd('cfilter')

-- Run substitute for each entry
vim.keymap.set('n', 'r', ':cdo s///gc<Left><Left><Left>', { buffer = true })

-- Remove qf items
vim.api.nvim_buf_create_user_command(0, 'RemoveQfItems', function(opts)
    local winid = vim.api.nvim_get_current_win()
    local is_loclist = vim.fn.win_gettype(winid) == 'loclist'
    local what = { items = 0, title = 0 }
    local list = is_loclist and vim.fn.getloclist(0, what) or vim.fn.getqflist(what)
    if #list.items > 0 then
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        for pos = opts.line2, opts.line1, -1 do
            table.remove(list.items, pos)
        end
        if is_loclist then
            vim.fn.setloclist(0, {}, 'r', { items = list.items, title = list.title })
        else
            vim.fn.setqflist({}, 'r', { items = list.items, title = list.title })
        end
        vim.api.nvim_win_set_cursor(0, { row > vim.fn.line('$') and vim.fn.line('$') or row, col })
    end
end, { range = true })

vim.keymap.set('n', 'dd', '<Cmd>RemoveQfItems<CR>', { buffer = true })
vim.keymap.set('x', 'd', ':RemoveQfItems<CR>', { buffer = true, silent = true })
