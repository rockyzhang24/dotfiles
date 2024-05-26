local M = {}

-- Close all the floating windows
function M.close_all_floating_wins()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= '' then
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
  for _, winid in ipairs(winids) do vim.api.nvim_win_close(winid, false)
  end
end

-- Close the diff windows in the current tab
function M.close_diff()
  local winids = vim.tbl_filter(function(winid)
    return vim.wo[winid].diff
  end, vim.api.nvim_tabpage_list_wins(0))

  if #winids > 1 then
    for _, winid in ipairs(winids) do
      local ok, msg = pcall(vim.api.nvim_win_close, winid, false)
      -- Handle the last window that cannot be closed by nvim_win_close
      if not ok and msg:match('^Vim:E444:') then
        -- If we run a script like `ngd` in the terminal, we should fully exit
        -- nvim
        if vim.g.from_script then
          vim.cmd('quit')
          return
        end
        if vim.api.nvim_buf_get_name(0):match('^fugitive://') then
          vim.cmd('Gedit')
        end
      end
    end
  end
end

-- Maximizes and restores the current window
-- Ref: https://github.com/szw/vim-maximizer
local function win_maximize()
  vim.t.maximizer_sizes = {
    before = vim.fn.winrestcmd(),
  }
  vim.cmd('vert resize | resize')
  vim.t.maximizer_sizes.after = vim.fn.winrestcmd()
  vim.cmd('normal! ze')
  vim.w.maximized = 1
end

local function win_restore()
  if vim.t.maximizer_sizes ~= nil then
    vim.cmd('silent! execute ' .. vim.t.maximizer_sizes.before)
    if vim.t.maximizer_sizes ~= vim.fn.winrestcmd() then
      vim.cmd('wincmd =')
    end
    vim.t.maximizer_sizes = nil
    vim.cmd('normal! ze')
    vim.w.maximized = 0
  end
end

function M.win_maximize_toggle()
  if vim.t.maximizer_sizes ~= nil then
    win_restore()
  else
    -- The current window can be maximized only if there are more than one non-floating windows in
    -- the tab
    local win_cnt = 0
    for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if vim.api.nvim_win_get_config(winid).relative == '' then
        win_cnt = win_cnt + 1
      end
      if win_cnt > 1 then
        win_maximize()
        return
      end
    end
  end
end

return M
