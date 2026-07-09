local notify = require('rockyz.utils.notify')

--------------------------------------------------------------------------------
-- Basic mappings
--------------------------------------------------------------------------------

vim.g.mapleader = ' '

vim.keymap.set({ 'n', 'x' }, '<Leader>', '<Nop>')
vim.keymap.set('n', '<Leader>,', ',')
vim.keymap.set({ 'n', 'x' }, 'q', '<Nop>')
vim.keymap.set('n', 'q;', 'q:')
vim.keymap.set({ 'n', 'x' }, '<Leader>q', 'q')
vim.keymap.set({ 'n', 'x' }, '-', '"_')
vim.keymap.set({ 'n', 'x', 'o' }, '+', '"+')
vim.keymap.set('x', '<', '<gv')
vim.keymap.set('x', '>', '>gv')
vim.keymap.set('n', '<Leader>i', '`^')
vim.keymap.set({ 'n', 'x', 'o' }, [[']], [[`]])
vim.keymap.set({ 'n', 'x', 'o' }, [[`]], [[']])
vim.keymap.set('n', 'g:', ':lua =')
vim.keymap.set('n', 'z=', '<Cmd>setlocal spell<CR>z=')
-- Use `v_d` when visual deletion should update the unnamed register
vim.keymap.set('x', 'x', '"_d')
-- Preserve '[ and '] on :write
vim.keymap.set('n', 'z.', ':silent lockmarks update ++p<CR>')
vim.keymap.set('n', 'vK', '<C-\\><C-n><Cmd>help!<CR>')
vim.keymap.set({ 'n', 'x', 'o' }, 'H', '^')
vim.keymap.set({ 'n', 'x', 'o' }, 'L', '$')

vim.keymap.set('n', '<TAB>', 'za')
vim.keymap.set('n', '<C-i>', '<C-i>')

-- Argument list
-- Reference: https://jkrl.me/vim/2025/05/28/nvim-arglist.html

-- List files in arglist
vim.keymap.set('n', '<Leader>al', '<C-l><Cmd>args<CR>')

-- Jump to the [count]th file, or the current one without [count]
vim.keymap.set('n', '<Leader>ag', function()
    local count = vim.v.count
    local count_prefix = count > 0 and tostring(count) or ''
    return ':<C-u>' .. count_prefix .. 'argu|args<CR><Esc>'
end, { expr = true })

-- Add current file to arglist
vim.keymap.set('n', '<Leader>aa', '<Cmd>$arge %<bar>argded<bar>args<CR>')
-- Delete current file from arglist
vim.keymap.set('n', '<Leader>ad', '<Cmd>argd %<bar>args<CR>')
-- Clear arglist
vim.keymap.set('n', '<Leader>ac', '<Cmd>%argd<CR><C-l>')

vim.keymap.set('n', 'zt', function()
    local count_prefix = vim.v.count > 0 and vim.v.count or ''
    vim.cmd('normal! ' .. count_prefix .. 'zt')
end)

vim.keymap.set('n', 'zb', function()
    local count_prefix = vim.v.count > 0 and vim.v.count or ''
    vim.cmd('normal! ' .. count_prefix .. 'zb')
end)

-- Move the current line or selections up and down with corresponding indentation

-- vim.keymap.set('n', '<M-j>', ':m .+1<CR>==', { silent = true })
-- vim.keymap.set('n', '<M-k>', ':m .-2<CR>==', { silent = true })
vim.keymap.set('x', 'J', ":m '>+1<CR>gv=gv", { silent = true })
vim.keymap.set('x', 'K', ":m '<-2<CR>gv=gv", { silent = true })
-- vim.keymap.set('i', '<M-j>', '<Esc>:m .+1<CR>==a', { silent = true })
-- vim.keymap.set('i', '<M-k>', '<Esc>:m .-2<CR>==a', { silent = true })

-- Join lines but retain the cursor position
vim.keymap.set('n', 'J', 'mzJ`z')
-- Un-join (split) the current line at the cursor position
vim.keymap.set('n', 'gj', 'i<c-j><esc>k$')
-- Make dot work over each line of a visual selection
vim.keymap.set('x', '.', ':normal .<CR>', { silent = true })
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

-- Smart i: indent properly on empty line
vim.keymap.set('n', 'i', function()
    if #vim.fn.getline('.') == 0 then
        return [["_cc]]
    else
        return 'i'
    end
end, { expr = true })

-- Remove trailing whitespace in the selected lines or the whole buffer
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

-- Insert [count] blank lines above or below the current line and preserve the cursor position
vim.keymap.set('n', '[<Space>', function()
    return 'm`' .. vim.v.count1 .. 'O<Esc>``'
end, { expr = true })

vim.keymap.set('n', ']<Space>', function()
    return 'm`' .. vim.v.count1 .. 'o<Esc>``'
end, { expr = true })

-- Time travel
vim.keymap.set('n', 'U', function()
    vim.cmd('earlier ' .. vim.v.count1 .. 'f')
end)

vim.keymap.set('n', '<M-r>', function()
    vim.cmd('later ' .. vim.v.count1 .. 'f')
end)

-- Format the whole buffer and preserve the cursor position
vim.keymap.set('n', 'gQ', 'mzgggqG`z<Cmd>delmarks z<CR>')

-- Toggle spell
vim.keymap.set('n', 'yoS', function()
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

vim.keymap.set('n', '<C-c>', 'ciw')

-- From TJ
-- vim.keymap.set('n', '<Leader><Leader>x', ':source %<CR>') -- execute the current file
-- vim.keymap.set('n', '<Leader>x', ':.lua<CR>') -- execute the current line
-- vim.keymap.set('v', '<Leader>x', ':lua<CR>') -- execute the selected lines

-- Make I and A in character-wise and linewise VISUAL be v_b_I
local function visual_block_insert(lhs, rhs)
    local mode = vim.fn.mode()
    if mode == 'v' or mode == 'V' then
        return rhs
    end
    return lhs
end

vim.keymap.set('x', 'I', function()
    return visual_block_insert('I', '<C-v>^o^I')
end, { expr = true })

vim.keymap.set('x', 'A', function()
    return visual_block_insert('A', '<C-v>0o$A')
end, { expr = true })

-- Toggle a shallow fold view for quick code overview
vim.keymap.set('n', 'yoz', function()
    if vim.w.shallow_outline_enabled then
        local prev_opts = vim.w.shallow_outline_prev_opts
        vim.wo.foldmethod = prev_opts.foldmethod
        vim.wo.foldnestmax = prev_opts.foldnestmax
        vim.wo.foldlevel = prev_opts.foldlevel
        vim.cmd('1,$foldopen!')
        vim.w.shallow_outline_enabled = false
    else
        vim.w.shallow_outline_prev_opts = {
            foldmethod = vim.wo.foldmethod,
            foldnestmax = vim.wo.foldnestmax,
            foldlevel = vim.wo.foldlevel,
        }
        vim.wo.foldmethod = 'indent'
        vim.wo.foldnestmax = 2
        vim.wo.foldlevel = 0
        vim.w.shallow_outline_enabled = true
    end
end)

-- Toggle a fold view to preview search matching
-- Source: https://vim.fandom.com/wiki/Folding_with_Regular_Expression
vim.keymap.set('n', 'z/', function()
    if vim.w.preview_search_matching then
        local prev_opts = vim.w.preview_search_matching_prev_opts
        vim.wo.foldmethod = prev_opts.foldmethod
        vim.wo.foldexpr = prev_opts.foldexpr
        vim.wo.foldlevel = prev_opts.foldlevel
        vim.wo.foldcolumn = prev_opts.foldcolumn
        vim.cmd.redraw()
        vim.w.preview_search_matching = false
    else
        vim.w.preview_search_matching_prev_opts = {
            foldmethod = vim.wo.foldmethod,
            foldexpr = vim.wo.foldexpr,
            foldlevel = vim.wo.foldlevel,
            foldcolumn = vim.wo.foldcolumn,
        }
        vim.w.preview_search_matching = true
        return ':setlocal foldexpr=(getline(v:lnum)=~@/)?0:(getline(v:lnum-1)=~@/)\\|\\|(getline(v:lnum+1)=~@/)?1:2 foldmethod=expr foldlevel=0 foldcolumn=2<CR>'
    end
end, { expr = true })

-- Enhanced Ctrl-G (borrowed from justinmk/config)
local function ctrl_g()
    local chunks = {}
    local is_file = vim.fn.empty(vim.fn.expand('%:p')) == 0
    -- Show file info
    local file_info = vim.trim(vim.fn.execute('norm! 2' .. vim.keycode('<C-g>')))
    local modified_time = is_file and vim.fn.strftime('%Y-%m-%d %H:%M', vim.fn.getftime(vim.fn.expand('%:p'))) or ''
    table.insert(chunks, { ('%s  %s\n'):format(file_info, modified_time) })
    -- Show git branch
    local git_ref = vim.fn.exists('*FugitiveHead') and vim.fn['FugitiveHead'](7) or nil
    if git_ref then
        table.insert(chunks, { ('branch: %s\n'):format(git_ref) })
    end
    -- Show current directory
    table.insert(chunks, { ('cwd: %s\n'):format(vim.fn.fnamemodify(vim.fn.getcwd(), ':~')) })
    -- Show current session
    table.insert(chunks, { ('session: %s\n'):format(#vim.v.this_session > 0 and vim.fn.fnamemodify(vim.v.this_session, ':~') or '?') })
    -- Show process id
    table.insert(chunks, { ('PID: %s\n'):format(vim.fn.getpid()) })
    -- Show current context
    table.insert(chunks, {
        vim.fn.getline(vim.fn.search('\\v^[[:alpha:]$_]', 'bn', 1, 100)),
        'Identifier',
    })
    vim.api.nvim_echo(chunks, false, {})
end

vim.keymap.set('n', '<Leader><C-g>', ctrl_g)

-- g?: Web search
vim.keymap.set('n', 'g??', function()
    vim.ui.open(('https://google.com/search?q=%s'):format(vim.fn.expand('<cword>')))
end)

vim.keymap.set('x', 'g??', function()
    local region = vim.fn.getregion(
        vim.fn.getpos('.'),
        vim.fn.getpos('v'),
        { type = vim.fn.mode() }
    )
    vim.ui.open(('https://google.com/search?q=%s'):format(vim.trim(table.concat(region, ' '))))
    vim.api.nvim_input('<esc>')
end)

-- Enhanced ga
-- Copied from @mfussenegger's config
local function format_bytesize(n, multiplier)
    if n > multiplier ^ 3 then
        n = n / (multiplier ^ 3)
        return n, 'G'
    end
    if n > multiplier ^ 2 then
        n = n / (multiplier ^ 2)
        return n, 'M'
    end
    if n > multiplier then
        n = n / multiplier
        return n, 'K'
    end
    return n, ''
end

vim.keymap.set('n', 'ga', function()
    local cword = vim.fn.expand('<cword>')
    local num = tonumber(cword:match('[^%d]*(%d+)[^%d]*'))
    if num then
        local n1024, unit1024 = format_bytesize(num, 1024)
        local n1000, unit1000 = format_bytesize(num, 1000)
        local bytesize_info = num > 1024
            and string.format('%.2f %siB   %.2f %sB', n1024, unit1024, n1000, unit1000)
            or ''
        local timestamp = num > 253402300800 -- unix timestamp in seconds for 9999-12-31
            and num / 1000.0
            or num
        local char = num < 128
            and string.format('char=%c', num)
            or ''
        vim.print(string.format(
            '%s %s 0x%02x   o%o   %s   %s',
            cword,
            char,
            num,
            num,
            os.date('%Y-%m-%d %H:%M', timestamp),
            bytesize_info
        ))
    else
        vim.cmd.ascii()
    end
end)

-- Insert on-the-fly snippet (expand snippet stored in register s)
-- Uncomment this after discarding LuaSnip
-- vim.keymap.set('i', '<C-r>s', function()
--     local snippet = vim.fn.getreg 's'
--     vim.snippet.expand(snippet)
-- end)

--------------------------------------------------------------------------------
-- Quickfix
--------------------------------------------------------------------------------

-- Toggle quickfix window
vim.keymap.set('n', 'yoq', function()
    if vim.fn.getqflist({ winid = 0 }).winid ~= 0 then
        vim.cmd.cclose()
    elseif #vim.fn.getqflist() > 0 then
        vim.cmd.copen()
        vim.cmd.wincmd('p')
    end
end)

-- Toggle location list window
vim.keymap.set('n', 'yol', function()
    if vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 then
        vim.cmd.lclose()
    elseif #vim.fn.getloclist(0) > 0 then
        vim.cmd.lopen()
        vim.cmd.wincmd('p')
    end
end)

-- Toggle between quickfix and location list
vim.cmd([[
nnoremap <silent><expr> <M-q> '@_:'.(&bt!=#'quickfix'<bar><bar>!empty(getloclist(0))?'lclose<bar>botright copen':'cclose<bar>botright lopen')
    \.(v:count ? '<bar>wincmd L' : '').'<CR>'
]])

--------------------------------------------------------------------------------
-- Quit/Close
--------------------------------------------------------------------------------

-- Diff windows
vim.keymap.set('n', 'qd', require('rockyz.utils.win').close_diff)
-- Diff windows in all tabs
vim.keymap.set('n', 'qD', [[<Cmd>tabdo lua require("rockyz.utils.win").close_diff()<CR>]])
-- Current tab
vim.keymap.set('n', 'qt', '<Cmd>tabclose<CR>')
-- Current window
vim.keymap.set('n', 'qw', '<Cmd>q<CR>')

--------------------------------------------------------------------------------
-- Search
--------------------------------------------------------------------------------

local function is_search_cmd()
    local cmdtype = vim.fn.getcmdtype()
    return cmdtype == '/' or cmdtype == '?'
end

-- Mark position before search
vim.keymap.set('n', '/', 'ms/')
vim.keymap.set('n', '?', 'ms?')

-- Use <C-l> to:
--   - redraw
--   - clear 'hlsearch'
--   - clearmatches()
--   - :diffupdate
--   - :syncbind
-- Use {count}<C-l> to also:
--   - clear all extmark namespaces
vim.keymap.set('n', '<C-l>', function()
    if vim.v.count > 0 then
        vim.fn.clearmatches()
        vim.api.nvim_buf_clear_namespace(0, -1, 0, -1)
    end
    vim.cmd('nohlsearch')
    vim.cmd('diffupdate')
    vim.cmd('syncbind')
    require('rockyz.scrollbar').clear_search()
    vim.cmd('normal! <C-l>')
end, { silent = true })

-- //: Search within VISUAL selection
vim.keymap.set('c', '/', function()
    if is_search_cmd() and vim.fn.getcmdline() == '' then
        return '<C-c><Esc>/\\%V'
    else
        return '/'
    end
end, { expr = true })

-- /<BS>: Inverse search (lines NOT containing pattern)
vim.keymap.set('c', '<BS>', function()
    if is_search_cmd() and vim.fn.getcmdline() == '' then
        return '\\v^(()@!.)*$<Left><Left><Left><Left><Left><Left><Left>'
    else
        return '<BS>'
    end
end, { expr = true })

-- Hit <Space> to match multiline whitespace
-- vim.keymap.set('c', '<Space>', function()
--     return is_search_cmd() and '\\_s\\+' or '<Space>'
-- end, { expr = true, remap = true }) -- Without remap, <Space> won't trigger abbreviations

--------------------------------------------------------------------------------
-- Substitute
--------------------------------------------------------------------------------

vim.keymap.set('n', 'gs', [[:let @/='\<'.expand('<cword>').'\>'<CR>cgn]])
vim.keymap.set('x', 'gs', [["sy:let @/=@s<CR>cgn]])

-- Replace the visually selected text, or the word under cursor
vim.keymap.set('x', '<Leader>s*', '"hy:%s/<C-r>h/<C-r>h/gc<Left><Left><Left>')
vim.keymap.set('n', '<Leader>s*', ':%s/\\<<C-r><C-w>\\>//gI<Left><Left><Left>')

-- Run :substitute inside VISUAL area with [g] flag on
vim.keymap.set('x', '<Leader>s/', function()
    local original_gdefault = vim.o.gdefault
    vim.o.gdefault = true

    vim.api.nvim_create_autocmd('CmdlineLeave', {
        group = vim.api.nvim_create_augroup('rockyz.keymap.reset_gdefault', { clear = true }),
        once = true,
        callback = vim.schedule_wrap(function()
            vim.o.gdefault = original_gdefault
        end),
    })

    return '<Esc>gv:s/\\%V'
end, { silent = false, expr = true })

-- Map ":'<,'>s/" to ":'<,'>s/\%V" (from @justinmk)
local function visual_sub()
    local skip = false
    local visual_sub_augroup = vim.api.nvim_create_augroup('rockyz.keymap.visual_sub', { clear = true })

    local function map_visual_sub()
        local cmd = vim.fn.getcmdline()
        local ok, parsed_cmd = pcall(vim.api.nvim_parse_cmd, cmd, {})
        if ok and parsed_cmd.cmd == 'substitute' and cmd:match("'<,'>s[^u ]") then
            skip = true
            vim.fn.setcmdline(cmd .. [[\%V]])
        end
    end

    vim.api.nvim_create_autocmd('CmdlineEnter', {
        group = visual_sub_augroup,
        callback = function()
            skip = false
        end,
    })

    vim.api.nvim_create_autocmd('CmdlineChanged', {
        group = visual_sub_augroup,
        callback = function()
            if not skip then
                map_visual_sub()
            end
        end,
    })
end
visual_sub()

-- Replace operator (inspired by @justinmk)
local replace_reg = '"'

local function set_replace_reg(reg_name)
    replace_reg = reg_name
end

function _G.rockyz_replace_without_yank(type)
    -- Save register contents and type so temporary edits can be restored
    local original_reg = vim.fn.getreg(replace_reg, 1)
    local original_regtype = vim.fn.getregtype(replace_reg)
    local original_selection = vim.o.selection

    vim.o.selection = 'inclusive'

    local ok, err = pcall(function()
        local replace_curlin = vim.fn.col("'[") == 1
            and (vim.fn.col('$') == 1 or vim.fn.col('$') == vim.fn.col("']") + 1)
            and vim.fn.line("'[") == vim.fn.line("']")

        if type == 'line' and replace_curlin then
            vim.cmd("keepjumps normal! '[V']\"" .. replace_reg .. 'P')
        elseif type == 'block' then
            vim.cmd("keepjumps normal! `[\\<C-V>`]\"" .. replace_reg .. 'P')
        else
            -- DWIM: if pasting linewise contents in a _characterwise_ motion, trim surrounding
            -- whitespace from the content to be pasted.
            if original_regtype == 'V' then
                vim.fn.setreg(replace_reg, vim.trim(original_reg), 'v')
            end
            vim.cmd("keepjumps normal! `[v`]\"" .. replace_reg .. 'P')
        end
    end)

    vim.o.selection = original_selection
    vim.fn.setreg(replace_reg, original_reg, original_regtype)

    if not ok then
        error(err, 0)
    end
end

vim.keymap.set('n', 'dr', function()
    set_replace_reg(vim.v.register)
    vim.o.opfunc = 'v:lua.rockyz_replace_without_yank'
    vim.api.nvim_feedkeys('g@', 'n', true)
end)

vim.keymap.set('n', 'drr', function()
    set_replace_reg(vim.v.register)
    vim.cmd('normal! 0')
    vim.o.opfunc = 'v:lua.rockyz_replace_without_yank'
    vim.api.nvim_feedkeys('g@$', 'n', true)
end)

--------------------------------------------------------------------------------
-- Buffer
--------------------------------------------------------------------------------

-- Switch to the alternate buffer or the first available file in MRU list
vim.keymap.set('n', '<BS>', require('rockyz.utils.buf').switch_last_buf)
-- Delete the current buffer and switch back to the previous one
vim.keymap.set('n', '<Leader>bd', require('rockyz.utils.buf').bufdelete)
-- Delete all the other unmodified buffers
vim.keymap.set('n', '<Leader>bo', require('rockyz.utils.buf').bufdelete_other)

--------------------------------------------------------------------------------
-- Copy and paste
--------------------------------------------------------------------------------

-- Keep cursor position when yanking
vim.keymap.set('n', 'y', function()
    require('rockyz.yank').save_win_view()
    return 'y'
end, { expr = true })

vim.keymap.set('n', '<Leader>y', function()
    require('rockyz.yank').save_win_view()
    return '"+y'
end, { expr = true })
vim.keymap.set('x', '<Leader>y', '"+y')
vim.keymap.set('n', '<Leader>Y', '"+y$')

-- Copy the entire buffer to system clipboard
vim.keymap.set('n', 'yY', function()
    require('rockyz.yank').save_win_view()
    vim.cmd('keepjumps keepmarks norm ggVG"+y')
end)

-- Paste and format
vim.keymap.set('n', 'p', 'p=`]')
vim.keymap.set('n', 'P', 'P=`]')

-- Paste over the selected text
vim.keymap.set('x', 'p', '"_c<ESC>p')

vim.keymap.set('n', '<Leader>p', function()
    require('rockyz.utils.misc').putline(vim.v.count1 .. ']p')
end)
vim.keymap.set('n', '<Leader>P', function()
    require('rockyz.utils.misc').putline(vim.v.count1 .. '[p')
end)

-- Select the last changed (or pasted) text
vim.keymap.set('n', 'gp', function()
    return '`[' .. vim.fn.strpart(vim.fn.getregtype(vim.v.register), 0, 1) .. '`]'
end, { expr = true })

-- Copy unnamed (") register to system (+) register
vim.keymap.set('n', 'yc', function()
    vim.fn.setreg('+', vim.fn.getreg('"'))
    notify.info('Copied " to +')
end)

-- Copy current file's name, dir and path
local function yank_to_reg(reg, text)
    vim.fn.setreg(reg, text)
    notify.info(string.format('%s is yanked to %s', text, reg))
end
-- Name
vim.keymap.set('n', 'yn', function()
    yank_to_reg(vim.v.register, vim.fn.expand('%:p:t'))
end)
-- Directory
vim.keymap.set('n', 'y/', function()
    yank_to_reg(vim.v.register, vim.fn.expand('%:.:h'))
end)
-- Relative path
vim.keymap.set('n', 'yp', function()
    yank_to_reg(vim.v.register, vim.fn.expand('%:.'))
end)
-- Absolute path
vim.keymap.set('n', 'yP', function()
    yank_to_reg(vim.v.register, vim.api.nvim_buf_get_name(0))
end)

--------------------------------------------------------------------------------
-- Command line
--------------------------------------------------------------------------------

vim.keymap.set('c', '<C-p>', '<Up>')
vim.keymap.set('c', '<C-n>', '<Down>')
vim.keymap.set('c', '<C-b>', '<Left>')
vim.keymap.set('c', '<C-f>', '<Right>')
vim.keymap.set('c', '<C-a>', '<Home>')
vim.keymap.set('c', '<C-e>', '<End>')
vim.keymap.set('c', '<C-d>', '<Del>')
-- Move one word left or right
vim.keymap.set('c', '<M-b>', '<S-Left>')
vim.keymap.set('c', '<M-f>', '<S-Right>')
-- Delete text to the beginning or end with <C-u> (defined by default) and <C-k>
vim.keymap.set('c', '<C-k>', '<C-\\>egetcmdline()[:getcmdpos() - 2]<CR>')
-- Delete the previous word
vim.keymap.set('c', '<M-BS>', '<C-w>')
vim.o.cedit = '<C-o>'

-- Insert current file directory
vim.keymap.set({ 'c', 'i' }, '<M-/>', '<C-r>=expand("%:.:h", 1)<CR>')
-- Insert filename tail
vim.keymap.set({ 'c', 'i' }, '<M-n>', '<C-r>=fnamemodify(@%, ":t")<CR>')

-- Insert last search pattern
vim.keymap.set({ 'c', 'i' }, '<C-r>?', '<C-r>=substitute(getreg("/"), "[<>\\]", "", "g")<CR>')

--------------------------------------------------------------------------------
-- Navigation (vim-unimpaired style)
--------------------------------------------------------------------------------

---Execute a command and print errors without a stacktrace
---@param opts table Arguments to vim.api.nvim_cmd()
local function nav_cmd(opts)
    local ok, err = pcall(vim.api.nvim_cmd, opts, {})
    if not ok then
        vim.api.nvim_echo({ { err:sub(#'Vim:' + 1) } }, true, { err = true })
    end
end

-- TODO: count does not work with some commands such as :next and :tprevious. See #30641

-- Argument list

-- Make arglist navigation support wrapping
local function nav_arglist(count)
    local arg_count = vim.fn.argc()
    if arg_count == 0 then
        return
    end
    local next_arg = (vim.fn.argidx() + count) % arg_count
    if next_arg < 0 then
        next_arg = next_arg + arg_count
    end
    vim.cmd((math.floor(next_arg + 1)) .. 'argu')
end

vim.keymap.set('n', '[a', function()
    nav_arglist(vim.v.count1 * -1)
    vim.cmd('args')
end)
vim.keymap.set('n', ']a', function()
    nav_arglist(vim.v.count1)
    vim.cmd('args')
end)
vim.keymap.set('n', '[A', function()
    vim.cmd('first')
    vim.cmd('args')
end)
vim.keymap.set('n', ']A', function()
    vim.cmd('last')
    vim.cmd('args')
end)

-- Buffers
vim.keymap.set('n', '[b', function()
    nav_cmd({ cmd = 'bprevious', count = vim.v.count1 })
end)
vim.keymap.set('n', ']b', function()
    nav_cmd({ cmd = 'bnext', count = vim.v.count1 })
end)
vim.keymap.set('n', '[B', function()
    if vim.v.count ~= 0 then
        nav_cmd({ cmd = 'buffer', count = vim.v.count })
    else
        nav_cmd({ cmd = 'bfirst' })
    end
end)
vim.keymap.set('n', ']B', function()
    if vim.v.count ~= 0 then
        nav_cmd({ cmd = 'buffer', count = vim.v.count })
    else
        nav_cmd({ cmd = 'blast' })
    end
end)

-- Quickfix
vim.keymap.set('n', '[q', function()
    nav_cmd({ cmd = 'cprevious', count = vim.v.count1 })
end)
vim.keymap.set('n', ']q', function()
    nav_cmd({ cmd = 'cnext', count = vim.v.count1 })
end)
vim.keymap.set('n', '[Q', function()
    nav_cmd({ cmd = 'cfirst', count = vim.v.count ~= 0 and vim.v.count or nil })
end)
vim.keymap.set('n', ']Q', function()
    nav_cmd({ cmd = 'clast', count = vim.v.count ~= 0 and vim.v.count or nil })
end)
vim.keymap.set('n', '[<C-q>', function()
    nav_cmd({ cmd = 'cpfile', count = vim.v.count1 })
end)
vim.keymap.set('n', ']<C-q>', function()
    nav_cmd({ cmd = 'cnfile', count = vim.v.count1 })
end)

-- Location list
vim.keymap.set('n', '[l', function()
    nav_cmd({ cmd = 'lprevious', count = vim.v.count1 })
end)
vim.keymap.set('n', ']l', function()
    nav_cmd({ cmd = 'lnext', count = vim.v.count1 })
end)
vim.keymap.set('n', '[L', function()
    nav_cmd({ cmd = 'lfirst', count = vim.v.count ~= 0 and vim.v.count or nil })
end)
vim.keymap.set('n', ']L', function()
    nav_cmd({ cmd = 'llast', count = vim.v.count ~= 0 and vim.v.count or nil })
end)
vim.keymap.set('n', '[<C-l>', function()
    nav_cmd({ cmd = 'lpfile', count = vim.v.count1 })
end)
vim.keymap.set('n', ']<C-l>', function()
    nav_cmd({ cmd = 'lnfile', count = vim.v.count1 })
end)

-- Tags
vim.keymap.set('n', '[t', function()
    nav_cmd({ cmd = 'tprevious', range = { vim.v.count1 } })
end)
vim.keymap.set('n', ']t', function()
    nav_cmd({ cmd = 'tnext', range = { vim.v.count1 } })
end)
vim.keymap.set('n', '[T', function()
    nav_cmd({ cmd = 'tfirst', range = vim.v.count ~= 0 and { vim.v.count } or nil })
end)
vim.keymap.set('n', ']T', function()
    if vim.v.count ~= 0 then
        nav_cmd({ cmd = 'tfirst', range = { vim.v.count } })
    else
        nav_cmd({ cmd = 'tlast' })
    end
end)
vim.keymap.set('n', '[<C-t>', function()
    nav_cmd({ cmd = 'ptprevious', range = { vim.v.count1 } })
end)
vim.keymap.set('n', ']<C-t>', function()
    nav_cmd({ cmd = 'ptnext', range = { vim.v.count1 } })
end)
-- Make section-jump work if '{' or '}' are not in the first column (see :h [[)
vim.keymap.set('n', '[[', ":<C-u>eval search('{', 'b')<CR>w99[{", { silent = true })
vim.keymap.set('n', '[]', "k$][%:<C-u>silent! eval search('}', 'b')<CR>", { silent = true })
vim.keymap.set('n', ']]', "j0[[%:<C-u>silent! eval search('{')<CR>", { silent = true })
vim.keymap.set('n', '][', ":<C-u>silent! eval search('}')<CR>b99]}", { silent = true })

-- Tab navigation
vim.keymap.set('n', '<M-[>', function()
    nav_cmd({ cmd = 'tabprevious', range = { vim.v.count1 } })
end)
vim.keymap.set('n', '<M-]>', function()
    vim.cmd('+' .. vim.v.count1 .. 'tabnext')
end)

--------------------------------------------------------------------------------
-- Tab
--------------------------------------------------------------------------------

-- Open a new tab with an empty window
vim.keymap.set('n', '<Leader>tn', '<Cmd>$tabnew<CR>')
-- Close the current tab
vim.keymap.set('n', '<Leader>tq', '<Cmd>tabclose<CR>')
-- Close all other tabs
vim.keymap.set('n', '<Leader>to', '<Cmd>tabonly<CR>')

-- Move tab to Nth position
vim.keymap.set('n', '<M-,>', function()
    return '<Cmd>tabmove ' .. (vim.v.count ~= 0 and vim.v.count or '-1') .. '<CR>'
end, { expr = true })
vim.keymap.set('n', '<M-.>', function()
    return '<Cmd>tabmove ' .. (vim.v.count ~= 0 and vim.v.count or '+1') .. '<CR>'
end, { expr = true })

-- <M-1> ... <M-9> to switch tabpage
for i = 1, 9 do
    vim.keymap.set('n', '<M-' .. i .. '>', i .. 'gt')
end

--------------------------------------------------------------------------------
-- Window
--------------------------------------------------------------------------------

-- Move cursor to one of the windows in four directions
vim.keymap.set({ 'n', 'i', 't' }, '<M-h>', '<C-\\><C-n><C-w>h')
vim.keymap.set({ 'n', 'i', 't' }, '<M-j>', '<C-\\><C-n><C-w>j')
vim.keymap.set({ 'n', 'i', 't' }, '<M-k>', '<C-\\><C-n><C-w>k')
vim.keymap.set({ 'n', 'i', 't' }, '<M-l>', '<C-\\><C-n><C-w>l')

-- Move cursor to the window 1 to 9
for i = 1, 9 do
    vim.keymap.set('n', '<Leader>' .. i, '<Cmd>' .. i .. 'wincmd w<CR>')
end

-- Go to the previous window
-- (The builtin ctrl-w p has a bug. It considers the window that is currently invalid)
vim.keymap.set('n', '<M-BS>', function()
    require('rockyz.mru_win').goto_recent_window()
end)

-- Split (use [count] to set the width or height)
vim.keymap.set('n', '<Leader>-', require('rockyz.utils.win').split)
vim.keymap.set('n', '<Leader><BSlash>', require('rockyz.utils.win').vsplit)

-- Open current window in a new tabpage (use [count] to close the current window)
vim.keymap.set('n', '<M-t>', function()
    if vim.v.count ~= 0 then
        return '<C-w>T'
    else
        return '<Cmd>tab split<CR>'
    end
end, { expr = true })

-- Resize
vim.keymap.set('n', '<C-Down>', '<C-w>5-')
vim.keymap.set('n', '<C-Up>', '<C-w>5+')
vim.keymap.set('n', '<C-Left>', '<C-w>5<')
vim.keymap.set('n', '<C-Right>', '<C-w>5>')
vim.keymap.set('t', '<C-Down>', '<C-\\><C-n><C-w>5-i')
vim.keymap.set('t', '<C-Up>', '<C-\\><C-n><C-w>5+i')
vim.keymap.set('t', '<C-Left>', '<C-\\><C-n><C-w>5<i')
vim.keymap.set('t', '<C-Right>', '<C-\\><C-n><C-w>5>i')

-- Balance size
vim.keymap.set('n', '<Leader>w=', '<C-w>=')

-- Close windows by giving the window numbers (e.g., :CloseWin 2 3)
-- To close a single window say window #5, :5q works as well
vim.keymap.set('n', '<Leader>wq', ':CloseWin<Space>')

-- Switch the layout (horizontal and vertical) of the TWO windows
vim.keymap.set('n', '<Leader>wl', require('rockyz.utils.win').switch_layout)

-- Close all other windows (not including floating ones)
vim.keymap.set('n', '<Leader>wo', function()
    local normal_win_count = 0
    for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.api.nvim_win_get_config(winid).relative == '' then
            normal_win_count = normal_win_count + 1
        end
    end
    return normal_win_count > 1 and '<C-w>o' or ''
end, { expr = true })

-- Maximize and restore the current window
vim.keymap.set('n', 'yom', require('rockyz.utils.win').win_maximize_toggle)

--------------------------------------------------------------------------------
-- Terminal
--------------------------------------------------------------------------------

-- Simulate <C-r> in insert mode for inserting the content of a register.
-- Reference: http://vimcasts.org/episodes/neovim-terminal-paste/
vim.keymap.set('t', '<C-Space><C-r>', function()
    return '<C-\\><C-n>"' .. vim.fn.nr2char(vim.fn.getchar()) .. 'pi'
end, { expr = true })

--------------------------------------------------------------------------------
-- Vimscript mappings
--------------------------------------------------------------------------------

vim.cmd([==[

" Insert formatted datetime (from @tpope vimrc)
inoremap <silent> <C-G><C-T> <C-R>=repeat(complete(col('.'),map(["%Y-%m-%d %H:%M:%S","%a, %d %b %Y %H:%M:%S %z","%Y %b %d","%d-%b-%y","%a %b %d %T %Z %Y","%Y%m%d"],'strftime(v:val)')+[localtime()]),0)<CR>

" Change directory (from @justinmk)
nnoremap cd%  <cmd>lcd %:h<bar>pwd<cr>
nnoremap cdd  :lcd <c-r>=luaeval('vim.fs.root(vim.fn.expand("%"), ".git")')<cr><bar>pwd<cr>
nnoremap cdu   <cmd>lcd ..<bar>pwd<cr>
nnoremap cd-   <cmd>lcd -<bar>pwd<cr>

" Show the last 40 :messages
nnoremap g> :set nomore<bar>echo repeat("\n",&cmdheight)<bar>40messages<bar>set more<CR>

" Toggle between ignoring and showing all whitespace changes in diff (e.g., it's very useful in :DiffOrig if we want to check all changes without whitespace)
nnoremap \<space> :set <C-R>=(&diffopt =~# 'iwhiteall') ? 'diffopt-=iwhiteall' : 'diffopt+=iwhiteall'<CR><CR>

]==])
