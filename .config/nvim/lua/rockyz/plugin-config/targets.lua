local g = vim.g
local api = vim.api

g.targets_seekRanges = 'cc cr cb cB lc ac Ac lr lb ar ab lB Ar aB Ab AB rr ll rb al rB Al bb aa bB Aa BB AA'
g.targets_jumpRanges = g.targets_seekRanges

api.nvim_create_augroup('mappings_control', { clear = true })
api.nvim_create_autocmd({ 'User' }, {
  group = 'mappings_control',
  pattern = 'targets#mappings#user',
  callback = function()
    vim.cmd([[
      call targets#mappings#extend({
        \ 'a': {},
        \ })
    ]])
  end,
})
