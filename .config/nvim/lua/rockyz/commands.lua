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

-- Diff two files side by side in a new tabpage
-- :DiffSplit <file1> <file2>
vim.api.nvim_create_user_command('DiffSplit', function(opts)
  if #opts.fargs ~= 2 then
    vim.api.nvim_echo({
      { 'ERROR: Require two file names.', 'ErrorMsg' },
    }, true, {})
  else
    vim.cmd('tabedit ' .. vim.fn.fnameescape(opts.fargs[1]))
    vim.cmd('rightbelow vert diffsplit ' .. vim.fn.fnameescape(opts.fargs[2]))
    vim.cmd('wincmd p')
    vim.cmd('normal! gg]c')
  end
end, { nargs = '+', complete = 'file' })

-- Profiler
vim.api.nvim_create_user_command('ProfileStart', function()
  require('plenary.profile').start('profile.log', { flame = true })
end, {})
vim.api.nvim_create_user_command('ProfileStop', function()
  require('plenary.profile').stop()
end, {})

-- Open a scratch buffer
vim.api.nvim_create_user_command('Scratch', function()
  vim.cmd('belowright 10new')
  local buf = vim.api.nvim_get_current_buf()
  for name, value in pairs {
    filetype = 'scratch',
    buftype = 'nofile',
    bufhidden = 'hide',
    swapfile = false,
    modifiable = true,
  } do
  vim.api.nvim_set_option_value(name, value, { buf = buf })
end
end, { nargs = 0 })
