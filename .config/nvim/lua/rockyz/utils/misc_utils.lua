local M = {}

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

---Paste the selection below or above the current line
---@param how string e.g., ]p for below, [p for above
function M.putline(how)
  local body, type = vim.fn.getreg(vim.v.register), vim.fn.getregtype(vim.v.register)
  if type == 'V' then
    vim.cmd('normal! "' .. vim.v.register .. how)
  else
    vim.fn.setreg(vim.v.register, body, 'l')
    vim.cmd('normal! "' .. vim.v.register .. how)
    vim.fn.setreg(vim.v.register, body, type)
  end
end

-- Colorize ANSI escape codes.
-- Used by kitty's scrollback pager
-- Taken from folke's config: https://github.com/folke/dot/blob/master/nvim/lua/util/init.lua
function M.colorize()
  vim.wo.number = false
  vim.wo.relativenumber = false
  vim.wo.statuscolumn = ""
  vim.wo.signcolumn = "no"
  vim.opt.listchars = { space = " " }

  local buf = vim.api.nvim_get_current_buf()

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  while #lines > 0 and vim.trim(lines[#lines]) == "" do
    lines[#lines] = nil
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})

  vim.b[buf].minianimate_disable = true

  vim.api.nvim_chan_send(vim.api.nvim_open_term(buf, {}), table.concat(lines, "\r\n"))
  vim.keymap.set("n", "q", "<cmd>qa!<cr>", { silent = true, buffer = buf })
  vim.api.nvim_create_autocmd("TextChanged", { buffer = buf, command = "normal! G$" })
  vim.api.nvim_create_autocmd("TermEnter", { buffer = buf, command = "stopinsert" })

  vim.defer_fn(function()
    vim.b[buf].minianimate_disable = false
  end, 2000)
end

return M
