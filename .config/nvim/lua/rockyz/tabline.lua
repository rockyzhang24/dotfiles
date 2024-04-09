local M = {}

function M.tabline()
  local tl = {}
  for i, tp in ipairs(vim.api.nvim_list_tabpages()) do
    table.insert(tl, '%' .. i .. 'T')
    if tp == vim.api.nvim_get_current_tabpage() then
      table.insert(tl, '%#TabLineSel#')
    else
      table.insert(tl, '%#TabLine#')
    end
    table.insert(tl, ' ' .. i .. ':')

    -- Buffer name
    local winid = vim.api.nvim_tabpage_get_win(tp)
    local bufnr = vim.api.nvim_win_get_buf(winid)
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    local ft = vim.bo[bufnr].filetype
    local name = ''
    if ft == 'qf' then
      name = vim.fn.win_gettype(winid) == 'loclist' and '[Location List]' or '[Quickfix]'
    elseif ft == 'fzf' then
      name = 'FZF'
    elseif ft == 'fugitive' then
      name = 'Fugitive'
    elseif ft == 'term' then
      name = 'Term'
    elseif ft == 'help' then
      name = 'Vim Help'
    elseif ft == 'oil' then
      name = 'Oil'
    elseif vim.fn.win_gettype(winid) == 'command' then
      name = 'Cmdwin'
    else
      if bufname == '' then
        name = 'No Name'
      else
        name = vim.fn.fnamemodify(bufname, ':t')
        -- For diff
        if vim.wo[winid].diff then
          name = name .. ' (diff)'
        end
      end
    end
    if not string.match(name, '%[.+%]$') then
      name = '[' .. name .. ']'
    end
    table.insert(tl, name .. ' ')

    -- "Modified" indicator
    local bufmodified = vim.fn.getbufvar(bufnr, '&mod')
    if bufmodified ~= 0 then
      table.insert(tl, '[+] ')
    end
  end
  table.insert(tl, '%#TabLineFill#%T')
  return table.concat(tl)
end

vim.o.tabline = "%{%v:lua.require('rockyz.tabline').tabline()%}"

return M
