local M = {}
local api = vim.api
local fn = vim.fn
local cmd = vim.cmd

-- Close all the floating windows
function M.close_all_floating_wins()
  for _, win in ipairs(api.nvim_list_wins()) do
    local config = api.nvim_win_get_config(win)
    if config.relative ~= "" then
      api.nvim_win_close(win, false)
      -- print('Closing window', win)
    end
  end
end

-- Close windows by giving window numbers
function M.close_wins(win_nums)
  local winids = {}
  for win_num in string.gmatch(win_nums, '%d+') do
    local winid = fn.win_getid(tonumber(win_num))
    table.insert(winids, winid)
  end
  for _, winid in ipairs(winids) do
    api.nvim_win_close(winid, false)
  end
end

-- Close the diff windows
function M.close_diff()
  local winids = vim.tbl_filter(function(winid)
    return vim.wo[winid].diff
  end, api.nvim_tabpage_list_wins(0))

  if #winids > 1 then
    for _, winid in ipairs(winids) do
      local ok, msg = pcall(api.nvim_win_close, winid, false)
      if not ok and msg:match('^Vim:E444:') then
        if api.nvim_buf_get_name(0):match('^fugitive://') then
          cmd('Gedit')
        end
      end
    end
  end
end

--- Open a floating window with prompts at the cursor for users to select one of
--- actions to run. E.g., A window with a prompt "[q]uickfix, [l]ocation ?" and
--- the actions table is like { q = action_1, l = action_2 }. The user could
--- press q to execute action_1.
---
---@param prompt string
---@param actions table<string, function|string>
function M.prompt_for_actions(prompt, actions)
  local bufnr = api.nvim_create_buf(false, true)
  local winid = api.nvim_open_win(bufnr, false, {
    relative = 'cursor',
    width = #prompt,
    height = 1,
    row = 1,
    col = 1,
    style = 'minimal',
    border = 'single',
    noautocmd = true
  })
  vim.wo[winid].winhl = 'Normal:Normal'
  api.nvim_buf_set_lines(bufnr, 0, 1, false, { prompt })
  -- Highlight each initial letter.
  -- Here I convert (?<=\[)[^\[\]](?=\]) to \%(\[\)\@<=[^[\]]\%(\]\)\@= by
  -- E2v function provided by eregex.vim.
  -- I know \zs and \ze also work, but I prefer PCRE than vim regex.
  -- The regex contains literal square brackets, we should use long
  -- brackets. [=[ ... ]=] is a long brackets of level 1. Ref:
  -- http://lua-users.org/wiki/StringsTutorial
  fn.matchadd('Hint', [=[\%(\[\)\@<=[^[\]]\%(\]\)\@=]=], 10, -1, { window = winid })
  vim.schedule(function()
    local char = fn.getchar()
    if type(char) == 'number' then
      char = fn.nr2char(char)
      for hint, action in pairs(actions) do
        if char == hint then
          if type(action) == 'function' then
            action()
          else
            cmd(action)
          end
        end
      end
    end
    cmd(('noautocmd bwipeout %d'):format(bufnr))
  end)
end

return M
