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

-- Files
-- Old files
-- Git files
-- Git commits
-- Git commits for current buffer
-- Search history
-- Command history
-- Buffers
-- Buffer delete
-- Files for my dotfiles
-- Files under HOME
-- Tabs
-- Quickfix/Location list items
-- Quickfix/Location list history
-- Ultimate grep (:RGU)
-- Live grep in my nvim config
-- Grep for the current word/selection
-- Live grep in current buffer
-- LSP references

local uv = require('luv')
local qf_utils = require('rockyz.utils.qf_utils')
local icon = require('rockyz.icons')

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

-- ANSI escape codes for colors
local colors = {
  directory = '\x1b[38;2;86;156;214m', -- Directory
  number = '\x1b[38;2;172;128;255m', -- Number
  type = {
    E = '\x1b[38;2;241;74;74m', -- DiagnosticError
    W = '\x1b[38;2;204;167;0m', -- DiagnosticWarn
    I = '\x1b[38;2;55;148;255m', -- DiagnosticInfo
    H = '\x1b[38;2;179;178;177m', -- DiagnosticHint
  },
  green = '\x1b[38;2;166;226;44m',
  red = '\x1b[38;2;249;36;114m',
  red_bold = '\x1b[1;38;2;249;36;114m',
  reset = '\x1b[m'
}

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
      'OldFiles> ',
    },
  }))
end)

-- Git files
vim.keymap.set('n', '<C-p>', function()
  vim.fn['fzf#vim#gitfiles'](
    '',
    vim.fn['fzf#vim#with_preview']({
      options = {
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
    \   "BufCommits> ",
    \   "--preview-window",
    \   "down,45%",
    \   "--header",
    \   ":: CTRL-S (toggle sort), CTRL-Y (yank commmit hashes), CTRL-D (diff)",
    \   "--bind",
    \   "focus:transform-preview-label:echo [ Diff with commit {1} ]",
    \ ]}, <bang>0)
]])
vim.keymap.set({ 'n', 'x' }, '<Leader>fc', function()
  vim.cmd('GitBufCommits')
end)

-- Search history
vim.keymap.set('n', '<Leader>f/', function()
  vim.fn['fzf#vim#search_history'](vim.fn['fzf#vim#with_preview']({
    options = {
      '--prompt',
      'SearchHist> ',
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
      'CommandHist> ',
      '--bind',
      'start:unbind(ctrl-/)',
      '--preview-window',
      'hidden',
    },
  }))
end)

-- Buffers
-- Enter to switch and CTRL-D to delete
vim.keymap.set('n', '<Leader>fb', function()
  vim.fn['fzf#vim#buffers']('', vim.fn['fzf#vim#with_preview']({
    ['sink*'] = function(lines)
      local key = lines[1]
      if key == 'ctrl-d' then
        for i = 2, #lines do
          local bufnr = string.match(lines[i], '%[(%d+)%]')
          if vim.bo[tonumber(bufnr)].buftype == 'terminal' then
            -- Force deletion of terminal buffer
            vim.cmd('bwipeout! ' .. bufnr)
          else
            vim.cmd('bwipeout ' .. bufnr)
          end
        end
      elseif key == '' then
        -- ENTER (only works when a single buffer is selected)
        if #lines ~= 2 then
          return
        end
        local bufnr = string.match(lines[2], '%[(%d+)%]')
        vim.cmd('buffer ' .. bufnr)
      else
        -- CTRL-X/V/T (works for multiple selected buffers)
        local action = vim.g.fzf_action[key]
        for i = 2, #lines do
          vim.cmd(action)
          local bufnr = string.match(lines[i], '%[(%d+)%]')
          vim.cmd('buffer ' .. bufnr)
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
        'HomeFiles> ',
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
          -- Space is the default delimiter in fzf, so temporarily replacing it with a special
          -- string such as "@@@@". When the bufname is needed in the preview later on, replace it
          -- back.
          cur_bufname = bufname:gsub(" ", "@@@@")
          cur_lnum = vim.api.nvim_win_get_cursor(winid)[1]
          -- Use green color to mark the current window in a tab
          filename = colors.green .. filename .. colors.reset
        end
        table.insert(filenames, filename)
      end
    end
    -- prefix is used by fzf itself for preview and sink, and it won't be presented in each entry
    local prefix = cur_bufname .. ' ' .. cur_lnum .. ' ' .. tid .. ' ' .. table.concat(winids, ',')
    local entry = prefix .. ' ' .. idx .. ': ' .. table.concat(filenames, ', ')
    -- Indicator for current tab
    if tid == cur_tab then
      entry = entry .. ' ' .. icon.caret.left
    end
    table.insert(entries, entry)
  end
  vim.fn['fzf#run'](vim.fn['fzf#wrap']({
    source = entries,
    ['sink*'] = function(lines)
      local key = lines[1]
      if key == 'ctrl-d' and #vim.api.nvim_list_tabpages() > 1 then
        for i = 2, #lines do
          for winid in lines[i]:match('%S+%s%S+%s%S+%s(%S+)'):gmatch('[^,]+') do
            vim.api.nvim_win_close(tonumber(winid), false)
          end
        end
      else
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
    table.insert(entry, colors.directory .. item.fname .. colors.reset)
  end
  local lnum_col = item.lnum
  if item.col ~= '' then
    lnum_col = item.lnum .. ':' .. item.col
  end
  if lnum_col ~= '' then
    table.insert(entry, colors.number .. lnum_col .. colors.reset)
  end
  local type_color = colors.type[item.type]
  if item.type ~= '' then
    local type = '[' .. item.type .. ']'
    if type_color then
      type = type_color .. type .. colors.reset
    end
    table.insert(entry, type)
  end
  if item.text ~= '' then
    local text = item.text
    if type_color then
      text = type_color .. text .. colors.reset
    end
    table.insert(entry, text)
  end
  return table.concat(entry, ' ')
end

---@param win_local boolean true for location list and false for quickfix
local function fzf_qf(win_local)
  local what = { items = 0 }
  local list = win_local and vim.fn.getloclist(0, what) or vim.fn.getqflist(what)
  local entries = {}
  for _, item in ipairs(list.items) do
    local bufnr = item.bufnr
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    local lnum = item.lnum
    -- The formatted entries will be fed to fzf.
    -- Each entry is like "bufnr bufname lnum path/to/the/file   |134:20| E error".
    -- The first three parts are used for fzf itself and won't be presented in fzf window.
    -- * bufnr is used for sink of fzf.vim
    -- * bufname and lnum are used for preview
    table.insert(entries, bufnr .. ' ' .. bufname .. ' ' .. lnum .. ' ' .. get_qf_entry(qf_utils.format_qf_item(item)))
  end
  -- fzf
  local prompt = win_local and 'LocationList' or 'QuickfixList'
  vim.fn['fzf#run'](vim.fn['fzf#wrap']({
    source = entries,
    ['sink'] = function(line)
      local bufnr = string.match(line, "%d+")
      local lnum = string.match(line, "%S+%s+%S+%s+(%S+)")
      vim.cmd('buffer ' .. bufnr)
      vim.cmd('execute ' .. lnum)
      vim.cmd('normal! zvzz')
    end,
    options = {
      '--ansi',
      '--no-multi',
      '--prompt',
      prompt .. '> ',
      '--header',
      ':: ENTER (jump to the file)',
      '--with-nth',
      '4..',
      '--preview-window',
      'down,45%,+{3}-/2',
      '--preview',
      bat_prefix .. ' --highlight-line {3} -- {2}',
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

-- Remove temp dirs when quiting nvim
vim.api.nvim_create_autocmd('VimLeave', {
  callback = function()
    uv.fs_rmdir(qflist_hist_dir, function()
    end)
    uv.fs_rmdir(loclist_hist_dir, function()
    end)
  end,
})

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
    -- Prepend id to each entry is to use it for the fzf's --preview option, because id serves as
    -- part of the filename of the temp file used for preview.
    -- id won't be presented in each entry in fzf (thanks to fzf's --with-nth option).
    -- Each entry presented in fzf is like: "[3] 1 items    Diagnostics".
    local entry = list.id .. ' [' .. cnt .. '] ' .. list.size .. ' items    ' .. list.title
    if list.nr == cur_nr then
      entry = entry .. ' ' .. icon.caret.left
    end
    table.insert(entries, entry)
    cnt = cnt + 1

    -- Filename of the temp file
    -- * For location list: use quickfix-id plus current winid
    -- * For quickfix list: use quickfix-id
    -- Name the file using quickfix-id because it is unique in a vim session. So each list will be
    -- associated with one specific temp file, and this allows for avoiding the need to regenerate
    -- the temp file every time.
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
  local prompt = win_local and 'LocationListHist' or 'QuickfixListHist'
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

-- Temp files for query restore and mode toggle
local rg_query = '/tmp/fzfvim-grep-rg-mode-query'
local fzf_query = '/tmp/fzfvim-grep-fzf-mode-query'
local fzf_mode_enabled = '/tmp/fzfvim-grep-fzf-mode-enabled'

-- Remove temp files
local function rm_temp_files()
  os.execute(string.format('rm -f %s %s %s', rg_query, fzf_query, fzf_mode_enabled))
end

---Generate the fzf options for rg and fzf integration
---@param rg string The final rg command
---@param query string The initial query for rg
---@param name string The name of that keymap
---@return table
local function get_fzf_opts_for_RG(rg, query, name)
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
  rm_temp_files()
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
  rm_temp_files()
  local rg = rg_prefix .. ' --glob=!minpac -- '
  local query = ''
  vim.fn['fzf#vim#grep2'](
    rg,
    query,
    {
      dir = '~/.config/nvim',
      options = get_fzf_opts_for_RG(rg, query, 'NvimConfig'),
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
        -- Show the current query in header. Set its style to bold, red foreground via ANSI color
        -- code.
        '--header',
        ':: Query: ' .. colors.red_bold .. header .. colors.reset,
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
