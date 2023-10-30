local M = {}

function M.tabline()
  local tl = {}
  for i, tp in ipairs(vim.api.nvim_list_tabpages()) do
    if tp == vim.api.nvim_get_current_tabpage() then
      table.insert(tl, '%#TabLineSel#')
    else
      table.insert(tl, '%#TabLine#')
    end
    table.insert(tl, ' ' .. i .. ' ')
    local name
    local winid = vim.api.nvim_tabpage_get_win(tp)
    local bufnr = vim.api.nvim_win_get_buf(winid)
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    name = vim.fn.fnamemodify(bufname, ':t')
    if not name or name == '' then
      local winType = vim.fn.win_gettype(winid)
      if winType == 'loclist' then
        name = '[Location]'
      elseif winType == 'quickfix' then
        name = '[Quickfix]'
      else
        name = '[No Name]'
      end
    end
    if string.match(bufname, '%d;#FZF') then
      name = '[FZF]'
    elseif string.match(bufname, 'fugitive:///') then
      name = '[Fugivie]'
    elseif string.match(bufname, 'oil:///') then
      name = '[Oil]'
    elseif string.match(bufname, 'term:.*/bin/zsh') then
      name = '[Zsh]'
    end
    table.insert(tl, name .. ' ')
    local bufmodified = vim.fn.getbufvar(bufnr, '&mod')
    if bufmodified ~= 0 then
      table.insert(tl, ' ')
    end
  end
  table.insert(tl, '%#TabLineFill#%T')
  return table.concat(tl)
end

vim.o.tabline = "%{%v:lua.require('rockyz.tabline').tabline()%}"

return M
