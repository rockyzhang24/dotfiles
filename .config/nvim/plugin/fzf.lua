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

-- <Leader>fr : Resume

-- <Leader>ff : Files
-- <Leader>fo : Old files
-- <Leader>f. : Files for my dotfiles
-- <Leader>f` : Files under $HOME
-- <Leader>fb : Buffers
-- <C-\>      : Buffers

-- <C-p>      : Git files
-- ,fc        : Git commits for current buffer
-- ,fC        : Git commits

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

-- <Leader>gg : live grep
-- <C-g>      : live grep
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

-- Commands
-- [RANGE]GitCommits [GIT LOG OPTIONS]
-- [RANGE]GitBufCommits [GIT LOG OPTIONS]
-- RGU [RG OPTIONS] [QUERY] [PATH]

--
-- Template to add a new finder
--
-- 1. Based on entries in a Lua table
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
--         -- Build each fzf entry and insert it into entries.
--
--         -- Call write() to write all entries into the pipe to display in fzf
--         write(entries)
--     end
--
--     fzf(spec, handle_contents)
-- end
--
-- 2. Based on an external bash command
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

local qf = require('rockyz.utils.qf_utils')
local color = require('rockyz.utils.color_utils')
local io_utils = require('rockyz.utils.io_utils')
local icons = require('rockyz.icons')
local notify = require('rockyz.utils.notify_utils')
local has_devicons, devicons = pcall(require, 'nvim-web-devicons')

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

-- Use the general statusline
vim.api.nvim_create_autocmd('User', {
    group = vim.api.nvim_create_augroup('rockyz.fzf.statusline', { clear = true }),
    pattern = 'FzfStatusLine',
    callback = function()
        vim.wo.statusline = ''
    end,
})

local rg_prefix = 'rg --column --line-number --no-heading --color=always --smart-case --with-filename'
local bat_prefix = 'bat --color=always --paging=never --style=numbers' -- used to preview text file
local fd_prefix = 'fd --hidden --follow --color=never --type f --type l ' .. vim.env.FD_EXCLUDE
local fzf_previewer = '~/.config/fzf/fzf-previewer.sh' -- used to preview various types of files (text, image, etc)
local headless_add_icon = 'nvim -n --headless -u NONE -i NONE --cmd "lua require(\'rockyz.headless.fzf_devicons\')" +q'

local common_expect = 'ctrl-x,ctrl-v,ctrl-t'

---Color a string by ANSI color code that is converted from a highlight group
---@param str string string to be colored
---@param hl string highlight group name
---@param from_type string? which color type in the highlight group will be used, 'fg', 'bg' or 'sp'
---@param to_type string? which ANSI color type will be output, 'fg' or 'bg'
local function ansi_string(str, hl, from_type, to_type)
    from_type = from_type or 'fg'
    to_type = to_type or 'fg'
    local ansi = color.hl2ansi(hl, from_type, to_type)
    local ansi_reset = '\x1b[m'
    return  ansi .. str .. ansi_reset
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
local fzf_mode_enabled = ''

---Get fzf options
---@param from_resume boolean? Whether the finder is called by fzf resume
---@param extra_opts table? Extra options
local function get_fzf_opts(from_resume, extra_opts)
    extra_opts = extra_opts or {}
    local common_opts = {
        '--ansi',
        '--multi',
        '--bind',
        -- Cache the query for fzf resume
        'result:execute-silent(echo {q} > ' .. cached_fzf_query .. ')',
    }
    -- When the finder is called by fzf resume, use the fzf's start event to fetch the cached query
    if from_resume then
        common_opts = vim.list_extend(common_opts, {
            '--bind',
            'start:transform-query:cat ' .. cached_fzf_query,
        })
    end
    return vim.list_extend(common_opts, extra_opts)
end

---@param label string The label or a shell command to generate the label
local function set_preview_label(label)
    return string.format('focus:transform-preview-label:echo [ %s ]', label)
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
        vim.system({ "mkfifo", fifopipe }):wait()
        -- vim.env.FZF_DEFAULT_COMMAND = 'cat ' .. fifopipe
        vim.env.FZF_DEFAULT_COMMAND = 'tail -n +1 -f ' .. fifopipe .. ' & echo $! > ' .. tail_pid
        vim.uv.fs_open(fifopipe, 'w', -1, vim.schedule_wrap(function(err, fd)
            if err then
                error(err)
            end
            output_pipe = vim.uv.new_pipe(false)
            output_pipe:open(fd)
            handle_contents()
        end))
    end

    vim.fn['fzf#run'](vim.fn['fzf#wrap'](spec))

    vim.env.FZF_DEFAULT_COMMAND = old_fzf_cmd
end

-- Close the pipe and kill tail process to terminate fzf's "loading" indicator
local function finish()
    vim.system({ 'bash', '-c', 'kill -9 $(<' .. tail_pid .. ')' })
    output_pipe:close()
    output_pipe = nil
end

---Write fzf entries to the pipe
---@param entries table Fzf entries
---@param multiline boolean? Whether each entry is a multiline item
local function write(entries, multiline)
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

-- Resume
vim.keymap.set('n', '<Leader>fr', function()
    if not cached_finder then
        notify.warn('No resume finder available!')
        return
    end
    if type(cached_finder) == 'function' then
        run(cached_finder, true)
    elseif type(cached_finder) == 'table' then
        -- The last executed command-line command
        -- A special argument `@@from_resume@@` is used to tell the command that it is executed via
        -- fzf resume
        local command = string.format(
            ':%s%s %s @@from_resume@@<CR>',
            cached_finder.range and cached_finder.range or '',
            cached_finder.cmd,
            cached_finder.args
        )
        local keys = vim.api.nvim_replace_termcodes(command, true, false, true)
        vim.api.nvim_feedkeys(keys, 'n', false)
    end
end)

-- Helper function for sink* to handle selected files
-- ENTER/CTRL-X/CTRL-V/CTRL-T to open files
---@param lines table The first item is the key; others are filenames.
local function sink_file(lines)
    local key = lines[1]
    local cmd = vim.g.fzf_action[key] or 'edit'
    for i = 2, #lines do
        if vim.fn.fnamemodify(lines[i], ':p') ~= vim.fn.expand('%:p') then
            vim.cmd(cmd .. ' ' .. lines[i])
        end
    end
end

-- Helper function to get git root dir
local function get_git_root()
    local cmd = { 'git', 'rev-parse', '--show-toplevel' }
    local obj = vim.system(cmd):wait()
    if obj.code ~= 0 then
        notify.info(obj.stderr:gsub('\n$', ''))
        return nil
    end
    return obj.stdout:gsub('\n$', '')
end

-- Files
local function files(from_resume)
    local fd_cmd = fd_prefix .. ' | ' .. headless_add_icon

    local function shortpath()
        local short = vim.fn.fnamemodify(vim.uv.cwd(), ':~:.')
        short = vim.fn.pathshorten(short)
        return short == '' and '~/' or (short:match('/$') and short or short .. '/')
    end

    local spec = {
        ['sink*'] = sink_file,
        options = get_fzf_opts(from_resume, {
            '--prompt',
            shortpath(),
            '--expect',
            common_expect,
            '--preview',
            fzf_previewer .. ' {2}',
            '--bind',
            set_preview_label('{2}'),
            '--accept-nth',
            '2',
        }),
    }

    fzf(spec, nil, fd_cmd)
end

-- Old files
local function old_files(from_resume)
    local spec = {
        ['sink*'] = sink_file,
        options = get_fzf_opts(from_resume, {
            '--prompt',
            'Old Files> ',
            '--tiebreak',
            'index',
            '--expect',
            common_expect,
            '--preview',
            fzf_previewer .. ' {2}',
            '--bind',
            set_preview_label('{2}'),
            '--accept-nth',
            '2',
        }),
    }

    local function handle_contents()
        local entries = {}
        for _, file in ipairs(vim.v.oldfiles) do
            if vim.fn.filereadable(file) == 1 then
                local icon = ansi_devicon(file)
                file = vim.fn.fnamemodify(file, ':~:.')
                local entry = icon .. ' ' .. file
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
    local git_root = vim.env.HOME
    local git_cmd = 'git -C '
        .. git_root
        .. ' --git-dir "$HOME/dotfiles" --work-tree "$HOME" ls-files --exclude-standard | '
        .. headless_add_icon

    local spec = {
        ['sink*'] = sink_file,
        options = get_fzf_opts(from_resume, {
            '--prompt',
            '.dotfiles> ',
            '--expect',
            common_expect,
            '--preview',
            fzf_previewer .. ' ' .. git_root .. '/{2}',
            '--accept-nth',
            git_root .. '/{2}',
            '--bind',
            set_preview_label('{2}'),
        }),
    }

    fzf(spec, nil, git_cmd)
end

vim.keymap.set('n', '<Leader>f.', function()
    run(dot_files)
end)

-- Find files under $HOME
local function home_files(from_resume)
    local fd_cmd = 'cd ' .. vim.env.HOME .. ' && ' .. fd_prefix .. ' | ' .. headless_add_icon

    local spec = {
        ['sink*'] = sink_file,
        options = get_fzf_opts(from_resume, {
            '--prompt',
            'Home Files> ',
            '--expect',
            common_expect,
            '--preview',
            fzf_previewer .. ' ' .. vim.env.HOME .. '/{2}',
            '--accept-nth',
            vim.env.HOME .. '/{2}',
            '--bind',
            set_preview_label('"~/"{2}')
        }),
    }

    fzf(spec, nil, fd_cmd)
end

vim.keymap.set('n', '<Leader>f`', function()
    run(home_files)
end)

-- Buffers
local function buffers(from_resume)
    local spec = {
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
        options = get_fzf_opts(from_resume, {
            '--multi',
            '--header-lines',
            '1',
            '--with-nth',
            '3..',
            '--prompt',
            'Buffers> ',
            '--header',
            ':: CTRL-D (delete buffers)',
            '--expect',
            common_expect .. ',ctrl-d',
            '--preview',
            '[[ {1} == "No_Name" ]] && echo "" || ' .. bat_prefix .. ' --highlight-line {2} -- {1}',
            '--preview-window',
            '+{2}-/2',
            '--bind',
            set_preview_label('{3..}'),
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
            -- Entry: <fullname> <lnum> <[bufnr]> <flags> <bufname>:<lnum>
            -- {3..} will be presented.
            local entry = string.format(
                '%s %s %-' .. max_bufnr_width .. 's %3s %s %s:%s',
                #fullname == 0 and 'No_Name' or fullname,
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

vim.keymap.set('n', '<C-\\>', function()
    run(buffers)
end)

-- Git files
local function git_files(from_resume)
    local git_root = get_git_root()
    local git_cmd = 'git -C ' .. git_root .. ' ls-files --exclude-standard | ' .. headless_add_icon

    local spec = {
        ['sink*'] = sink_file,
        options = get_fzf_opts(from_resume, {
            '--prompt',
            'Git Files> ',
            '--expect',
            common_expect,
            '--preview',
            fzf_previewer .. ' ' .. git_root .. '/{2}',
            '--accept-nth',
            git_root .. '/{2}',
            '--header',
            'Git Root: ' .. vim.fn.fnamemodify(git_root, ':~'),
            '--bind',
            set_preview_label('{2}'),
        }),
    }

    fzf(spec, nil, git_cmd)
end

vim.keymap.set('n', '<C-p>', function()
    run(git_files)
end)

--
-- Git commits (for the whole project) and Git buffer commits (for current buffer)
--

-- Create two commands, GitCommits and GitBufCommits
-- Any command accepts git log options and supports a range
-- E.g., :GitCommits 'foo' --name-only
-- A special argument `@@from_resume@@` is used internally for fzf resume

local function create_commands(name, func)
    vim.api.nvim_create_user_command(name, function(opts)
        local from_resume = opts.args:match('@@from_resume@@') and true or false
        local args = opts.args:gsub('@@from_resume@@', '')
        cached_finder = {
            range = opts.line1 .. ',' .. opts.line2,
            cmd =  opts.name,
            args = args,
        }
        vim.cmd(
            string.format(
                [[%s,%scall %s(%s, {
                    \ "options": [
                    \     "--prompt",
                    \     %s,
                    \     "--preview-window",
                    \     "down,45%%",
                    \     "--header",
                    \     ":: CTRL-S (toggle sort), CTRL-Y (yank commmit hashes), CTRL-D (diff)",
                    \     "--bind",
                    \     "focus:transform-preview-label:echo [ Diff with commit %s ]",
                    \     "--bind",
                    \     "result:execute-silent(echo {q} > ]] .. cached_fzf_query .. [[)",
                    \     "--bind",
                    \     "start:transform-query:%s"
                    \ ]
                \ }, 0)]],
                opts.line1,
                opts.line2,
                func,
                string.format("'%s'", args),
                string.format("'%s> '", name),
                string.format("'%s'", name == 'GitCommits' and '{2}' or '{1}'),
                from_resume and ('cat ' .. cached_fzf_query) or ''
            )
        )
    end, {
        nargs = '*',
        range = '%',
    })
end

create_commands('GitBufCommits', 'fzf#vim#buffer_commits')
create_commands('GitCommits', 'fzf#vim#commits')

local function run_git_commit_cmd(cmd)
    local str = string.format(":%s<CR>", cmd)
    local keys = vim.api.nvim_replace_termcodes(str, true, false, true)
    vim.api.nvim_feedkeys(keys, 'n', false)
end

vim.keymap.set({ 'n', 'x' }, ',fc', function()
    run_git_commit_cmd('GitBufCommits')
end)

vim.keymap.set({ 'n', 'x' }, ',fC', function()
    run_git_commit_cmd('GitCommits')
end)

--
-- Git branches
--

local function git_branches(from_resume)
    -- Extract the branch name for fzf preview and border label
    --
    --   entry                            |  extracted branch
    --------------------------------------|-----------------
    --   branch                           |    branch
    --   remotes/origin/branch            |    remotes/origin/branch
    -- * (HEAD detached at origin/branch) |    origin/branch
    --
    local cmd_extract_branch = '[[ {1} == "*" ]] && branch={2} || branch={1}; [[ $branch == "(HEAD" ]] && entry={} && branch=${entry#*\\(HEAD detached at } && branch=${branch%%\\)*}; echo $branch'
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
                notify.info('[Git] switching to ' .. branch .. ' branch...')
                vim.system(cmd, {}, function(obj)
                    if obj.code ~= 0 then
                    else
                        vim.schedule(function()
                            vim.notify('[Git] switched to ' .. branch .. ' branch.', vim.log.levels.INFO)
                            vim.cmd('checktime')
                        end)
                    end
                end)
            elseif key == 'ctrl-d' then
                -- CTRL-D to delete branches
                local cmd_del_branch = { 'git', '-C', root_dir, 'branch', '--delete' }
                local cmd_cur_branch = { 'git', '-C', root_dir, 'rev-parse', '--abbrev-ref', 'HEAD' }
                local cur_branch = vim.system(cmd_cur_branch):wait().stdout
                local del_branches = {}
                for i = 2, #lines do
                    local branch = lines[i]:match('[^%s%*]+')
                    if branch ~= cur_branch then
                        table.insert(del_branches, branch)
                    end
                end
                local msg = string.format(
                    'Delete %s %s?',
                    #del_branches > 1 and 'branches' or 'branch',
                    table.concat(del_branches, ', ')
                )
                if vim.fn.confirm(msg, '&Yes\n&No') == 1 then
                    cmd_del_branch = vim.list_extend(cmd_del_branch, del_branches)
                    vim.system(cmd_del_branch, {}, function(obj)
                        local output = (obj.stderr and obj.stderr or '') .. (obj.stdout and obj.stdout or '')
                        if obj.code == 0 then
                            notify.info(output)
                        else
                            notify.err(output)
                        end
                    end)
                end
            end
        end,
        options = get_fzf_opts(from_resume, {
            '--prompt',
            'Git Branches> ',
            '--expect',
            'ctrl-d',
            '--header',
            ':: ENTER (checkout), CTRL-D (delete branches)',
            '--preview-window',
            'down,60%',
            '--preview',
            'git log --graph --pretty=oneline --abbrev-commit --color $(' .. cmd_extract_branch .. ')',
            '--bind',
            set_preview_label('Branch: $(' .. cmd_extract_branch .. ')'),
        })
    }

    local function handle_contents()
        local entries = {}
        vim.system({'git', 'branch', '--all', '-vv', '--color'}, { text = true }, function(obj)
            for line in obj.stdout:gmatch('[^\n]+') do
                table.insert(entries, line)
            end
            write(entries)
        end)
    end

    fzf(spec, handle_contents)
end

vim.keymap.set('n', ',fb', function()
    run(git_branches)
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
            if key == 'ctrl-d' then
                -- CTRL-D to delete marks
                for i = 2, #lines do
                    local mark = lines[i]:match('[^ ]+')
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
                    local mark = lines[i]:match('[^ ]+')
                    vim.cmd('stopinsert')
                    vim.cmd('normal! `' .. mark)
                end
            end
        end,
        options = get_fzf_opts(from_resume, {
            '--with-nth',
            '..-2',
            '--header-lines',
            '1',
            '--prompt',
            'Marks> ',
            '--header',
            ':: CTRL-D (delete marks)',
            '--expect',
            common_expect .. ',ctrl-d',
            '--preview',
            ' [[ -f {-1} ]] && ' .. bat_prefix .. ' --highlight-line {2} -- {-1} || echo File does not exist, no preview!',
            '--preview-window',
            '+{2}-/2',
            '--bind',
            set_preview_label('{-1}'),
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
        local header = string.format('%s  %s  %s %s %s', 'mark', 'line', 'col', 'file/text', 'filepath_for_preview')
        table.insert(entries, header)

        for i = 3, #all_marks do
            local mark, line, col, text = all_marks[i]:match('(.)%s+(%d+)%s+(%d+)%s+(.*)')
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
                filepath = 'No_File'
            end

            -- Each fzf entry has 5 parts: mark, line, col, file/text and filepath
            -- The first 4 parts are presented in fzf; the last part, filepath, is used for preview
            local entry = string.format(
                ' %-26s %25s %25s %s %s',
                ansi_string(mark, 'FzfFilename'), -- 23 chars
                ansi_string(line, 'FzfLnum'), -- 22 chars if line is 1 digit
                ansi_string(col, 'FzfCol'), -- 22 chars if col is 1 digit
                text,
                filepath
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
            if key == 'ctrl-d' and #vim.api.nvim_list_tabpages() > 1 then
                -- CTRL-D: delete tabs
                for i = 2, #lines do
                    for winid in lines[i]:match('%S+%s%S+%s%S+%s(%S+)'):gmatch('[^,]+') do
                        winid = tonumber(winid)
                        if winid then
                            vim.api.nvim_win_close(winid, false)
                        end
                    end
                end
            elseif #lines == 2 then
                -- ENTER with single selection: select tab
                local tid = tonumber(string.match(lines[2], '%S+%s%S+%s(%S+)'))
                if tid then
                    vim.api.nvim_set_current_tabpage(tid)
                end
            end
        end,
        options = get_fzf_opts(from_resume, {
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
            set_preview_label('$(echo {1} | sed "s/@@@@/ /g; s|^$HOME|~|")'),
        }),
    }

    local function handle_contents()
        local entries = {}
        vim.api.nvim_win_call(win, function()
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
                            filename = ansi_string(filename, 'DiagnosticOk')
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
            write(entries)
        end)
    end

    fzf(spec, handle_contents)
end

vim.keymap.set('n', '<Leader>ft', function()
    run(tabs)
end)

--
-- Argument list
--

local function args(from_resume)
    local spec = {
        ['sink*'] = function(lines)
            local key = lines[1]
            if key == 'ctrl-d' then
                -- CTRL-D: delete from arglist
                for i = 2, #lines do
                    vim.cmd.argdelete(string.match(lines[i], '%S+%s%S+%s(%S+)'))
                end
            else
                -- ENTER/CTRL-X/CTRL-V/CTRL-T
                local action = vim.g.fzf_action[key]
                for i = 2, #lines do
                    if action then
                        vim.cmd(action)
                    end
                    local index = tonumber(lines[i]:match('^%d+'))
                    vim.cmd('argument! ' .. index)
                end
            end
        end,
        options = get_fzf_opts(from_resume, {
            '--with-nth',
            '2..',
            '--prompt',
            'Args> ',
            '--header',
            ':: CTRL-D (delete from arglist)',
            '--expect',
            common_expect .. ',ctrl-d',
            '--preview',
            bat_prefix .. ' -- {3}',
            '--bind',
            set_preview_label('{3}'),
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
                -- Fzf entry consists of 3 parts: index, devicon, filename
                -- Index is used for file switch and it won't be presented in fzf
                local entry = string.format('%s %s %s', #entries + 1, devicon, f)
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

--
-- Helptags
--

local function helptags(from_resume)

    local spec = {
        ['sink*'] = function(lines)
            if #lines > 2 then
                notify.warn('No support multiple selections')
            end
            local key = lines[1]
            local tag = string.match(lines[2], '^%S+')
            if key == '' or key == 'ctrl-x' then
                vim.cmd('help ' .. tag)
            elseif key == 'ctrl-v' then
                vim.cmd('vert help ' .. tag)
            elseif key == 'ctrl-t' then
                vim.cmd('tab help ' .. tag)
            end
        end,
        options = get_fzf_opts(from_resume, {
            '--with-nth',
            '..2',
            '--nth',
            '1',
            '--no-multi',
            '--prompt',
            'Helptags> ',
            '--expect',
            common_expect,
            '--header',
            ':: CTRL-V (open in vertical split), CTRL-T (open in new tab)',
            '--preview',
            -- This script is taken from fzf.vim/bin/tagpreview.sh
            'TARGET_LINE="$(nvim -R -i NONE -u NONE -e -m -s {3} -c "set nomagic" -c "silent "{4} -c \'let l=line(".") | new | put =l | print | qa!\')"; \
            START_LINE="$(( TARGET_LINE - 5 ))"; \
            (( START_LINE <= 0 )) && START_LINE=1; \
            END_LINE="$(( START_LINE + FZF_PREVIEW_LINES - 1 ))"; ' .. bat_prefix .. ' --style plain --language VimHelp --highlight-line "${TARGET_LINE}" --line-range="${START_LINE}:${END_LINE}" -- {3}',
            '--bind',
            set_preview_label('{1} {2}'),
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
                            -- fzf entry
                            -- It consists of three parts: tag, filename, file_fullpath
                            -- Only the first two parts are presented in fzf. The third part
                            -- file_fullpath is used to open the help file.
                            local tag = fields[1]
                            local filename = fields[2] -- help file name
                            local excmd = fields[3] -- Ex command
                            local file_fullpath = help_files[filename] -- help file fullpath
                            local entry = string.format(
                                '%s %s %s %s',
                                ansi_string(tag, 'Label'),
                                ansi_string('[' .. filename .. ']', 'FzfDesc'),
                                file_fullpath,
                                excmd
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

--
-- Commands
--

local function commands(from_resume)
    local spec = {
        ['sink*'] = function(lines)
            local cmd = lines[2]:match('^%S+')
            vim.cmd('stopinsert')
            vim.api.nvim_feedkeys(':' .. cmd, 'n', true)
        end,
        options = get_fzf_opts(from_resume, {
            '--ansi',
            '--no-multi',
            '--with-nth',
            '2',
            '--prompt',
            'Commands> ',
            '--preview',
            'echo {3..}',
            '--preview-window',
            'down,3',
            '--bind',
            set_preview_label('{1}'),
        }),
    }

    local function handle_contents()

        -- The structure of each entry is as follows (3 parts):
        -- command colored_command description
        --    |       |                  |____________ shown in preview
        --    |       |___ presented in fzf
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
                .. ' '
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
                entry = entry .. ' ' .. table.concat(desc, '\\n')
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
                        table.insert(fzf_entries, cmd .. ' ' .. ansi_string(cmd, 'PreProc') .. ' Description: ' .. desc)
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
                table.insert(fzf_entries, cmd .. ' ' .. ansi_string(cmd, 'PreProc') .. ' Description: ' .. desc)
            end
        end

        write(fzf_entries)
    end

    fzf(spec, handle_contents)
end

vim.keymap.set('n', '<Leader>fc', function()
    run(commands)
end)

--
-- Registers
--

local function registers(from_resume)
    local spec = {
        ['sink*'] = function(lines)
            -- ENTER will paster the content in the selected register at the cursor position
            local reg = lines[1]:match("%[(.-)%]")
            local ok, text = pcall(vim.fn.getreg, reg)
            if ok and #text > 0 then
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
            set_preview_label('Register {1}'),
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

--
-- Zoxide
--

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
                vim.cmd('cd ' .. cwd)
                notify.info('cwd set to ' .. cwd)
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
            set_preview_label('{2}'),
        }),
    }

    local function handle_contents()
        local entries = {}
        vim.system({'zoxide', 'query', '--list', '--score'}, { text = true }, function(obj)
            for line in obj.stdout:gmatch('[^\n]+') do
                local score, dir = line:match("(%d+%.%d+)%s+(.-)$")
                local entry = string.format('%8s\t%s', score, dir)
                table.insert(entries, entry)
            end
            write(entries)
        end)
    end

    fzf(spec, handle_contents)
end

vim.keymap.set('n', '<Leader>fz', function()
    run(zoxide)
end)

--
-- Find entries in quickfix and location list
--

-- Construct entry in qf
-- <filename> <lnum>-<end_lnum>:<col>-<end_col> [<type>] <text>
local function get_qf_entry(item)
    local entry = {}
    if item.fname ~= '' then
        table.insert(entry, ansi_string(item.fname, 'QuickfixFilename'))
    end
    local lnum_col = item.lnum
    if item.col ~= '' then
        lnum_col = item.lnum .. ':' .. item.col
    end
    if lnum_col ~= '' then
        table.insert(entry, ansi_string(lnum_col, 'Number'))
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
            type = ansi_string(type, hl)
        end
        table.insert(entry, type)
    end
    if item.text ~= '' then
        local text = item.text
        if hl then
            text = ansi_string(text, hl)
        end
        table.insert(entry, text)
    end
    return table.concat(entry, ' ')
end

---@param win_local boolean true for location list and false for quickfix
local function qf_items_fzf(win_local, from_resume)
    local what = { items = 0, title = 0 }
    local list = win_local and vim.fn.getloclist(0, what) or vim.fn.getqflist(what)
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
        options = get_fzf_opts(from_resume, {
            '--prompt',
            win_local and 'Location List' or 'Quickfix List' .. '> ',
            '--header',
            ':: ENTER (display the error), CTRL-R (refine the current ' .. (win_local and 'loclist' or 'quickfix') .. ')\n:: CTRL-Q (send to quickfix), CTRL-L (send to loclist)',
            '--with-nth',
            '4..',
            '--expect',
            common_expect .. ',ctrl-q,ctrl-l,ctrl-r',
            '--preview',
            bat_prefix .. ' --highlight-line {3} -- {2}',
            '--preview-window',
            'down,45%,+{3}-/2',
            '--bind',
            set_preview_label('$(echo {2} | sed "s|^$HOME|~|")'),
        }),
    }

    local function handle_contents()
        local entries = {}
        for _, item in ipairs(list.items) do
            local bufnr = item.bufnr
            local bufname = vim.api.nvim_buf_get_name(bufnr)
            local lnum = item.lnum
            -- The formatted entries will be fed to fzf.
            -- Each entry is like "index bufname lnum path/to/the/file:134:20 [E] error"
            -- The first three parts are used for fzf itself and won't be presented in fzf window.
            -- * index: display the error by :[nr]cc!
            -- * bufname and lnum: fzf preview
            local entry = #entries + 1 .. ' ' .. bufname .. ' ' .. lnum .. ' ' .. get_qf_entry(qf.format_qf_item(item))
            table.insert(entries, entry)
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

-- To preview the list, we need to dump all errors in the list to a temporary file and cat this
-- file.
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
            local count = string.match(lines[1], '^(%d+)')
            vim.cmd('silent! ' .. count .. hist_cmd)
            vim.cmd(open_cmd)
        end,
        placeholder = '',
        options = get_fzf_opts(from_resume, {
            '--with-nth',
            '3..',
            '--no-multi',
            '--prompt',
            prompt.. '> ',
            '--header',
            ':: ENTER (switch to selected list)',
            '--preview-window',
            'down,45%',
            '--preview',
            'cat {2}',
            '--bind',
            set_preview_label('{3..}'),
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

            -- Build fzf entry: "3 tmpfile [3] 1 items    Diagnostics"
            -- The first part is quickfix-id that is used to switch the specific quickfix.
            -- The second part "tmpfile" is the path of the temporary file used by cat in --preview. The
            -- other parts will be presented in fzf.
            local entry = i .. ' ' .. err_tmpfile .. ' [' .. i .. '] ' .. list.size .. ' items    ' .. list.title
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
                local str = get_qf_entry(qf.format_qf_item(item))
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
-- It has two modes (ALT-F for switching between each other)
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
        fzf_mode_enabled = vim.fn.tempname() -- tempfile to record whether it is currently in fzf mode
    end
    local is_fzf_mode = vim.uv.fs_stat(fzf_mode_enabled)
    local mode = is_fzf_mode and 'FZF' or 'RG'
    local search_enabled = is_fzf_mode and true or false
    -- Initial rg query
    if from_resume and vim.uv.fs_stat(cached_rg_query) then
        rg_query = '$(cat ' .. cached_rg_query .. ')'
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
    local opts =  {
        '--ansi',
        '--prompt',
        string.format('%s [%s]> ', prompt, mode),
        '--bind',
        'start:reload(' .. rg .. ' ' .. rg_query .. ' ' .. path .. ')' .. set_query .. unbind_change,
        '--bind',
        'change:reload:' .. rg .. ' {q} ' .. path .. ' || true',
        '--bind',
        -- Cache the query into the specific tempfile based on the current mode
        'result:execute-silent([[ ! -e ' .. fzf_mode_enabled .. ' ]] && echo {q} > ' .. cached_rg_query .. ' || echo {q} > ' .. cached_fzf_query .. ')',
        '--bind',
        'alt-f:transform:\
        [[ ! -e ' .. fzf_mode_enabled .. ' ]] && { \
            touch ' .. fzf_mode_enabled .. '; \
            echo "unbind(change)+change-prompt(' .. prompt .. ' [FZF]> )+enable-search+transform-query(cat ' .. cached_fzf_query .. ')"; \
        } || { \
            rm ' .. fzf_mode_enabled .. '; \
            echo "change-prompt(' .. prompt .. ' [RG]> )+disable-search+reload(' .. rg .. ' {q} || true)+rebind(change)+transform-query(cat ' .. cached_rg_query .. ')"\
        }',
        '--bind',
        set_preview_label('{1}:{2}:{3}'),
        '--delimiter',
        ':',
        '--header',
        ':: ALT-F (toggle FZF mode and RG mode)',
        '--preview-window',
        'down,45%,+{2}-/2',
        '--preview',
        bat_prefix .. ' --highlight-line {2} -- {1}',
    }
    if not search_enabled then
        table.insert(opts, '--disabled')
    end
    return vim.list_extend(opts, extra_opts)
end

-- Define a new command :RGU (U for Ultimate) that accepts rg options
-- Synopsis: :RGU [RG OPTIONS] [QUERY] [PATH]. The QUERY PATH can be placed anywhere
-- A special argument `@@from_resume@@` is used internally for fzf resume
vim.api.nvim_create_user_command('RGU', function(opts)
    local extra_flags = {}
    local query = ''
    local path = ''
    local from_resume
    for _, arg in ipairs(opts.fargs) do
        if arg:match('^-') ~= nil then
            table.insert(extra_flags, arg)
        elseif arg:match('@@from_resume@@') then
            from_resume = true
        elseif vim.uv.fs_stat(arg) then
            path = arg
        elseif query == '' then
            query = arg
        else
            notify.error('Error: more than one query string are given!')
            return
        end
    end
    cached_finder = {
        cmd = opts.name,
        args = opts.args:gsub('@@from_resume@@', ''),
    }
    local rg_args = table.concat(extra_flags, ' ')
    local rg = rg_prefix .. ' ' .. rg_args .. ' --'
    vim.fn['fzf#vim#grep2'](rg, query, {
        options = get_fzf_opts_for_live_grep(rg, query, path, 'RGU', {}, from_resume),
    })
end, { nargs = '*' })

vim.keymap.set('n', '<Leader>gg', function()
    vim.cmd('RGU')
end)

vim.keymap.set('n', '<C-g>', function()
    vim.cmd('RGU')
end)

-- Live grep in nvim config
local function live_grep_nvim_config(from_resume)
    local rg = rg_prefix .. ' --glob=!minpac -- '
    local query = ''
    vim.fn['fzf#vim#grep2'](
        rg,
        query,
        {
            dir = '~/.config/nvim',
            options = get_fzf_opts_for_live_grep(rg, query, '', 'Nvim Config', {}, from_resume),
        }
    )
end

vim.keymap.set('n', '<Leader>gv', function()
    run(live_grep_nvim_config)
end)

--
-- Live grep in current buffer
--

local function grep_buffer(from_resume)
    local rg = rg_prefix .. ' --'
    local filename = vim.api.nvim_buf_get_name(0)
    if #filename == 0 or not vim.uv.fs_stat(filename) then
        notify.warn('Live grep in current buffer requires a valid buffer!')
        return
    end
    vim.fn['fzf#vim#grep2'](rg, '', {
        options = get_fzf_opts_for_live_grep(rg, '', filename, 'Buffer', {
            '--with-nth',
            '2..',
            '--header',
            ':: Current buffer: ' .. vim.fn.expand('%:~:.'),
        }, from_resume)
    })
end

vim.keymap.set('n', '<Leader>gb', function()
    run(grep_buffer)
end)

--
-- Grep for the current word (normal mode) or the current selection (visual mode)
--

-- Cache the rg query for fzf resume
local cached_grep_word_rg_query = ''

---@param from_resume boolean? Whether or not this function is called from fzf resume
local function grep_word(from_resume)
    local rg_query
    local header
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
    header = rg_query
    rg_query = vim.fn.escape(rg_query, '.*+?()[]{}\\|^$')
    local rg = rg_prefix .. ' -- ' .. vim.fn['fzf#shellescape'](rg_query)
    vim.fn['fzf#vim#grep'](
        rg,
        {
            options = get_fzf_opts(from_resume, {
                '--prompt',
                'Word [Rg]> ',
                '--preview-window',
                'down,45%,+{2}-/2',
                '--preview',
                bat_prefix .. ' --highlight-line {2} -- {1}',
                -- Show the current rg query in header. Set its style to bold, red foreground via ANSI
                -- color code.
                '--header',
                ':: Query: ' .. ansi_string(header, 'FzfRgQuery'),
                '--bind',
                set_preview_label('{1}:{2}:{3}'),
            }),
        }
    )
end

vim.keymap.set({ 'n', 'x' }, '<Leader>g*', function()
    run(grep_word)
end)

--
-- LSP
--
-- Each fzf entry consists of 6 parts: index, offset_encoding, filename, lnum, col, fzf_text.
--
-- Only fzf_text will be presented in fzf. index is used to fetch the corresponding qf items from
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
local function symbols_to_entries_and_items(symbols, ctx, child_prefix, all_entries, all_items)

    local client = vim.lsp.get_client_by_id(ctx.client_id)
    if not client then
        return
    end

    local client_name = client.name
    local colored_client_name = ansi_string(client_name, 'FzfDesc')
    local offset_encoding = client.offset_encoding
    local bufnr = ctx.bufnr

    -- Recursion (DFS) to iterate child symbols if there are any
    local function _symbols_to_entries_and_items(_symbols, _child_prefix)
        for _, symbol in ipairs(_symbols) do
            local kind = vim.lsp.protocol.SymbolKind[symbol.kind] or 'Unknown'
            local icon = icons.symbol_kinds[kind]
            local colored_icon_kind = ansi_string(icon .. ' ' .. kind, 'SymbolKind' .. kind)
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
                local devicon = ansi_devicon(filename)
                local fzf_text = '[' .. colored_icon_kind .. '] ' .. symbol.name .. ' '
                    .. colored_client_name
                    .. string.rep(' ', 6)
                    .. (devicon == '' and devicon or devicon .. ' ')
                    .. ansi_string(vim.fn.fnamemodify(filename, ':~:.'), 'FzfFilename') .. ':'
                    .. ansi_string(tostring(lnum), 'FzfLnum').. ':'
                    .. ansi_string(tostring(col), 'FzfCol')
                table.insert(all_entries, table.concat({
                    #all_entries + 1,
                    offset_encoding,
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

                local line = vim.api.nvim_buf_get_lines(bufnr, start_pos.line, start_pos.line + 1, false)[1]
                local end_line = vim.api.nvim_buf_get_lines(bufnr, end_pos.line, end_pos.line + 1, false)[1]

                local lnum = start_pos.line + 1
                local col = start_pos.character == 0 and start_pos.character
                    or vim.str_byteindex(line, offset_encoding, start_pos.character, false) + 1
                local end_lnum = end_pos.line + 1
                local end_col = end_pos.character == 0 and end_pos.character
                    or vim.str_byteindex(end_line, offset_encoding, end_pos.character, false) + 1
                local text = '[' .. icon .. kind .. '] ' .. symbol.name .. ' ' .. client_name

                -- Use two whitespaces for each level of indentation to show the hierarchical structure
                local fzf_text = _child_prefix .. '[' .. colored_icon_kind .. '] ' .. symbol.name .. ' ' .. colored_client_name

                -- Fzf entries
                table.insert(all_entries, table.concat({
                    #all_entries + 1,
                    offset_encoding,
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
                    text = text,
                })
                if symbol.children then
                    _symbols_to_entries_and_items(symbol.children, _child_prefix .. string.rep(' ', 2))
                end
            end
        end
    end

    _symbols_to_entries_and_items(symbols, child_prefix)
end

---Send request document symbols or workspace symbols and then execute fzf
---@param title string The title for quickfix list and fzf prompt
---@param symbol_query string The query for requesting workspace symbols. It will be empty for document
---symbol request
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
    if symbol_query ~= '' then
        fzf_header = ':: Query: ' .. ansi_string(symbol_query, 'FzfRgQuery') .. '\n' .. fzf_header
        fzf_preview_window = 'down,45%,' .. fzf_preview_window
    end

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
                    local offset_encoding = lines[i]:match('^%S+%s(%S+)')
                    if symbol_query ~= '' then
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
            ' ',
            '--with-nth',
            '6..',
            '--prompt',
            title .. '> ',
            '--header',
            fzf_header,
            '--expect',
            common_expect .. ',ctrl-q,ctrl-l',
            '--preview',
            bat_prefix .. ' --highlight-line {4} -- {3}',
            '--preview-window',
            fzf_preview_window,
            '--bind',
            set_preview_label('$(echo {3}:{4}:{5} | sed "s|^$HOME|~|")'),
        }),
    }

    local function handle_contents()
        local remaining = #clients
        for _, client in ipairs(clients) do
            client:request(method, params, function(_, result, ctx)
                symbols_to_entries_and_items(result, ctx, '', all_entries, all_items)
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
vim.keymap.set('n', '<Leader>ls', function()
    run(function(from_resume)
        local params = { textDocument = vim.lsp.util.make_text_document_params() }
        lsp_symbols('textDocument/documentSymbol', params, 'LSP Document Symbols', '', from_resume)
    end)
end)

-- Resume of workspace_symbols finder needs the predefined symbol query
local cached_symbol_query = ''
local function workspace_symbols_resume(from_resume)
    local params = { query = cached_symbol_query }
    lsp_symbols('workspace/symbol', params, 'LSP Workspace Symbols', cached_symbol_query, from_resume)
end

-- LSP workspace symbols
vim.keymap.set('n', '<Leader>lS', function()
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
        local fzf_text = icon == '' and icon or icon .. ' '
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
            fzf_text,
        }, ' ')
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
                    local offset_encoding = lines[i]:match('^%S+%s(%S+)')
                    vim.lsp.util.show_document(item.user_data, offset_encoding)
                end
            end
        end,
        options = get_fzf_opts(from_resume, {
            '--with-nth',
            '6..',
            '--prompt',
            title .. '> ',
            '--header',
            ':: CTRL-Q (send to quickfix), CTRL-L (send to loclist)',
            '--expect',
            common_expect .. ',ctrl-q,ctrl-l',
            '--preview',
            bat_prefix .. ' --highlight-line {4} -- {3}',
            '--preview-window',
            'down,45%,+{4}-/2',
            '--bind',
            set_preview_label('$(echo {3}:{4}:{5} | sed "s|^$HOME|~|")'),
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
        notify.warn('No diagnostics!')
        return
    end

    local title = string.format('Diagnostics (%s)', opts.all and 'workspace' or 'document')
    local spec = {
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
            '--read0',
            '--with-nth',
            '5..',
            '--prompt',
            title .. '> ',
            '--header',
            ':: CTRL-Q (send to quickfix), CTRL-L (send to loclist)',
            '--expect',
            common_expect .. ',ctrl-q,ctrl-l',
            '--preview',
            bat_prefix .. ' --highlight-line {3} -- {2}',
            '--preview-window',
            '+{3}-/2',
            '--bind',
            set_preview_label('$(echo {2}:{3}:{4} | sed "s|^$HOME|~|")'),
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
            local filename = vim.api.nvim_buf_get_name(bufnr)
            local devicon = ansi_devicon(filename)
            local diag_icon = ansi_string(diag_icons[diag.severity].text, diag_icons[diag.severity].hl)
            local lnum = diag.lnum + 1
            local col = diag.col + 1
            -- Fzf entry
            -- Each entry consists of 5 parts:
            -- index, filename, lnum, col, fzf_text
            -- Only fzf_text will be presented in fzf. The first part, index, is used to retrieve the
            -- corresponding original diagnostic item from the selected entry in fzf.
            local fzf_text = string.format(
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
                fzf_text
            }, ' '))
        end
        write(entries)
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
