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
  for _, winid in ipairs(winids) do
    vim.api.nvim_win_close(winid, false)
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

---Open a floating window with prompts at the cursor for users to select one of
---actions to run. E.g., A window with a prompt "[q]uickfix, [l]ocation ?" and
---the actions table is like { q = action_1, l = action_2 }. The user could
---press q to execute action_1.
---
---@param prompt string
---@param actions table<string, function|string>
function M.prompt_for_actions(prompt, actions)
  local bufnr = vim.api.nvim_create_buf(false, true)
  local winid = vim.api.nvim_open_win(bufnr, false, {
    relative = 'cursor',
    width = #prompt,
    height = 1,
    row = 1,
    col = 1,
    style = 'minimal',
    border = vim.g.border_style,
    noautocmd = true,
  })
  vim.wo[winid].winhl = 'Normal:Normal'
  vim.api.nvim_buf_set_lines(bufnr, 0, 1, false, { prompt })
  -- Highlight each initial letter.
  -- Here I convert (?<=\[)[^\[\]](?=\]) to \%(\[\)\@<=[^[\]]\%(\]\)\@= by
  -- E2v function provided by eregex.vim.
  -- I know \zs and \ze also work, but I prefer PCRE than vim regex.
  -- The regex contains literal square brackets, we should use long
  -- brackets. [=[ ... ]=] is a long brackets of level 1. Ref:
  -- http://lua-users.org/wiki/StringsTutorial
  vim.fn.matchadd('Hint', [=[\%(\[\)\@<=[^[\]]\%(\]\)\@=]=], 10, -1, { window = winid })
  vim.schedule(function()
    local char = vim.fn.getchar()
    if type(char) == 'number' then
      char = vim.fn.nr2char(char)
      for hint, action in pairs(actions) do
        if char == hint then
          if type(action) == 'function' then
            action()
          else
            vim.cmd(action)
          end
        end
      end
    end
    vim.cmd(('noautocmd bwipeout %d'):format(bufnr))
  end)
end

-- Align the markdown table with tabular.vim
-- Ref: https://gist.github.com/tpope/287147
function M.md_table_bar_align()
  local p = '^%s*|%s.*%s|%s*$'
  local line = vim.fn.line('.')
  local prev_line = vim.fn.getline(line - 1)
  local cur_line = vim.fn.getline('.')
  local next_line = vim.fn.getline(line + 1)
  local cur_col = vim.fn.col('.')
  if vim.fn.exists(':Tabularize') and cur_line:match('^%s*|') and (prev_line:match(p) or next_line:match(p)) then
    local col = #cur_line:sub(1, cur_col):gsub('[^|]', '')
    local pos = #vim.fn.matchstr(cur_line:sub(1, cur_col), ".*|\\s*\\zs.*")
    vim.cmd('Tabularize/|/l1')
    vim.cmd('normal! 0')
    vim.fn.search(('[^|]*|'):rep(col) .. ('\\s\\{-\\}'):rep(pos), 'ce', line)
  end
end

return M
