--------------------------------------------------
-- This is the configurations for junegunn/fzf.vim
--------------------------------------------------

-- fzf#vim#with_preview()
--
-- 1. It uses the value of g:fzf_vim.preview_window to set the preview window of fzf through its
--    --preview-window option.
-- 2. It sets the --preview option of fzf to `--preview fzf.vim/bin/preview.sh {FILENAME}:{LINENO}`.
--    {FILENAME} and {LINENO} are placeholders of fzf. In this case, {FILENAME} will be the file
--    name for bat and {LINENO} the line number to be highlighted for bat's --highlight-line option.
-- 3. The placeholders in fzf's --preview option can be specified through the placeholder field in
--    the table passed to this function. This table is the spec dictionary similar to vim#wrap.
-- 4. If the placeholder is assigned to an empty string, fzf#vim#with_preview won't set --preview
--    option for fzf. The outer function calling fzf#vim#with_preview may set --preview instead
--    (e.g., fzf#vim#commits set --preview to use delta), or we can explicitly set the --preview
--    option in the `options` table in the spec dictionary (e.g., see the BCommits keymap below). If
--    --preview option is not set anywhere, the one defined in FZF_DEFAULT_OPTS will be used.
--
-- sink and sink*
-- The implementation of sink and sink* in fzf.vim handles fzf_action. If we overwrite sink or
-- sink*, we need to handle fzf_action by ourselves.

-----------------------------------
-- The support finders are as below
-----------------------------------

-- <Leader>ff : Files
-- <Leader>fo : Old files
-- <C-p>      : Git files
-- <Leader>fc : Git commits for current buffer
-- <Leader>fC : Git commits
-- <Leader>f/ : Search history
-- <Leader>f: : Command history
-- <Leader>fb : Buffers
-- <Leader>f. : Files for my dotfiles
-- <Leader>f~ : Files under $HOME
-- <Leader>ft : Tabs

-- <Leader>fq : Quickfix list items
-- <Leader>fl : Location list items
-- <Leader>fQ : Quickfix list history
-- <Leader>fL : Location list history

-- <Leader>gg : Ultimate grep (:RGU)
-- <Leader>gv : Live grep in my nvim config
-- <Leader>g* : Grep for the current word/selection
-- <Leader>gb : Live grep in current buffer

-- <Leader>ls : LSP document symbols
-- <Leader>lS : LSP workspace symbols
-- <Leader>ld : LSP definitions
-- <Leader>lr : LSP references
-- <Leader>li : LSP implementations
-- <Leader>lD : LSP declarations
-- <Leader>lt : LSP type definitions

-- <Leader>fd : document diagnostics
-- <Leader>fD : workspace diagnostics

local uv = require('luv')
local qf_utils = require('rockyz.utils.qf_utils')
local color_utils = require('rockyz.utils.color_utils')
local icons = require('rockyz.icons')

-- Use the globally set statusline
vim.api.nvim_create_autocmd('User', {
    group = vim.api.nvim_create_augroup('fzf-statusline', { clear = true }),
    pattern = 'FzfStatusLine',
    callback = function()
        vim.wo.statusline = ''
    end,
})

local rg_prefix = 'rg --column --line-number --no-heading --color=always --smart-case'
local bat_prefix = 'bat --color=always --paging=never --style=numbers'

---Color a string by ANSI color code that is converted from a highlight group
---@param str string string to be colored
---@param hl string highlight group name
---@param from_type string? which color type in the highlight group will be used, 'fg', 'bg' or 'sp'
---@param to_type string? which ANSI color type will be output, 'fg' or 'bg'
local function color_str(str, hl, from_type, to_type)
    from_type = from_type or 'fg'
    to_type = to_type or 'fg'
    local ansi = color_utils.hl2ansi(hl, from_type, to_type)
    local ansi_reset = '\x1b[m'
    return  ansi .. str .. ansi_reset
end

-- Get ANSI colored devicon for a filename
local function get_colored_devicon(filename)
    local devicon = ''
    local has_devicons, devicons = pcall(require, 'nvim-web-devicons')
    if has_devicons then
        local file_icon, file_icon_hl = devicons.get_icon(filename, vim.fn.fnamemodify(filename, ':e'), { default = true })
        devicon = color_str(file_icon, file_icon_hl)
    end
    return devicon
end

vim.g.fzf_layout = {
    window = {
        width = 0.8,
        height = 0.85,
    },
}

vim.g.fzf_action = {
    ['ctrl-x'] = 'split',
    ['ctrl-v'] = 'vsplit',
    ['ctrl-t'] = 'tab split',
}

-- The layout of the preview window. vim#fzf#with_preview must be used to make this option
-- effective.
vim.g.fzf_vim = {
    preview_window = {
        'right,60%',
        'ctrl-/',
    },
}

-- Path completion in INSERT mode
vim.keymap.set('i', '<C-x><C-f>', function()
    vim.fn['fzf#vim#complete#path'](
        'fd',
        vim.fn['fzf#wrap'](vim.fn['fzf#vim#with_preview']({
            placeholder = '',
            options = {
                '--prompt',
                'Paths> ',
            },
        }))
    )
end)

-- Files
vim.keymap.set('n', '<Leader>ff', function()
    vim.fn['fzf#vim#files'](
        '',
        vim.fn['fzf#vim#with_preview']({
            options = {
            },
        })
    )
end)

-- Old files
vim.keymap.set('n', '<Leader>fo', function()
    vim.fn['fzf#vim#history'](vim.fn['fzf#vim#with_preview']({
        options = {
            '--prompt',
            'Old Files> ',
        },
    }))
end)

-- Git files
vim.keymap.set('n', '<C-p>', function()
    vim.fn['fzf#vim#gitfiles'](
        '',
        vim.fn['fzf#vim#with_preview']({
            options = {
                '--prompt',
                'Git Files> ',
            },
        })
    )
end)

-- Git commits
vim.cmd([[
    command! -bar -bang -nargs=* -range=% GitCommits <line1>,<line2>call fzf#vim#commits(<q-args>, {
        \ "options": [
        \   "--prompt",
        \   "Commits> ",
        \   "--preview-window",
        \   "down,45%",
        \   "--header",
        \   ":: CTRL-S (toggle sort), CTRL-Y (yank commmit hashes), CTRL-D (diff)",
        \   "--bind",
        \   "focus:transform-preview-label:echo [ Diff with commit {2} ]",
        \ ]}, <bang>0)
]])
vim.keymap.set({ 'n', 'x' }, '<Leader>fC', function()
    vim.cmd('GitCommits')
end)

-- Git commits for current buffer or visual-select lines
vim.cmd([[
    command! -bar -bang -nargs=* -range=% GitBufCommits <line1>,<line2>call fzf#vim#buffer_commits(<q-args>, {
        \ "options": [
        \   "--prompt",
        \   "Buffer Commits> ",
        \   "--preview-window",
        \   "down,45%",
        \   "--header",
        \   ":: CTRL-S (toggle sort), CTRL-Y (yank commmit hashes), CTRL-D (diff)",
        \   "--bind",
        \   "focus:transform-preview-label:echo [ Diff with commit {1} ]",
        \ ]}, <bang>0)
]])
vim.keymap.set({ 'n', 'x' }, '<leader>fc', function()
    vim.cmd('GitBufCommits')
end)

-- Search history
vim.keymap.set('n', '<Leader>f/', function()
    vim.fn['fzf#vim#search_history'](vim.fn['fzf#vim#with_preview']({
        options = {
            '--prompt',
            'Search History> ',
            '--bind',
            'start:unbind(ctrl-/)',
            '--preview-window',
            'hidden',
        },
    }))
end)

-- Command history
vim.keymap.set('n', '<Leader>f:', function()
    vim.fn['fzf#vim#command_history'](vim.fn['fzf#vim#with_preview']({
        options = {
            '--prompt',
            'Command History> ',
            '--bind',
            'start:unbind(ctrl-/)',
            '--preview-window',
            'hidden',
        },
    }))
end)

-- Buffers
-- CTRL-D: delete selected buffers
vim.keymap.set('n', '<Leader>fb', function()
    vim.fn['fzf#vim#buffers']('', vim.fn['fzf#vim#with_preview']({
        ['sink*'] = function(lines)
            local key = lines[1]
            if key == 'ctrl-d' then
                -- CTRL-D to delete selected buffers
                for i = 2, #lines do
                    local bufnr = tonumber(string.match(lines[i], '%[(%d+)%]'))
                    require('rockyz.utils.buf_utils').bufdelete({ bufnr = bufnr, wipe = true })
                end
            else
                -- ENTER with only a single selection: switch to the buffer
                -- CTRL-X/V/T supports multiple selections
                if key == '' and #lines ~= 2 then
                    return
                end
                local action = vim.g.fzf_action[key]
                action = action and action .. ' | buffer ' or 'buffer '
                for i = 2, #lines do
                    local bufnr = string.match(lines[i], '%[(%d+)%]')
                    vim.cmd(action .. bufnr)
                end
            end
        end,
        placeholder = '{1}',
        options = {
            '--multi',
            '--header-lines',
            '0',
            '--prompt',
            'Buffers> ',
            '--header',
            ':: CTRL-D (delete buffers)',
            '--expect',
            'ctrl-d,ctrl-x,ctrl-v,ctrl-t',
            '--bind',
            'focus:transform-preview-label:echo [ {3..} ]',
        },
    }))
end)

-- Find files for my dotfiles
vim.keymap.set('n', '<Leader>f.', function()
    vim.fn['fzf#vim#files'](
        '',
        vim.fn['fzf#vim#with_preview']({
            source = 'ls-dotfiles',
            options = {
                '--prompt',
                'Dotfiles> ',
            },
        })
    )
end)

-- Find files under home directory
vim.keymap.set('n', '<Leader>f~', function()
    vim.fn['fzf#vim#files'](
        '~',
        vim.fn['fzf#vim#with_preview']({
            options = {
                '--prompt',
                'Home Files> ',
            },
        })
    )
end)

-- Marks
vim.keymap.set('n', '<Leader>fm', function()
    local filename = '$([[ -f {4} ]] && echo {4} || echo ' .. vim.api.nvim_buf_get_name(0) .. ')'
    vim.fn['fzf#vim#marks'](vim.fn['fzf#vim#with_preview']({
        placeholder = '',
        options = {
            '--prompt',
            'Marks> ',
            '--preview-window',
            '+{2}-/2',
            '--preview',
            bat_prefix .. ' --highlight-line {2} -- ' .. filename,
            '--bind',
            'focus:transform-preview-label:echo [ {1}:{2}:{3} ]',
        },
    }))
end)

-- Tabs
vim.keymap.set('n', '<Leader>ft', function()
    local entries = {}
    local cur_tab = vim.api.nvim_get_current_tabpage()
    for idx, tid in ipairs(vim.api.nvim_list_tabpages()) do
        local filenames = {}
        -- Store winids in each tab. They are used for closing the tab via CTRL-D.
        local winids = {}
        local cur_winid = vim.api.nvim_tabpage_get_win(tid)
        local cur_bufname
        local cur_lnum
        for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(tid)) do
            -- Only consider the normal windows and ignore the floating windows
            if vim.api.nvim_win_get_config(winid).relative == '' then
                table.insert(winids, winid)
                local bufnr = vim.api.nvim_win_get_buf(winid)
                local bufname = vim.api.nvim_buf_get_name(bufnr)
                if bufname == '' then
                    bufname = '[No Name]'
                end
                local filename = vim.fn.fnamemodify(bufname, ':t')
                -- Handle current window in each tab
                if winid == cur_winid then
                    -- Space is the default delimiter in fzf, so temporarily replacing it with a
                    -- special string such as "@@@@". When the bufname is needed in the preview
                    -- later on, replace it back.
                    cur_bufname = bufname:gsub(" ", "@@@@")
                    cur_lnum = vim.api.nvim_win_get_cursor(winid)[1]
                    -- Mark the current window in a tab by a distinct color
                    filename = color_str(filename, 'DiagnosticOk')
                end
                table.insert(filenames, filename)
            end
        end
        -- prefix is used by fzf itself for preview and sink, and it won't be presented in each
        -- entry
        local prefix = cur_bufname .. ' ' .. cur_lnum .. ' ' .. tid .. ' ' .. table.concat(winids, ',')
        local entry = prefix .. ' ' .. idx .. ': ' .. table.concat(filenames, ', ')
        -- Indicator for current tab
        if tid == cur_tab then
            entry = entry .. ' ' .. icons.caret.left
        end
        table.insert(entries, entry)
    end
    vim.fn['fzf#run'](vim.fn['fzf#wrap']({
        source = entries,
        ['sink*'] = function(lines)
            local key = lines[1]
            if key == 'ctrl-d' and #vim.api.nvim_list_tabpages() > 1 then
                -- CTRL-D: delete tabs
                for i = 2, #lines do
                    for winid in lines[i]:match('%S+%s%S+%s%S+%s(%S+)'):gmatch('[^,]+') do
                        vim.api.nvim_win_close(tonumber(winid), false)
                    end
                end
            else
                -- ENTER with single selection: select tab
                if #lines == 2 then
                    local tid = string.match(lines[2], '%S+%s%S+%s(%S+)')
                    vim.api.nvim_set_current_tabpage(tonumber(tid))
                end
            end
        end,
        options = {
            '--ansi',
            '--with-nth',
            '5..',
            '--prompt',
            'Tabs> ',
            '--header',
            ':: CTRL-D (close tabs)',
            '--expect',
            'ctrl-d',
            '--preview',
            'file=$(echo {1} | sed "s/@@@@/ /g"); [[ -f $file ]] && ' .. bat_prefix .. ' --highlight-line {2} -- $file || echo "No preview support!"',
            '--bind',
            'focus:transform-preview-label:echo [ $(echo {1} | sed "s/@@@@/ /g; s|^$HOME|~|") ]',
        },
    }))
end)

--
-- Find entries in quickfix and location list
--

-- Construct entry in qf
-- <filename> <lnum>-<end_lnum>:<col>-<end_col> [<type>] <text>
local function get_qf_entry(item)
    local entry = {}
    if item.fname ~= '' then
        table.insert(entry, color_str(item.fname, 'Directory'))
    end
    local lnum_col = item.lnum
    if item.col ~= '' then
        lnum_col = item.lnum .. ':' .. item.col
    end
    if lnum_col ~= '' then
        table.insert(entry, color_str(lnum_col, 'Number'))
    end
    local type_hl = {
        E = 'DiagnosticError',
        W = 'DiagnosticWarn',
        I = 'DiagnosticInfo',
        H = 'DiagnosticHint',
    }
    local hl = type_hl[item.type]
    if item.type ~= '' then
        local type = '[' .. item.type .. ']'
        if hl then
            type = color_str(type, hl)
        end
        table.insert(entry, type)
    end
    if item.text ~= '' then
        local text = item.text
        if hl then
            text = color_str(text, hl)
        end
        table.insert(entry, text)
    end
    return table.concat(entry, ' ')
end

---@param win_local boolean true for location list and false for quickfix
local function fzf_qf(win_local)
    local what = { items = 0, title = 0 }
    local list = win_local and vim.fn.getloclist(0, what) or vim.fn.getqflist(what)
    local entries = {}
    local index = 1
    for _, item in ipairs(list.items) do
        local bufnr = item.bufnr
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        local lnum = item.lnum
        -- The formatted entries will be fed to fzf.
        -- Each entry is like "index bufname lnum path/to/the/file:134:20 [E] error"
        -- The first three parts are used for fzf itself and won't be presented in fzf window.
        -- * index: display the error by :[nr]cc!
        -- * bufname and lnum: fzf preview
        table.insert(entries, index .. ' ' .. bufname .. ' ' .. lnum .. ' ' .. get_qf_entry(qf_utils.format_qf_item(item)))
        index = index + 1
    end
    -- fzf
    local prompt = win_local and 'Location List' or 'Quickfix List'
    vim.fn['fzf#run'](vim.fn['fzf#wrap']({
        source = entries,
        ['sink*'] = function(lines)
            local key = lines[1]
            if key == 'ctrl-q' or key == 'ctrl-l' or key == 'ctrl-r' then
                -- CTRL-Q: send to a new quickfix
                -- CTRL-L: send to a new location list
                -- CTRL-R: refine the current quickfix with selections
                local new_qf_items = {}
                for i = 2, #lines do
                    local idx = tonumber(string.match(lines[i], '^%d+'))
                    table.insert(new_qf_items, list.items[idx])
                end
                local new_what = { title = list.title, items = new_qf_items }
                if key == 'ctrl-q' then
                    vim.fn.setqflist({}, ' ', new_what)
                elseif key == 'ctrl-l' then
                    vim.fn.setloclist(0, {}, ' ', new_what)
                else
                    if win_local then
                        vim.fn.setloclist(0, {}, 'u', new_what)
                    else
                        vim.fn.setqflist({}, 'u', new_what)
                    end
                end
            elseif key == '' and #lines == 2 then
                -- ENTER with a single selection: display the error
                local nr = string.match(lines[2], '^%d+')
                vim.cmd(nr .. 'cc!')
            else
                -- ENTER/CTRL-X/CTRL-V/CTRL-T with multiple selections
                local action = vim.g.fzf_action[key]
                for i = 2, #lines do
                    if action then
                        vim.cmd(action)
                    end
                    local idx = tonumber(string.match(lines[i], '^%d+'))
                    local item = list.items[idx]
                    local bufnr = item.bufnr
                    if vim.api.nvim_buf_is_loaded(bufnr) then
                        vim.cmd('buffer! ' .. bufnr)
                    else
                        vim.cmd('edit! ' .. vim.fn.bufname(bufnr))
                    end
                    vim.api.nvim_win_set_cursor(0, { item.lnum, item.col - 1 })
                    vim.cmd('normal! zvzz')
                end
            end
        end,
        options = {
            '--ansi',
            '--prompt',
            prompt .. '> ',
            '--header',
            ':: ENTER (display the error), CTRL-R (refine the current ' .. (win_local and 'loclist' or 'quickfix') .. ')\n:: CTRL-Q (send to quickfix), CTRL-L (send to loclist)',
            '--with-nth',
            '4..',
            '--expect',
            'ctrl-x,ctrl-v,ctrl-t,ctrl-q,ctrl-l,ctrl-r',
            '--preview',
            bat_prefix .. ' --highlight-line {3} -- {2}',
            '--preview-window',
            'down,45%,+{3}-/2',
            '--bind',
            'focus:transform-preview-label:echo [ $(echo {2} | sed "s|^$HOME|~|") ]',
        },
    }))
end

-- Quickfix list
vim.keymap.set('n', '<Leader>fq', function()
    fzf_qf(false)
end)

-- Location list
vim.keymap.set('n', '<Leader>fl', function()
    fzf_qf(true)
end)

--
-- Quickfix list history and location list history
--

-- Create temp dirs to store temp files for quickfix/location list preview
local qflist_hist_dir = vim.fn.tempname()
local loclist_hist_dir = vim.fn.tempname()
uv.fs_mkdir(qflist_hist_dir, 511, function()
end)
uv.fs_mkdir(loclist_hist_dir, 511, function()
end)

-- Write contents into a file
local function write_file(filepath, contents)
    local file, _ = uv.fs_open(filepath, 'w', 438)
    uv.fs_write(file, contents, -1, function()
        uv.fs_close(file)
    end)
end

-- Show list history in fzf and support preview for each entry.
-- Dump the errors in each list into a separate temp file, and cat this file to preview the list.
---@param win_local boolean Whether it's a window-local location list or quickfix list
local function fzf_qf_history(win_local)
    local hist_dir = win_local and loclist_hist_dir or qflist_hist_dir
    local cur_nr = win_local and vim.fn.getloclist(0, { nr = 0 }).nr or vim.fn.getqflist({ nr = 0 }).nr
    local entries = {}
    local cnt = 1
    for i = 1, 10 do
        local what = { nr = i, id = 0, title = true, items = true, size = true }
        local list = win_local and vim.fn.getloclist(0, what) or vim.fn.getqflist(what)
        if list.id == 0 then
            break
        end
        -- Prepend id to each entry is to use it for the fzf's --preview option, because id serves
        -- as part of the filename of the temp file used for preview.
        -- id won't be presented in each entry in fzf (thanks to fzf's --with-nth option).
        -- Each entry presented in fzf is like: "[3] 1 items    Diagnostics".
        local entry = list.id .. ' [' .. cnt .. '] ' .. list.size .. ' items    ' .. list.title
        if list.nr == cur_nr then
            entry = entry .. ' ' .. icons.caret.left
        end
        table.insert(entries, entry)
        cnt = cnt + 1

        -- Filename of the temp file
        -- * For location list: use quickfix-id plus current winid
        -- * For quickfix list: use quickfix-id
        -- Name the file using quickfix-id because it is unique in a vim session. So each list will
        -- be associated with one specific temp file, and this allows for avoiding the need to
        -- regenerate the temp file every time.
        local hist_path = hist_dir .. '/' .. list.id
        if win_local then
            hist_path = hist_path .. '-' .. vim.api.nvim_get_current_win()
        end
        local stat, _ = uv.fs_stat(hist_path)
        if not stat then
            local errors = {}
            -- Number of entries written to the temp file for preview
            local hist_size = 100
            for j = 1, hist_size do
                local item = list.items[j]
                if item == nil then
                    break
                end
                local str = get_qf_entry(qf_utils.format_qf_item(item))
                table.insert(errors, str)
            end
            write_file(hist_path, table.concat(errors, '\n'))
        end
    end

    -- fzf
    local hist_cmd = win_local and 'lhistory' or 'chistory'
    local open_cmd = win_local and 'lopen' or 'copen'
    local prompt = win_local and 'Location List History' or 'Quickfix List History'
    local preview = 'cat ' .. hist_dir .. '/$(echo {1} | sed "s/[][]//g")'
    if win_local then
        preview = preview .. '-' .. vim.api.nvim_get_current_win()
    end
    vim.fn['fzf#run'](vim.fn['fzf#wrap']({
        source = entries,
        ['sink'] = function(line)
            local count = string.match(line, '[(%d+)]')
            vim.cmd('silent! ' .. count .. hist_cmd)
            vim.cmd(open_cmd)
        end,
        placeholder = '',
        options = {
            '--with-nth',
            '2..',
            '--no-multi',
            '--prompt',
            prompt.. '> ',
            '--header',
            ':: ENTER (switch to selected list)',
            '--preview-window',
            'down,45%',
            '--preview',
            preview,
            '--bind',
            'focus:transform-preview-label:echo [ {2..} ]',
        },
    }))
end

-- List all the quickfix lists and switch to the selected one
vim.keymap.set('n', '<Leader>fQ', function()
    fzf_qf_history(false)
end)

-- List all the location lists for the current window and switch to the selected one
vim.keymap.set('n', '<Leader>fL', function()
    fzf_qf_history(true)
end)

--
-- Config grep to be the same as my shell script frg (~/.config/fzf/fzfutils/frg). It could run rg
-- with its normal options and has two modes:
-- * RG mode (fzf will be just an interactive interface for RG) and
-- * FZF mode (fzf will be the fuzzy finder for the results of RG)
--

---Generate the fzf options for rg and fzf integration
---@param rg string The final rg command
---@param query string The initial query for rg
---@param name string The name of that keymap
---@return table
local function get_fzf_opts_for_RG(rg, query, name)
    local rg_query = vim.fn.tempname() -- tempfile to store the query in rg
    local fzf_query = vim.fn.tempname() -- tempfile to store the query in fzf
    local fzf_mode_enabled = vim.fn.tempname() -- tempfile to record whether it is currently in fzf mode
    return {
        '--ansi',
        '--disabled',
        '--query',
        query,
        '--prompt',
        name .. ' [RG]> ',
        '--bind',
        'start:reload(' .. rg .. ' ' .. vim.fn.shellescape(query) .. ')',
        '--bind',
        'change:reload:' .. rg .. ' {q} || true',
        '--bind',
        'alt-f:transform:\
        [[ ! -e ' .. fzf_mode_enabled .. ' ]] && { \
            touch ' .. fzf_mode_enabled .. '; \
            echo "unbind(change)+change-prompt(' .. name .. ' [FZF]> )+enable-search+transform-query({ echo {q} > ' .. rg_query .. '; cat ' .. fzf_query .. ' })"; \
        } || { \
            rm ' .. fzf_mode_enabled .. '; \
            echo "change-prompt(' .. name .. ' [RG]> )+disable-search+reload(' .. rg .. ' {q} || true)+rebind(change)+transform-query({ echo {q} > ' .. fzf_query .. '; cat ' .. rg_query .. ' })"\
        }',
        '--bind',
        'focus:transform-preview-label:echo [ {1}:{2}:{3} ]',
        '--delimiter',
        ':',
        '--header',
        ':: ALT-F (toggle FZF mode and RG mode)',
        '--preview-window',
        'down,45%,+{2}-/2',
        '--preview',
        bat_prefix .. ' --highlight-line {2} -- {1}',
    }
end

-- Define a new command :RGU (U for Ultimate) that supports rg options and two modes
vim.api.nvim_create_user_command('RGU', function(opts)
    local extra_flags = {}
    local query = ''
    for _, arg in ipairs(opts.fargs) do
        if arg:match('^-') ~= nil then
            table.insert(extra_flags, arg)
        else
            query = arg
        end
    end
    local rg = rg_prefix .. ' ' .. table.concat(extra_flags, ' ') .. ' -- '
    vim.fn['fzf#vim#grep2'](
        rg,
        query,
        {
            options = get_fzf_opts_for_RG(rg, query, 'RGU'),
        }
    )
end, { bang = true, nargs = '*' })
vim.keymap.set('n', '<Leader>gg', ':RGU ')

-- Live grep in nvim config
vim.keymap.set('n', '<Leader>gv', function()
    local rg = rg_prefix .. ' --glob=!minpac -- '
    local query = ''
    vim.fn['fzf#vim#grep2'](
        rg,
        query,
        {
            dir = '~/.config/nvim',
            options = get_fzf_opts_for_RG(rg, query, 'Nvim Config'),
        }
    )
end)

-- Grep for the current word (normal mode) or the current selection (visual mode)
vim.keymap.set({ 'n', 'x' }, '<Leader>g*', function()
    local query
    local header
    if vim.fn.mode() == 'v' then
        local saved_reg = vim.fn.getreg('v')
        vim.cmd([[noautocmd sil norm "vy]])
        query = vim.fn.getreg('v')
        vim.fn.setreg('v', saved_reg)
    else
        query = vim.fn.expand('<cword>')
    end
    header = query
    query = vim.fn.escape(query, '.*+?()[]{}\\|^$')
    local rg = rg_prefix .. ' -- ' .. vim.fn['fzf#shellescape'](query)
    vim.fn['fzf#vim#grep'](
        rg,
        {
            options = {
                '--prompt',
                'Word [Rg]> ',
                '--preview-window',
                'down,45%,+{2}-/2',
                '--preview',
                bat_prefix .. ' --highlight-line {2} -- {1}',
                -- Show the current query in header. Set its style to bold, red foreground via ANSI
                -- color code.
                '--header',
                ':: Query: ' .. color_str(header, 'RipgrepQuery'),
                '--bind',
                'focus:transform-preview-label:echo [ {1}:{2}:{3} ]',
            },
        }
    )
end)

-- Live grep in current buffer
vim.keymap.set('n', '<Leader>gb', function()
    local rg = rg_prefix .. ' --with-filename --'
    local initial_query = ''
    local filename = vim.api.nvim_buf_get_name(0)
    if #filename == 0 or not vim.uv.fs_stat(filename) then
        print("Live grep in current buffer requires a valid buffer!")
        return
    end
    vim.fn['fzf#vim#grep2'](rg, initial_query, {
        options = {
            '--ansi',
            '--query',
            initial_query,
            '--with-nth',
            '2..',
            '--prompt',
            'Buffer [Rg]> ',
            '--bind',
            'start:reload(' .. rg .. " '' " .. filename .. ')',
            '--bind',
            'change:reload:' .. rg .. ' {q} ' .. filename .. '|| true',
            '--bind',
            'focus:transform-preview-label:echo [ {1}:{2}:{3} ]',
            '--preview-window',
            'down,45%,+{2}-/2',
            '--preview',
            bat_prefix .. ' --highlight-line {2} -- {1}',
            '--header',
            ':: Current buffer: ' .. vim.fn.expand('%:~:.'),
        },
    })
end)

--
-- LSP
--
-- Each fzf entry consists of 5 parts: index, filename, lnum, col, fzf_text.
--
-- Only fzf_text will be displayed in fzf. Other parts are used in running fzf such as fzf preview,
-- setting border label, sending selections to quickfix and etc.
--
-- The `index` represents the position of the current entry among all entries. The order of all fzf
-- entries is consistent with the order of all quickfix items. When selecting certain entries in fzf
-- and wanting to send them to quickfix, their corresponding quickfix items can be retrieved using
-- their indices.
--

--
-- LSP document symbols and workspace symbols
--

-- Convert symbols to fzf entries and quickfix items
-- Reference: the source code of vim.lsp.util.symbols_to_items
-- (https://github.com/neovim/neovim/blob/master/runtime/lua/vim/lsp/util.lua)
local function symbols_to_entries_and_items(symbols, ctx, bufnr, offset_encoding, child_prefix, all_entries, all_items)
    for _, symbol in ipairs(symbols) do
        local kind = vim.lsp.protocol.SymbolKind[symbol.kind] or 'Unknown'
        local icon = icons.symbol_kinds[kind]
        local colored_icon_kind = color_str(icon .. kind, 'SymbolKind' .. kind)
        local client_name = '[' .. vim.lsp.get_client_by_id(ctx.client_id).name .. ']'
        local colored_client_name = color_str(client_name, 'Comment')
        if symbol.location then
            --
            -- LSP's WorkspaceSymbol[]
            --
            -- Get quickfix item. vim.lsp.util.locations_to_items will handle the conversion from
            -- utf-32 or utf-16 index to utf-8 index internally.
            local item = vim.lsp.util.locations_to_items({ symbol.location }, offset_encoding)[1]
            item.text = '[' .. icon .. kind .. '] ' .. symbol.name .. ' ' .. client_name
            table.insert(all_items, item)
            -- Construct fzf entries
            local filename = item.filename
            local lnum = item.lnum
            local col = item.col
            local devicon = get_colored_devicon(filename)
            local fzf_text = '[' .. colored_icon_kind .. '] ' .. symbol.name
                .. ' ' .. colored_client_name
                .. string.rep(' ', 6)
                .. (devicon == '' and devicon or devicon .. ' ')
                .. color_str(vim.fn.fnamemodify(filename, ':~:.'), 'RipgrepFilename')
                .. ':' .. color_str(tostring(lnum), 'RipgrepLineNum')
                .. ':' .. color_str(tostring(col), 'RipgrepColNum')
            table.insert(all_entries, table.concat({
                #all_entries + 1,
                filename,
                lnum,
                col,
                fzf_text,
            }, ' '))
        elseif symbol.selectionRange then
            --
            -- LSP's DocumentSymbol[]
            --
            local filename = vim.api.nvim_buf_get_name(bufnr)
            local start_pos = symbol.selectionRange.start
            local end_pos = symbol.selectionRange['end']
            local lnum = start_pos.line + 1
            local line = vim.api.nvim_buf_get_lines(0, start_pos.line, start_pos.line + 1, false)[1]
            local col = vim.str_byteindex(line, offset_encoding, start_pos.character, false) + 1
            local end_lnum = end_pos.line + 1
            local end_line = vim.api.nvim_buf_get_lines(0, end_pos.line, end_pos.line + 1, false)[1]
            local end_col = vim.str_byteindex(end_line, offset_encoding, end_pos.character, false) + 1
            local text = '[' .. icon .. kind .. '] ' .. symbol.name .. ' ' .. client_name
            -- Use two whitespaces for each level of indentation to show the hierarchical structure
            local fzf_text = child_prefix .. '[' .. colored_icon_kind .. '] ' .. symbol.name .. ' ' .. colored_client_name
            -- Fzf entries
            table.insert(all_entries, table.concat({
                #all_entries + 1,
                filename,
                lnum,
                col,
                fzf_text,
            }, ' '))
            -- Quickfix items
            table.insert(all_items, {
                filename = filename,
                lnum = lnum,
                end_lnum = end_lnum,
                col = col,
                end_col = end_col,
                text = text
            })
            if symbol.children then
                symbols_to_entries_and_items(symbol.children, ctx, bufnr, offset_encoding, child_prefix .. string.rep(' ', 2), all_entries, all_items)
            end
        end
    end
end

---Send request document symbols or workspace symbols and then execute fzf
---@param title string The title for quickfix list and fzf prompt
---@param query string The query for requesting workspace symbols. It will be empty for document
---symbol request
local function request_symbols_and_fzf_exec(method, params, title, query)
    local bufnr = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients({ method = method, bufnr = bufnr })
    if not next(clients) then
        vim.notify(string.format('No active clients supporting %s method', method), vim.log.levels.WARN)
        return
    end
    local remaining = #clients
    local all_entries = {}
    local all_items = {}

    local function fzf_exec(offset_encoding)
        local fzf_header = ':: CTRL-Q (send to quickfix), CTRL-L (send to loclist)'
        local fzf_preview_window = '+{3}-/2'
        if query ~= '' then
            fzf_header = ':: Query: ' .. color_str(query, 'RipgrepQuery') .. '\n' .. fzf_header
            fzf_preview_window = 'down,45%,' .. fzf_preview_window
        end
        vim.fn['fzf#run'](vim.fn['fzf#wrap']({
            source = all_entries,
            ['sink*'] = function(lines)
                local key = lines[1]
                if key == 'ctrl-q' or key == 'ctrl-l' then
                    -- CTRL-Q: send to quickfix; CTRL-L: send to location list
                    local loclist = key == 'ctrl-l'
                    local qf_items = {}
                    for i = 2, #lines do
                        local idx = tonumber(lines[i]:match('^%S+'))
                        table.insert(qf_items, all_items[idx])
                    end
                    if loclist then
                        vim.fn.setloclist(0, {}, ' ', { title = title, items = qf_items })
                        vim.cmd('botright lopen')
                    else
                        vim.fn.setqflist({}, ' ', { title = title, items = qf_items })
                        vim.cmd('botright copen')
                    end
                else
                    -- ENTER/CTRL-X/CTRL-V/CTRL-T with multiple selections
                    local action = vim.g.fzf_action[key]
                    for i = 2, #lines do
                        if action then
                            vim.cmd(action)
                        end
                        local idx = tonumber(lines[i]:match('^%S+'))
                        local item = all_items[idx]
                        if query ~= '' then
                            -- For workspace symbol
                            vim.lsp.util.show_document(item.user_data, offset_encoding)
                        else
                            -- For document symbol
                            vim.cmd("normal! m'") -- save position to jumplist
                            vim.api.nvim_win_set_cursor(0, { item.lnum, item.col - 1 })
                            vim.cmd('normal! zvzz')
                        end
                    end
                end
            end,
            options = {
                '--ansi',
                '--delimiter',
                ' ',
                '--with-nth',
                '5..',
                '--prompt',
                title .. '> ',
                '--header',
                fzf_header,
                '--expect',
                'ctrl-x,ctrl-v,ctrl-t,ctrl-q,ctrl-l',
                '--preview',
                bat_prefix .. ' --highlight-line {3} -- {2}',
                '--preview-window',
                fzf_preview_window,
                '--bind',
                'focus:transform-preview-label:echo [ $(echo {2}:{3}:{4} | sed "s|^$HOME|~|") ]',
            },
        }))
    end

    for _, client in ipairs(clients) do
        client.request(method, params, function(_, result, ctx)
            symbols_to_entries_and_items(result, ctx, bufnr, client.offset_encoding, '', all_entries, all_items)
            remaining = remaining - 1
            if remaining == 0 then
                fzf_exec(client.offset_encoding)
            end
        end)
    end
end

-- LSP document symbols
vim.keymap.set('n', '<Leader>ls', function()
    local params = { textDocument = vim.lsp.util.make_text_document_params() }
    request_symbols_and_fzf_exec('textDocument/documentSymbol', params, 'LSP Document Symbols', '')
end)

-- LSP workspace symbols
vim.keymap.set('n', '<Leader>lS', function()
    local query = vim.fn.input('Query: ')
    local params = { query = query }
    request_symbols_and_fzf_exec('workspace/symbol', params, 'LSP Workspace Symbols', query)
end)

--
-- LSP definitions, references, implementations, declarations, type definitions
--

-- Convert lsp.Location[] to fzf entries and quickfix items
local function locations_to_entries_and_items(locations, offset_encoding, all_entries, all_items)
    local items = vim.lsp.util.locations_to_items(locations, offset_encoding)
    vim.list_extend(all_items, items)
    -- Construct fzf entries
    for _, item in ipairs(items) do
        local filename = item.filename
        local lnum = item.lnum
        local col = item.col
        local icon = get_colored_devicon(filename)
        local fzf_text = icon == '' and icon or icon .. ' '
            .. color_str(vim.fn.fnamemodify(filename, ':~:.'), 'RipgrepFilename')
            .. ':' .. color_str(tostring(lnum), 'RipgrepLineNum')
            .. ':' .. color_str(tostring(col), 'RipgrepColNum')
            .. ': ' .. item.text
        table.insert(all_entries, table.concat({
            #all_entries + 1,
            filename,
            lnum,
            col,
            fzf_text,
        }, ' '))
    end
end

local function request_locations_and_fzf_exec(method, title)
    local bufnr = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients({ method = method, bufnr = bufnr })
    if not next(clients) then
        vim.notify(string.format('No active clients supporting %s method', method), vim.log.levels.WARN)
        return
    end
    local win = vim.api.nvim_get_current_win()
    local remaining = #clients
    local all_items = {}
    local all_entries = {}

    local function fzf_exec(offset_encoding)
        vim.fn['fzf#run'](vim.fn['fzf#wrap']({
            source = all_entries,
            ['sink*'] = function(lines)
                local key = lines[1]
                if key == 'ctrl-q' or key == 'ctrl-l' then
                    -- CTRL-Q: send to quickfix; CTRL-L: send to location list
                    local loclist = key == 'ctrl-l'
                    local qf_items = {}
                    for i = 2, #lines do
                        local idx = tonumber(lines[i]:match('^%S+'))
                        table.insert(qf_items, all_items[idx])
                    end
                    if loclist then
                        vim.fn.setloclist(0, {}, ' ', { title = title, items = qf_items })
                        vim.cmd('botright lopen')
                    else
                        vim.fn.setqflist({}, ' ', { title = title, items = qf_items })
                        vim.cmd('botright copen')
                    end
                else
                    -- ENTER/CTRL-X/CTRL-V/CTRL-T with multiple selections
                    local action = vim.g.fzf_action[key]
                    for i = 2, #lines do
                        if action then
                            vim.cmd(action)
                        end
                        local idx = tonumber(lines[i]:match('^%S+'))
                        local item = all_items[idx]
                        vim.lsp.util.show_document(item.user_data, offset_encoding)
                    end
                end
            end,
            options = {
                '--ansi',
                '--with-nth',
                '5..',
                '--prompt',
                title .. '> ',
                '--header',
                ':: CTRL-Q (send to quickfix), CTRL-L (send to loclist)',
                '--expect',
                'ctrl-x,ctrl-v,ctrl-t,ctrl-q,ctrl-l',
                '--preview',
                bat_prefix .. ' --highlight-line {3} -- {2}',
                '--preview-window',
                'down,45%,+{3}-/2',
                '--bind',
                'focus:transform-preview-label:echo [ $(echo {2}:{3}:{4} | sed "s|^$HOME|~|") ]',
            },
        }))
    end

    for _, client in ipairs(clients) do
        local params = vim.lsp.util.make_position_params(win, client.offset_encoding)
        if method == 'textDocument/references' then
            params.context = { includeDeclaration = true }
        end
        client.request(method, params, function(_, result)
            locations_to_entries_and_items(result or {}, client.offset_encoding, all_entries, all_items)
            remaining = remaining - 1
            if remaining == 0 then
                fzf_exec(client.offset_encoding)
            end
        end)
    end
end

-- LSP definitions
vim.keymap.set('n', '<Leader>ld', function()
    request_locations_and_fzf_exec('textDocument/definition', 'LSP Definitions')
end)
-- LSP references
vim.keymap.set('n', '<Leader>lr', function()
    request_locations_and_fzf_exec('textDocument/references', 'LSP References')
end)
-- LSP implementations
vim.keymap.set('n', '<Leader>li', function()
    request_locations_and_fzf_exec('textDocument/implementation', 'LSP Implementations')
end)
-- LSP declarations
vim.keymap.set('n', '<Leader>lD', function()
    request_locations_and_fzf_exec('textDocument/declaration', 'LSP Declarations')
end)
-- LSP type definitions
vim.keymap.set('n', '<Leader>lt', function()
    request_locations_and_fzf_exec('textDocument/typeDefinition', 'LSP Type Definitions')
end)

--
-- Diagnostics
--

local function get_diagnostics(opts)
    opts = opts or {}
    local curbuf = vim.api.nvim_get_current_buf()
    local diags = vim.diagnostic.get(not opts.all and curbuf or nil)
    if vim.tbl_isempty(diags) then
        vim.notify('No diagnostics!', vim.log.levels.WARN)
        return
    end

    local diag_icons = {
        { text = 'E', hl = 'DiagnosticError', }, -- Error
        { text = 'W', hl = 'DiagnosticWarn', }, -- Warn
        { text = 'I', hl = 'DiagnosticInfo', }, -- Info
        { text = 'H', hl = 'DiagnosticHint', }, -- Hint
    }

    local title = string.format('Diagnostics (%s)', opts.all and 'workspace' or 'document')

    -- Fzf entries
    local entries = {}

    for _, diag in ipairs(diags) do
        local bufnr = diag.bufnr
        local filename = vim.api.nvim_buf_get_name(bufnr)
        local devicon = get_colored_devicon(filename)
        local diag_icon = color_str(diag_icons[diag.severity].text, diag_icons[diag.severity].hl)
        -- Fzf entry
        -- Each entry consists of 5 parts:
        -- index, filename, lnum, col, fzf_text
        -- Only fzf_text will be displayed in fzf. The first part, index, is used to retrieve the
        -- corresponding original diagnostic item from the selected entry in fzf.
        local fzf_text = string.format(
            -- Use `\0` and fzf's `--read0` to support multi-line items
            -- Ref: https://junegunn.github.io/fzf/tips/processing-multi-line-items/
            '%s %s %s:%s:%s:\n%s%s\0',
            diag_icon,
            devicon,
            vim.fn.fnamemodify(filename, ':~:.'),
            color_str(tostring(diag.lnum), 'RipgrepLineNum'),
            color_str(tostring(diag.col), 'RipgrepColNum'),
            string.rep(' ', 2) .. (diag.source and '[' .. diag.source .. '] ' or ''),
            string.gsub(diag.message, '\n', '\n' .. string.rep(' ', 2))
        )
        table.insert(entries, table.concat({
            #entries + 1,
            filename,
            diag.lnum,
            diag.col,
            fzf_text
        }, ' '))
    end

    local diags_tempfile = vim.fn.tempname()

    local function fzf_exec()
        vim.fn['fzf#run'](vim.fn['fzf#wrap']({
            source = 'cat ' .. diags_tempfile,
            -- Even though diagnostics are multi-line items, `lines` contains linewise contents
            -- rather than the whole item. However, we can get the index of each item easily because
            -- it is the number in the beginning of the item.
            ['sink*'] = function(lines)
                local key = lines[1]
                if key == 'ctrl-q' or key == 'ctrl-l' then
                    -- CTRL-Q: send to quickfix; CTRL-L: send to location list
                    local loclist = key == 'ctrl-l'
                    local selected_diags = {}
                    for i = 2, #lines do
                        local idx = tonumber(lines[i]:match('^%d+'))
                        if idx then
                            table.insert(selected_diags, diags[idx])
                        end
                    end
                    local items = vim.diagnostic.toqflist(selected_diags)
                    if loclist then
                        vim.fn.setloclist(0, {}, ' ', { title = title, items = items })
                        vim.cmd('botright lopen')
                    else
                        vim.fn.setqflist({}, ' ', { title = title, items = items })
                        vim.cmd('botright copen')
                    end
                else
                    -- ENTER/CTRL-X/CTRL-V/CTRL-T
                    local action = vim.g.fzf_action[key]
                    for i = 2, #lines do
                        if action then
                            vim.cmd(action)
                        end
                        local idx = tonumber(lines[i]:match('^%d+'))
                        if idx then
                            local diag = diags[idx]
                            local bufnr = diag.bufnr
                            if vim.api.nvim_buf_is_loaded(bufnr) then
                                vim.cmd('buffer! ' .. bufnr)
                            else
                                vim.cmd('edit! ' .. vim.fn.bufname(bufnr))
                            end
                            vim.api.nvim_win_set_cursor(0, { diag.lnum, diag.col - 1 })
                            vim.cmd('normal! zvzz')
                        end
                    end
                end
            end,
            options = {
                '--read0',
                '--ansi',
                '--with-nth',
                '5..',
                '--prompt',
                title .. '> ',
                '--header',
                ':: CTRL-Q (send to quickfix), CTRL-L (send to loclist)',
                '--expect',
                'ctrl-x,ctrl-v,ctrl-t,ctrl-q,ctrl-l',
                '--preview',
                bat_prefix .. ' --highlight-line {3} -- {2}',
                '--preview-window',
                '+{3}-/2',
                '--bind',
                'focus:transform-preview-label:echo [ $(echo {2}:{3}:{4} | sed "s|^$HOME|~|") ]',
            },
        }))
    end

    uv.fs_open(diags_tempfile, 'w', 438, function(_, fd)
        uv.fs_write(fd, entries, 0, function()
            -- Use schedule_wrap to avoid E5560 "vimscript function must be called in a fast event",
            -- see :h E5560.
            uv.fs_close(fd, vim.schedule_wrap(fzf_exec))
        end)
    end)
end

-- Diagnostics (document)
vim.keymap.set('n', '<Leader>fd', function()
    get_diagnostics()
end)
-- Diagnostics (workspace)
vim.keymap.set('n', '<Leader>fD', function()
    get_diagnostics({ all = true })
end)
