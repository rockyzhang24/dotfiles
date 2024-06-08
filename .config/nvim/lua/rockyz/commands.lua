local function scratch_buf_init()
  local buf = vim.api.nvim_get_current_buf()
  for name, value in pairs({
    filetype = 'scratch',
    buftype = 'nofile',
    bufhidden = 'hide',
    swapfile = false,
    modifiable = true,
  }) do
    vim.api.nvim_set_option_value(name, value, { buf = buf })
  end
end

-- Close windows by giving window numbers, e.g., :CloseWin 1 2 3
vim.api.nvim_create_user_command('CloseWin', function(opts)
  require('rockyz.utils.win_utils').close_wins(opts.args)
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
  scratch_buf_init()
end, { nargs = 0 })

-- Messages redirection
-- 1. Redirect messages to a file
vim.api.nvim_create_user_command('MsgsFile', function()
  local file = '$HOME/Downloads/messages.txt'
  vim.cmd('redir >> ' .. file .. ' | silent messages | redir END')
end, {})
-- 2. Redirect messages to system clipboard
vim.api.nvim_create_user_command('MsgsClip', function()
  vim.cmd('redir @*>  | silent messages | redir END')
end, {})
-- 3. Redirect messages to a split window
vim.api.nvim_create_user_command('MsgsSplit', function()
  vim.cmd('vertical new')
  scratch_buf_init()
  vim.cmd('redir => msg_output | silent messages | redir END')
  vim.cmd("execute 'put =msg_output'")
end, {})
