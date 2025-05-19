vim.o.termguicolors = true
vim.o.background = 'dark'

-- Remove the background color for transparent background
if vim.g.transparent then
    vim.api.nvim_create_augroup('rockyz.color.bg_clean', { clear = true })
    vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
        group = 'rockyz.color.bg_clean',
        pattern = '*',
        callback = function()
            local normal_hl = vim.api.nvim_get_hl(0, { name = 'Normal' })
            vim.api.nvim_set_hl(0, 'Normal', { fg = normal_hl.fg, bg = 'NONE' })
        end,
    })
end

-- Sync the terminal backgroud to remove the frame around vim which appears if vim's normal
-- backgroud color differs from what is used in terminal itself.
-- Ref:
-- https://www.reddit.com/r/neovim/comments/1ehidxy/you_can_remove_padding_around_neovim_instance/
-- https://github.com/neovim/neovim/issues/16572#issuecomment-1954420136
local modified = false
local sync_term_bg_group = vim.api.nvim_create_augroup('rockyz.color.sync_term_bg', { clear = true })
vim.api.nvim_create_autocmd({ 'UIEnter', 'ColorScheme' }, {
    group = sync_term_bg_group,
    callback = function()
        local normal = vim.api.nvim_get_hl(0, { name = 'Normal' })
        if normal.bg then
            io.write(string.format('\027]11;#%06x\027\\', normal.bg))
            modified = true
        end
    end,
})
vim.api.nvim_create_autocmd('UILeave', {
    group = sync_term_bg_group,
    callback = function()
        if modified then
            io.write('\027]111\027\\')
        end
    end,
})

vim.cmd('colorscheme ' .. vim.g.colorscheme)
