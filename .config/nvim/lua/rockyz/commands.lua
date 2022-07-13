local command = vim.api.nvim_create_user_command

-- Close windows by giving window numbers, e.g., :CloseWin 1 2 3
command('CloseWin', function(opts) require('rockyz.utils').close_wins(opts.args) end, { nargs = '+' })
