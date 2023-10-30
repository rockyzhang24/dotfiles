-- Auto-create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  pattern = '*',
  group = vim.api.nvim_create_augroup('auto_create_dir', { clear = true }),
  callback = function(ctx)
    -- Prevent oil.nivm from creating an extra oil:/ dir when we create a
    -- file/dir
    if vim.bo.ft == 'oil' then
      return
    end
    local dir = vim.fn.fnamemodify(ctx.file, ':p:h')
    local res = vim.fn.isdirectory(dir)
    if res == 0 then
      vim.fn.mkdir(dir, 'p')
    end
  end,
})

-- Highlight the selections on yank
vim.api.nvim_create_autocmd({ 'TextYankPost' }, {
  pattern = '*',
  group = vim.api.nvim_create_augroup('highlight_yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = 'Substitute', timeout = 300 })
  end,
})

-- Reload buffer if it is modified outside neovim
vim.api.nvim_create_autocmd({
  'FocusGained',
  'BufEnter',
  'CursorHold',
}, {
  group = vim.api.nvim_create_augroup('buffer_reload', { clear = true }),
  callback = function()
    if vim.fn.getcmdwintype() == '' then
      vim.cmd('checktime')
    end
  end,
})

-- Automatically load diagnostics into location list
vim.api.nvim_create_autocmd({ 'DiagnosticChanged' }, {
  group = vim.api.nvim_create_augroup('diagnostics', { clear = true }),
  callback = function()
    vim.diagnostic.setloclist({ open = false })
  end,
})
