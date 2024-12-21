local M = {}

vim.g.mapleader = ' '

vim.keymap.set({ 'n', 'x' }, '<Leader>', '<Nop>')
vim.keymap.set('n', '<Leader>,', ',')
vim.keymap.set({ 'n', 'x' }, '_', '"_')
vim.keymap.set('x', '<', '<gv')
vim.keymap.set('x', '>', '>gv')
-- Move the current line or selections up and down with corresponding indentation
-- vim.keymap.set('n', '<M-j>', ':m .+1<CR>==', { silent = true })
-- vim.keymap.set('n', '<M-k>', ':m .-2<CR>==', { silent = true })
vim.keymap.set('x', 'J', ":m '>+1<CR>gv=gv", { silent = true })
vim.keymap.set('x', 'K', ":m '<-2<CR>gv=gv", { silent = true })
vim.keymap.set('i', '<M-j>', '<Esc>:m .+1<CR>==a', { silent = true })
vim.keymap.set('i', '<M-k>', '<Esc>:m .-2<CR>==a', { silent = true })
-- Join lines but retain the cursor position
vim.keymap.set('n', 'J', 'mzJ`z')
-- Make dot work over visual line selections
vim.keymap.set('n', '.', ':normal.<CR>', { silent = true })
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
-- Format the whole buffer and preserve the cursor position
vim.keymap.set('n', 'gQ', 'mzgggqG`z<Cmd>delmarks z<CR>')
-- close diff windows
vim.keymap.set('n', 'dq', require('rockyz.utils.win_utils').close_diff)
-- close diff windows in all tabs
vim.keymap.set('n', 'dQ', [[<Cmd>tabdo lua require("rockyz.utils.win_utils").close_diff()<CR>]])
-- Toggle the quickfix window
vim.keymap.set('n', 'yoq', function()
    if vim.fn.getqflist({ winid = 0 }).winid ~= 0 then
        vim.cmd.cclose()
    elseif #vim.fn.getqflist() > 0 then
        vim.cmd.copen()
        vim.cmd.wincmd('p')
    end
end)
-- Toggle the location list window
vim.keymap.set('n', 'yol', function()
    if vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 then
        vim.cmd.lclose()
    elseif #vim.fn.getloclist(0) > 0 then
        vim.cmd.lopen()
        vim.cmd.wincmd('p')
    end
end)
-- Toggle spell
vim.keymap.set('n', 'yos', function()
    vim.wo.spell = not vim.wo.spell
end)
-- Toggle diffthis for each window in the current tab page
vim.keymap.set('n', 'yodd', function()
    if vim.wo.diff then
        vim.cmd('windo diffoff')
    else
        vim.cmd('windo diffthis')
    end
end)
-- Toggle autoformat (format-on-save)
vim.keymap.set('n', 'yof', ':ToggleAutoFormat<CR>') -- buffer-local
vim.keymap.set('n', 'yoF', ':ToggleAutoFormat!<CR>') -- global

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
-- Substitute
--
-- Substitute the visually selected text, or the word under cursor
vim.keymap.set('x', '<Leader>sw', '"hy:%s/<C-r>h/<C-r>h/gc<Left><Left><Left>')
vim.keymap.set('n', '<Leader>sw', ':%s/\\<<C-r><C-w>\\>//gI<Left><Left><Left>')

--
-- Buffer
--

-- Delete the current buffer and switch back to the previous one
vim.keymap.set('n', '<Leader>bd', require('rockyz.utils.buf_utils').bufdelete)
-- Delete all the other unmodified buffers
vim.keymap.set('n', '<Leader>bo', require('rockyz.utils.buf_utils').bufdelete_other)

--
-- Copy and paste
--

vim.keymap.set({ 'n', 'x' }, '<Leader>y', '"+y')
vim.keymap.set('n', '<Leader>Y', '"+y$')
vim.keymap.set('n', '<Leader>Y', '"+y$')
-- Paste and format
vim.keymap.set('n', 'p', 'p=`]')
vim.keymap.set('n', 'P', 'P=`]')
-- Paste over the selected text
vim.keymap.set('x', 'p', '"_c<ESC>p')
-- Paste below or above the current cursor
vim.keymap.set('n', '<Leader>p', function()
    require('rockyz.utils.misc_utils').putline(vim.v.count1 .. ']p')
end)
vim.keymap.set('n', '<Leader>P', function()
    require('rockyz.utils.misc_utils').putline(vim.v.count1 .. '[p')
end)
-- Select the last changed (or pasted) text
vim.keymap.set('n', 'gp', function()
    return '`[' .. vim.fn.strpart(vim.fn.getregtype(vim.v.register), 0, 1) .. '`]'
end, { expr = true })
-- Copy unnamed(") register to system(*) register
vim.keymap.set('n', 'yc', function()
    vim.fn.setreg('+', vim.fn.getreg('"'))
end)

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
vim.o.cedit = '<C-o>'
-- Use %% to get the absolute filepath of the current buffer in command-line
-- mode
vim.keymap.set('c', '%%', function()
    vim.api.nvim_feedkeys(vim.fn.expand('%:p:h') .. '/', 'c', false)
end)

--
-- Navigation
-- vim-unimpaired style mappings. Ref: See: https://github.com/tpope/vim-unimpaired
--

-- Argument list
vim.keymap.set('n', '[a', function()
    vim.cmd.previous({ count = vim.v.count1 })
end)
vim.keymap.set('n', ']a', function()
    vim.cmd.next({ count = vim.v.count1 })
end)
vim.keymap.set('n', '[A', function()
    if vim.v.count ~= 0 then
        vim.cmd.argument({ count = vim.v.count })
    else
        vim.cmd.first()
    end
end)
vim.keymap.set('n', ']A', function()
    if vim.v.count ~= 0 then
        vim.cmd.argument({ count = vim.v.count })
    else
        vim.cmd.last()
    end
end)
-- Buffers
vim.keymap.set('n', '[b', function()
    vim.cmd.bprevious({ count = vim.v.count1 })
end)
vim.keymap.set('n', ']b', function()
    vim.cmd.bnext({ count = vim.v.count1 })
end)
vim.keymap.set('n', '[B', function()
    if vim.v.count ~= 0 then
        vim.cmd.buffer({ count = vim.v.count })
    else
        vim.cmd.bfirst()
    end
end)
vim.keymap.set('n', ']B', function()
    if vim.v.count ~= 0 then
        vim.cmd.buffer({ count = vim.v.count })
    else
        vim.cmd.blast()
    end
end)
-- Quickfix
vim.keymap.set('n', '[q', function()
    vim.cmd.cprevious({ count = vim.v.count1 })
end)
vim.keymap.set('n', ']q', function()
    vim.cmd.cnext({ count = vim.v.count1 })
end)
vim.keymap.set('n', '[Q', function()
    if vim.v.count ~= 0 then
        vim.cmd.cc({ count = vim.v.count })
    else
        vim.cmd.cfirst()
    end
end)
vim.keymap.set('n', ']Q', function()
    if vim.v.count ~= 0 then
        vim.cmd.cc({ count = vim.v.count })
    else
        vim.cmd.clast()
    end
end)
vim.keymap.set('n', '[<C-Q>', function()
    vim.cmd.cpfile({ count = vim.v.count1 })
end)
vim.keymap.set('n', ']<C-Q>', function()
    vim.cmd.cnfile({ count = vim.v.count1 })
end)
-- Location List
vim.keymap.set('n', '[l', function()
    vim.cmd.lprevious({ count = vim.v.count1 })
end)
vim.keymap.set('n', ']l', function()
    vim.cmd.lnext({ count = vim.v.count1 })
end)
vim.keymap.set('n', '[L', function()
    if vim.v.count ~= 0 then
        vim.cmd.ll({ count = vim.v.count })
    else
        vim.cmd.lfirst()
    end
end)
vim.keymap.set('n', ']L', function()
    if vim.v.count ~= 0 then
        vim.cmd.ll({ count = vim.v.count })
    else
        vim.cmd.llast()
    end
end)
vim.keymap.set('n', '[<C-l>', function()
    vim.cmd.lpfile({ count = vim.v.count })
end)
vim.keymap.set('n', ']<C-l>', function()
    vim.cmd.lnfile({ count = vim.v.count })
end)
-- Make section-jump work if '{' or '}' are not in the first column (see :h [[)
vim.keymap.set('n', '[[', ":<C-u>eval search('{', 'b')<CR>w99[{", { silent = true })
vim.keymap.set('n', '[]', "k$][%:<C-u>silent! eval search('}', 'b')<CR>", { silent = true })
vim.keymap.set('n', ']]', "j0[[%:<C-u>silent! eval search('{')<CR>", { silent = true })
vim.keymap.set('n', '][', ":<C-u>silent! eval search('}')<CR>b99]}", { silent = true })

--
-- Tab
--

-- Open a new tab with an empty window
vim.keymap.set('n', '<Leader>tn', '<Cmd>$tabnew<CR>')
-- Close the current tab
vim.keymap.set('n', '<Leader>tq', '<Cmd>tabclose<CR>')
-- Close all other tabs
vim.keymap.set('n', '<Leader>to', '<Cmd>tabonly<CR>')
-- Move the current tab to the left or right
vim.keymap.set('n', '<Leader>t,', '<Cmd>-tabmove<CR>')
vim.keymap.set('n', '<Leader>t.', '<Cmd>+tabmove<CR>')

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
vim.keymap.set('n', '<Leader><BSlash>', ':vsplit<CR>', { silent = true })
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
vim.keymap.set('n', '<Leader>wq', ':CloseWin<Space>')
-- Switch the layout (horizontal and vertical) of the TWO windows
vim.keymap.set('n', '<Leader>wl', require('rockyz.utils.win_utils').switch_layout)
-- Close all other windows (not including floating ones)
vim.keymap.set('n', '<Leader>wo', function()
    return vim.fn.len(vim.fn.filter(vim.api.nvim_tabpage_list_wins(0), function(_, v)
        return vim.api.nvim_win_get_config(v).relative == ''
    end)) > 1 and '<C-w>o' or ''
end, { expr = true })
---Scroll the other window
---@param dir string direction, u for up and d for down
local function scroll_other_win(dir)
    vim.cmd('noautocmd silent! wincmd p')
    vim.cmd('exec "normal! \\<C-' .. dir .. '>"')
    vim.cmd('noautocmd silent! wincmd p')
end
vim.keymap.set({ 'n', 'i' }, '<M-u>', function()
    scroll_other_win('u')
end)
vim.keymap.set({ 'n', 'i' }, '<M-d>', function()
    scroll_other_win('d')
end)
-- Maximize and restore the current window
vim.keymap.set('n', 'yom', require('rockyz.utils.win_utils').win_maximize_toggle)

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
