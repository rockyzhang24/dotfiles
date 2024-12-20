vim.o.termguicolors = true
vim.o.background = 'dark'

-- Remove the background color for transparent background
if vim.g.transparent then
    vim.api.nvim_create_augroup('CleanBackground', { clear = true })
    vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
        group = 'CleanBackground',
        pattern = '*',
        callback = function()
            local normal_hl = vim.api.nvim_get_hl(0, { name = 'Normal' })
            vim.api.nvim_set_hl(0, 'Normal', { fg = normal_hl.fg, bg = 'NONE' })
        end,
    })
end

-- Enable the window border for all floating windows such as diagnostics,
-- autocomplete menu and etc.
-- By default, NormalFloat is linked to Pmenu whose background maybe diffrent
-- from Normal. If the border of the floating window is enabled, the overall
-- look is not good no matter what backgroud of the border is set. The
-- workaround is to remove the background of the float window, i.e., link
-- NormalFloat to Normal.
-- Some float windows, like the autocomplete menu from nvim-cmp, use
-- 'winhighlight' to control its highlighting. We should remove the backgroun of
-- the float window through this option, e.g., vim.o.winhighlight =
-- 'Normal:Normal'
if vim.g.border_enabled then
    vim.api.nvim_create_augroup('HighlightAdjust', { clear = true })
    vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
        group = 'HighlightAdjust',
        pattern = '*',
        callback = function()
            vim.api.nvim_set_hl(0, 'NormalFloat', { link = 'Normal' })
        end,
    })
end

-- Sync the terminal backgroud to remove the frame around vim which appears if vim's normal
-- backgroud color differs from what is used in terminal itself.
-- Ref:
-- https://www.reddit.com/r/neovim/comments/1ehidxy/you_can_remove_padding_around_neovim_instance/
-- https://github.com/neovim/neovim/issues/16572#issuecomment-1954420136
local modified = false
local sync_term_bg_group = vim.api.nvim_create_augroup('rockyz/sync_term_bg', { clear = true })
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
