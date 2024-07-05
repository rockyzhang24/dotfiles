local M = {}

-- Insert string into table if it's not empty
function M.insert_if_not_empty(t, str)
  if str == '' then
    return
  end
  table.insert(t, str)
end

return M
