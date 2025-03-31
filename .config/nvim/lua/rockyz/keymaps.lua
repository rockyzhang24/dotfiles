local notify = require('rockyz.utils.notify_utils')

vim.g.mapleader = ' '

vim.keymap.set({ 'n', 'x' }, '<Leader>', '<Nop>')
vim.keymap.set('n', '<Leader>,', ',')
vim.keymap.set({ 'n', 'x' }, 'q', '<Nop>')
vim.keymap.set('n', 'q;', 'q:')
vim.keymap.set({ 'n', 'x' }, '<Leader>q', 'q')
vim.keymap.set({ 'n', 'x' }, '-', '"_')
vim.keymap.set('x', '<', '<gv')
vim.keymap.set('x', '>', '>gv')
vim.keymap.set({ 'n', 'x' }, 'gh', '^')
vim.keymap.set({ 'n', 'x' }, 'gl', 'g_')
vim.keymap.set('n', '<BS>', '<C-^>')
vim.keymap.set('n', '<Leader>i', '`^')
vim.keymap.set({ 'n', 'x', 'o' }, [[']], [[`]])
vim.keymap.set({ 'n', 'x', 'o' }, [[`]], [[']])
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
-- Smart dd and cc: use blackhole register if we delete empty line
local function smart_del(key)
    local cmd = key .. key
    if vim.api.nvim_get_current_line():match('^%s*$') then
        return '"_' .. cmd
    else
        return cmd
    end
end
vim.keymap.set('n', 'dd', function()
    return smart_del('d')
end, { expr = true })
vim.keymap.set('n', 'cc', function()
    return smart_del('c')
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
-- Toggle the quickfix window
vim.keymap.set('n', '\\q', function()
    if vim.fn.getqflist({ winid = 0 }).winid ~= 0 then
        vim.cmd.cclose()
    elseif #vim.fn.getqflist() > 0 then
        vim.cmd.copen()
        vim.cmd.wincmd('p')
    end
end)
-- Toggle the location list window
vim.keymap.set('n', '\\l', function()
    if vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 then
        vim.cmd.lclose()
    elseif #vim.fn.getloclist(0) > 0 then
        vim.cmd.lopen()
        vim.cmd.wincmd('p')
    end
end)
-- Toggle spell
vim.keymap.set('n', '\\s', function()
    vim.wo.spell = not vim.wo.spell
end)
-- Toggle diffthis for each window in the current tab page
vim.keymap.set('n', '\\dd', function()
    if vim.wo.diff then
        vim.cmd('windo diffoff')
    else
        vim.cmd('windo diffthis')
    end
end)
-- Toggle autoformat (format-on-save)
vim.keymap.set('n', '\\f', ':ToggleAutoFormat<CR>') -- buffer-local
vim.keymap.set('n', '\\F', ':ToggleAutoFormat!<CR>') -- global

vim.keymap.set('n', '<C-c>', 'ciw')

-- From TJ
vim.keymap.set('n', '<Leader><Leader>x', '<Cmd>source %<CR>') -- execute the current file
vim.keymap.set('n', '<Leader>x', ':.lua<CR>') -- execute the current line
vim.keymap.set('v', '<Leader>x', ':lua<CR>') -- execute the selected lines

-- Insert on-the-fly snippet (expand snippet stored in register s)
-- Uncomment this after discarding LuaSnip
-- vim.keymap.set('i', '<C-r>s', function()
--     local snippet = vim.fn.getreg 's'
--     vim.snippet.expand(snippet)
-- end)

--
-- Quit/Close
--

-- Diff windows
vim.keymap.set('n', 'qd', require('rockyz.utils.win_utils').close_diff)
-- Diff windows in all tabs
vim.keymap.set('n', 'qD', [[<Cmd>tabdo lua require("rockyz.utils.win_utils").close_diff()<CR>]])
-- Current tab
vim.keymap.set('n', 'qt', '<Cmd>tabclose<CR>')
-- Current window
vim.keymap.set('n', 'qw', '<Cmd>q<CR>')

--
-- Search
--

-- Clean search highlighting and update diff if needed
vim.keymap.set('n', '<Esc>', function()
    if vim.v.hlsearch then
        return ":<C-u>nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR>"
    else
        return '<Esc>'
    end
end, { expr = true, silent = true })

-- Search inside VISUAL area
vim.keymap.set('x', '/', '<Esc>/\\%V')

--
-- Substitute
--

-- Replace the visually selected text, or the word under cursor
vim.keymap.set('x', '<Leader>rw', '"hy:%s/<C-r>h/<C-r>h/gc<Left><Left><Left>')
vim.keymap.set('n', '<Leader>rw', ':%s/\\<<C-r><C-w>\\>//gI<Left><Left><Left>')

-- Run :substitute inside VISUAL aera with [g] flag on
vim.keymap.set('x', '<Leader>rr', function()
    vim.o.gdefault = true
    vim.api.nvim_create_autocmd('CmdlineLeave', {
        group = vim.api.nvim_create_augroup('rockyz.reset_gdefault', { clear = true }),
        once = true,
        callback = vim.schedule_wrap(function()
            vim.o.gdefault = false
        end),
    })
    return '<Esc>gv:s/\\%V'
end, { silent = false, expr = true })

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

local function yank_reg(reg, text)
    vim.fn.setreg(reg, text)
    notify.info(string.format('%s is yanked to %s', text, reg))
end

vim.keymap.set('n', 'yd', function()
    yank_reg(vim.v.register, vim.fn.expand('%:p:h'))
end)
vim.keymap.set('n', 'yn', function()
    yank_reg(vim.v.register, vim.fn.expand('%:p:t'))
end)
vim.keymap.set('n', 'yp', function()
    yank_reg(vim.v.register, vim.fn.expand('%:p'))
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
-- Navigation (vim-unimpaired style)
--

---Execute a command and print errors without a stacktrace
---@param opts table Arguments to vim.api.nvim_cmd()
local function cmd(opts)
    local ok, err = pcall(vim.api.nvim_cmd, opts, {})
    if not ok then
        vim.api.nvim_echo({ { err:sub(#'Vim:' + 1) } }, true, { err = true })
    end
end

-- TODO: count doesn't work with some commands such as :next, :tprevious, etc. See #30641

-- Argument list
vim.keymap.set('n', '[a', function()
    cmd({ cmd = 'previous', count = vim.v.count1 })
end)
vim.keymap.set('n', ']a', function()
    cmd({ cmd = 'next', range = { vim.v.count1 } })
end)
vim.keymap.set('n', '[A', function()
    if vim.v.count ~= 0 then
        cmd({ cmd = 'argument', count = vim.v.count })
    else
        cmd({ cmd = 'first' })
    end
end)
vim.keymap.set('n', ']A', function()
    if vim.v.count ~= 0 then
        cmd({ cmd = 'argument', count = vim.v.count })
    else
        cmd({ cmd = 'last' })
    end
end)
-- Buffers
vim.keymap.set('n', '[b', function()
    cmd({ cmd = 'bprevious', count = vim.v.count1 })
end)
vim.keymap.set('n', ']b', function()
    cmd({ cmd = 'bnext', count = vim.v.count1 })
end)
vim.keymap.set('n', '<M-h>', function()
    cmd({ cmd = 'bprevious', count = vim.v.count1 })
end)
vim.keymap.set('n', '<M-l>', function()
    cmd({ cmd = 'bnext', count = vim.v.count1 })
end)
vim.keymap.set('n', '[B', function()
    if vim.v.count ~= 0 then
        cmd({ cmd = 'buffer', count = vim.v.count })
    else
        cmd({ cmd = 'bfirst' })
    end
end)
vim.keymap.set('n', ']B', function()
    if vim.v.count ~= 0 then
        cmd({ cmd = 'buffer', count = vim.v.count })
    else
        cmd({ cmd = 'blast' })
    end
end)
-- Quickfix
vim.keymap.set('n', '[q', function()
    cmd({ cmd = 'cprevious', count = vim.v.count1 })
end)
vim.keymap.set('n', ']q', function()
    cmd({ cmd = 'cnext', count = vim.v.count1 })
end)
vim.keymap.set('n', '<M-k>', function()
    cmd({ cmd = 'cprevious', count = vim.v.count1 })
end)
vim.keymap.set('n', '<M-j>', function()
    cmd({ cmd = 'cnext', count = vim.v.count1 })
end)
vim.keymap.set('n', '[Q', function()
    cmd({ cmd = 'cfirst', count = vim.v.count ~= 0 and vim.v.count or nil })
end)
vim.keymap.set('n', ']Q', function()
    cmd({ cmd = 'clast', count = vim.v.count ~= 0 and vim.v.count or nil })
end)
vim.keymap.set('n', '[<C-q>', function()
    cmd({ cmd = 'cpfile', count = vim.v.count1 })
end)
vim.keymap.set('n', ']<C-q>', function()
    cmd({ cmd = 'cnfile', count = vim.v.count1 })
end)
-- Location List
vim.keymap.set('n', '[l', function()
    cmd({ cmd = 'lprevious', count = vim.v.count1 })
end)
vim.keymap.set('n', ']l', function()
    cmd({ cmd = 'lnext', count = vim.v.count1 })
end)
vim.keymap.set('n', '[L', function()
    cmd({ cmd = 'lfirst', count = vim.v.count ~= 0 and vim.v.count or nil })
end)
vim.keymap.set('n', ']L', function()
    cmd({ cmd = 'llast', count = vim.v.count ~= 0 and vim.v.count or nil })
end)
vim.keymap.set('n', '[<C-l>', function()
    cmd({ cmd = 'lpfile', count = vim.v.count1 })
end)
vim.keymap.set('n', ']<C-l>', function()
    cmd({ cmd = 'lnfile', count = vim.v.count1 })
end)
-- Tags
vim.keymap.set('n', '[t', function()
    cmd({ cmd = 'tprevious', range = { vim.v.count1 } })
end)
vim.keymap.set('n', ']t', function()
    cmd({ cmd = 'tnext', range = { vim.v.count1 } })
end)
vim.keymap.set('n', '[T', function()
    cmd({ cmd = 'tfirst', range = vim.v.count ~= 0 and { vim.v.count } or nil })
end)
vim.keymap.set('n', ']T', function()
    if vim.v.count ~= 0 then
        cmd({ cmd = 'tfirst', range = { vim.v.count } })
    else
        cmd({ cmd = 'tlast' })
    end
end)
vim.keymap.set('n', '[<C-t>', function()
    cmd({ cmd = 'ptprevious', range = { vim.v.count1 } })
end)
vim.keymap.set('n', ']<C-t>', function()
    cmd({ cmd = 'ptnext', range = { vim.v.count1 } })
end)
-- Tabs
vim.keymap.set('n', '<M-[>', function()
    cmd({ cmd = 'tabprevious', range = { vim.v.count1 } })
end)
vim.keymap.set('n', '<M-]>', function()
    vim.cmd('+' .. vim.v.count1 .. 'tabnext')
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
-- Open current buffer in new tab
vim.keymap.set('n', '<C-w><C-t>', '<Cmd>tab split<CR>')

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
    vim.keymap.set('n', '<Leader>' .. i, '<Cmd>' .. i .. 'wincmd w<CR>')
end
-- Go to the previous window
-- (The builtin ctrl-w p has a bug. It considers the window that is currently invalid)
vim.keymap.set('n', '<Leader>wp', function()
    require('rockyz.utils.mru_win').goto_recent()
end)
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
vim.keymap.set('n', '\\z', require('rockyz.utils.win_utils').win_maximize_toggle)

--
-- Terminal
--

vim.keymap.set('t', '<M-\\>', '<C-\\><C-n>')
-- Simulate <C-r> in insert mode for inserting the content of a register.
-- Reference: http://vimcasts.org/episodes/neovim-terminal-paste/
vim.keymap.set('t', '<M-r>', function()
    return '<C-\\><C-n>"' .. vim.fn.nr2char(vim.fn.getchar()) .. 'pi'
end, { expr = true })
