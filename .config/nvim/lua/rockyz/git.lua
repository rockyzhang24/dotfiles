-- References:
-- justinmk/vim-ug

local has_gitsigns, gitsigns = pcall(require, 'gitsigns')
local notify = require('rockyz.utils.notify')

local git_log_cmd = 'Git log --pretty="%h%d %s  %aN (%cr)" --date=relative'

local function git_relative_path()
    local obj = vim.system({ 'git', 'rev-parse', '--show-toplevel' }, { text = true }):wait()
    if obj.code ~= 0 then
        return vim.fn.expand('%')
    end

    local git_root = vim.trim(obj.stdout)
    local file_path = vim.api.nvim_buf_get_name(0)

    return vim.fs.relpath(git_root, file_path) or vim.fn.expand('%')
end

local function fugitive_detect()
    if vim.b.git_dir == nil then
        vim.fn.FugitiveDetect()
    end
end

local function command_output(args)
    local obj = vim.system(args, { text = true }):wait()
    if obj.code ~= 0 then
        return nil
    end
    return vim.trim(obj.stdout)
end

---Parse "owner/repo" from a git remote URL (HTTPS or SSH)
---@param url string
---@return string?
local function parse_github_repo(url)
    local path = url:match('^git@github%.com:(.+)$')
    or url:match('^ssh://git@github%.com/(.+)$')
    or url:match('^https?://github%.com/(.+)$')

    if not path then
        return nil
    end

    path = path:gsub('/+$', ''):gsub('%.git$', '')
    return path:match('^([%w_.-]+/[%w_.-]+)$')
end

local function github_remotes()
    local remotes_raw = command_output({ 'git', 'remote' })
    if remotes_raw == nil then
        return nil, 'not in a Git repository'
    end
    if remotes_raw == '' then
        return nil, 'no git remotes found'
    end

    local remotes = {}
    local seen = {}

    for remote in vim.gsplit(remotes_raw, '\n', { trimempty = true }) do
        local url = command_output({ 'git', 'remote', 'get-url', remote })
        local repo = url and parse_github_repo(url)

        if repo and not seen[repo] then
            seen[repo] = true
            remotes[#remotes + 1] = {
                repo = repo,
                owner = repo:match('^([^/]+)/'),
            }
        end
    end

    if #remotes == 0 then
        return nil, 'no GitHub remotes found'
    end

    return remotes
end

local function parent_repo(repo)
    local parent = command_output({
        'gh',
        'api',
        ('repos/%s'):format(repo),
        '--jq',
        'select(.fork) | .parent.full_name // empty',
    })

    return parent ~= '' and parent or nil
end

---@return string? pr_url
local function find_pr(repo, head)
    local url = command_output({
        'gh',
        'api',
        ('repos/%s/pulls'):format(repo),
        '--method',
        'GET',
        '--raw-field',
        'head=' .. head,
        '--raw-field',
        'state=all',
        '--raw-field',
        'per_page=1',
        '--jq',
        '.[0].html_url // empty',
    })

    return url ~= '' and url or nil
end

---Tries to get the GitHub PR URL for the current branch:
---1. Get the current branch name
---2. Collect the parse GitHub remotes
---3. Search fork remotes' parent repositories for a PR whose head matches "{fork_owner}:{branch}"
---4. If none is found, search each remote's own repository for a PR whose head matches
---   "{remote_owner}:{branch}"
---5. Return the first matching PR URL
---
---@return boolean status
---@return string url or error message
local function get_pr_url()
    local branch = command_output({ 'git', 'branch', '--show-current' })
    if branch == nil then
        return false, 'not in a Git repository'
    end
    if branch == '' then
        return false, 'HEAD is detached'
    end

    local remotes, err = github_remotes()
    if not remotes then
        return false, err
    end

    -- Search PRs from a fork branch into each fork's parent repository
    for _, remote in ipairs(remotes) do
        local parent = parent_repo(remote.repo)
        if parent then
            local pr_url = find_pr(parent, remote.owner .. ':' .. branch)
            if pr_url then
                return true, pr_url
            end
        end
    end

    -- Search PRs whose source branch is in the same repository
    for _, remote in ipairs(remotes) do
        local pr_url = find_pr(remote.repo, remote.owner .. ':' .. branch)
        if pr_url then
            return true, pr_url
        end
    end

    return false, ('no PR found for branch "%s"'):format(branch)
end

local scm_context_pattern = [[^\(@@ .* @@\|[<=>|]\{7}[<=>|]\@!\)]]

---Jump to the previous or next SCM conflict marker or diff hunk header
---Reference: tpope/vim-unimpaired
---@param reverse boolean
local function jump_scm_context(reverse)
    vim.fn.search(scm_context_pattern, reverse and 'bW' or 'W')
end

--------------------------------------------------------------------------------
-- Keymaps
--------------------------------------------------------------------------------

-- Jump to next change
vim.keymap.set('n', '<C-n>', function()
    if vim.wo.diff then
        vim.cmd('normal! ]c')
        jump_scm_context(false)
        return
    end

    if has_gitsigns then
        gitsigns.next_hunk({ wrap = false })
    else
        jump_scm_context(false)
    end
end)

-- Jump to previous change
vim.keymap.set('n', '<C-p>', function()
    if vim.wo.diff then
        vim.cmd('normal! [c')
        jump_scm_context(true)
        return
    end

    if has_gitsigns then
        gitsigns.prev_hunk({ wrap = false })
    else
        jump_scm_context(true)
    end
end)

-- Blame this line
vim.keymap.set('n', 'Ub', function()
    vim.cmd('.,Git blame')
    vim.api.nvim_feedkeys(vim.keycode('<CR>'), 'm', false)
end, { silent = true })

-- {visual}Ub to blame the selected range
vim.keymap.set('x', 'Ub', ':Git blame<CR>')

-- UB to open blame view, honoring revision from blame.ignoreRevsFile.
-- [count]UB to open blame without ignored revisions; any nonzero count clears them.
vim.keymap.set('n', 'UB', function()
    local ignore_revs = vim.v.count > 0 and ' --ignore-revs-file ""' or ''
    vim.cmd('Git blame' .. ignore_revs)
end)

-- Blame this line (gitsigns.nvim)
vim.keymap.set('n', 'Un', function()
    if has_gitsigns then
        gitsigns.blame_line()
    end
end)

-- Uc to commit using the current file's most-recent commit-message
-- [count]Uc: same as Uc, but skips Git commit verification hooks with --no-verify
vim.keymap.set('n', 'Uc', function()
    local result = vim.fn.FugitiveExecute({
        'log',
        '-1',
        '--format=%s',
        '--',
        vim.fn.FugitivePath(),
    })
    local subject = result.stdout[1]

    if subject == nil then
        notify.error('[Fugitive] no previous commit found for the current file')
        return
    end

    local no_verify = vim.v.count > 0 and '--no-verify ' or ''
    vim.cmd('Git commit ' .. no_verify .. '--edit -m ' .. vim.fn.shellescape(subject))
end)

-- Ud to diff this buffer
-- [count]Ud to diff this buffer with [count] commits earlier
vim.keymap.set('n', 'Ud', function()
    if vim.wo.diff then
        vim.cmd('diffupdate')
        return
    end

    vim.cmd('update')

    local count = vim.v.count
    if count == 0 then
        local result = vim.fn.FugitiveExecute({
            'diff',
            '--',
            vim.fn.FugitivePath(),
        })

        if #result.stdout == 1 and result.stdout[1] == '' then
            vim.cmd('echo "no changes"')
            return
        end
    end

    local revision = count > 0 and (' HEAD' .. string.rep('^', count)) or ''
    vim.cmd('Gvdiffsplit' .. revision)
end)

-- `:Gedit<CR>`
vim.keymap.set('n', 'Ue', ':Gedit<CR>', { silent = true })

-- Start a `:Git commit --fixup=` command for the current file's most-recent commit
-- Use `git rebase -i --autosquash origin/main` later to fold it into that commit
vim.keymap.set('n', 'Uf', function()
    local result = vim.fn.FugitiveExecute({
        'log',
        '-1',
        '--format=%h',
        '--',
        vim.fn.FugitivePath(),
    })
    local commit = result.stdout[1]

    if commit == nil then
        notify.error('[Fugitive] no previous commit found for the current file')
        return
    end

    return ':Git commit --fixup=' .. commit
end, { expr = true })

-- `:Guh .` (see https://github.com/justinmk/guh.nvim)
vim.keymap.set('n', 'Ug', ':Guh .<CR>')

-- Show logs (Git history) for this file
vim.keymap.set('n', 'Ul', '<Cmd>' .. git_log_cmd .. ' --follow -- %<CR>')
-- Show logs (Git history) for the current repo
vim.keymap.set('n', 'UL', '<Cmd>' .. git_log_cmd .. '<CR>')
-- Show logs (Git history) for the selected range
vim.keymap.set('x', 'Ul', ':Gclog!<CR>')
-- Show the most-recent commit fot this file
vim.keymap.set('n', 'Uh', '<Cmd>Gedit @<CR>')

-- Start a `:Git log ... ` command
vim.keymap.set('n', 'U:', ':' .. git_log_cmd)

-- Show the logs (Git history) for this Method/Function
vim.keymap.set('n', 'Um', function()
    local function_name = vim.fn.expand('<cword>')
    local file_path = git_relative_path()
    return ':' .. git_log_cmd .. ' -L :' .. function_name .. ':' .. vim.fn.fnameescape(file_path)
end, { expr = true })

-- Flog
vim.keymap.set('n', 'Uv', '<Cmd>Flog<CR>')
vim.keymap.set('n', 'UV', '<Cmd>Flog -raw-args=--follow -path=%<CR>') -- For current file

-- Ur to read the index version into the buffer
-- [count]Ur to read the version [count] commits ago into the buffer
vim.keymap.set('n', 'Ur', function()
    local count = vim.v.count
    local object = count > 0 and (' @' .. string.rep('^', count) .. ':%') or ''
    vim.cmd('Gread' .. object)
end)

-- Show git status
vim.keymap.set('n', 'Us', ':Git<CR>', { silent = true })

-- `:Gedit` on <cWORD>
vim.keymap.set('n', 'Uu', ':Gedit <C-r><C-a><CR>', { silent = true })

-- `:Gwrite!<CR>`
vim.keymap.set('n', 'Uw', function()
    fugitive_detect()
    vim.cmd('checktime %')
    vim.cmd('Gwrite')
end)

-- Ux for `:GBrowse`
-- [count]Ux to open the GitHub PR associated with the current branch1
vim.keymap.set('n', 'Ux', function()
    if vim.v.count == 0 then
        if not pcall(vim.cmd, '.GBrowse') then
            vim.api.nvim_feedkeys(':.GBrowse @', 'n', false)
        end
        return
    end

    local ok, result = get_pr_url()
    if ok then
        vim.ui.open(result)
    else
        notify.error('[Fugitive] ' .. result)
    end
end)

-- {visual}Ux to `:GBrowse` the selected range
vim.keymap.set(
    'x',
    'Ux',
    ":<C-u>try<Bar>'<,'>GBrowse<Bar>catch<Bar>call feedkeys('gv:GBrowse @')<Bar>endtry<CR>"
)

-- Start a `:Git` command followed by `:Git status`
vim.keymap.set('n', 'U.', ':Git  <C-r><C-w><Bar>Git status<Home><Right><Right><Right><Right>')

-- Gitsigns
if has_gitsigns then
    -- Preview hunk
    vim.keymap.set('n', 'Up', gitsigns.preview_hunk)
    vim.keymap.set('n', 'Ui', gitsigns.preview_hunk_inline)
    -- Toggle word diff
    vim.keymap.set('n', 'yow', gitsigns.toggle_word_diff)
    -- Text object
    vim.keymap.set({ 'x', 'o' }, 'ih', ':<C-u>Gitsigns select_hunk<CR>', { silent = true })
    -- Populate hunks to quickfix
    vim.keymap.set('n', 'Uq', gitsigns.setqflist) -- current buffer
    vim.keymap.set('n', 'UQ', function() -- all modified files
        gitsigns.setqflist('all')
    end)
end

-- Linewise partial staging in visual-mode
vim.keymap.set('x', '<C-o>', ':diffget<CR>')
vim.keymap.set('x', '<C-p>', ':diffput<CR>')

-- During a Fugitive three-way merge diff, take the current hunk from Git index stage 2 (U2) or
-- stage 3 (U3) into the working-tree result buffer.
vim.keymap.set('n', 'U2', '<Cmd>diffget //2<CR>')
vim.keymap.set('n', 'U3', '<Cmd>diffget //3<CR>')

vim.cmd([[
" Prepare a Git grep for the word under the cursor; use ':/!*.foo' for exclusions; send results to quickfix. (vim-fugitive)
nnoremap \g  mS:Ggrep! -q <C-R>=(system(['git','grep','-P'])=~#'no pattern')?'-P':'-E'<CR> <C-R>=shellescape(fnameescape(expand('<cword>')))<CR> -- ':/' ':/!*.pdf'
    \<Home><C-Right><C-Right><C-Right><C-Right><Left>

" Recall the last Git grep and position the cursor on its search pattern (vim-fugitive)
nnoremap 9\g  :Ggrep<Up><Home><C-Right><C-Right><C-Right><C-Right><Left>
]])

--------------------------------------------------------------------------------
-- Autocmds
--------------------------------------------------------------------------------

local augroup = vim.api.nvim_create_augroup('rockyz.git', { clear = true })

vim.api.nvim_create_autocmd({ 'User' }, {
    group = augroup,
    pattern = 'FugitiveIndex,FugitiveCommit',
    callback = function()
        vim.keymap.set(
            'n',
            'dt',
            ':Gtabedit <Plug><cfile><Bar>Gdiffsplit! @<CR>',
            { buffer = 0, remap = true, silent = true }
        )
    end,
})

vim.api.nvim_create_autocmd('FileType', {
    group = augroup,
    pattern = { 'fugitive', 'fugitiveblame' },
    callback = function()
        vim.keymap.set('n', 'q', 'gq', {
            buf = 0,
            nowait = true,
            remap = true,
            silent = true,
        })
    end,
})

vim.api.nvim_create_autocmd('BufWinEnter', {
    group = augroup,
    callback = function(event)
        if vim.fn.exists('*FugitiveDetect') == 1 and event.file == '' then
            vim.fn.FugitiveDetect(vim.fn.getcwd())
        end
    end,
})
