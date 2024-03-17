local M = {}

vim.g.mapleader = ' '

vim.keymap.set({ 'n', 'x' }, '<Leader>', '<Nop>')
vim.keymap.set('n', '<Leader>,', ',')
vim.keymap.set({ 'n', 'x' }, '_', '"_')
vim.keymap.set({ 'n', 'x', 'o' }, 'H', '^')
vim.keymap.set({ 'n', 'x', 'o' }, 'L', '$')
vim.keymap.set('x', '<', '<gv')
vim.keymap.set('x', '>', '>gv')
-- Move the current line or selections up and down with corresponding indentation
vim.keymap.set('n', '<M-j>', ':m .+1<CR>==', { silent = true })
vim.keymap.set('n', '<M-k>', ':m .-2<CR>==', { silent = true })
vim.keymap.set('i', '<M-j>', '<Esc>:m .+1<CR>==a', { silent = true })
vim.keymap.set('i', '<M-k>', '<Esc>:m .-2<CR>==a', { silent = true })
vim.keymap.set('x', 'J', ":m '>+1<CR>gv=gv", { silent = true })
vim.keymap.set('x', 'K', ":m '<-2<CR>gv=gv", { silent = true })
-- Join lines but retain the cursor position
vim.keymap.set('n', 'J', 'mzJ`z')
-- Make dot work over visual line selections
vim.keymap.set('n', '.', ':norm.<CR>', { silent = true })
-- Clone current paragraph
vim.keymap.set('n', 'cp', 'yap<S-}>p')
-- Move the view horizontally when nowrap is set
vim.keymap.set('n', 'zh', '10zh')
vim.keymap.set('n', 'zl', '10zl')
-- Visual select all
vim.keymap.set('n', '<M-a>', 'VggoG')
-- Smart jk
local function smart_jk(jk)
  if vim.v.count ~= 0 then
    if vim.v.count > 5 then
      return "m'" .. vim.v.count .. jk
    end
    return jk
  end
  return 'g' .. jk
end
vim.keymap.set('n', 'j', function()
  return smart_jk('j')
end, { expr = true })
vim.keymap.set('n', 'k', function()
  return smart_jk('k')
end, { expr = true })
-- Smart dd: use blackhole register if we delete empty line by dd
vim.keymap.set('n', 'dd', function()
  if vim.api.nvim_get_current_line():match('^%s*$') then
    return '"_dd'
  else
    return 'dd'
  end
end, { expr = true })
-- Smart i: make i indent properly on empty line
vim.keymap.set('n', 'i', function()
  if #vim.fn.getline('.') == 0 then
    return [["_cc]]
  else
    return 'i'
  end
end, { expr = true })
-- Remove the trailing whitespaces in the selected lines or the whole buffer
vim.keymap.set(
  'n',
  '<Leader>$',
  ":<C-u>call utils#Preserve('%s/\\s\\+$//e')<CR>;",
  { silent = true }
)
vim.keymap.set(
  'x',
  '<Leader>$',
  ":<C-u>call utils#Preserve('s/\\s\\+$//e', visualmode())<CR>;",
  { silent = true }
)
-- Insert blank lines above or below the current line and preserve the cursor position
vim.keymap.set('n', '[<Space>', 'm`' .. vim.v.count .. 'O<Esc>``')
vim.keymap.set('n', ']<Space>', 'm`' .. vim.v.count .. 'o<Esc>``')
-- Time travel
vim.keymap.set('n', 'U', "<Cmd>execute 'earlier ' .. vim.v.count1 .. 'f'<CR>")
vim.keymap.set('n', '<M-r>', "<Cmd>execute 'later ' .. vim.v.count1 .. 'f'<CR>")
-- Macro
vim.keymap.set({ 'n', 'x' }, '<Leader>m', 'q')
-- Toggle the quickfix window
vim.keymap.set('n', '<BS>q', function()
  if vim.fn.getqflist({ winid = 0 }).winid ~= 0 then
    vim.cmd.cclose()
  elseif #vim.fn.getqflist() > 0 then
    vim.cmd.copen()
    vim.cmd.wincmd('p')
  end
end)
-- Toggle the location list window
vim.keymap.set('n', '<BS>l', function()
  if vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 then
    vim.cmd.lclose()
  elseif #vim.fn.getloclist(0) > 0 then
    vim.cmd.lopen()
    vim.cmd.wincmd('p')
  end
end)
-- Format the whole buffer and preserve the cursor position
vim.keymap.set('n', 'gQ', 'mzgggqG`z<Cmd>delmarks z<CR>')

--
-- Quit and close
--

vim.keymap.set({ 'n', 'x' }, 'q', '<NOP>')
vim.keymap.set('n', 'Q', '<NOP>')
vim.keymap.set('n', 'qq', '<Cmd>q<CR>')
vim.keymap.set('n', 'qa', '<Cmd>qa<CR>')
vim.keymap.set('n', 'qt', '<Cmd>tabclose<CR>')
-- close quickfix or location list window
vim.keymap.set('n', 'qc', require('rockyz.qf').close)
-- close diff windows
vim.keymap.set('n', 'qd', require('rockyz.utils').close_diff)
-- close diff windows in all tabs
vim.keymap.set('n', 'qD', [[<Cmd>tabdo lua require("rockyz.utils").close_diff()<CR>]])

--
-- Search
--

-- Search within selected range
vim.keymap.set('x', '/', '<Esc>/\\%V')
-- Clean search highlighting and update diff if needed
vim.keymap.set('n', '<Esc>', function()
  if vim.v.hlsearch then
    return ":<C-u>nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR>"
  else
    return '<Esc>'
  end
end, { expr = true, silent = true })

--
-- Replace
--
-- Replace visually selected word, or word under cursor
vim.keymap.set('x', '<Leader>rw', '"hy:%s/<C-r>h/<C-r>h/gc<Left><Left><Left>')
vim.keymap.set('n', '<Leader>rw', ':%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>')

--
-- Buffer
--

-- Delete the current buffer and switch back to the previous one
vim.keymap.set('n', '<Leader>bd', ':<C-u>bprevious <Bar> bdelete #<CR>', { silent = true })
-- Delete all the other unmodified buffers
vim.keymap.set('n', '<Leader>bo', ':call utils#BufsDel()<CR>', { silent = true })

--
-- Copy and paste
--

vim.keymap.set('n', 'Y', 'y$')
vim.keymap.set({ 'n', 'x' }, '<Leader>y', '"+y')
vim.keymap.set('n', '<Leader>Y', '"+y$')
-- Paste and format
vim.keymap.set('n', 'p', 'p=`]')
-- Paste over the selected text
vim.keymap.set('x', 'p', '_c<ESC>p')
-- Paste non-linewise text above or below current cursor and format
vim.keymap.set('n', '<Leader>p', 'm`o<Esc>p==``')
vim.keymap.set('n', '<Leader>P', 'm`O<Esc>p==``')
-- Select the last changed (or pasted) text
vim.keymap.set('n', 'gp', function()
  return '`[' .. vim.fn.strpart(vim.fn.getregtype(), 0, 1) .. '`]'
end, { expr = true })

--
-- Command line
--

vim.keymap.set('c', '<C-p>', '<Up>')
vim.keymap.set('c', '<C-n>', '<Down>')
vim.keymap.set('c', '<C-b>', '<Left>')
vim.keymap.set('c', '<C-f>', '<Right>')
vim.keymap.set('c', '<C-a>', '<Home>')
vim.keymap.set('c', '<C-e>', '<End>')
vim.keymap.set('c', '<C-d>', '<Del>')
-- Move one word left/right
vim.keymap.set('c', '<M-b>', '<S-Left>')
vim.keymap.set('c', '<M-f>', '<S-Right>')
-- Delete all characters till the beginning/end by <C-u> (defined by default) and <C-k>
vim.keymap.set('c', '<C-k>', '<C-\\>egetcmdline()[:getcmdpos() - 2]<CR>')
-- Delete the previous word
vim.keymap.set('c', '<M-BS>', '<C-w>')
-- Open the command-line window using <C-o> instead of q:
vim.o.cedit = '<C-o>'
-- Use %% to get the absolute filepath of the current buffer in command-line
-- mode
vim.keymap.set('c', '%%', function()
  vim.api.nvim_feedkeys(vim.fn.expand('%:p:h') .. '/', 'c', false)
end)

--
-- Navigation
--

-- Misspelled words ([s and ]s are occupied by lsp symbol navigation)
vim.keymap.set('n', '[x', '[s')
vim.keymap.set('n', ']x', ']s')
-- Argument list
vim.keymap.set('n', '[a', ':<C-u>previous<CR>', { silent = true })
vim.keymap.set('n', ']a', ':<C-u>next<CR>', { silent = true })
vim.keymap.set('n', '[A', ':<C-u>first<CR>', { silent = true })
vim.keymap.set('n', ']A', ':<C-u>last<CR>', { silent = true })
-- Buffers
vim.keymap.set('n', '[b', ':<C-u>bprevious<CR>', { silent = true })
vim.keymap.set('n', ']b', ':<C-u>bnext<CR>', { silent = true })
vim.keymap.set('n', '<Left>', ':<C-u>bprevious<CR>', { silent = true })
vim.keymap.set('n', '<Right>', ':<C-u>bnext<CR>', { silent = true })
vim.keymap.set('n', '[B', ':<C-u>bfirst<CR>', { silent = true })
vim.keymap.set('n', ']B', ':<C-u>blast<CR>', { silent = true })
-- Quickfix
vim.keymap.set('n', '[q', ':<C-u>cprevious<CR>zv', { silent = true })
vim.keymap.set('n', ']q', ':<C-u>cnext<CR>zv', { silent = true })
vim.keymap.set('n', '[Q', ':<C-u>cfirst<CR>zv', { silent = true })
vim.keymap.set('n', ']Q', ':<C-u>clast<CR>zv', { silent = true })
-- Location List
vim.keymap.set('n', '[l', ':<C-u>lprevious<CR>zv', { silent = true })
vim.keymap.set('n', ']l', ':<C-u>lnext<CR>zv', { silent = true })
vim.keymap.set('n', '[L', ':<C-u>lfirst<CR>zv', { silent = true })
vim.keymap.set('n', ']L', ':<C-u>llast<CR>zv', { silent = true })
-- Tabs
vim.keymap.set('n', '[t', ':<C-u>tabprevious<CR>', { silent = true })
vim.keymap.set('n', ']t', ':<C-u>tabnext<CR>', { silent = true })
vim.keymap.set('n', '[T', ':<C-u>tabfirst<CR>', { silent = true })
vim.keymap.set('n', ']T', ':<C-u>tablast<CR>', { silent = true })
-- Make section-jump work if '{' or '}' are not in the first column (see :h [[)
vim.keymap.set('n', '[[', ":<C-u>eval search('{', 'b')<CR>w99[{", { silent = true })
vim.keymap.set('n', '[]', "k$][%:<C-u>silent! eval search('}', 'b')<CR>", { silent = true })
vim.keymap.set('n', ']]', "j0[[%:<C-u>silent! eval search('{')<CR>", { silent = true })
vim.keymap.set('n', '][', ":<C-u>silent! eval search('}')<CR>b99]}", { silent = true })

--
-- Tab
--

-- Open a new tab with an empty window
vim.keymap.set('n', '<Leader>tn', ':$tabnew<CR>', { silent = true })
-- Close all other tabs
vim.keymap.set('n', '<Leader>to', ':tabonly<CR>', { silent = true })
-- Move the current tab to the left or right
vim.keymap.set('n', '<Leader>t,', ':-tabmove<CR>', { silent = true })
vim.keymap.set('n', '<Leader>t.', ':+tabmove<CR>', { silent = true })

--
-- Window
--

-- Move cursor to one of the windows in four directions
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')
-- Move cursor to the window 1 to 9
for i = 1, 9, 1 do
  vim.keymap.set('n', '<Leader>' .. i, ':' .. i .. 'wincmd w<CR>')
end
-- Go to the previous window
vim.keymap.set('n', '<Leader>wp', '<C-w>p')
-- Split
vim.keymap.set('n', '<Leader>-', ':split<CR>', { silent = true })
vim.keymap.set('n', '<Leader><BS>', ':vsplit<CR>', { silent = true })
-- Move current window to new tab
vim.keymap.set('n', '<Leader>wt', '<C-w>T')
-- Duplicate the current window in a new tab
vim.keymap.set('n', '<Leader>wT', ':tab split<CR>', { silent = true })
-- Resize
vim.keymap.set('n', '<Leader><Down>', '<C-w>5-')
vim.keymap.set('n', '<Leader><Up>', '<C-w>5+')
vim.keymap.set('n', '<Leader><Left>', '<C-w>5<')
vim.keymap.set('n', '<Leader><Right>', '<C-w>5>')
-- Balance size
vim.keymap.set('n', '<Leader>w=', '<C-w>=')
-- Close windows by giving the window numbers
vim.keymap.set('n', '<Leader>wc', ':CloseWin<Space>')
-- Switch the layout (horizontal and vertical) of the TWO windows
vim.keymap.set('n', '<Leader>wl', function()
  local wins = vim.api.nvim_tabpage_list_wins(0)
  -- Filter out the floating windows
  local norm_wins = {}
  for _, win in ipairs(wins) do
    if vim.api.nvim_win_get_config(win).relative == '' then
      table.insert(norm_wins, win)
    end
  end
  if #norm_wins ~= 2 then
    print('Layout toggling only works for two windows.')
    return
  end
  -- pos is {row, col}
  local pos1 = vim.api.nvim_win_get_position(norm_wins[1])
  local pos2 = vim.api.nvim_win_get_position(norm_wins[2])
  local key_codes = ''
  if pos1[1] == pos2[1] then
    key_codes = vim.api.nvim_replace_termcodes('<C-w>t<C-w>K', true, false, true)
  else
    key_codes = vim.api.nvim_replace_termcodes('<C-w>t<C-w>H', true, false, true)
  end
  vim.api.nvim_feedkeys(key_codes, 'm', false)
end)
-- Close all other windows (not including float windows)
vim.keymap.set('n', '<Leader>wo', function()
  return vim.fn.len(vim.fn.filter(vim.api.nvim_tabpage_list_wins(0), function(_, v)
    return vim.api.nvim_win_get_config(v).relative == ''
  end)) > 1 and '<C-w>o' or ''
end, { expr = true })
-- Scroll the other window
-- 1:half-page up, 2:half-page down
function M.other_win_scroll(mode)
  vim.cmd('noautocmd silent! wincmd p')
  if mode == 1 then
    vim.cmd('exec "normal! \\<c-u>"')
  elseif mode == 2 then
    vim.cmd('exec "normal! \\<c-d>"')
  end
  vim.cmd('noautocmd silent! wincmd p')
end

vim.keymap.set('n', '<M-u>', "<Cmd>lua require('rockyz.mappings').other_win_scroll(1)<CR>")
vim.keymap.set('n', '<M-d>', "<Cmd>lua require('rockyz.mappings').other_win_scroll(2)<CR>")
vim.keymap.set('i', '<M-u>', "<C-\\><C-o><Cmd>lua require('rockyz.mappings').other_win_scroll(1)<CR>")
vim.keymap.set('i', '<M-d>', "<C-\\><C-o><Cmd>lua require('rockyz.mappings').other_win_scroll(2)<CR>")

--
-- Terminal
--

vim.keymap.set('t', '<Leader><Esc>', '<C-\\><C-n>')
-- Simulate <C-r> in insert mode for inserting the content of a register.
-- Reference: http://vimcasts.org/episodes/neovim-terminal-paste/
vim.keymap.set('t', '<M-r>', function()
  return '<C-\\><C-n>"' .. vim.fn.nr2char(vim.fn.getchar()) .. 'pi'
end, { expr = true })

return M
