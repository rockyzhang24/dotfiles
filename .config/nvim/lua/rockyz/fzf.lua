-----------------------------------
-- The support finders are as below
-----------------------------------

-- <Leader>fr : Resume

-- <Leader>ff : Files
-- <Leader>fo : Old files
-- <Leader>f. : Files for my dotfiles
-- <Leader>fb : Buffers
-- <M-\>  : Buffers and MRU

-- <Leader>f/ : Search history
-- <Leader>f: : Command history

-- <Leader>fm : Marks
-- <Leader>ft : Tabs
-- <Leader>fa : Argument list
-- <Leader>fh : Helptags
-- <Leader>fc : Commands
-- <Leader>f" : Registers

-- <Leader>fz : Zoxide

-- <Leader>fq : Quickfix list items
-- <Leader>fl : Location list items
-- <Leader>fQ : Quickfix list history
-- <Leader>fL : Location list history

-- <C-g>      : Live grep
-- <Leader>gv : Live grep in my nvim config
-- <Leader>g* : Grep for the current word/selection
-- g/         : Live grep in current buffer

-- gO         : LSP document symbols
-- gr/        : LSP workspace symbols
-- <Leader>ld : LSP definitions
-- <Leader>lr : LSP references
-- <Leader>li : LSP implementations
-- <Leader>lD : LSP declarations
-- <Leader>lt : LSP type definitions

-- <Leader>fd : Diagnostics (document)
-- <Leader>fD : Diagnostics (workspace)

-- <C-p>      : Git files
-- ,fs        : Git status
-- ,fb        : Git branches
-- ,fc        : Git commits (buffer)
-- ,fC        : Git commits
-- ,fh        : Git stash
-- ,ft        : Git worktrees

-- gO         : Tags (buffer)
-- gr/        : Tags

-- INSERT mode completion
-- <C-x><C-f> : Complete paths

-- vim.ui.select

--
-- Template to add a new finder
--
-- 1. Use Lua table as fzf's input
--
-- local function demo_finder(from_resume)
--     local spec = {
--         ['sink*'] = function(lines)
--             -- lines[1] is the key we pressed if it's declared in --expect
--             -- lines[2..] are the selected entries
--         end,
--         options = get_fzf_opts(from_resume, {
--             -- fzf options go here
--         }),
--     }
--
--     local function handle_contents()
--         local entries = {}
--         -- Below we build each fzf entry and insert it into entries.
--         -- ......
--         -- Call write() to write all entries into the pipe to display in fzf
--         write(entries)
--     end
--
--     fzf(spec, handle_contents)
-- end
--
-- 2. Use the raw output of external command as fzf's input
--
-- local function demo_finder(from_resume)
--     local spec = {
--         ['sink*'] = function(lines)
--         end,
--         options = get_fzf_opts(from_resume, {
--         })
--     }
--
--     -- The external bash command
--     local bash_cmd = ''
--
--     fzf(spec, nil, bash_cmd)
-- end
--
-- To bind it to a keymap:
--
-- vim.keymap.set('n', '<Leader>ff', function()
--     run(demo_finder)
-- end)
--
-- Now, this finder can be brought up by the keymap and also it supports resume by <Leader>fr
--

local qf = require('rockyz.quickfix')
local color = require('rockyz.utils.color')
local io_utils = require('rockyz.utils.io')
local icons = require('rockyz.icons')
local notify = require('rockyz.utils.notify')
local system = require('rockyz.utils.system')
local ui = require('rockyz.utils.ui')
local api = require('rockyz.utils.api')
local has_devicons, devicons = pcall(require, 'nvim-web-devicons')
local mru = require('rockyz.mru')

local theme = vim.g.fzf_theme or 'default'

---@alias LabelPos 'preview' | 'border' # Where to place the label, used for transform-preview-label or transform-border-label
---
---@class FzfWindowLayout
---@field width number
---@field height number
---@field yoffset? number
---
---@class FzfLayout # vim.g.fzf_layout, ref: https://github.com/junegunn/fzf/blob/master/README-VIM.md#configuration
---@field window FzfWindowLayout
---
---@class FzfTheme
---@field layout table vim.g.fzf_layout
---@field border string fzf's --border
---@field preview_window string fzf's --preview-window
---@field label_pos LabelPos
---@field get_select_ui_layout fun(n: number): FzfLayout # vim.g.fzf_layout specific to vim.ui.select

---@class FzfConfig
---@field default FzfTheme
---@field ivy FzfTheme
local config = {
    -- Default theme
    default = {
        layout = {
            window = {
                width = 0.8,
                height = 0.85,
            },
        },
        border = 'rounded',
        preview_window = 'nohidden',
        get_select_ui_layout = function(n)
            return {
                window = {
                    width = 0.4,
                    height = math.floor(math.min(vim.o.lines * 0.8 - 10, n + 4) + 0.5),
                },
            }
        end,
    },
    -- Ivy theme
    ivy = {
        layout = {
            window = {
                width = 1,
                height = 0.4,
                yoffset = 1.1,
            },
        },
        border = 'top',
        preview_window = 'hidden,border-left',
        label_pos = 'border',
        get_select_ui_layout = function(n)
            return {
                window = {
                    width = 1,
                    height = math.floor(math.min(vim.o.lines * 0.8 - 10, n + 3) + 0.5),
                    yoffset = 1.1,
                },
            }
        end,
    },
}

vim.g.fzf_layout = config[theme].layout

vim.g.fzf_action = {
    ['ctrl-x'] = 'split',
    ['ctrl-v'] = 'vsplit',
    ['ctrl-t'] = 'tab split',
}

-- Use the general statusline
vim.api.nvim_create_autocmd('User', {
    group = vim.api.nvim_create_augroup('rockyz.fzf.statusline', { clear = true }),
    pattern = 'FzfStatusLine',
    callback = function()
        vim.wo.statusline = ''
    end,
})

local fd_exclude = vim.env.FD_EXCLUDE and vim.env.FD_EXCLUDE or ''

local rg_prefix = 'rg --column --line-number --no-heading --color=always --smart-case --with-filename'
-- Use bat to preview text file
local bat_prefix = 'bat --color=always --paging=never --style=numbers'
local fd_prefix = 'fd --hidden --follow --color=never --type f --type l ' .. fd_exclude
-- A script to preview various types of files (text, image, etc)
local fzf_previewer = '~/.config/fzf/fzf-previewer.sh'
local diff_pager = '| delta --width $FZF_PREVIEW_COLUMNS'

---Get the command to decorate input lines, e.g., prepend a devicon to the filename. This command
---gets input through a pipe.
---For example, fd --type f | dressup_cmd('fd')
---@param source string Different types of input such as 'fd', 'git_status', etc
local function dressup_cmd(source)
    return string.format(
        'nvim -n --headless -u NONE -i NONE --cmd "colorscheme "' .. vim.g.colorscheme .. ' --cmd "let g:source = \'%s\'" --cmd "lua require(\'rockyz.headless.fzf_dressup\')" +q',
        source
    )
end

---@type table<string, string> A map from highlight group to ANSI color code
local cached_ansi = {}

---Color a string by ANSI color code that is converted from a highlight group
---@param str string string to be colored
---@param hl string highlight group name
---@param from_type string? which color type in the highlight group will be used, 'fg', 'bg' or 'sp'
---@param to_type string? which ANSI color type will be output, 'fg' or 'bg'
local function ansi_string(str, hl, from_type, to_type)
    from_type = from_type or 'fg'
    to_type = to_type or 'fg'
    if not cached_ansi[hl] then
        cached_ansi[hl] = color.hl2ansi(hl, from_type, to_type)
    end
    return cached_ansi[hl] .. str .. '\x1b[m'
end

-- Get ANSI colored devicon for a filename
local function ansi_devicon(filename)
    if not has_devicons then
        return ''
    end
    local ext = vim.fn.fnamemodify(filename, ':e')
    local file_icon, file_icon_hl = devicons.get_icon(filename, ext, { default = true })
    return ansi_string(file_icon, file_icon_hl)
end

---Handler for vim.system's error
---@param error string obj.stderr
---@param output string obj.stdout
local function system_on_error(error, output)
    notify.error({ error, output })
end

local function shortpath(path)
    local short = vim.fn.fnamemodify(path, ':~:.')
    short = vim.fn.pathshorten(short)
    return short == '' and '~/' or (short:match('/$') and short or short .. '/')
end

---Set quickfix or location list and open its window without focus
---@param what table The "what" parameter for vim.fn.setqflist
---@param is_local boolean? Location list or not
---@param action string? The "action" parameter for vim.fn.setqflist
local function setqflist(what, is_local, action)
    action = action or ' '
    if is_local then
        vim.fn.setloclist(0, {}, action, what)
        vim.cmd('botright lopen')
    else
        vim.fn.setqflist({}, action, what)
        vim.cmd('botright copen')
    end
    vim.cmd('silent wincmd p')
end

local cached_fzf_query -- cached the last fzf query
local cached_rg_query -- cached the last rg query (for live greps)
local cached_finder -- cached the last executed fzf finder
if not cached_fzf_query then
    cached_fzf_query = vim.fn.tempname()
end
if not cached_rg_query then
    cached_rg_query = vim.fn.tempname()
end

-- Record whether Rg is in fzf mode or not
local in_fzf_mode = ''

local common_opts = {
    '--ansi',
    '--multi',
    '--border',
    config[theme].border,
    '--preview-window',
    config[theme].preview_window,
    '--border-label-pos',
    '-3',
}

---Get fzf options
---@param from_resume boolean? Whether the finder is called by fzf resume
---@param extra table? Extra options
local function get_fzf_opts(from_resume, extra)
    extra = extra or {}
    local opts = vim.list_extend(vim.deepcopy(common_opts), {
        -- Cache the query for fzf resume
        '--bind',
        'result:execute-silent(echo {q} > ' .. cached_fzf_query .. ')',
    })
    -- When the finder is called by fzf resume, use the fzf's start event to fetch the cached query
    if from_resume then
        opts = vim.list_extend(opts, {
            '--bind',
            'start:transform-query:cat ' .. cached_fzf_query,
        })
    end
    return vim.list_extend(opts, extra)
end

---@param label string The label or a shell command to generate the label
local function set_label(label)
    return string.format('focus:transform-%s-label:echo ┨ %s ┠', config[theme].label_pos, label)
end

---Bash command to replace $HOME with tilde
---@param path string
local function tildefy_home(path)
    return '$(echo ' .. path .. ' | sed "s|^$HOME|~|")'
end

---@param extra_keys table? Extra keys for --expect
---@param exclude_defaults boolean? Whether to exclude the default keys, i.e., ctrl-x, ctrl-v and
---ctrl-t
local function expect_keys(extra_keys, exclude_defaults)
    extra_keys = extra_keys or {}
    local extra = table.concat(extra_keys, ',')
    return exclude_defaults and extra or ('ctrl-x,ctrl-v,ctrl-t,' .. extra)
end

--
-- There are two ways to provide input to fzf: raw output from an external command like fd or git,
-- or feed entries by a Lua table.
--
-- * For the first case, we can simply set FZF_DEFAULT_COMMAND to the external command.
-- * For the second case, we can connect fzf to a fifo pipe waiting for the contents. With this
-- approach, fzf's UI will display immediately without blocking. Once the contents are processed, we
-- write them into the pipe, and they will be displayed in fzf.
--

local fifopipe = nil
local output_pipe = nil

-- Record the pid of the tail command so that we can kill it right after all contents are written to
-- the pipe to terminate the fzf "loading" indicator.
local tail_pid = vim.fn.tempname()

---Launch fzf. Its contents can be an external command's output, or a lua table containing all
---entries.
---@param spec table The spec dictionary, see https://github.com/junegunn/fzf/blob/master/README-VIM.md
---@param handle_contents function? Build the table containing all fzf entries and write them to the
---pipe
---@param fzf_cmd string? External bash command
local function fzf(spec, handle_contents, fzf_cmd)
    local old_fzf_cmd = vim.env.FZF_DEFAULT_COMMAND
    vim.env.FZF_DEFAULT_COMMAND = fzf_cmd

    if handle_contents and not fzf_cmd then
        fifopipe = vim.fn.tempname()
        system.sync('mkfifo ' .. fifopipe)
        -- vim.env.FZF_DEFAULT_COMMAND = 'cat ' .. fifopipe
        vim.env.FZF_DEFAULT_COMMAND = 'tail -n +1 -f ' .. fifopipe .. ' & echo $! > ' .. tail_pid
        vim.uv.fs_open(fifopipe, 'w', -1, vim.schedule_wrap(function(err, fd)
            if err then
                error(err)
            end
            output_pipe = vim.uv.new_pipe(false)
            if not output_pipe then
                notify.error('[FZF] Failed to create the output pipe!')
                return
            end
            output_pipe:open(fd)
            handle_contents()
        end))
    end

    vim.fn['fzf#run'](vim.fn['fzf#wrap'](spec))

    vim.env.FZF_DEFAULT_COMMAND = old_fzf_cmd
end

-- Close the pipe and kill tail process to terminate fzf's "loading" indicator
local function finish()
    system.async({ 'bash', '-c', 'kill -9 $(<' .. tail_pid .. ')' }, {}, nil, system_on_error)
    if output_pipe then
        output_pipe:close()
        output_pipe = nil
    end
end

---Write fzf entries to the pipe
---@param entries table Fzf entries
---@param multiline boolean? Whether each entry is a multiline item
local function write(entries, multiline)
    if not output_pipe then
        return
    end
    output_pipe:write(vim.tbl_map(function(x)
            return not multiline and x .. '\n' or x
    end, entries), function()
        finish()
    end)
end

---Cache the given finder for later fzf resume and run the finder (launch fzf UI, process entries
---and send the entries to fzf for display)
---@param finder function
---@param from_resume boolean? Whether it is called from fzf resume
local function run(finder, from_resume)
    cached_finder = finder
    finder(from_resume)
end

-- Resume
vim.keymap.set('n', '<Leader>fr', function()
    if not cached_finder then
        notify.warn('No resume finder available!')
        return
    end
    run(cached_finder, true)
end)

-- Helper function for sink* to handle selected files
-- ENTER/CTRL-X/CTRL-V/CTRL-T to open files
---@param lines table The first item is the key; others are filenames.
local function sink_file(lines)
    local key = lines[1]
    local action = vim.g.fzf_action[key] or 'edit'
    for i = 2, #lines do
        if vim.fn.fnamemodify(lines[i], ':p') ~= vim.fn.expand('%:p') then
            vim.cmd(action .. ' ' .. lines[i])
        end
    end
end

-- Files
local function files(from_resume)
    local fd_cwd = fd_prefix .. ' | ' .. dressup_cmd('fd')
    local fd_home = 'cd $HOME; ' .. fd_prefix .. ' | ' .. dressup_cmd('fd')
    local prompt_cwd = shortpath(vim.uv.cwd())

    local spec = {
        ['sink*'] = sink_file,
        options = get_fzf_opts(from_resume, {
            '--delimiter',
            '\t',
            '--with-nth',
            '1',
            '--prompt',
            prompt_cwd,
            '--expect',
            expect_keys(),
            '--preview',
            fzf_previewer .. ' {2}',
            '--accept-nth',
            '{2}',
            '--header',
            ':: ALT-/ (toggle HOME/CWD)',
            '--bind',
            set_label(tildefy_home('{2}')),
            '--bind',
            'alt-/:transform:[[ ! $FZF_PROMPT == "~/" ]] && {' ..
                'echo "reload(' .. vim.fn.escape(fd_home, '"') .. ')+change-prompt(~/)";' ..
            '} || {' ..
                'echo "reload(' .. vim.fn.escape(fd_cwd, '"') .. ')+change-prompt(' .. prompt_cwd .. ')";' ..
            '}',
        }),
    }

    fzf(spec, nil, fd_cwd)
end

vim.keymap.set('n', '<Leader>ff', function()
    run(files)
end)

-- Old files
local function old_files(from_resume)
    local spec = {
        ['sink*'] = sink_file,
        options = get_fzf_opts(from_resume, {
            '--delimiter',
            '\t',
            '--with-nth',
            '2',
            '--prompt',
            'Old Files> ',
            '--tiebreak',
            'index',
            '--expect',
            expect_keys(),
            '--preview',
            fzf_previewer .. ' {1}',
            '--bind',
            set_label('{2}'),
            '--accept-nth',
            '1',
        }),
    }

    local function handle_contents()
        local entries = {}
        for _, file in ipairs(vim.v.oldfiles) do
            if vim.fn.filereadable(file) == 1 then
                local icon = ansi_devicon(file)
                file = vim.fn.fnamemodify(file, ':~:.')
                local entry = string.format('%s\t%s %s', file, icon, file)
                table.insert(entries, entry)
            end
        end
        write(entries)
    end

    fzf(spec, handle_contents)
end

vim.keymap.set('n', '<Leader>fo', function()
    run(old_files)
end)

-- Find files for my dotfiles
local function dot_files(from_resume)
    local git_cmd = 'ls-gitfiles dot | ' .. dressup_cmd('ls_gitfiles')

    local spec = {
        ['sink*'] = sink_file,
        options = get_fzf_opts(from_resume, {
            '--delimiter',
            '\t',
            '--with-nth',
            '1',
            '--prompt',
            '.dotfiles> ',
            '--expect',
            expect_keys(),
            '--preview',
            'line={} \
            if [[ "${line:1:2}" =~ D ]]; then \
                if git --git-dir=$HOME/dotfiles --work-tree=$HOME show HEAD:{2} | file - | grep -q text; then \
                    git --git-dir=$HOME/dotfiles --work-tree=$HOME show HEAD:{2} | bat --color=always --style=numbers \
                else \
                    echo "No preview for this deleted file" \
                fi \
            else \
                ' .. fzf_previewer .. ' ~/{2} \
            fi \
            ',
            '--accept-nth',
            '~/{2}',
            '--bind',
            set_label('{2}'),
        }),
    }

    fzf(spec, nil, git_cmd)
end

vim.keymap.set('n', '<Leader>f.', function()
    run(dot_files)
end)

-- Buffers
local function buffers(from_resume)
    local spec = {
        ['sink*'] = function(lines)
            local key = lines[1]
            if key == 'alt-bs' then
                -- ALT-BS to delete selected buffers
                for i = 2, #lines do
                    local bufnr = tonumber(string.match(lines[i], '%[(%d+)%]'))
                    require('rockyz.utils.buf').bufdelete({ bufnr = bufnr, wipe = true })
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
        options = get_fzf_opts(from_resume, {
            '--multi',
            '--delimiter',
            '\t',
            '--header-lines',
            '1',
            '--with-nth',
            '3..',
            '--prompt',
            'Buffers> ',
            '--header',
            ':: ALT-BS (delete buffers)',
            '--expect',
            expect_keys({ 'alt-bs' }),
            '--preview',
            '[[ {1} == "[No Name]" ]] && echo "" || ' .. bat_prefix .. ' --highlight-line {2} -- {1}',
            '--preview-window',
            '+{2}-/2',
            '--bind',
            set_label('{3..}'),
        }),
    }

    local function handle_contents()
        local buflist = vim.api.nvim_list_bufs()
        local max_bufnr = 0
        local bufinfos = vim.iter(buflist):map(function(b)
            if vim.api.nvim_buf_is_valid(b) and vim.fn.buflisted(b) == 1 and vim.bo[b].filetype ~= 'qf' then
                max_bufnr = b > max_bufnr and b or max_bufnr
                return vim.fn.getbufinfo(b)[1]
            end
        end):totable()

        table.sort(bufinfos, function(a, b)
            return a.lastused > b.lastused
        end)

        local hls = {
            bufnr = 'Number',
            lnum = 'FzfLnum',
            col = 'FzfCol',
        }

        local max_bufnr_width = #ansi_string('', hls.bufnr) + #tostring(max_bufnr) + 2

        local entries = {}
        for _, bufinfo in ipairs(bufinfos) do
            local bufnr = bufinfo.bufnr
            local fullname = bufinfo.name
            local icon = ansi_devicon(fullname)
            local dispname = #fullname == 0 and '[No Name]' or vim.fn.fnamemodify(fullname, ':~:.')
            local current_buf = vim.api.nvim_get_current_buf()
            local alternate_buf = vim.fn.bufnr('#')
            local lnum = bufinfo.lnum
            local flags = {
                bufnr == current_buf and '%' or (bufnr == alternate_buf and '#' or ''),
                bufinfo.hidden == 1 and 'h' or 'a',
                vim.bo[bufnr].readonly and '=' or (vim.bo[bufnr].modifiable and '' or '-'),
                bufinfo.changed == 1 and '+' or '',
            }
            -- Entry: <fullname>\t<lnum>\t<[bufnr]> <flags> <icon> <bufname>:<lnum>
            -- {3..} will be presented.
            local entry = string.format(
                '%s\t%s\t%-' .. max_bufnr_width .. 's %3s %s %s:%s',
                #fullname == 0 and '[No Name]' or fullname,
                lnum,
                '[' .. ansi_string(bufnr, hls.bufnr) .. ']',
                table.concat(flags, ''),
                icon,
                dispname,
                ansi_string(tostring(lnum), hls.lnum)
            )
            table.insert(entries, entry)
        end
        write(entries)
    end

    fzf(spec, handle_contents)
end

vim.keymap.set('n', '<Leader>fb', function()
    run(buffers)
end)

-- Buffers and MRU
-- (Shout out to @kevinhwang91)
local function bufs_and_mru(from_resume)
    local cur_bufnr = vim.api.nvim_get_current_buf()
    local alt_bufnr = vim.fn.bufnr('#')
    local expr = [[{"bufnr": v:val.bufnr, "name": v:val.name, "lnum": v:val.lnum, ]] ..
    [["lastused": v:val.lastused, "changed": v:val.changed}]]
    local bufinfo_list = vim.api.nvim_eval(([[map(getbufinfo({'buflisted':1}), %q)]]):format(expr))
    table.sort(bufinfo_list, function(a, b)
        return a.lastused > b.lastused
    end)
    local header_lines = #bufinfo_list > 0 and bufinfo_list[1].bufnr == cur_bufnr and '1' or '0'

    local spec = {
        ['sink*'] = function(lines)
            -- ALT-BS to delete the buffer from the buffer list
            -- ENTER/CTRL-X/CTRL-V/CTRL-T to switch to the buffer or edit the file
            local key = lines[1]
            local action = vim.g.fzf_action[key]
            for i = 2, #lines do
                local filename = string.match(lines[i], '^(.-)\t')
                local bufnr = string.match(lines[i], '%[(%d+)%]')
                local cmd = bufnr and ('buffer ' .. bufnr) or ('edit ' .. filename)
                if key == 'alt-bs' then
                    if bufnr then
                        require('rockyz.utils.buf').bufdelete({ bufnr = tonumber(bufnr), wipe = true })
                    end
                else
                    vim.cmd(action and (action .. ' | ' .. cmd) or cmd)
                end
            end
        end,
        options = get_fzf_opts(from_resume, {
            '--multi',
            '--delimiter',
            '\t',
            '--header',
            ':: ALT-BS (delete buffers)',
            '--header-lines',
            header_lines,
            '--with-nth',
            '3..',
            '--prompt',
            'MRU> ',
            '--tiebreak',
            'index',
            '--expect',
            expect_keys({ 'alt-bs' }),
            '--preview',
            '[[ {1} == "[No Name]" ]] && echo "" || ' .. bat_prefix .. ' --highlight-line {2} -- {1}',
            '--preview-window',
            '+{2}-/2',
            '--bind',
            set_label('{3..}'),
        }),
    }

    local function handle_contents()
        local max_bufnr = 0
        local buf_names = {}
        for _, b in ipairs(bufinfo_list) do
            buf_names[b.name] = true
            if b.bufnr > max_bufnr then
                max_bufnr = b.bufnr
            end
        end
        local max_digit = math.floor(math.log10(max_bufnr)) + 1
        local mru_list = mru.list()
        local entries = {}
        local entry_fmt = '%s\t%s\t%s[%s] %s'
        for _, b in ipairs(bufinfo_list) do
            local bufnr = b.bufnr
            local buftype = vim.bo[bufnr].buftype
            if buftype ~= 'help' and buftype ~= 'quickfix' and buftype ~= 'prompt' then
                local name = b.name
                local icon = ansi_devicon(name)
                local lnum = b.lnum
                local readonly = vim.bo[bufnr].readonly
                local modified = b.changed == 1
                local flag = ''
                if modified then
                    flag = ansi_string('+ ', 'DiagnosticError')
                elseif readonly then
                    flag = ansi_string('- ', 'DiagnosticWarn')
                end

                local sname = name == '' and '[No Name]' or vim.fn.fnamemodify(name, ':~:.')
                if bufnr == cur_bufnr then
                    sname = ansi_string(sname, 'Directory')
                elseif bufnr == alt_bufnr then
                    sname = ansi_string(sname, 'Conditional')
                end

                sname = flag .. icon .. ' ' .. sname
                local bufnr_str = ansi_string(tostring(bufnr), 'Number')
                local digit = math.floor(math.log10(bufnr)) + 1
                local padding = (' '):rep(max_digit - digit)
                -- Entry: <fullname>\t<lnum>\t<[bufnr]> <flag> <icon> <bufname>
                -- {3..} will be presented
                local entry = entry_fmt:format(name, lnum, padding, bufnr_str, sname)
                table.insert(entries, entry)
            end
        end

        entry_fmt = '%s\t0\t' .. (' '):rep(max_digit + 2) .. ' %s'
        for _, f in ipairs(mru_list) do
            if not buf_names[f] then
                local icon = ansi_devicon(f)
                local sname = vim.fn.fnamemodify(f, ':~:.')
                -- Entry: <fullname>\t<0>\t<icon> <bufname>
                -- {3..} will be presented
                local entry = entry_fmt:format(f, icon .. ' ' .. sname)
                table.insert(entries, entry)
            end
        end

        write(entries)
    end

    fzf(spec, handle_contents)
end

vim.keymap.set('n', '<M-\\>', function()
    run(bufs_and_mru)
end)

---Helper function to get history
local function get_history(name)
    local entries = {}
    local history = vim.fn.execute('history ' .. name)
    ---@diagnostic disable-next-line: cast-local-type
    history = vim.split(history, '\n')
    for i = #history, 3, -1 do
        local item = history[i]
        table.insert(entries, item:match('%d+ +(.+)$'))
    end
    return entries
end

-- Search history
local function search_history(from_resume)
    local spec = {
        ['sink*'] = function(lines)
            -- ENTER to run the search
            -- CTRL-E to input the query for further edit
            local key = lines[1]
            if key == '' or key == 'ctrl-e' then
                local query = lines[2]
                vim.cmd('stopinsert')
                vim.api.nvim_feedkeys('/' .. query, 'n', true)
            end
            if key == '' then
            vim.api.nvim_feedkeys(
                vim.api.nvim_replace_termcodes('<CR>', true, false, true),
                'n',
                false
            )
            end
        end,
        options = get_fzf_opts(from_resume, {
            '--no-multi',
            '--prompt',
            'Search History> ',
            '--bind',
            'ctrl-/:ignore',
            '--preview-window',
            'hidden',
            '--header',
            ':: ENTER (run), CTRL-E (edit)',
            '--expect',
            'ctrl-e',
        }),
    }

    local function handle_contents()
        local entries = get_history('search')
        write(entries)
    end

    fzf(spec, handle_contents)
end

vim.keymap.set('n', '<Leader>f/', function()
    run(search_history)
end)

-- Command history
local function command_history(from_resume)
    local spec = {
        ['sink*'] = function(lines)
            local key = lines[1]
            local cmd = lines[2]
            if key == '' then
                -- ENTER to run the command
                vim.cmd(cmd)
                vim.fn.histadd('cmd', cmd)
            elseif key == 'ctrl-e' then
                -- CTRL-E to input the command for further edit
                vim.cmd('stopinsert')
                vim.api.nvim_feedkeys(':' .. cmd, 'n', true)
            end
        end,
        options = get_fzf_opts(from_resume, {
            '--no-multi',
            '--prompt',
            'Command History> ',
            '--bind',
            'ctrl-/:ignore',
            '--preview-window',
            'hidden',
            '--header',
            ':: ENTER (run), CTRL-E (edit)',
            '--expect',
            'ctrl-e',
        }),
    }

    local function handle_contents()
        local entries = get_history('cmd')
        write(entries)
    end

    fzf(spec, handle_contents)
end

vim.keymap.set('n', '<Leader>f:', function()
    run(command_history)
end)

-- Marks
local function marks(from_resume)
    local buf = vim.api.nvim_get_current_buf()
    local win = vim.api.nvim_get_current_win()
    local spec = {
        ['sink*'] = function(lines)
            local key = lines[1]
            if key == 'alt-bs' then
                -- ALT-BS to delete marks
                for i = 2, #lines do
                    local mark = lines[i]:match('^(.-)\t')
                    vim.api.nvim_win_call(win, function()
                        local ok, res = pcall(vim.api.nvim_buf_del_mark, buf, mark)
                        if ok and res then
                            return
                        end
                        vim.cmd.delmarks(mark)
                    end)
                end
            else
                -- ENTER/CTRL-X/CTRL-V/CTRL-T to open file
                local action = vim.g.fzf_action[key]
                for i = 2, #lines do
                    if action then
                        vim.cmd(action)
                    end
                    local mark = lines[i]:match('^(.-)\t')
                    vim.cmd('stopinsert')
                    vim.cmd('normal! `' .. mark)
                end
            end
        end,
        options = get_fzf_opts(from_resume, {
            '--delimiter',
            '\t',
            '--with-nth',
            '4..',
            '--header-lines',
            '1',
            '--prompt',
            'Marks> ',
            '--header',
            ':: ALT-BS (delete marks)',
            '--expect',
            expect_keys({ 'alt-bs' }),
            '--preview',
            ' [[ -f {2} ]] && ' .. bat_prefix .. ' --highlight-line {3} -- {2} || echo File does not exist, no preview!',
            '--preview-window',
            '+{3}-/2',
            '--bind',
            set_label('{2}'),
        })
    }

    local function handle_contents()
        local entries = {}

        local all_marks = vim.api.nvim_win_call(win, function()
            return vim.api.nvim_buf_call(buf, function()
                return vim.fn.execute('marks')
            end)
        end)

        all_marks = vim.split(all_marks, '\n')

        -- First entry as the header
        local header = string.format('%s\t%s\t%s\t%s  %s  %s  %s', 'mark', 'filepath', 'lnum', 'mark', 'lnum', 'col', 'file/text')
        table.insert(entries, header)

        local mark_width = #ansi_string('', 'FzfFilename') + 4
        local lnum_width = #ansi_string('', 'FzfLnum') + 4
        local col_width = #ansi_string('', 'FzfCol') + 3
        local entry_fmt = '%s\t%s\t%s\t%-' .. mark_width .. 's  %' .. lnum_width .. 's  %' .. col_width .. 's  %s'

        for i = 3, #all_marks do
            local mark, lnum, col, text = all_marks[i]:match('(.)%s+(%d+)%s+(%d+)%s+(.*)')
            col = tostring(tonumber(col) + 1)

            -- Get the file path of the mark. It won't be presented in fzf, but is used for preview.
            local filepath = text
            -- nvim_buf_get_mark cannot get `'` mark correctly without curwin
            -- https://github.com/neovim/neovim/issues/29807
            local pos = vim.api.nvim_win_call(win, function()
                return vim.api.nvim_buf_get_mark(buf, mark)
            end)
            if pos and pos[1] > 0 then
                filepath = vim.api.nvim_buf_get_name(buf)
            end
            if filepath == '' then
                filepath = '[No File]'
            end

            -- Entry: <mark>\t<filepath>\t<lnum>\t<colored_mark>  <colored_lnum>  <colored_col>  <text>
            -- {4..} will be presented.
            local entry = entry_fmt:format(
                mark,
                filepath,
                lnum,
                ansi_string(mark, 'FzfFilename'),
                ansi_string(lnum, 'FzfLnum'),
                ansi_string(col, 'FzfCol'),
                text
            )
            table.insert(entries, entry)
        end
        write(entries)
    end

    fzf(spec, handle_contents)
end

vim.keymap.set('n', '<Leader>fm', function()
    run(marks)
end)

-- Tabs
local function tabs(from_resume)
    local win = vim.api.nvim_get_current_win()

    local spec = {
        ['sink*'] = function(lines)
            local key = lines[1]
            if key == 'alt-bs' and #vim.api.nvim_list_tabpages() > 1 then
                -- ALT-BS: delete tabs
                for i = 2, #lines do
                    for winid in lines[i]:match('^[^\t]+\t%S+\t%S+\t(%S+)\t'):gmatch('[^,]+') do
                        winid = tonumber(winid)
                        if winid then
                            vim.api.nvim_win_close(winid, false)
                        end
                    end
                end
            elseif #lines == 2 then
                -- ENTER with single selection: select tab
                local tid = tonumber(string.match(lines[2], '^[^\t]+\t%S+\t(%S+)'))
                if tid then
                    vim.api.nvim_set_current_tabpage(tid)
                end
            end
        end,
        options = get_fzf_opts(from_resume, {
            '--delimiter',
            '\t',
            '--with-nth',
            '5',
            '--prompt',
            'Tabs> ',
            '--header',
            ':: ALT-BS (delete tabs)',
            '--expect',
            'alt-bs',
            '--preview',
            'file={1}; [[ -f $file ]] && ' .. bat_prefix .. ' --highlight-line {2} -- $file || echo "No preview support!"',
            '--bind',
            set_label(tildefy_home('{1}')),
        }),
    }

    local function handle_contents()
        local entries = {}
        vim.api.nvim_win_call(win, function()
            local cur_tab = vim.api.nvim_get_current_tabpage()
            for idx, tid in ipairs(vim.api.nvim_list_tabpages()) do
                local filenames = {}
                -- Store winids in each tab. They are used for closing the tab via ALT-BS.
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
                            cur_bufname = bufname
                            cur_lnum = vim.api.nvim_win_get_cursor(winid)[1]
                            -- Mark the current window in a tab by a distinct color
                            filename = ansi_string(filename, 'DiagnosticOk')
                        end
                        table.insert(filenames, filename)
                    end
                end
                -- Entry: <cur_bufname>\t<cur_lnum>\t<tid>\t<winids>\t<idx>:<filenames>
                -- {5..} will be presented.
                local entry = cur_bufname .. '\t' .. cur_lnum .. '\t' .. tid .. '\t' .. table.concat(winids, ',') .. '\t'
                    .. idx .. ': ' .. table.concat(filenames, ', ')
                -- Indicator for current tab
                if tid == cur_tab then
                    entry = entry .. ' ' .. icons.caret.left
                end
                table.insert(entries, entry)
            end
            write(entries)
        end)
    end

    fzf(spec, handle_contents)
end

vim.keymap.set('n', '<Leader>ft', function()
    run(tabs)
end)

-- Argument list
local function args(from_resume)
    local spec = {
        ['sink*'] = function(lines)
            local key = lines[1]
            if key == 'alt-bs' then
                -- ALT-BS: delete from arglist
                for i = 2, #lines do
                    local filename = string.match(lines[i], '^%d+\t(.-)\t')
                    vim.cmd.argdelete(filename)
                end
            else
                -- ENTER/CTRL-X/CTRL-V/CTRL-T
                local action = vim.g.fzf_action[key]
                for i = 2, #lines do
                    if action then
                        vim.cmd(action)
                    end
                    local index = tonumber(lines[i]:match('^(%d+)\t'))
                    vim.cmd('argument! ' .. index)
                end
            end
        end,
        options = get_fzf_opts(from_resume, {
            '--delimiter',
            '\t',
            '--with-nth',
            '3..',
            '--prompt',
            'Args> ',
            '--header',
            ':: ALT-BS (delete from arglist)',
            '--expect',
            expect_keys({ 'alt-bs' }),
            '--preview',
            bat_prefix .. ' -- {2}',
            '--bind',
            set_label('{2}'),
        }),
    }

    local argc = vim.fn.argc()
    if argc == 0 then
        notify.warn('Argument list is empty')
        return
    end

    local function handle_contents()
        local entries = {}
        for i = 0, argc - 1 do
            local f = vim.fn.argv(i)
            ---@diagnostic disable-next-line: param-type-mismatch
            local fs = vim.uv.fs_stat(f)
            if fs and fs.type == 'file' then
                local devicon = ansi_devicon(f)
                -- Entry: <idx>\t<filename>\t<icon> <filename>
                -- {3..} will be presented. <idx> is used to switch file; <filename> is used to
                -- delete the file from arglist
                local entry = string.format('%s\t%s\t%s %s', #entries + 1, f, devicon, f)
                table.insert(entries, entry)
            end
        end
        write(entries)
    end

    fzf(spec, handle_contents)
end

vim.keymap.set('n', '<Leader>fa', function()
    run(args)
end)

-- Helptags
local function helptags(from_resume)

    local spec = {
        ['sink*'] = function(lines)
            if #lines > 2 then
                notify.warn('Multiple selection is not supported')
            end
            local key = lines[1]
            local tag = string.match(lines[2], '^(.-)\t')
            if key == '' or key == 'ctrl-x' then
                vim.cmd('help ' .. tag)
            elseif key == 'ctrl-v' then
                vim.cmd('vert help ' .. tag)
            elseif key == 'ctrl-t' then
                vim.cmd('tab help ' .. tag)
            end
        end,
        options = get_fzf_opts(from_resume, {
            '--delimiter',
            '\t',
            '--with-nth',
            '{4..}',
            '--nth',
            '1',
            '--no-multi',
            '--prompt',
            'Helptags> ',
            '--expect',
            expect_keys(),
            '--header',
            ':: CTRL-V (open in vertical split), CTRL-T (open in new tab)',
            '--preview',
            -- This script is taken from fzf.vim/bin/tagpreview.sh
            'TARGET_LINE="$(nvim -R -i NONE -u NONE -e -m -s {2} -c "set nomagic" -c "silent "{3} -c \'let l=line(".") | new | put =l | print | qa!\')"; \
            START_LINE="$(( TARGET_LINE - 5 ))"; \
            (( START_LINE <= 0 )) && START_LINE=1; \
            END_LINE="$(( START_LINE + FZF_PREVIEW_LINES - 1 ))"; ' .. bat_prefix .. ' --style plain --language VimHelp --highlight-line "${TARGET_LINE}" --line-range="${START_LINE}:${END_LINE}" -- {2}',
            '--bind',
            set_label('{4}'),
        }),
    }

    local function handle_contents()
        local langs = vim.split(vim.o.helplang, ',')
        local langs_map = {}
        for _, lang in ipairs(langs) do
            langs_map[lang] = true
        end

        ---@type table<string, string[]> A map from language to tag files
        local tag_files = {}
        local function add_tag_file(lang, file)
            if langs_map[lang] then
                if tag_files[lang] then
                    table.insert(tag_files[lang], file)
                else
                    tag_files[lang] = { file }
                end
            end
        end

        ---@type table<string, string> A map from the tag file name to its full path
        local help_files = {}
        local all_files = vim.fn.globpath(vim.o.runtimepath, 'doc/*', true, true)
        for _, fullpath in ipairs(all_files) do
            local file = vim.fn.fnamemodify(fullpath, ':t')
            if file == 'tags' then
                add_tag_file('en', fullpath)
            elseif file:match('^tags%-..$') then
                local lang = file:sub(-2)
                add_tag_file(lang, fullpath)
            else
                help_files[file] = fullpath
            end
        end

        local fzf_entries = {}
        local tags_map = {}
        local delimiter = string.char(9)
        for _, lang in ipairs(langs) do
            for _, file in ipairs(tag_files[lang] or {}) do
                local lines = vim.split(io_utils.read_file(file), '\n')
                for _, line in ipairs(lines) do
                    if not line:match('^!_TAG_') then
                        local fields = vim.split(line, delimiter)
                        if #fields == 3 and not tags_map[fields[1]] then
                            -- Entry: <tag>\t<file_fullpath>\t<cmd>\t<tag> <[filename]>
                            -- {4..} will be presented. {1} <tab> is used to open the tag file; {2}
                            -- <file_fullpath> is used to open the help file.
                            local tag = fields[1]
                            local filename = fields[2] -- help file name
                            local excmd = fields[3] -- Ex command
                            local file_fullpath = help_files[filename] -- help file fullpath
                            local entry = string.format(
                                '%s\t%s\t%s\t%s %s',
                                tag,
                                file_fullpath,
                                excmd,
                                ansi_string(tag, 'Label'),
                                ansi_string('[' .. filename .. ']', 'FzfDesc')
                            )
                            table.insert(fzf_entries, entry)
                        end
                        tags_map[fields[1]] = true
                    end
                end
            end
        end
        write(fzf_entries)
    end

    fzf(spec, handle_contents)
end

vim.keymap.set('n', '<Leader>fh', function()
    run(helptags)
end)

-- Commands
local function commands(from_resume)
    local spec = {
        ['sink*'] = function(lines)
            local cmd = lines[1]:match('^(.-)\t')
            vim.cmd('stopinsert')
            vim.api.nvim_feedkeys(':' .. cmd, 'n', true)
        end,
        options = get_fzf_opts(from_resume, {
            '--delimiter',
            '\t',
            '--no-multi',
            '--with-nth',
            '2',
            '--prompt',
            'Commands> ',
            '--preview',
            'echo {3..}',
            '--preview-window',
            theme == 'default' and 'down,3' or '',
            '--bind',
            set_label('{1}'),
        }),
    }

    local function handle_contents()

        -- The structure of each entry is as follows (3 parts):
        -- <command>\t<colored_command>\t<description>
        --    |            |                  |____________ shown in preview
        --    |            |___ presented in fzf
        --    |___ used for sink
        local fzf_entries = {}

        -- 1. Process user defined commands
        local global_commands = vim.api.nvim_get_commands({})
        local buf_commands = vim.api.nvim_buf_get_commands(0, {})

        ---@param cmds table<string, table> Commands associated with their information
        ---@return string[] # A table having sorted command names
        local function get_sorted_cmds(cmds)
            local t = {}
            for k, v in pairs(cmds) do
                if type(v) == 'table' then
                    table.insert(t, k)
                end
            end
            table.sort(t)
            return t
        end

        local sorted_buf_cmds = get_sorted_cmds(buf_commands)
        local sorted_global_cmds = get_sorted_cmds(global_commands)

        local function build_entries(cmds, buffer_local)
            local entries = {}
            if vim.tbl_isempty(cmds) then
                return entries
            end
            for _, cmd in ipairs(cmds) do
                local entry = cmd
                .. '\t'
                .. (buffer_local and ansi_string(cmd, 'Function') or ansi_string(cmd, 'Directory'))
                local info = buffer_local and buf_commands[cmd] or global_commands[cmd]
                local desc = {}
                if info.bang then
                    table.insert(desc, 'bang: true')
                end
                if info.nargs then
                    table.insert(desc, 'nargs: ' .. info.nargs)
                end
                if info.definition and info.definition ~= '' then
                    table.insert(desc, 'Definition: ' .. info.definition)
                end
                entry = entry .. '\t' .. table.concat(desc, '\\n')
                table.insert(entries, entry)
            end
            return entries
        end

        fzf_entries = vim.tbl_extend(
            'force',
            build_entries(sorted_global_cmds),
            build_entries(sorted_buf_cmds, true)
        )

        -- 2. Process builtin commands
        local help = vim.fn.globpath(vim.o.runtimepath, 'doc/index.txt')
        if vim.uv.fs_stat(help) then
            local cmd, desc
            for line in io_utils.read_file(help):gmatch('[^\n]*\n') do
                -- Builtin command is in the line starting with `|:FOO`
                if line:match('^|:[^|]') then
                    if cmd then
                        table.insert(fzf_entries, cmd .. '\t' .. ansi_string(cmd, 'PreProc') .. '\tDescription: ' .. desc)
                    end
                    cmd, desc = line:match('^|:(%S+)|%s+%S+%s+(.*%S)')
                elseif cmd then
                    -- For desc that spans multiple lines
                    if line:match('^%s+%S') then
                        local desc_continue = line:match('^%s*(.*%S)')
                        desc = desc .. (desc_continue and ' ' .. desc_continue or '')
                    end
                    if line:match('^%s*$') then
                        break
                    end
                end
            end
            if cmd then
                table.insert(fzf_entries, cmd .. '\t' .. ansi_string(cmd, 'PreProc') .. '\tDescription: ' .. desc)
            end
        end

        write(fzf_entries)
    end

    fzf(spec, handle_contents)
end

vim.keymap.set('n', '<Leader>fc', function()
    run(commands)
end)

-- Registers
local function registers(from_resume)
    local spec = {
        ['sink*'] = function(lines)
            -- ENTER will paster the content in the selected register at the cursor position
            local reg = lines[1]:match("%[(.-)%]")
            local ok, text = pcall(vim.fn.getreg, reg)
            if ok and #text > 0 then
                ---@diagnostic disable-next-line: param-type-mismatch
                vim.api.nvim_paste(text, false, -1)
            end
        end,
        options = get_fzf_opts(from_resume, {
            '--read0',
            '--no-multi',
            '--prompt',
            'Registers> ',
            '--header',
            ':: ENTER (paste at cursor)',
            '--preview', -- show register content in preview
            "echo {} | sed '1s/^\\[[0-9A-Z\"-\\#\\=_/\\*\\+:\\.%]\\] //'",
            '--bind',
            set_label('Register {1}'),
        }),
    }

    local function handle_contents()
        local regs = { [["]], "-", "#", "=", "_", "/", "*", "+", ":", ".", "%" }
        -- Numbered registers
        for i = 0, 9 do
            table.insert(regs, tostring(i))
        end
        -- Named registers
        for i = 65, 90 do
            table.insert(regs, string.char(i))
        end

        local function escape_special(text)
            local gsub_map = {
                ['\3']  = '^C', -- <C-c>
                ['\27'] = '^[', -- <Esc>
                ['\18'] = '^R', -- <C-r>
            }
            for k, v in pairs(gsub_map) do
                text = text:gsub(k, ansi_string(v, 'PreProc')):gsub('\n$', '')
            end
            return text
        end

        -- Entry: <[register]> <text>
        local entries = {}
        for _, r in ipairs(regs) do
            local _, text = pcall(vim.fn.getreg, r)
            text = escape_special(text)
            if text and #text > 0 then
                table.insert(
                    entries,
                    string.format('[%s] %s\0', ansi_string(r, 'FzfLnum'), text)
                )
            end
        end

        write(entries, true)
    end

    fzf(spec, handle_contents)
end

vim.keymap.set('n', '<Leader>f"', function()
    run(registers)
end)

-- Zoxide
local function zoxide(from_resume)
    local preview_cmd = ''
    if vim.fn.executable('eza') == 1 then
        preview_cmd = 'eza -la --color=always --icons -g --group-directories-first {2}'
    else
        preview_cmd = 'gls -hFNla --color=always --group-directories-first --hyperlink=auto {2}'
    end
    local spec = {
        ['sink*'] = function(lines)
            -- ENTER will cd to the selected directory
            local cwd = lines[1]:match('[^\t]+$')
            if vim.uv.fs_stat(cwd) then
                -- Instead of changing cwd globally, we can change it locally: lcd (window local) or
                -- tcd (tab local)
                local cmd = 'cd'
                vim.cmd(cmd .. ' ' .. cwd)
                notify.info('cwd is set to ' .. cwd)
            end
        end,
        options = get_fzf_opts(from_resume, {
            '--nth',
            '2',
            '--no-multi',
            '--delimiter',
            '\t',
            '--tiebreak',
            'end,index',
            '--prompt',
            'Zoxide> ',
            '--header',
            ':: ENTER (cd to the dir)\n' .. string.format('%8s\t%s', 'score', 'directory'),
            '--preview',
            preview_cmd,
            '--bind',
            set_label('{2}'),
        }),
    }

    local function handle_contents()
        local entries = {}
        system.async('zoxide query --list --score', { text = true }, function(output)
            for line in output:gmatch('[^\n]+') do
                local score, dir = line:match('(%d+%.%d+)%s+(.-)$')
                -- Entry: <score>\t<directory>
                local entry = string.format('%8s\t%s', score, dir)
                table.insert(entries, entry)
            end
            write(entries)
        end, system_on_error)
    end

    fzf(spec, handle_contents)
end

vim.keymap.set('n', '<Leader>fz', function()
    run(zoxide)
end)

--
-- Find entries in quickfix and location list
--

local qf_type_hl = {
    E = 'DiagnosticError',
    W = 'DiagnosticWarn',
    I = 'DiagnosticInfo',
    H = 'DiagnosticHint',
}
local ansi_lnum_len = #ansi_string('', 'QuickfixLnum')
local ansi_col_len = #ansi_string('', 'QuickfixCol')
local qf_line_fmt = '%s |%' .. (tostring(5) + ansi_lnum_len) .. 's:%-' .. (tostring(3) + ansi_col_len) .. 's|%s %s'

---Construct the line shown in fzf quickfix finder. It has the same style as the line in quickfix.
---<filename> |<lnum>:<col>| <type> <text>
---@param item table
local function build_qf_fzf_line(item)
    item = qf.normalize(item)
    local type = item.type
    local text = item.text
    local type_hl = qf_type_hl[type]
    if type_hl then
        type = ansi_string(type, type_hl)
        text = ansi_string(text, type_hl)
    end
    local fzf_line = qf_line_fmt:format(
        ansi_string(item.filename, 'QuickfixFilename'),
        ansi_string(tostring(item.lnum), 'QuickfixLnum'),
        ansi_string(tostring(item.col), 'QuickfixCol'),
        type == '' and '' or ' ' .. type,
        text
    )
    return fzf_line
end

---@param win_local boolean true for location list and false for quickfix
local function qf_items_fzf(win_local, from_resume)
    local what = { items = 0, title = 0 }
    local list
    local spec = {
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
                    setqflist(new_what)
                elseif key == 'ctrl-l' then
                    setqflist(new_what, true)
                else
                    if win_local then
                        setqflist(new_what, true, 'u')
                    else
                        setqflist(new_what, false, 'u')
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
        options = get_fzf_opts(from_resume, {
            '--delimiter',
            '\t',
            '--prompt',
            win_local and 'Location List' or 'Quickfix List' .. '> ',
            '--header',
            ':: ENTER (display the error), CTRL-R (refine the current ' .. (win_local and 'loclist' or 'quickfix') .. ')\n:: CTRL-Q (send to quickfix), CTRL-L (send to loclist)',
            '--with-nth',
            '7..',
            '--expect',
            expect_keys({ 'ctrl-q', 'ctrl-l', 'ctrl-r' }),
            '--preview',
            bat_prefix .. ' --highlight-line {3} -- {2}',
            '--preview-window',
            '+{3}-/2' .. (theme == 'default' and ',down,45%' or ''),
            '--bind',
            set_label(tildefy_home('{2}') .. ':{3}:{4}: \\[{5}\\] {6}'),
        }),
    }

    local function handle_contents()
        local entries = {}
        list = win_local and vim.fn.getloclist(0, what) or vim.fn.getqflist(what)
        for _, item in ipairs(list.items) do
            local bufnr = item.bufnr
            local bufname = vim.api.nvim_buf_get_name(bufnr)
            local fzf_line = build_qf_fzf_line(item)
            -- The formatted entries will be fed to fzf.
            -- Each entry is like "index bufname lnum path/to/the/file:134:20 [E] error"
            -- The first three parts are used for fzf itself and won't be presented in fzf window.
            -- * index: display the error by :[nr]cc!
            -- * bufname and lnum: fzf preview
            entries[#entries + 1] = table.concat({
                #entries + 1,
                bufname,
                item.lnum,
                item.col,
                item.type,
                item.text,
                fzf_line,
            }, '\t')
        end
        write(entries)
    end

    fzf(spec, handle_contents)
end

local function quickfix_items(from_resume)
    qf_items_fzf(false, from_resume)
end

local function loclist_items(from_resume)
    qf_items_fzf(true, from_resume)
end

-- Quickfix list
vim.keymap.set('n', '<Leader>fq', function()
    run(quickfix_items)
end)

-- Location list
vim.keymap.set('n', '<Leader>fl', function()
    run(loclist_items)
end)

--
-- Quickfix list history and location list history
--

-- To preview the list, we dump all errors in the list to a temporary file and cat this file.
local err_tmpfile_prefix = vim.fn.tempname()
local err_tmpfile = ''

-- Show list history in fzf with preview support
-- Dump the errors in each list into a separate temp file, and cat this file to preview the list.
---@param win_local boolean Whether it's a window-local location list or quickfix list
local function qf_history_fzf(win_local, from_resume)
    local hist_cmd = win_local and 'lhistory' or 'chistory'
    local open_cmd = win_local and 'lopen' or 'copen'
    local prompt = win_local and 'Location List History' or 'Quickfix List History'
    local spec = {
        ['sink*'] = function(lines)
            local count = string.match(lines[1], '^(%d+)\t')
            vim.cmd('silent! ' .. count .. hist_cmd)
            vim.cmd(open_cmd)
        end,
        placeholder = '',
        options = get_fzf_opts(from_resume, {
            '--delimiter',
            '\t',
            '--with-nth',
            '3..',
            '--no-multi',
            '--prompt',
            prompt.. '> ',
            '--header',
            ':: ENTER (switch to selected list)',
            '--preview-window',
            theme == 'default' and 'down,45%' or '',
            '--preview',
            'cat {2}',
            '--bind',
            set_label('{3..}'),
        }),
    }

    local function handle_contents()
        local cur_nr = win_local and vim.fn.getloclist(0, { nr = 0 }).nr or vim.fn.getqflist({ nr = 0 }).nr
        local entries = {}
        for i = 1, 10 do
            local what = { nr = i, id = 0, title = true, items = true, size = true }
            local list = win_local and vim.fn.getloclist(0, what) or vim.fn.getqflist(what)
            if list.id == 0 then
                break
            end

            -- Build the temporary file name: prefix-rockyz-id for quickfix; prefix-rockyz-id-winid for
            -- loclist
            err_tmpfile = err_tmpfile_prefix .. '-rockyz-' .. list.id
            if win_local then
                err_tmpfile = err_tmpfile .. '-' .. vim.api.nvim_get_current_win()
            end

            -- Entry: <quickfix_id>\t<err_tmpfile>\t<[quickfix_id]> <size> items    <title>
            -- {3..} will be presented.
            -- {1} <quickfix_id> is used to switch to the specific quickfix list; {2} <err_tmpfile>
            -- is the path of the temporary file used by cat in fzf preview.
            local entry = i .. '\t' .. err_tmpfile .. '\t[' .. i .. '] ' .. list.size .. ' items    ' .. list.title
            if list.nr == cur_nr then
                entry = entry .. ' ' .. icons.caret.left
            end
            table.insert(entries, entry)

            -- Write errors in the list into the temporary file for previewing
            local errors = {}
            for _, item in ipairs(list.items) do
                if item == nil then
                    break
                end
                local str = build_qf_fzf_line(item)
                table.insert(errors, str)
            end
            io_utils.write_file_async(err_tmpfile, table.concat(errors, '\n'))
        end
        write(entries)
    end

    fzf(spec, handle_contents)
end

local function quickfix_history(from_resume)
    qf_history_fzf(false, from_resume)
end

local function loclist_history(from_resume)
    qf_history_fzf(true, from_resume)
end

-- List all the quickfix lists and switch to the selected one
vim.keymap.set('n', '<Leader>fQ', function()
    run(quickfix_history)
end)

-- List all the location lists for the current window and switch to the selected one
vim.keymap.set('n', '<Leader>fL', function()
    run(loclist_history)
end)

--
-- Grep
--
-- Live grep
-- It has two modes (ALT-M for switching between each other)
-- * RG mode (fzf will be just an interactive interface for RG)
-- * FZF mode (fzf will be the fuzzy finder for the current results of RG)
--

---Generate the fzf options for rg and fzf integration
---@param rg string The final rg command
---@param rg_query string The initial query for rg
---@param path string File or directory for rg to search
---@param prompt string Fzf prompt string
---@param extra_opts table? Extra fzf options
---@param from_resume boolean? Whether or not the finder is called from fzf resume
---@return table Fzf options for live grep
local function get_fzf_opts_for_live_grep(rg, rg_query, path, prompt, extra_opts, from_resume)
    extra_opts = extra_opts or {}
    if not from_resume then
        cached_rg_query = vim.fn.tempname()
        cached_fzf_query = vim.fn.tempname()
        in_fzf_mode = vim.fn.tempname() -- tempfile to record whether it is currently in fzf mode
    end
    local is_fzf_mode = vim.uv.fs_stat(in_fzf_mode)
    local mode = is_fzf_mode and 'FZF' or 'RG'
    local search_enabled = is_fzf_mode and true or false
    -- Initial rg query
    if from_resume and vim.uv.fs_stat(cached_rg_query) then
        rg_query = '"$(cat ' .. cached_rg_query .. ')"'
    else
        rg_query = vim.fn.shellescape(rg_query)
    end
    -- Initial fzf query
    local set_query = ''
    if from_resume then
        set_query = string.format(
            '+transform-query(cat %s)',
            is_fzf_mode and cached_fzf_query or cached_rg_query
        )
    end
    -- Unbind the change event if it is called by fzf resume and rg's initial mode is fzf mode
    local unbind_change = ''
    if from_resume and is_fzf_mode then
        unbind_change = '+unbind(change)'
    end
    -- Print quickfix title used in winbar of quickfix window
    -- E.g., "Live Grep: Rg Query foo | Fzf Query bar"
    local print_qf_title = 'transform(rg_query=$(cat ' .. cached_rg_query .. '); rg_query=${rg_query:-[empty]}; fzf_query=$(cat ' .. cached_fzf_query .. '); fzf_query=${fzf_query:-[empty]}; echo "print(' .. prompt .. ': Rg Query $rg_query | Fzf Query $fzf_query)")'

    local opts = vim.list_extend(vim.deepcopy(common_opts), {
        '--ansi',
        '--multi',
        '--prompt',
        string.format('%s [%s]> ', prompt, mode),
        '--bind',
        'start:reload(' .. rg .. ' ' .. rg_query .. ' ' .. path .. ')' .. set_query .. unbind_change,
        '--bind',
        'change:reload:' .. rg .. ' {q} ' .. path .. ' || true',
        '--bind',
        -- Cache the query into the specific tempfile based on the current mode
        'result:execute-silent([[ ! $FZF_PROMPT =~ FZF ]] && echo {q} > ' .. cached_rg_query .. ' || echo {q} > ' .. cached_fzf_query .. ')',
        '--bind',
        'alt-m:transform:\
        [[ ! $FZF_PROMPT =~ FZF ]] && { \
            touch ' .. in_fzf_mode .. '; \
            echo "unbind(change)+change-prompt(' .. prompt .. ' [FZF]> )+enable-search+transform-query(cat ' .. cached_fzf_query .. ')"; \
        } || { \
            rm ' .. in_fzf_mode .. '; \
            echo "change-prompt(' .. prompt .. ' [RG]> )+disable-search+reload(' .. rg .. ' {q} || true)+rebind(change)+transform-query(cat ' .. cached_rg_query .. ')"\
        }',
        '--bind',
        set_label(tildefy_home('{1}') .. ':{2}:{3}'),
        '--delimiter',
        ':',
        '--header',
        ':: ALT-M (toggle FZF mode and RG mode), CTRL-Q (send to quickfix), CTRL-L (send to loclist)',
        '--bind',
        'enter:print()+accept,ctrl-x:print(ctrl-x)+accept,ctrl-v:print(ctrl-v)+accept,ctrl-t:print(ctrl-t)+accept',
        '--bind',
        'ctrl-l:print(ctrl-l)+' .. print_qf_title .. '+accept',
        '--bind',
        'ctrl-q:print(ctrl-q)+' .. print_qf_title .. '+accept',
        '--preview-window',
        '+{2}-/2' .. (theme == 'default' and ',down,45%' or ''),
        '--preview',
        bat_prefix .. ' --highlight-line {2} -- {1}',
    })

    if not search_enabled then
        table.insert(opts, '--disabled')
    end
    return vim.list_extend(opts, extra_opts)
end

---Send selections in grep to quickfix or location list
---@param lines table lines[1] is the key (ctrl-q or ctrl-l); lines[2] is the title for quickfix or
---loclist; lines[3..] are selected lines.
---@param is_loclist boolean? Send to location list or not
local function grep_sel_to_qf(lines, is_loclist)
    local qf_items = {}
    for i = 3, #lines do
        local filename, lnum, col, text = lines[i]:match('^([^:]+):([^:]+):([^:]+):(.*)$')
        local bufnr = vim.fn.bufnr(filename)
        table.insert(qf_items, {
            bufnr = bufnr ~= -1 and bufnr or nil,
            filename = filename,
            lnum = tonumber(lnum),
            col = tonumber(col),
            text = text,
        })
    end
    table.sort(qf_items, function(a, b)
        if a.filename == b.filename then
            if a.lnum == b.lnum then
                return math.max(0, a.col) < math.max(0, b.col)
            else
                return math.max(0, a.lnum) < math.max(0, b.lnum)
            end
        else
            return a.filename < b.filename
        end
    end)
    local title = lines[2]
    local what = { nr = '$', title = title, items = qf_items }
    if is_loclist then
        setqflist(what, true)
    else
        setqflist(what, false)
    end
end

---sink* for live grep
---ENTER/CTRL-X/CTRL-V/CTRL-T to open files and set cursor position
---CTRL-Q/CTRL-L to send selections to quickfix or location list
---@param lines table lines[1] is the query used as the title when sent to qf. For CTRL-Q/CTRL-L,
---lines[2] is the title for quickfix or loclist and lines[3..] are selected lines. For other keys,
---lines[2..] are selected lines.
local function sink_grep(lines)
    local key = lines[1]
    if key == 'ctrl-q' then
        grep_sel_to_qf(lines)
    elseif key == 'ctrl-l' then
        grep_sel_to_qf(lines, true)
    else
        for i = 2, #lines do
            local filename, lnum, col = lines[i]:match('^([^:]+):([^:]+):([^:]+):.*$')
            local cmd = vim.g.fzf_action[key] or 'edit'
            -- if vim.fn.fnamemodify(lines[i], ':p') ~= vim.fn.expand('%:p') then
            -- end
            vim.cmd(cmd .. ' ' .. filename)
            vim.api.nvim_win_set_cursor(0, { tonumber(lnum), tonumber(col) - 1 })
        end
    end
end

-- Live grep
local function live_grep(from_resume)
    local rg_cmd = rg_prefix .. ' --'
    local spec = {
        ['sink*'] = sink_grep,
        options = get_fzf_opts_for_live_grep(rg_cmd, '', '', 'Live Grep', {}, from_resume)
    }
    fzf(spec, nil, rg_cmd)
end

vim.keymap.set('n', '<C-g>', function()
    run(live_grep)
end)

-- Live grep in Neovim config
local function live_grep_nvim_config(from_resume)
    local rg_cmd = rg_prefix .. ' --glob=!minpac --'
    local path = vim.env.HOME .. '/.config/nvim'
    local spec = {
        ['sink*'] = sink_grep,
        -- Instead of specify the path in rg command, we can set dir field in spec dict. fzf#run
        -- will lcd to this dir.
        -- dir = path,
        options = get_fzf_opts_for_live_grep(rg_cmd, '', path, 'Nvim Config [LGrep]', {}, from_resume)
    }
    fzf(spec, nil, rg_cmd)
end

vim.keymap.set('n', '<Leader>gv', function()
    run(live_grep_nvim_config)
end)

-- Live grep for current buffer
local function live_grep_cur_buffer(from_resume)
    local rg_cmd = rg_prefix .. ' --'
    local filename = vim.api.nvim_buf_get_name(0)
    if #filename == 0 or not vim.uv.fs_stat(filename) then
        notify.warn('Current buffer should be valid')
        return
    end
    local spec = {
        ['sink*'] = sink_grep,
        options = get_fzf_opts_for_live_grep(rg_cmd, '', filename, 'Buffer [LGrep]', {
            '--with-nth',
            '2..',
            '--header',
            ':: Current Buf: ' .. vim.fn.expand('%:~:.'),
        }, from_resume)
    }
    fzf(spec, nil, rg_cmd)
end

vim.keymap.set('n', 'g/', function()
    run(live_grep_cur_buffer)
end)

-- Grep for current word or VISUAL selection
local cached_grep_word_rg_query = '' -- cache rg query for fzf resume
local function grep_cur_word(from_resume)
    local rg_query
    if from_resume then
        rg_query = cached_grep_word_rg_query
    elseif vim.fn.mode() == 'v' then
        local saved_reg = vim.fn.getreg('v')
        vim.cmd([[noautocmd sil norm "vy]])
        rg_query = vim.fn.getreg('v')
        vim.fn.setreg('v', saved_reg)
    else
        rg_query = vim.fn.expand('<cword>')
    end
    cached_grep_word_rg_query = rg_query

    -- Print quickfix title used in winbar of quickfix window
    -- E.g., "Word Grep: Word/Selection foo | Fzf Query bar"
    local print_qf_title = 'transform(echo "print(Word Grep: Word/Selection ' .. (rg_query == '' and '[empty]' or rg_query) .. ' | Fzf Query xxxxxx)")'

    local spec = {
        ['sink*'] = sink_grep,
        options = get_fzf_opts(from_resume, {
            '--delimiter',
            ':',
            '--prompt',
            'Word [Grep]> ',
            '--preview-window',
            '+{2}-/2' .. (theme == 'default' and ',down,45%' or ''),
            '--preview',
            bat_prefix .. ' --highlight-line {2} -- {1}',
            '--header',
            ':: Word/Selection: ' .. ansi_string(rg_query, 'FzfRgQuery'),
            '--bind',
            set_label('{1}:{2}:{3}'),
            '--bind',
            'enter:print()+accept,ctrl-x:print(ctrl-x)+accept,ctrl-v:print(ctrl-v)+accept,ctrl-t:print(ctrl-t)+accept',
            '--bind',
            'ctrl-q:print(ctrl-q)+' .. print_qf_title .. '+accept',
            '--bind',
            'ctrl-l:print(ctrl-l)+' .. print_qf_title .. '+accept',
        }),
    }

    rg_query = vim.fn.escape(rg_query, '.*+?()[]{}\\|^$')
    local rg_cmd = rg_prefix .. ' -- ' .. vim.fn['fzf#shellescape'](rg_query)

    fzf(spec, nil, rg_cmd)
end

vim.keymap.set({ 'n', 'x' }, '<Leader>g*', function()
    run(grep_cur_word)
end)

--
-- LSP
--
-- Each fzf entry consists of 6 parts: index, offset_encoding, filename, lnum, col, fzf_line.
--
-- Only fzf_line will be presented in fzf. index is used to fetch the corresponding qf items from
-- the selected fzf entries. offset_encoding is used for jumping to the location. filename, lnum and
-- col are used for fzf preview and border label.
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
local function symbol_conversion(symbols, ctx, guide_prev, all_entries, all_items)
    if symbols == nil then
        return
    end
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    if not client then
        return
    end

    -- Tree guide symbols
    local guide_vert = icons.tree.vertical
    local guide_mid = icons.tree.middle
    local guide_last = icons.tree.last

    local client_name = client.name
    local colored_client_name = ansi_string(client_name, 'FzfDesc')
    local offset_encoding = client.offset_encoding
    local bufnr = ctx.bufnr

    -- For document symbols, this function will be called recursively if the symbol has children
    local function _symbol_conversion(_symbols, _guide_prev)
        for i, symbol in ipairs(_symbols) do

            local filename, range
            if symbol.location then
                -- LSP's WorkspaceSymbol[]
                filename = vim.uri_to_fname(symbol.location.uri)
                range = symbol.location.range
            elseif symbol.selectionRange then
                -- LSP's DocumentSymbol[]
                filename = vim.api.nvim_buf_get_name(bufnr)
                range = symbol.selectionRange
            end

            if filename and range then
                local kind = vim.lsp.protocol.SymbolKind[symbol.kind] or 'Unknown'
                local icon = icons.symbol_kinds[kind]
                local colored_icon_kind = ansi_string(icon .. ' ' .. kind, 'SymbolKind' .. kind)

                local row = range['start'].line
                local end_row = range['end'].line

                local lnum = row + 1
                local end_lnum = end_row + 1

                local col = range['start'].character
                if col > 0 then
                    local line = api.get_lines(bufnr, { row })[row] or ''
                    col = vim.str_byteindex(line, offset_encoding, col, false)
                end
                col = col + 1

                local end_col = range['end'].character
                if end_col > 0 then
                    local end_line = api.get_lines(bufnr, { end_row })[end_row] or ''
                    end_col = vim.str_byteindex(end_line, offset_encoding, end_col, false)
                end
                end_col = end_col + 1

                local fzf_line
                if symbol.location then
                    -- Workspace symbols
                    local devicon = ansi_devicon(filename)
                    local part1 = '[' .. colored_icon_kind .. '] ' .. symbol.name .. ' ' .. colored_client_name
                    local part1_no_color = '[' .. icon .. ' ' .. kind .. '] ' .. symbol.name .. client_name
                    fzf_line = string.format(
                        '%s %s%s%s:%s:%s',
                        part1,
                        string.rep(' ', 70 - #part1_no_color), -- add spaces for alignment
                        devicon == '' and devicon or (devicon .. ' '),
                        ansi_string(vim.fn.fnamemodify(filename, ':~:.'), 'FzfFilename'),
                        ansi_string(tostring(lnum), 'FzfLnum'),
                        ansi_string(tostring(col), 'FzfCol')
                    )
                else
                    -- Document symbols
                    local guide = ''
                    if _guide_prev ~= '' then
                        guide = _guide_prev .. (i == #_symbols and guide_last or guide_mid)
                    end
                    fzf_line = guide .. '[' .. colored_icon_kind .. '] ' .. symbol.name .. ' ' .. colored_client_name
                end

                local qf_text = '[' .. icon .. ' ' .. kind .. '] ' .. symbol.name .. ' (' .. client_name .. ')'

                all_entries[#all_entries + 1] = table.concat({
                    #all_entries + 1,
                    offset_encoding,
                    filename,
                    lnum,
                    col,
                    fzf_line,
                }, '\t')

                all_items[#all_items + 1] = {
                    filename = filename,
                    lnum = lnum,
                    end_lnum = end_lnum,
                    col = col,
                    end_col = end_col,
                    text = qf_text,
                    user_data = symbol.location,
                }
            end

            -- Recursive traverse child symbols if there are any (only available for document
            -- symbols)
            if symbol.children then
                _symbol_conversion(symbol.children, _guide_prev .. (i == #_symbols and '  ' or guide_vert))
            end
        end
    end

    _symbol_conversion(symbols, guide_prev)
end

---Send request document symbols or workspace symbols and then execute fzf
---@param title string The title for quickfix list and fzf prompt
---@param symbol_query string|nil The query for requesting workspace symbols. It will be nil for
---document symbol request
---@param from_resume boolean? Whether it is called from fzf resume or not
local function lsp_symbols(method, params, title, symbol_query, from_resume)
    local bufnr = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients({ method = method, bufnr = bufnr })
    if not next(clients) then
        notify.warn(string.format('No active clients supporting %s method', method))
        return
    end

    local all_entries = {} -- fzf entries
    local all_items = {} -- quickfix items

    local fzf_header = ':: CTRL-Q (send to quickfix), CTRL-L (send to loclist)'
    local fzf_preview_window = '+{4}-/2'
    if symbol_query then
        fzf_header = ':: Query: ' .. (symbol_query == '' and '[empty]' or ansi_string(symbol_query, 'FzfRgQuery')) .. '\n' .. fzf_header
        fzf_preview_window = fzf_preview_window .. (theme == 'default' and ',down,45%' or '')
    end

    local spec = {
        ['sink*'] = function(lines)
            local key = lines[1]
            if key == 'ctrl-q' or key == 'ctrl-l' then
                -- CTRL-Q: send to quickfix; CTRL-L: send to location list
                local loclist = key == 'ctrl-l'
                local qf_items = {}
                for i = 2, #lines do
                    local idx = tonumber(lines[i]:match('^(%d+)\t'))
                    table.insert(qf_items, all_items[idx])
                end
                local what = { title = title, items = qf_items }
                if loclist then
                    setqflist(what, true)
                else
                    setqflist(what)
                end
            else
                -- ENTER/CTRL-X/CTRL-V/CTRL-T with multiple selections
                local action = vim.g.fzf_action[key]
                for i = 2, #lines do
                    if action then
                        vim.cmd(action)
                    end
                    local idx = tonumber(lines[i]:match('^(%d+)\t'))
                    local item = all_items[idx]
                    local offset_encoding = lines[i]:match('^%d+\t([^\t]+)\t')
                    if symbol_query then
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
        options = get_fzf_opts(from_resume, {
            '--delimiter',
            '\t',
            '--with-nth',
            '6..',
            '--prompt',
            title .. '> ',
            '--header',
            fzf_header,
            '--expect',
            expect_keys({ 'ctrl-q', 'ctrl-l' }),
            '--preview',
            bat_prefix .. ' --highlight-line {4} -- {3}',
            '--preview-window',
            fzf_preview_window,
            '--bind',
            set_label(tildefy_home('{3}:{4}:{5}')),
        }),
    }

    local function handle_contents()
        local remaining = #clients
        for _, client in ipairs(clients) do
            client:request(method, params, function(_, result, ctx)
                symbol_conversion(result, ctx, '', all_entries, all_items)
                remaining = remaining - 1
                if remaining == 0 then
                    write(all_entries)
                end
            end, bufnr)
        end
    end

    fzf(spec, handle_contents)
end

-- LSP document symbols
vim.keymap.set('n', 'gO', function()
    run(function(from_resume)
        local params = { textDocument = vim.lsp.util.make_text_document_params() }
        lsp_symbols('textDocument/documentSymbol', params, 'LSP Document Symbols', nil, from_resume)
    end)
end)

-- Resume of workspace_symbols finder needs the predefined symbol query
local cached_symbol_query = ''
local function workspace_symbols_resume(from_resume)
    local params = { query = cached_symbol_query }
    lsp_symbols('workspace/symbol', params, 'LSP Workspace Symbols', cached_symbol_query, from_resume)
end

-- LSP workspace symbols
vim.keymap.set('n', 'gr/', function()
    local symbol_query = vim.fn.input('Query: ')
    cached_symbol_query = symbol_query
    cached_finder = workspace_symbols_resume
    local params = { query = symbol_query }
    lsp_symbols('workspace/symbol', params, 'LSP Workspace Symbols', symbol_query)
end)

--
-- LSP definitions, references, implementations, declarations, type definitions
--

-- Convert lsp.Location[] to fzf entries and quickfix items
local function locations_to_entries_and_items(locations, ctx, all_entries, all_items)
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    if not client then
        return
    end

    local items = vim.lsp.util.locations_to_items(locations, client.offset_encoding)
    vim.list_extend(all_items, items)
    -- Construct fzf entries
    for _, item in ipairs(items) do
        local filename = item.filename
        local lnum = item.lnum
        local col = item.col
        local icon = ansi_devicon(filename)
        local fzf_line = icon == '' and icon or icon .. ' '
        ---@diagnostic disable-next-line: param-type-mismatch
        .. ansi_string(vim.fn.fnamemodify(filename, ':~:.'), 'FzfFilename')
        .. ':' .. ansi_string(tostring(lnum), 'FzfLnum')
        .. ':' .. ansi_string(tostring(col), 'FzfCol')
        .. ': ' .. item.text
        local entry = table.concat({
            #all_entries + 1,
            client.offset_encoding,
            filename,
            lnum,
            col,
            fzf_line,
        }, '\t')
        table.insert(all_entries, entry)
    end
end

local function lsp_locations(method, title, from_resume)
    local bufnr = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients({ method = method, bufnr = bufnr })
    if not next(clients) then
        notify.warn(string.format('No active clients supporting %s method', method))
        return
    end
    local win = vim.api.nvim_get_current_win()

    local all_entries = {}
    local all_items = {}

    local spec = {
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
                local what = { title = title, items = qf_items }
                if loclist then
                    setqflist(what, true)
                else
                    setqflist(what)
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
                    local offset_encoding = lines[i]:match('^%S+%s(%S+)')
                    vim.lsp.util.show_document(item.user_data, offset_encoding)
                end
            end
        end,
        options = get_fzf_opts(from_resume, {
            '--delimiter',
            '\t',
            '--with-nth',
            '6..',
            '--prompt',
            title .. '> ',
            '--header',
            ':: CTRL-Q (send to quickfix), CTRL-L (send to loclist)',
            '--expect',
            expect_keys({ 'ctrl-q', 'ctrl-l' }),
            '--preview',
            bat_prefix .. ' --highlight-line {4} -- {3}',
            '--preview-window',
            '+{4}-/2' .. (theme == 'default' and ',down,45%' or ''),
            '--bind',
            set_label(tildefy_home('{3}:{4}:{5}')),
        }),
    }

    local function handle_contents()
        local remaining = #clients
        for _, client in ipairs(clients) do
            local params = vim.lsp.util.make_position_params(win, client.offset_encoding)
            if method == 'textDocument/references' then
                ---@diagnostic disable-next-line: inject-field
                params.context = { includeDeclaration = true }
            end
            client:request(method, params, function(_, result, ctx)
                locations_to_entries_and_items(result or {}, ctx, all_entries, all_items)
                remaining = remaining - 1
                if remaining == 0 then
                    write(all_entries)
                end
            end, bufnr)
        end
    end

    fzf(spec, handle_contents)
end

-- LSP definitions
vim.keymap.set('n', '<Leader>ld', function()
    run(function(from_resume)
        lsp_locations('textDocument/definition', 'LSP Definitions', from_resume)
    end)
end)
-- LSP references
vim.keymap.set('n', '<Leader>lr', function()
    run(function(from_resume)
        lsp_locations('textDocument/references', 'LSP References', from_resume)
    end)
end)
-- LSP implementations
vim.keymap.set('n', '<Leader>li', function()
    run(function(from_resume)
        lsp_locations('textDocument/implementation', 'LSP Implementations', from_resume)
    end)
end)
-- LSP declarations
vim.keymap.set('n', '<Leader>lD', function()
    run(function(from_resume)
        lsp_locations('textDocument/declaration', 'LSP Declarations', from_resume)
    end)
end)
-- LSP type definitions
vim.keymap.set('n', '<Leader>lt', function()
    run(function(from_resume)
        lsp_locations('textDocument/typeDefinition', 'LSP Type Definitions', from_resume)
    end)
end)

--
-- Diagnostics
--

local function diagnostics(from_resume, opts)
    opts = opts or {}
    local curbuf = vim.api.nvim_get_current_buf()
    local diags = vim.diagnostic.get(not opts.all and curbuf or nil)
    if vim.tbl_isempty(diags) then
        notify.warn('No diagnostics')
        return
    end

    local title = string.format('Diagnostics (%s)', opts.all and 'workspace' or 'document')
    local spec = {
        -- NOTE:
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
                    local idx = tonumber(lines[i]:match('^(%d+)\t'))
                    if idx then
                        table.insert(selected_diags, diags[idx])
                    end
                end
                local items = vim.diagnostic.toqflist(selected_diags)
                local what = { title = title, items = items }
                if loclist then
                    setqflist(what, true)
                else
                    setqflist(what)
                end
            else
                -- ENTER/CTRL-X/CTRL-V/CTRL-T
                local action = vim.g.fzf_action[key]
                for i = 2, #lines do
                    local idx = tonumber(lines[i]:match('^(%d+)\t'))
                    if idx then
                        if action then
                            vim.cmd(action)
                        end
                        local diag = diags[idx]
                        local bufnr = diag.bufnr
                        if bufnr and vim.api.nvim_buf_is_loaded(bufnr) then
                            vim.cmd('buffer! ' .. bufnr)
                        else
                            vim.cmd('edit! ' .. vim.fn.bufname(bufnr))
                        end
                        vim.api.nvim_win_set_cursor(0, { diag.lnum + 1, diag.col })
                        vim.cmd('normal! zvzz')
                    end
                end
            end
        end,
        options = get_fzf_opts(from_resume, {
            '--delimiter',
            '\t',
            '--read0',
            '--highlight-line',
            '--with-nth',
            '5..',
            '--prompt',
            title .. '> ',
            '--header',
            ':: CTRL-Q (send to quickfix), CTRL-L (send to loclist)',
            '--expect',
            expect_keys({ 'ctrl-q', 'ctrl-l' }),
            '--preview',
            bat_prefix .. ' --highlight-line {3} -- {2}',
            '--preview-window',
            '+{3}-/2',
            '--bind',
            set_label(tildefy_home('{2}:{3}:{4}')),
        }),
    }

    local function handle_contents()
        local diag_icons = {
            { text = 'E', hl = 'DiagnosticError', }, -- Error
            { text = 'W', hl = 'DiagnosticWarn', }, -- Warn
            { text = 'I', hl = 'DiagnosticInfo', }, -- Info
            { text = 'H', hl = 'DiagnosticHint', }, -- Hint
        }

        local entries = {}
        for _, diag in ipairs(diags) do
            local bufnr = diag.bufnr
            ---@diagnostic disable-next-line: param-type-mismatch
            local filename = vim.api.nvim_buf_get_name(bufnr)
            local devicon = ansi_devicon(filename)
            local diag_icon = ansi_string(diag_icons[diag.severity].text, diag_icons[diag.severity].hl)
            local lnum = diag.lnum + 1
            local col = diag.col + 1
            -- Entry: <index>\t<filename>\t<lnum>\t<col>\t<fzf_line>
            -- Only fzf_line will be presented in fzf. The first part, <index>, is used to retrieve the
            -- corresponding original diagnostic item from the selected entry in fzf.
            local fzf_line = string.format(
                -- Use `\0` and fzf's `--read0` to support multi-line items
                -- Ref: https://junegunn.github.io/fzf/tips/processing-multi-line-items/
                '%s %s %s:%s:%s:\n%s%s\0',
                diag_icon,
                devicon,
                ansi_string(vim.fn.fnamemodify(filename, ':~:.'), 'QuickfixFilename'),
                ansi_string(tostring(lnum), 'QuickfixLnumCol'),
                ansi_string(tostring(col), 'QuickfixLnumCol'),
                string.rep(' ', 2) .. (diag.source and '[' .. diag.source .. '] ' or ''),
                string.gsub(diag.message, '\n', '\n' .. string.rep(' ', 2))
            )
            table.insert(entries, table.concat({
                #entries + 1,
                filename,
                lnum,
                col,
                fzf_line
            }, '\t'))
        end
        write(entries, true)
    end

    fzf(spec, handle_contents)
end

-- Diagnostics (document)
vim.keymap.set('n', '<Leader>fd', function()
    run(function(from_resume)
        diagnostics(from_resume)
    end)
end)
-- Diagnostics (workspace)
vim.keymap.set('n', '<Leader>fD', function()
    run(function(from_resume)
        diagnostics(from_resume, { all = true })
    end)
end)

--
-- Git
--

---Helper function to get git root dir
---@param dir string?
local function get_git_root(dir)
    if not dir then
        local path = vim.fn.expand('%:p:h')
        -- Extract everything before ".git"
        dir = path:match('^(.-)[/\\]%.git[/\\]?.*$') or path
        -- Remove "fugitive://" from the beginning
        dir = dir:gsub('^fugitive://', '')
    end
    local cmd = { 'git', '-C', dir, 'rev-parse', '--show-toplevel' }
    local obj = system.sync(cmd)
    if obj.code ~= 0 then
        system_on_error(obj.stderr, obj.stdout)
        return nil
    end
    return obj.stdout:gsub('\n$', '')
end

-- Git files
local function git_files(from_resume)
    local git_root = get_git_root()
    if git_root == nil then
        return
    end

    local arg = (vim.env.GIT_DIR == vim.env.HOME .. '/dotfiles') and 'dot' or ''
    local git_cmd = 'ls-gitfiles ' .. arg .. ' | ' .. dressup_cmd('ls_gitfiles')

    local spec = {
        ['sink*'] = sink_file,
        options = get_fzf_opts(from_resume, {
            '--delimiter',
            '\t',
            '--with-nth',
            '1',
            '--prompt',
            'Git Files> ',
            '--expect',
            expect_keys(),
            '--preview',
            'line={} \
            if [[ "${line:1:2}" =~ D ]]; then \
                if git show HEAD:{2} | file - | grep -q text; then \
                    git show HEAD:{2} | bat --color=always --style=numbers \
                else \
                    echo "No preview for this deleted file" \
                fi \
            else \
                ' .. fzf_previewer .. ' ' .. git_root .. '/{2} \
            fi \
            ',
            '--accept-nth',
            git_root .. '/{2}',
            '--header',
            'Git Root: ' .. vim.fn.fnamemodify(git_root, ':~'),
            '--bind',
            set_label('{2}'),
        }),
    }

    fzf(spec, nil, git_cmd)
end

vim.keymap.set('n', '<C-p>', function()
    run(git_files)
end)

-- Git status
local function git_status(from_resume)
    local root_dir = get_git_root()
    if root_dir == nil then
        return
    end

    local git = 'git -C ' .. root_dir

    local spec = {
        ['sink*'] = function(lines)
            local key = lines[1]
            local filenames = {}
            -- Extract filename in each selected entry
            for i = 2, #lines do
                local file = lines[i]:match('\t(.*)')
                if file and file ~= '' then
                    table.insert(filenames, file)
                end
            end
            local files_newline = table.concat(filenames, '\n')
            local files_str = table.concat(filenames, ' ')
            local file_or_files = #filenames > 1 and 'files' or 'the file'
            if key == 'ctrl-h' then
                -- CTRL-H to unstage
                ui.input_yes(string.format('%s\nUnstage %s above? (y/N)', files_newline, file_or_files), function()
                    system.async(git .. ' reset -- ' .. files_str, {}, function(output)
                        notify.info(output)
                    end, system_on_error)
                end)
            elseif key == 'ctrl-l' then
                -- CTRL-L to stage
                ui.input_yes(string.format('%s\nStage %s above? (y/N)', files_newline, file_or_files), function()
                    system.async(git .. ' add -- ' .. files_str, {}, function(output)
                        notify.info(output)
                    end, system_on_error)
                end)
            elseif key == 'ctrl-r' then
                -- CTRL-R to reset, i.e., discard all changes including both staged changes and
                -- unstaged changes
                ui.input_yes(string.format('%s\nReset %s above (y/N)', files_newline, file_or_files), function()
                    for i = 2, #lines do
                        local is_untracked = lines[i]:match('^%[%?%?%]')
                        local cmd = is_untracked and
                            (git .. ' clean -f ' .. filenames[i - 1]) or
                            (git .. ' checkout HEAD -- ' .. filenames[i - 1])
                        system.async(cmd, {}, vim.schedule_wrap(function(output)
                            vim.cmd('checktime')
                            notify.info(output)
                        end), system_on_error)
                    end
                end)
            end
        end,
        options = get_fzf_opts(from_resume, {
            '--delimiter',
            '\t',
            '--with-nth',
            1,
            '--prompt',
            'Git Status> ',
            '--header',
            ':: CTRL-H (unstage), CTRL-L (stage), CTRL-R (reset)',
            '--expect',
            expect_keys({ 'ctrl-h', 'ctrl-l', 'ctrl-r' }, true),
            '--preview',
            -- Three cases:
            -- 1) Untracked:
            --   folder: list contents of the folder by tree
            --   file: git diff --no-index /dev/null <file>
            -- 2) Unstaged: git diff <file>
            -- 3) Staged: git diff --staged <file>
            'git_status=$(' .. git .. ' status -s -uall -- {2}) \
            if (echo $git_status | grep "^??") &>/dev/null; then \
                if [[ -d {2} ]]; then \
                    tree -C {2} \
                else \
                    ' .. git .. ' diff --no-index -- /dev/null {2} ' .. diff_pager .. ' \
                fi \
            else \
                diff_output=$(' .. git .. ' diff -- {2}) \
                if [[ -n $diff_output ]]; then \
                    echo $diff_output ' .. diff_pager .. ' \
                else \
                    ' .. git .. ' diff --staged -- {2} ' .. diff_pager .. ' \
                fi \
            fi',
            '--bind',
            set_label('{1}'),
        }),
    }

    -- Fzf entry is [<staged><unstaged>] <git status text>\t<filename> with \t as delimiter.
    -- {1} is displayed in fzf and it could be one of
    -- 1. [ M] file1
    -- 2. [MM] file2
    -- 3. [R ] oldfile -> newfile
    -- 4. [??] newfile

    local git_cmd = 'git -c colors.status=false --no-optional-locks status --porcelain=v1'
    if vim.env.GIT_DIR == vim.env.HOME .. '/dotfiles' then
        git_cmd = git_cmd .. ' -uall ' .. vim.env.XDG_CONFIG_HOME
    end
    git_cmd = git_cmd .. ' | ' .. dressup_cmd('git_status')

    fzf(spec, nil, git_cmd)
end

vim.keymap.set('n', ',fs', function()
    run(git_status)
end)

-- Git branches
local function git_branches(from_resume)
    -- Extract the branch name for fzf preview and border label
    --
    --   entry                            |  extracted branch
    --------------------------------------+-----------------
    --   branch                           |    branch
    --   remotes/origin/branch            |    remotes/origin/branch
    -- * (HEAD detached at origin/branch) |    origin/branch
    --
    local extract_branch_cmd = ' \
        [[ {1} == "*" ]] && branch={2} || branch={1}; \
        [[ $branch == "(HEAD" ]] && entry={} && branch=${entry#*\\(HEAD detached at } && branch=${branch%%\\)*}; \
        echo $branch \
    '
    local root_dir = get_git_root()
    if root_dir == nil then
        return
    end
    local spec = {
        ['sink*'] = function(lines)
            local key = lines[1]
            if key == '' and #lines == 2 then
                -- ENTER to checkout the branch
                local cmd = { 'git', '-C', root_dir, 'switch' }
                local branch = lines[2]:match('[^ ]+')
                -- Do nothing of the selected branch is the currently active
                if branch:find('%*') ~= nil then
                    return
                end
                if branch:find('^remotes/') then
                    branch = branch:match('remotes/.-/(.-)$')
                    print(branch)
                end
                table.insert(cmd, branch)
                notify.info('Switching to ' .. branch .. ' branch...')
                system.async(cmd, {}, vim.schedule_wrap(function(_)
                    vim.cmd('checktime')
                    notify.info('Switched to ' .. branch .. ' branch.')
                end), system_on_error)
            elseif key == 'alt-bs' then
                -- ALT-BS to delete branches
                local cmd_del_branch = { 'git', '-C', root_dir, 'branch', '--delete' }
                local cmd_cur_branch = { 'git', '-C', root_dir, 'rev-parse', '--abbrev-ref', 'HEAD' }
                local cur_branch = system.sync(cmd_cur_branch).stdout
                local del_branches = {}
                for i = 2, #lines do
                    local branch = lines[i]:match('[^%s%*]+')
                    if branch ~= cur_branch then
                        table.insert(del_branches, branch)
                    end
                end
                local msg = string.format(
                    'Delete %s %s',
                    #del_branches > 1 and 'branches' or 'branch',
                    table.concat(del_branches, ', ')
                )
                vim.ui.input({
                    prompt = msg .. '? (y/N)',
                }, function(input)
                    if input and input:lower() == 'y' then
                        cmd_del_branch = vim.list_extend(cmd_del_branch, del_branches)
                        system.async(cmd_del_branch, {}, function(output)
                            notify.info(output)
                        end, system_on_error)
                    end
                end)
            end
        end,
        options = get_fzf_opts(from_resume, {
            '--prompt',
            'Git Branches> ',
            '--expect',
            'alt-bs',
            '--header',
            ':: ENTER (checkout), ALT-BS (delete branches)',
            '--preview-window',
            theme == 'default' and 'down,60%' or '',
            '--preview',
            'git log --graph --pretty=oneline --abbrev-commit --color $(' .. extract_branch_cmd .. ')',
            '--bind',
            set_label('Branch: $(' .. extract_branch_cmd .. ')'),
        })
    }

    local function handle_contents()
        local entries = {}
        system.async('git branch --all -vv --color', { text = true }, function(output)
            for line in output:gmatch('[^\n]+') do
                table.insert(entries, line)
            end
            write(entries)
        end, system_on_error)
    end

    fzf(spec, handle_contents)
end

vim.keymap.set('n', ',fb', function()
    run(git_branches)
end)

-- Git commits

---Build the command for fzf preview
---@param root_dir string Git root directory
---@param range table? { start_line, end_line } as the range of VISUAL selection
local function get_preview_cmd_git_commits(root_dir, range)
    -- orderfile used for "git show -O" to display the current file as the first one
    local orderfile = vim.fn.tempname()
    local bufname = vim.api.nvim_buf_get_name(0)
    local file = io.open(orderfile, 'w')
    if file then
        file:write(bufname:sub(#root_dir + 2))
        file:close()
    end

    local preview_cmd = ''

    if range then
        preview_cmd = string.format('git log -L %d,%d:%s', range[1], range[2], bufname)
    else
        -- Extract the hash commit and use git show to preview it
        preview_cmd = 'hash=$(echo {} | grep -o "[a-f0-9]\\{7,\\}" | head -1); git show -O' .. orderfile .. ' --format=format: --color=always $hash'
    end
    return preview_cmd .. ' ' .. diff_pager
end

---Get the sink function for git commits
local function get_sink_fn_git_commits(root_dir)
    ---Extract the commit hash from git log output
    ---"* 81055ee nvim(fzf): remove fzf.vim 3 days ago <Rocky Zhang>" --> "81055ee"
    local function extract_hash(line)
        local s, e = vim.regex('[0-9a-f]\\{7,40}'):match_str(line)
        return line:sub(s + 1, e)
    end

    return function(lines)
        local key = lines[1]
        if key == 'ctrl-y' then
            -- CTRL-Y to copy the commit hashes
            local hashes = table.concat(vim.iter({unpack(lines, 2)}):map(function(v)
                return extract_hash(v)
            end):totable(), ' ')
            if not hashes then
                return
            end
            local reg
            local selection_regs = { unnamed = [[*]], unnamedplus = [[+]] }
            reg = selection_regs[vim.o.clipboard] and selection_regs[vim.o.clipboard] or [["]]
            vim.fn.setreg(reg, hashes)
            vim.fn.setreg([[0]], hashes)
            notify.info(string.format('Commit hashes copied to register %s', reg))
        elseif key == 'alt-bs' then
            -- ALT-BS to diff against the commits (only available for buffer commits)
            for i = 2, #lines do
                local hash = extract_hash(lines[i])
                if hash and hash ~= '' then
                    vim.cmd('tab sb')
                    vim.cmd('Gdiffsplit ' .. hash)
                end
            end
        elseif key == '' then
            -- ENTER to checkout the commit
            if #lines > 2 then
                notify.warn('To checkout a commit, select only one and do not choose multiple.')
                return
            end
            local cur_commit_hash = system.sync({ 'git', '-C', root_dir, 'rev-parse', '--short', 'HEAD' }).stdout
            local s, e = vim.regex('[0-9a-f]\\{7,40}'):match_str(lines[2])
            local sele_commit_hash = lines[2]:sub(s + 1, e)
            if sele_commit_hash == cur_commit_hash then
                return
            end
            vim.ui.input({
                prompt = 'Checkout commit ' .. sele_commit_hash .. '? (y/N)',
            }, function(input)
                if input and input:lower() == 'y' then
                    local obj = system.sync({ 'git', '-C', root_dir, 'checkout', sele_commit_hash })
                    if obj.code ~= 0 then
                        notify.error({ obj.stderr, obj.stdout })
                    else
                        notify.info(obj.stdout)
                    end
                end
            end)
        end
    end
end

local function git_commits(from_resume)
    local root_dir = get_git_root()
    if root_dir == nil then
        return
    end

    local preview_cmd = get_preview_cmd_git_commits(root_dir)

    local spec = {
        ['sink*'] = get_sink_fn_git_commits(root_dir),
        options = get_fzf_opts(from_resume, {
            '--prompt',
            'Git Commits> ',
            '--header',
            ':: ENTER (checkout commit), CTRL-Y (yank commits)',
            '--expect',
            expect_keys({ 'ctrl-y' }, true),
            '--preview-window',
            theme == 'default' and 'down,60%' or '',
            '--preview',
            preview_cmd,
            '--bind',
            set_label('Preview'),
        }),
    }

    local git_cmd = 'git log --graph --color=always --format="%C(auto)%h%d %s %C(green)%cr %C(blue dim)<%an>"'

    fzf(spec, nil, git_cmd)
end

vim.keymap.set('n', ',fC', function()
    run(git_commits)
end)

-- Git commit (buffer)
local function git_buf_commit(from_resume)
    local root_dir = get_git_root()
    if root_dir == nil then
        return
    end

    local bufname = vim.api.nvim_buf_get_name(0)
    if #bufname == 0 then
        notify.info('Git commits (buffer) is not available for unnamed buffers.')
        return
    end

    local obj = system.sync({ 'git', '-C', root_dir, 'ls-files', '--error-unmatch', bufname })
    if obj.code ~= 0 then
        notify.error({ obj.stderr, obj.stdout })
        return
    end

    local git_cmd = 'git log --color=always --format="%C(auto)%h%d %s %C(green)%cr %C(blue dim)<%an>"'
    local preview_cmd

    local mode = vim.api.nvim_get_mode().mode
    if mode == 'v' or mode == 'V' or mode == '\22' then
        local start_line = vim.fn.getpos('.')[2]
        local end_line = vim.fn.getpos('v')[2]
        if end_line < start_line then
            start_line, end_line = end_line, start_line
        end
        local range = string.format('-L %d,%d:%s --no-patch', start_line, end_line, bufname)
        git_cmd = git_cmd .. ' ' .. range
        preview_cmd = get_preview_cmd_git_commits(root_dir, { start_line, end_line })
    else
        git_cmd = git_cmd .. ' --follow ' .. bufname
        preview_cmd = get_preview_cmd_git_commits(root_dir)
    end

    local spec = {
        ['sink*'] = get_sink_fn_git_commits(root_dir),
        options = get_fzf_opts(from_resume, {
            '--prompt',
            'Git Commits (buffer)> ',
            '--header',
            ':: ENTER (checkout commit), CTRL-Y (yank commits), ALT-BS (diff against commits)',
            '--expect',
            expect_keys({ 'alt-bs', 'ctrl-y' }, true),
            '--preview-window',
            theme == 'default' and 'down,60%' or '',
            '--preview',
            preview_cmd,
            '--bind',
            set_label('Preview'),
        }),
    }

    fzf(spec, nil, git_cmd)
end

vim.keymap.set({ 'n', 'x' }, ',fc', function()
    run(git_buf_commit)
end)

-- Git stash
local function git_stash(from_resume)
    local root_dir = get_git_root()
    if root_dir == nil then
        return
    end

    local spec = {
        ['sink*'] = function(lines)
            local key = lines[1]
            if key == '' and #lines == 2 then
                -- ENTER to apply the stash
                vim.ui.input({
                    prompt = lines[2] .. '\nApply this stash? (y/N)',
                }, function(input)
                    if input and input:lower() == 'y' then
                        -- Extract the stash name , e.g., stash@{1}
                        local name = lines[2]:match('^(%S+):')
                        system.async('git stash apply ' .. name, {}, function(output)
                            notify.info(output)
                        end, system_on_error)
                    end
                end)
            elseif key == 'alt-bs' then
                -- ALT-BS to drop stashes
                vim.ui.input({
                    prompt = table.concat(lines, '\n', 2)  .. '\nDrop ' .. (#lines > 2 and 'these stashes' or 'the stash') .. '? (y/N)',
                }, function(input)
                    if input and input:lower() == 'y' then
                        for i = 2, #lines do
                            local name = lines[i]:match('^(%S+):')
                            system.async('git stash drop ' .. name, {}, function(output)
                                notify.info(output)
                            end, system_on_error)
                        end
                    end
                end)
            elseif key == 'alt-enter' and #lines == 2 then
                -- ALT-ENTER to pop the stash
                vim.ui.input({
                    prompt = lines[2] .. '\nPop this stash? (y/N)',
                }, function(input)
                    if input and input:lower() == 'y' then
                        local name = lines[2]:match('^(%S+):')
                        system.async('git stash pop ' .. name, {}, function(output)
                            notify.info(output)
                        end, system_on_error)
                    end
                end)
            end
        end,
        options = get_fzf_opts(from_resume, {
            '--delimiter',
            ':',
            '--prompt',
            'Git Stash> ',
            '--header',
            ':: ENTER (apply), ALT-ENTER (pop), ALT-BS (drop)',
            '--expect',
            expect_keys({ 'alt-bs', 'alt-enter' }, true),
            '--preview',
            'git --no-pager stash show --patch --color {1} ' .. diff_pager,
            '--preview-window',
            theme == 'default' and 'down,60%' or '',
            '--bind',
            set_label('{1}'),
        }),
    }

    local function handle_contents()
        local entries = {}
        system.async('git --no-pager stash list', { text = true }, vim.schedule_wrap(function(output)
            for line in output:gmatch('[^\n]+') do
                local stash, revision, rest = line:match('^(%S+)({%d+})(:.*)')
                if stash then
                    stash = ansi_string(stash, 'FzfFilename')
                    revision = ansi_string(revision, 'Number')
                    local entry = stash .. revision .. rest
                    table.insert(entries, entry)
                end
            end
            write(entries)
        end), system_on_error)
    end

    fzf(spec, handle_contents)
end

vim.keymap.set('n', ',fh', function()
    run(git_stash)
end)

-- Git worktrees
local function git_worktrees(from_resume)
    local root_dir = get_git_root()
    if root_dir == nil then
        return
    end

    local git_cmd = 'git worktree list'

    local spec = {
        ['sink*'] = function(lines)
            local path = lines[1]:match('^(.*) %x+ %[[^%]]+%]$'):gsub('^%s+', ''):gsub('%s+$', '')
            if path == vim.uv.cwd() then
                notify.warn('cwd already set to ' .. path)
                return
            end
            path = vim.fn.fnamemodify(path, ':p')
            if vim.uv.fs_stat(path) then
                -- Instead of changing cwd globally, we can change it locally: lcd (window local) or
                -- tcd (tab local)
                local cmd = 'cd'
                vim.cmd(cmd .. ' ' .. path)
                notify.info('cwd set to ' .. path)
            else
                notify.warn('Unable to set cwd to ' .. path .. ', directory is not accessible.')
            end
        end,
        options = get_fzf_opts(from_resume, {
            '--no-multi',
            '--prompt',
            'Git Worktrees> ',
            '--header',
            ':: ENTER (cd to path)\n:: CWD: ' .. vim.uv.cwd(),
            '--preview',
            'git log --color --pretty=format:"%C(yellow)%h%Creset %Cgreen(%><(12)%cr%><|(12))%Creset %s %C(blue)<%an>%Creset" {-2}',
            '--preview-window',
            theme == 'default' and 'down,60%' or '',
            '--bind',
            set_label('{}'),
        })
    }

    fzf(spec, nil, git_cmd)
end

vim.keymap.set('n', ',ft', function()
    run(git_worktrees)
end)

-- In each line of a tag file, the tagname may contain whitespaces and \t is the delimiter to
-- separate fields. So we need a special string (different from whitespace and \t) as fzf's
-- delimiter.
local special_delimiter = '@@@@'

-- Tags
local function tags(from_resume)
    local tagfiles = vim.fn.tagfiles()
    if vim.tbl_isempty(tagfiles) then
        notify.warn('Tags file does not exist. Create one with ctags -R')
        return
    end

    local spec = {
        ['sink*'] = function(lines)
            local key = lines[1]
            local action = vim.g.fzf_action[key] or (key == '' and 'edit' or 'silent keepjumps keepalt hide edit')
            local items = {}

            local magic, wrapscan, autochdir = vim.o.magic, vim.o.wrapscan, vim.o.autochdir
            vim.o.magic, vim.o.wrapscan, vim.o.autochdir = false, true, false

            for i = 2, #lines do
                local filename, excmd = lines[i]:match('^(.+)' .. special_delimiter .. '(.*)' .. special_delimiter .. '.*' .. special_delimiter)
                if filename ~= vim.fn.expand('%:p') then
                    vim.cmd(action .. ' ' .. filename)
                elseif key == 'ctrl-x' or key == 'ctrl-v' or key == 'ctrl-t' then
                    vim.cmd(action)
                end
                if key == 'ctrl-q' or key == 'ctrl-l' then
                    vim.cmd('silent keepjumps keepalt execute "' .. excmd .. '"')
                    table.insert(items, {
                        filename = vim.fn.expand('%'),
                        lnum = vim.fn.line('.'),
                        text = vim.fn.getline('.'),
                    })
                else
                    vim.cmd('silent execute "' .. excmd .. '"')
                end
            end

            vim.o.magic, vim.o.wrapscan, vim.o.autochdir = magic, wrapscan, autochdir

            if #items > 0 then
                local what = { title = 'Tags', items = items }
                if key == 'ctrl-q' then
                    setqflist(what)
                elseif key == 'ctrl-l' then
                    setqflist(what, true)
                end
            end
        end,
        options = get_fzf_opts(from_resume, {
            '--delimiter',
            special_delimiter,
            '--with-nth',
            '4..',
            '--prompt',
            'Tags> ',
            '--expect',
            expect_keys({ 'ctrl-q', 'ctrl-l' }),
            '--header',
            ':: CTRL-Q (send to quickfix), CTRL-L (send to loclist)',
            '--preview',
            'center="$([[ {2} =~ ^[0-9]+$ ]] && echo {2} || nvim -n --headless -u NONE -i NONE -c "set nomagic" -c {2} -c "echo line(\'.\')" -c "q" {1} 2>&1)"; \
            start_line="$(( center - FZF_PREVIEW_LINES / 2))"; \
            (( start_line <= 0 )) && start_line=1; \
            end_line="$(( start_line + FZF_PREVIEW_LINES - 1 ))";'
            .. bat_prefix .. ' --line-range="$start_line:$end_line" --highlight-line="$center" -- {1}',
            '--bind',
            set_label('{3} \\| ' .. tildefy_home('{1}')), -- show "tagname | filename" on the preview label
        }),
    }

    local function handle_contents()
        local entries = {}
        for _, tagfile in ipairs(tagfiles) do
            tagfile = vim.fn.fnamemodify(tagfile, ':p')
            for line in io_utils.read_file(tagfile):gmatch('[^\n]*\n') do
                if not line:match('^!_TAG_') then
                    local tagname, filename, excmd = line:match('([^\t]+)\t([^\t]+)\t(.*);"')
                    local devicon = ansi_devicon(filename)
                    local fzf_line = string.format(
                        '%-30s %s %s%s',
                        tagname,
                        devicon,
                        ansi_string(vim.fn.fnamemodify(filename, ':~:.'), 'FzfFilename'),
                        excmd == '' and '' or (tonumber(excmd) == nil and ': ' .. ansi_string(excmd, 'FzfTagsPattern') or ': ' .. ansi_string(excmd, 'Number'))
                    )
                    entries[#entries + 1] = table.concat({
                        -- Absolute file path relative to the tag file
                        filename:match('^/') and filename or (vim.fn.fnamemodify(tagfile, ':h') .. '/' .. filename),
                        excmd == '' and -1 or excmd,
                        tagname,
                        fzf_line,
                    }, special_delimiter)
                end
            end
        end
        write(entries)
    end

    fzf(spec, handle_contents)
end

vim.keymap.set('n', 'gr/', function()
    run(tags)
end)

-- Buffer tags
local function buffer_tags(from_resume)
    local filename = vim.api.nvim_buf_get_name(0)
    if #filename == 0 then
        notify.warn('Buffer tags is not available for unnamed buffer.')
        return
    end
    if vim.fn.filereadable(filename) == 0 then
        notify.warn('Save the file first')
        return
    end
    local bufnr = vim.api.nvim_get_current_buf()

    local spec = {
        ['sink*'] = function(lines)
            local key = lines[1]
            local items = {}
            for i = 2, #lines do
                local lnum = lines[i]:match('^.*' .. special_delimiter .. '(%d+)' .. special_delimiter)
                lnum = tonumber(lnum)
                if key == 'ctrl-q' or key == 'ctrl-l' then
                    -- CTRL-Q, CTRL-L: send to quickfix or location list
                    table.insert(items, {
                        filename = filename,
                        lnum = lnum,
                        ---@diagnostic disable-next-line: param-type-mismatch
                        text = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1],
                    })
                else
                    -- ENTER/CTRL-X/CTRL-V/CTRL-T
                    local action = vim.g.fzf_action[key]
                    if action then
                        vim.cmd(action)
                    end
                    vim.cmd("normal! m'") -- save position to jumplist
                    vim.api.nvim_win_set_cursor(0, { lnum, 0 })
                    vim.cmd('normal! zvzz')
                end
            end

            if #items > 0 then
                local what = { title = 'Buffer Tags', items = items }
                if key == 'ctrl-q' then
                    setqflist(what)
                elseif key == 'ctrl-l' then
                    setqflist(what, true)
                end
            end
        end,
        options = get_fzf_opts(from_resume, {
            '--delimiter',
            special_delimiter,
            '--with-nth',
            '3..',
            '--prompt',
            'Buffer Tags> ',
            '--expect',
            expect_keys({ 'ctrl-q', 'ctrl-l' }),
            '--header',
            ':: CTRL-Q (send to quickfix), CTRL-L (send to loclist)',
            '--preview',
            bat_prefix .. ' --highlight-line {2} -- ' .. filename,
            '--preview-window',
            '+{2}-/2',
            '--bind',
            set_label(tildefy_home(filename .. ':{2} \\({1}\\)')),
        }),
    }

    local function handle_contents()
        local entries = {}
        system.async('ctags -f - --fields=+n ' .. filename, { text = true }, vim.schedule_wrap(function(output)
            for line in output:gmatch('[^\n]+') do
                local tagname, excmd, lnum = line:match('([^\t]+)\t[^\t]+\t(.*);"\t.*line:(%d+)')
                local fzf_line = string.format(
                    '%-30s%s',
                    tagname,
                    excmd == '' and '' or (tonumber(excmd) == nil and ' ' .. ansi_string(excmd, 'FzfTagsPattern') or ' ' .. ansi_string(excmd, 'Number'))
                )
                entries[#entries + 1] = table.concat({
                    tagname,
                    lnum,
                    fzf_line
                }, special_delimiter)
            end
            write(entries)
        end))
    end

    fzf(spec, handle_contents)
end

vim.keymap.set('n', 'gO', function()
    run(buffer_tags)
end)

--
-- INSERT mode completion
--

-- Complete path (include files and dirs)
local function complete_path(from_resume)
    local fd_cmd = 'fd ' .. fd_exclude
    local fd_abs_cmd = 'fd --absolute-path ' .. fd_exclude
    local prompt = shortpath(vim.uv.cwd())

    local winid = vim.api.nvim_get_current_win()
    local bufnr = vim.api.nvim_win_get_buf(winid)

    local spec = {
        ['sink*'] = function(lines)
            -- ENTER to insert the selected path at cursor
            local row, col = unpack(vim.api.nvim_win_get_cursor(winid))
            local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1]
            local after = #line > col and line:sub(col + 1) or ''
            local newline = line:sub(1, col) .. lines[1] .. after
            local newcol = col + #lines[1]
            vim.api.nvim_set_current_line(newline)
            vim.api.nvim_win_set_cursor(winid, { row, newcol })
            vim.api.nvim_feedkeys('a', 'n', true)
        end,
        options = get_fzf_opts(from_resume, {
            '--no-multi',
            '--prompt',
            prompt,
            '--preview-window',
            'hidden',
            '--header',
            ':: ALT-/ (switch between absolute and relative)\n:: CWD: ' .. vim.uv.cwd(),
            '--bind',
            'ctrl-/:ignore',
            '--bind',
            'alt-/:transform:[[ ! $FZF_PROMPT =~ Absolute ]] && echo "reload(' .. fd_abs_cmd .. ')+change-prompt(Absolute Paths> )" || echo "reload(' .. fd_cmd .. ')+change-prompt(' .. prompt .. ')"',
        }),
    }
    fzf(spec, nil, fd_cmd)
end

vim.keymap.set('i', '<C-x><C-f>', function()
    run(complete_path)
end)

--
-- vim.ui.select
--

local function select(items, opts, on_choice)
    assert(type(on_choice) == 'function', 'on_choice must be a function')
    opts = opts or {}

    local title = opts.prompt or 'Select'
    title = title:gsub('^%s*', ''):gsub('[%s:]*$', '')

    local spec = {
        ['sink*'] = function(lines)
            local choice = tonumber(lines[1]:match('^(%d+)%.'))
            on_choice(items[choice], choice)
        end,
        options = get_fzf_opts(nil, {
            '--no-multi',
            '--nth',
            1,
            '--prompt',
            title .. '> ',
            '--preview-window',
            'hidden',
            '--bind',
            'ctrl-/:ignore',
        }),
    }

    local function handle_contents()
        local num_hl = 'Number'
        local num_width = math.floor(math.log10(#items)) + 1 -- number of digits #items has
        local num_ansi_width = #ansi_string('', num_hl)
        local format_item = opts.format_item or tostring
        local kind = opts.kind
        local entries = {}
        for i, item in ipairs(items) do
            local formatted_item = format_item(item)
            if kind == 'codeaction' then
                local client = vim.lsp.get_client_by_id(item.ctx.client_id)
                if client then
                    formatted_item = formatted_item .. ' ' .. ansi_string('[' .. client.name .. ']', 'FzfDesc')
                end
            end
            entries[#entries + 1] = string.format(
                '%' .. num_width + num_ansi_width .. 's. %s',
                ansi_string(tostring(i), num_hl),
                formatted_item
            )
        end
        write(entries)
    end

    local prev_layout = vim.g.fzf_layout
    vim.g.fzf_layout = config[theme].get_select_ui_layout(#items)

    fzf(spec, handle_contents)

    vim.g.fzf_layout = prev_layout
end

vim.ui.select = select
