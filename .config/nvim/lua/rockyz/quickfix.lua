local M = {}

local qf_utils = require('rockyz.utils.qf_utils')

function M.qftf(info)
  local items
  local ret = {}
  if info.quickfix == 1 then
    items = vim.fn.getqflist({ id = info.id, items = 0 }).items
  else
    items = vim.fn.getloclist(info.winid, { id = info.id, items = 0 }).items
  end
  for i = info.start_idx, info.end_idx do
    local e = items[i]
    local str = qf_utils.format_qf_item(e)
    table.insert(ret, str)
  end
  return ret
end

vim.o.quickfixtextfunc = [[{info -> v:lua.require('rockyz.quickfix').qftf(info)}]]

return M
