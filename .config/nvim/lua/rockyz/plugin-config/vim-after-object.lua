local api = vim.api

api.nvim_create_augroup('after_object', { clear = true })
api.nvim_create_autocmd({ 'VimEnter' }, {
  group = 'after_object',
  pattern = '*',
  callback = function()
    vim.cmd([[
      call after_object#enable([']', '['], '=', ':', '-', '#', ' ')
    ]])
  end,
})
