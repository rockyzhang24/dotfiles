vim.o.termguicolors = true
vim.o.background = vim.g.dark_background and 'dark' or 'light'

-- Clear the Normal background when transparent background is enabled
if vim.g.transparent_background then
    local clear_bg_augroup = vim.api.nvim_create_augroup('rockyz.color.clear_bg', { clear = true })

    vim.api.nvim_create_autocmd('ColorScheme', {
        group = clear_bg_augroup,
        callback = function()
            local normal_hl = vim.api.nvim_get_hl(0, { name = 'Normal' })
            vim.api.nvim_set_hl(0, 'Normal', { fg = normal_hl.fg, bg = 'NONE' })
        end,
    })
end

-- Sync the terminal background to remove the frame around Vim
-- This happens when Vim's Normal background differs from the terminal background
-- References:
-- https://www.reddit.com/r/neovim/comments/1ehidxy/you_can_remove_padding_around_neovim_instance/
-- https://github.com/neovim/neovim/issues/16572#issuecomment-1954420136
local terminal_background_synced = false
local sync_terminal_bg_augroup = vim.api.nvim_create_augroup('rockyz.color.sync_terminal_bg', { clear = true })
vim.api.nvim_create_autocmd({ 'UIEnter', 'ColorScheme' }, {
    group = sync_terminal_bg_augroup,
    callback = function()
        local normal = vim.api.nvim_get_hl(0, { name = 'Normal' })
        if normal.bg then
            io.write(string.format('\027]11;#%06x\027\\', normal.bg))
            terminal_background_synced = true
        end
    end,
})
vim.api.nvim_create_autocmd('UILeave', {
    group = sync_terminal_bg_augroup,
    callback = function()
        if terminal_background_synced then
            io.write('\027]111\027\\')
        end
    end,
})

vim.cmd('colorscheme ' .. vim.fn.fnameescape(vim.g.colorscheme))
