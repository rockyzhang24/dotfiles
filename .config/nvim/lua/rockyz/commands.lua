-- Close windows by giving window numbers, e.g., :CloseWin 1 2 3
vim.api.nvim_create_user_command('CloseWin', function(opts)
  require('rockyz.utils').close_wins(opts.args)
end, { nargs = '+' })

-- Change indentation for the current buffer
-- `:Reindent cur_indent new_indent`, e.g., `:Reindent 2 4` for changing the
-- indentation from 2 to 4
vim.api.nvim_create_user_command('Reindent', function(opts)
  vim.cmd('call utils#Reindent(' .. string.gsub(opts.args, ' ', ', ') .. ')')
end, { nargs = '+' })
