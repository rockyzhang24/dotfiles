local M = {}

-- Close all the floating windows
function M.close_all_floating_wins()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= "" then
      vim.api.nvim_win_close(win, false)
      -- print('Closing window', win)
    end
  end
end

-- Close windows by giving window numbers
function M.close_wins(win_nums)
  local winids = {}
  for win_num in string.gmatch(win_nums, '%d+') do
    local winid = vim.fn.win_getid(tonumber(win_num))
    table.insert(winids, winid)
  end
  for _, winid in ipairs(winids) do
    vim.api.nvim_win_close(winid, false)
  end
end

return M
