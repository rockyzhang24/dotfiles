vim.api.nvim_create_augroup('after_object', { clear = true })
vim.api.nvim_create_autocmd({ 'VimEnter' }, {
  group = 'after_object',
  pattern = '*',
  callback = function()
    vim.cmd([[
      call after_object#enable([']', '['], '=', ':', '-', '#', ' ')
    ]])
  end,
})
