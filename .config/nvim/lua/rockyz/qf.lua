local M = {}
local fn = vim.fn

-- Change the appearance for the texts displayed in quickfix
-- Ref: https://github.com/kevinhwang91/nvim-bqf#customize-quickfix-window-easter-egg
function M.qftf(info)
  local items
  local ret = {}
  if info.quickfix == 1 then
    items = fn.getqflist({ id = info.id, items = 0 }).items
  else
    items = fn.getloclist(info.winid, { id = info.id, items = 0 }).items
  end
  local limit = 31
  local fname_fmt1, fname_fmt2 = '%-' .. limit .. 's', '…%.' .. (limit - 1) .. 's'
  local valid_fmt = '%s │%5d:%-3d│%s %s'
  for i = info.start_idx, info.end_idx do
    local e = items[i]
    local fname = ''
    local str
    if e.valid == 1 then
      if e.bufnr > 0 then
        fname = fn.bufname(e.bufnr)
        if fname == '' then
          fname = '[No Name]'
        else
          fname = fname:gsub('^' .. vim.env.HOME, '~')
        end
        -- char in fname may occur more than 1 width, ignore this issue in order to keep performance
        if #fname <= limit then
          fname = fname_fmt1:format(fname)
        else
          fname = fname_fmt2:format(fname:sub(1 - limit))
        end
      end
      local lnum = e.lnum > 99999 and -1 or e.lnum
      local col = e.col > 999 and -1 or e.col
      local qtype = e.type == '' and '' or ' ' .. e.type:sub(1, 1):upper()
      str = valid_fmt:format(fname, lnum, col, qtype, e.text)
    else
      str = e.text
    end
    table.insert(ret, str)
  end
  return ret
end

vim.o.quickfixtextfunc = [[{info -> v:lua.require('rockyz.qf').qftf(info)}]]

-- Show a prompt to close quickfix window and/or the location list window
function M.close()
  local locWinid = fn.getloclist(0, { winid = 0 }).winid
  if locWinid == 0 then
    vim.cmd('cclose')
  else
    local qfWinid = fn.getqflist({ winid = 0 }).winid
    if qfWinid == 0 then
      vim.cmd('lclose')
    else
      local prompt = ' [q]uickfix, [l]ocation, [a]ll ? '
      local actions = {
        q = 'cclose',
        l = 'lclose',
        a = 'lclose | cclose',
      }
      require('rockyz.utils').prompt_for_actions(prompt, actions)
    end
  end
end

-- Show a prompt to open the quickfix window and/or the location list window
local function open_loclist()
  if next(fn.getloclist(0)) ~= nil then
    vim.cmd('lopen')
  else
    print('No location list for current window')
  end
end
function M.open()
  local prompt = ' [q]uickfix, [l]ocation, [a]ll ? '
  local actions = {
    q = 'copen',
    l = open_loclist,
    a = function()
      open_loclist()
      vim.cmd('copen')
    end,
  }
  require('rockyz.utils').prompt_for_actions(prompt, actions)
end

return M
