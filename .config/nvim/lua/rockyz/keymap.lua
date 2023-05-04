local M = {}

-- noremap by default is true.
M.map = function(mode, lhs, rhs, opts)
  opts = opts or {}
  if opts.silent == nil then
    opts.silent = true
  end
  vim.keymap.set(mode, lhs, rhs, opts)
end

M.unmap = function(mode, lhs, opts)
  vim.keymap.del(mode, lhs, opts)
end

return M
