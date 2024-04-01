-- Configurations for fzf.vim

-- Notes about fzf#vim#with_preview()
--
-- 1. It uses the value of g:fzf_vim.preview_window to set the preview window of fzf through its
--    --preview-window option.
-- 2. It sets the --preview option of fzf to `--preview fzf.vim/bin/preview.sh {FILENAME}:{LINENO}`.
--    {FILENAME} and {LINENO} are placeholders of fzf. In this case, {FILENAME} will be the file
--    name for bat and {LINENO} the line number to be highlighted for bat's --highlight-line option.
-- 3. The placeholders in fzf's --preview option can be specified through the placeholder field in
--    the table passed to this function. This table is the spec dictionary similar to vim#wrap. The
--    "Deleted selected buffers" keymap below illustrate how to set the placeholders.
-- 4. If the placeholder is assigned to an empty string, fzf#vim#with_preview won't set --preview
--    option for fzf. The outer function calling fzf#vim#with_preview may set --preview instead
--    (e.g., fzf#vim#commits set --preview to use delta), or we can explicitly set the --preview
--    option in the `options` table in the spec dictionary (e.g., see the BCommits keymap below). If
--    --preview option is not set anywhere, the one defined in FZF_DEFAULT_OPTS will be used.

local uv = require('luv')
local qf = require('rockyz.qf')
local bar_icon = require('rockyz.icons').separators.bar

local rg_prefix = 'rg --column --line-number --no-heading --color=always --smart-case'
local bat_prefix = 'bat --color=always --paging=never --style=numbers'

vim.g.fzf_layout = {
  window = {
    height = 0.8,
    width = 0.5,
  },
}

vim.g.fzf_action = {
  ['ctrl-x'] = 'split',
  ['ctrl-v'] = 'vsplit',
  ['ctrl-t'] = 'tab drop',
  ['enter'] = 'drop',
}

-- The layout of the preview window. vim#fzf#with_preview must be used to make this option
-- effective.
vim.g.fzf_vim = {
  preview_window = {
    'up,40%,border-down',
    'ctrl-/',
  },
}

local function merge_default(opts)
  local extra_default_opts = {
    '--border',
    'rounded',
    '--layout',
    'reverse-list',
  }
  return vim.list_extend(opts, extra_default_opts)
end

-- Files
vim.keymap.set('n', '<Leader>ff', function()
  vim.fn['fzf#vim#files'](
    '',
    vim.fn['fzf#vim#with_preview']({
      options = merge_default({
        '--preview-window',
        'hidden',
      }),
    })
  )
end)

-- Old files
vim.keymap.set('n', '<Leader>fo', function()
  vim.fn['fzf#vim#history'](vim.fn['fzf#vim#with_preview']({
    options = merge_default({
      '--prompt',
      'OldFiles> ',
      '--preview-window',
      'hidden',
    }),
  }))
end)

-- Git files
vim.keymap.set('n', '<C-p>', function()
  vim.fn['fzf#vim#gitfiles'](
    '',
    vim.fn['fzf#vim#with_preview']({
      options = merge_default({
        '--preview-window',
        'hidden',
      }),
    })
  )
end)

-- Git commits
vim.cmd([[
  command! -bar -bang -nargs=* -range=% GitCommits <line1>,<line2>call fzf#vim#commits(<q-args>, {
    \ "options": [
    \   "--border",
    \   "rounded",
    \   "--layout",
    \   "reverse-list",
    \   "--prompt",
    \   "Commits> ",
    \   "--preview-window",
    \   "up,70%,border-down",
    \   "--header",
    \   ":: CTRL-S (toggle sort), CTRL-Y (yank commmit hashes), CTRL-D (diff)",
    \ ]}, <bang>0)
]])
vim.keymap.set({ 'n', 'x' }, '<Leader>fC', function()
  local original_layout = vim.g.fzf_layout
  vim.g.fzf_layout = {
    window = {
      height = 0.8,
      width = 0.8,
    }
  }
  vim.cmd('GitCommits')
  vim.g.fzf_layout = original_layout
end)

-- Git commits for current buffer or visual-select lines
vim.cmd([[
  command! -bar -bang -nargs=* -range=% GitBufCommits <line1>,<line2>call fzf#vim#buffer_commits(<q-args>, {
    \ "options": [
    \   "--border",
    \   "rounded",
    \   "--layout",
    \   "reverse-list",
    \   "--prompt",
    \   "BufCommits> ",
    \   "--preview-window",
    \   "up,70%,border-down",
    \   "--header",
    \   ":: CTRL-S (toggle sort), CTRL-Y (yank commmit hashes), CTRL-D (diff)",
    \ ]}, <bang>0)
]])
vim.keymap.set({ 'n', 'x' }, '<Leader>fc', function()
  local original_layout = vim.g.fzf_layout
  vim.g.fzf_layout = {
    window = {
      height = 0.8,
      width = 0.8,
    }
  }
  vim.cmd('GitBufCommits')
  vim.g.fzf_layout = original_layout
end)

-- Search history
vim.keymap.set('n', '<Leader>f/', function()
  vim.fn['fzf#vim#search_history'](vim.fn['fzf#vim#with_preview']({
    options = merge_default({
      '--prompt',
      'SearchHist> ',
      '--bind',
      'start:unbind(ctrl-/)',
      '--preview-window',
      'hidden',
    }),
  }))
end)

-- Command history
vim.keymap.set('n', '<Leader>f:', function()
  vim.fn['fzf#vim#command_history'](vim.fn['fzf#vim#with_preview']({
    options = merge_default({
      '--prompt',
      'CommandHist> ',
      '--bind',
      'start:unbind(ctrl-/)',
      '--preview-window',
      'hidden',
    }),
  }))
end)

-- Buffers
vim.keymap.set('n', '<Leader>fb', function()
  vim.fn['fzf#vim#buffers'](
  '',
  vim.fn['fzf#vim#with_preview']({
    placeholder = '{1}',
    options = merge_default({
      '--prompt',
      'Buffers> ',
    }),
  })
  )
end)

-- Delete the selected buffers
-- Ref: https://github.com/junegunn/fzf.vim/pull/733#issuecomment-559720813
vim.keymap.set('n', '<Leader>bD', function()
  -- :ls returns a multiple lines string containing infos of all buffers (each
  -- line is one buffer)
  local bufs = vim.fn.execute('ls')
  local buflist = {}
  -- Get a list of buffers: split the string by \n.
  -- Each buffer info is like ` 7 h "path/to/the/buffer" line 10`. It has 5
  -- parts: bufnr, indicators (may have multiple), buffer path, literal word line and the line number
  -- of of cursor.
  for item in string.gmatch(bufs, '([^\n]+)\n?') do
    -- Remove the doulbe quotes in the buffer path
    local buf = string.gsub(item, '"', '')
    table.insert(buflist, buf)
  end
  vim.fn['fzf#run'](vim.fn['fzf#wrap'](vim.fn['fzf#vim#with_preview']({
    source = buflist,
    -- lines is a table containing all the selections (each selection is a
    -- buffer info)
    ['sink*'] = function(lines)
      local bufnrs = {}
      for _, line in ipairs(lines) do
        -- Extract the bufnr, i.e., the first part in the buffer info, and
        -- insert it into bufnrs
        table.insert(bufnrs, string.match(line, '^%s+(%d+)'))
      end
      if next(bufnrs) ~= nil then
        vim.cmd('bwipeout ' .. table.concat(bufnrs, ' '))
      end
    end,
    options = merge_default({
      '--multi',
      '--prompt',
      'DelBufs> ',
      '--header',
      ':: ENTER (delete all selected buffers)',
      -- Set SCROLL in the preview window, {-1} is the line numbrer
      '--preview-window',
      '+{-1}-/2',
    }),
    -- {FILENAME}:{LINENO}
    -- In each buffer info, the 3rd to last part is the buffer path that will be the
    -- FILENAME for bat and the last part is the line number that is for bat's
    -- --highlight-line option
    placeholder = '{-3}:{-1}',
  })))
end)

-- Find files for my dotfiles
vim.keymap.set('n', '<Leader>f.', function()
  vim.fn['fzf#vim#files'](
    '',
    vim.fn['fzf#vim#with_preview']({
      source = 'ls-dotfiles',
      options = merge_default({
        '--prompt',
        'Dotfiles> ',
        '--preview-window',
        'hidden',
      }),
    })
  )
end)

-- Find files under home directory
vim.keymap.set('n', '<Leader>f~', function()
  vim.fn['fzf#vim#files'](
    '~',
    vim.fn['fzf#vim#with_preview']({
      options = merge_default({
        '--prompt',
        'HomeFiles> ',
        '--preview-window',
        'hidden',
      }),
    })
  )
end)

-- Marks
vim.keymap.set('n', '<Leader>fm', function()
  local filename = '$([[ -f {4} ]] && echo {4} || echo ' .. vim.api.nvim_buf_get_name(0) .. ')'
  vim.fn['fzf#vim#marks'](vim.fn['fzf#vim#with_preview']({
    placeholder = '',
    options = merge_default({
      '--prompt',
      'Marks> ',
      '--preview-window',
      '+{2}-/2',
      '--preview',
      bat_prefix .. ' --highlight-line {2} -- ' .. filename,
    })
  }))
end)

-- Path completion in normal mode
vim.keymap.set('i', '<C-x><C-f>', function()
  vim.fn['fzf#vim#complete#path']('fd')
end)

--
-- Find entries in quickfix and location list
--

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
    table.insert(entries, bufnr .. ' ' .. bufname .. ' ' .. lnum .. ' ' .. qf.format_qf_item(item))
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
    placeholder = '',
    options = merge_default({
      '--no-multi',
      '--prompt',
      prompt .. '> ',
      '--header',
      ':: ENTER (open the file)',
      '--with-nth',
      '4..',
      '--preview-window',
      'up,70%,border-down,+{3}-/2',
      '--preview',
      bat_prefix .. ' --highlight-line {3} -- {2}',
    }),
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
      entry = entry .. ' '
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
        local str = qf.format_qf_item(item)
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
    options = merge_default({
      '--with-nth',
      '2..',
      '--no-multi',
      '--prompt',
      prompt.. '> ',
      '--header',
      ':: ENTER (switch to the selected quickfix list)',
      '--preview-window',
      'up,70%,border-down',
      '--preview',
      preview,
    }),
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
  name = name or ''
  return merge_default({
    '--ansi',
    '--disabled',
    '--query',
    query,
    '--prompt',
    name .. ' [RG]> ',
    '--bind',
    'start:reload(' .. rg .. ' ' .. vim.fn.shellescape(query) .. ')+unbind(ctrl-r)',
    '--bind',
    'change:reload:' .. rg .. ' {q} || true',
    '--bind',
    'ctrl-f:unbind(change,ctrl-f)+change-prompt('
      .. name
      .. ' [FZF]> )+enable-search+rebind(ctrl-r)+transform-query(echo {q} > /tmp/rg-fzf-vim-r; cat /tmp/rg-fzf-vim-f)',
    '--bind',
    'ctrl-r:unbind(ctrl-r)+change-prompt('
      .. name
      .. ' [RG]> )+disable-search+reload('
      .. rg
      .. ' {q} || true)+rebind(change,ctrl-f)+transform-query(echo {q} > /tmp/rg-fzf-vim-f; cat /tmp/rg-fzf-vim-r)',
    '--delimiter',
    ':',
    '--header',
    ':: CTRL-R (RG mode), CTRL-F (FZF mode)',
    '--preview-window',
    'up,70%,border-down,+{2}-/2',
    '--preview',
    bat_prefix .. ' --highlight-line {2} -- {1}',
  })
end

-- Define a new command :RGU (U for Ultimate) that supports rg options and two modes
vim.api.nvim_create_user_command('RGU', function(opts)
  os.execute('rm -f /tmp/rg-fzf-vim-{r,f}')
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

-- Live grep (:RG) in nvim config
vim.keymap.set('n', '<Leader>gv', function()
  os.execute('rm -f /tmp/rg-fzf-vim-{r,f}')
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

-- Grep (:Rg) for the current word (normal mode) or the current selection (visual mode)
vim.keymap.set({ 'n', 'x' }, '<Leader>gw', function()
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
      options = merge_default({
        '--prompt',
        'Word [Rg]> ',
        '--preview-window',
        'up,70%,border-down,+{2}-/2',
        '--preview',
        bat_prefix .. ' --highlight-line {2} -- {1}',
        -- Show the current query in header. Set its style to bold, red foreground via ANSI color
        -- code.
        '--header',
        ':: Query: \x1b[1;31m' .. header .. '\x1b[m',
      }),
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
    options = merge_default({
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
      '--preview-window',
      'up,70%,border-down,+{2}-/2',
      '--preview',
      bat_prefix .. ' --highlight-line {2} -- {1}',
      '--header',
      ':: Current buffer: ' .. vim.fn.expand('%:~:.'),
    }),
  })
end)
