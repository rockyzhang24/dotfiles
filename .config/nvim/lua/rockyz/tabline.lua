local M = {}

local icons = require('rockyz.icons')

local special_fts = {
  qf = '',
  fzf = 'FZF',
  fugitive = 'Fugitive',
  term = 'Term',
  help = 'Vim Help',
  oil = 'Oil',
}

function M.render()
  local tabs = {}

  for i, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
    local is_cur = tabpage == vim.api.nvim_get_current_tabpage()
    local items = {}

    -- Tab number
    -- %iT label at the beginning of each tab is used for mouse click
    local num = string.format('%%%sT %s.', i, i)
    table.insert(items, num)

    -- Title
    local winid = vim.api.nvim_tabpage_get_win(tabpage)
    local bufnr = vim.api.nvim_win_get_buf(winid)
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    local filetype = vim.bo[bufnr].filetype
    local tab_title = ''
    special_fts.qf = vim.fn.win_gettype(winid) == 'loclist' and 'Location List' or 'Quickfix List'
    if special_fts[filetype] ~= nil then
      tab_title = string.format('[%s]', special_fts[filetype])
    elseif vim.fn.win_gettype(winid) == 'command' then
      tab_title = '[Command Window]'
    elseif bufname == '' then
      tab_title = '[No Name]'
    else
      tab_title = vim.fn.fnamemodify(bufname, ':t')
      -- For diff
      if vim.wo[winid].diff then
        tab_title = tab_title .. ' (diff)'
      end
    end
    table.insert(items, tab_title)

    -- "Modified" indicator
    local bufmodified = vim.fn.getbufvar(bufnr, '&mod')
    if bufmodified ~= 0 then
      table.insert(items, icons.misc.circle_filled)
    end

    local tab = table.concat(items, ' ') .. ' '
    -- Highlight the current tab page
    if is_cur then
      tab = string.format('%%#TabLineSel#%s%%*', tab)
    end
    -- Add right border
    local fmt_str = '%s%%#TabBorderRight' .. (is_cur and 'Active' or '') .. '#%s%%*'
    tab = string.format(fmt_str, tab, icons.separators.bar_right)

    table.insert(tabs, tab)
  end

  local tabline = table.concat(tabs)
  tabline = string.format('%%#TabLine#%s%%#TabLineFill%%T', tabline)
  return tabline
end

vim.o.showtabline = 2
vim.o.tabline = "%{%v:lua.require('rockyz.tabline').render()%}"

return M
