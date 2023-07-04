local g = vim.g
local o = vim.o
local cmd = vim.cmd
local api = vim.api

o.termguicolors = true
o.background = "dark"

if g.transparent then
  api.nvim_create_augroup('CleanBackground', { clear = true })
  api.nvim_create_autocmd({ 'ColorScheme' }, {
    group = 'CleanBackground',
    pattern = '*',
    callback = function()
      api.nvim_set_hl(0, "Normal", { bg = "NONE" })
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
if g.border_enabled then
  api.nvim_create_augroup('HighlightAdjust', { clear = true })
  api.nvim_create_autocmd({ 'ColorScheme' }, {
    group = 'HighlightAdjust',
    pattern = '*',
    callback = function()
      api.nvim_set_hl(0, 'NormalFloat', { link = 'Normal' })
    end,
  })
end

cmd("colorscheme " .. g.colorscheme)
