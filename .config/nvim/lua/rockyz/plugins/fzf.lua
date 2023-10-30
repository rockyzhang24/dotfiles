-- Configurations for fzf.vim

local rg_prefix = 'rg --column --line-number --no-heading --color=always --smart-case'

-- Override fzf default options set in shell
-- The cursor shape in nvim builtin terminal is block instead of beam, so we
-- need an extra space before the info separator for a better looking.
vim.env.FZF_DEFAULT_OPTS = vim.env.FZF_DEFAULT_OPTS .. " --info 'inline: <'"

vim.g.fzf_layout = {
  window = {
    width = 1,
    height = 0.6,
    yoffset = 1.0,
    border = 'top',
  },
}

vim.g.fzf_preview_window = {
  'right,border-left',
  'ctrl-/',
}

vim.g.fzf_action = {
  ['ctrl-x'] = 'split',
  ['ctrl-v'] = 'vsplit',
  ['ctrl-t'] = 'tab drop',
  ['enter'] = 'drop',
}

vim.keymap.set('n', '<Leader>fb', '<Cmd>Buffers<CR>')
vim.keymap.set('n', '<C-p>', '<Cmd>GFiles<CR>')
vim.keymap.set('n', '<Leader>ff', '<Cmd>Files<CR>')
vim.keymap.set('n', '<Leader>fo', '<Cmd>History<CR>')
vim.keymap.set('n', '<Leader>f/', '<Cmd>History/<CR>')
vim.keymap.set('n', '<Leader>f;', '<Cmd>History:<CR>')
vim.keymap.set('n', '<Leader>fc', '<Cmd>BCommits<CR>')

-- Delete the selected buffers
-- Ref: https://github.com/junegunn/fzf.vim/pull/733#issuecomment-559720813
vim.keymap.set('n', '<Leader>bD', function()
  -- :ls returns a multiple lines string containing infos of all buffers (each
  -- line is one buffer)
  local bufs = vim.fn.execute('ls')
  local buflist = {}
  -- Get a list of buffers: split the string by \n.
  -- Each buffer info is like ` 7 h "path/to/the/buffer" line 10`. It has 5
  -- parts: bufnr, indicator, buffer path, literal word line and the line number
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
    options = {
      '--multi',
      '--reverse',
      '--prompt',
      'DelBufs> ',
      '--header',
      'Press ENTER to delete all the selected buffers',
      -- Set SCROLL in the preview window, {5} is the line numbrer
      '--preview-window',
      '+{5}-/2',
    },
    -- fzf#vim`with_preview accepts a placeholder field and the format is
    -- FILENAME[:LINENO]. The placeholder will be passed into the preview script
    -- (fzf.vim/bin/preview.sh) where command bat is used as the preview
    -- command. FILENAME is the FILE for bat, and LINENO is for --highlight-line
    -- in bat.
    -- In each buffer info, the 3rd part is the buffer path that will be the
    -- FILENAME for bat and the 5th part is the line number that is for bat's
    -- --highlight-line option
    placeholder = '{3}:{5}',
  })))
end)

-- List all the quickfix lists and switch to the selected one
vim.keymap.set('n', '<Leader>fQ', function()
  -- :chistory outputs a multiple line string containing all the quickfix lists
  -- (each line is one qf list)
  local qfs = vim.fn.execute('chistory')
  local qflist = {}
  local i = 1
  -- Get a list of quickfix lists: split the string by \n.
  -- We prepend sequence number in order to switch to the specific qf list via
  -- :[count]chistory
  for qf in string.gmatch(qfs, '([^\n]+)\n?') do
    table.insert(qflist, '[' .. i .. '] ' .. qf)
    i = i + 1
  end
  vim.fn['fzf#run'](vim.fn['fzf#wrap'](vim.fn['fzf#vim#with_preview']({
    source = qflist,
    ['sink*'] = function(lines)
      local count = string.match(lines[1], '[(%d+)]')
      vim.cmd('silent! ' .. count .. 'chistory')
    end,
    options = {
      '--no-multi',
      '--reverse',
      '--prompt',
      'QuickfixListHist> ',
      '--header',
      'Press Enter to switch to the selected quickfix list',
      '--preview-window',
      'hidden,<9999(hidden)',
      '--bind',
      'start:unbind(ctrl-/)+unbind(ctrl-_)',
    },
  })))
end)

-- List all the location lists and switch to the selected one
vim.keymap.set('n', '<Leader>fL', function()
  -- :lhistory outputs a multiple line string containing all the location lists
  -- (each line is one list)
  local lls = vim.fn.execute('lhistory')
  local list = {}
  local i = 1
  -- Get a list of location lists: split the string by \n.
  -- We prepend sequence number in order to switch to the specific location list
  -- via :[count]lhistory
  for l in string.gmatch(lls, '([^\n]+)\n?') do
    table.insert(list, '[' .. i .. '] ' .. l)
    i = i + 1
  end
  vim.fn['fzf#run'](vim.fn['fzf#wrap'](vim.fn['fzf#vim#with_preview']({
    source = list,
    ['sink*'] = function(lines)
      local count = string.match(lines[1], '[(%d+)]')
      vim.cmd('silent! ' .. count .. 'lhistory')
    end,
    options = {
      '--no-multi',
      '--reverse',
      '--prompt',
      'LocationListHist> ',
      '--header',
      'Press Enter to switch to the selected location list',
      '--preview-window',
      'hidden,<9999(hidden)',
      '--bind',
      'start:unbind(ctrl-/)+unbind(ctrl-_)',
    },
  })))
end)

-- Find files (:Files) for my dotfiles
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

-- Find files under home
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

-- Path completion in normal mode
vim.keymap.set('i', '<C-x><C-f>', function()
  vim.fn['fzf#vim#complete#path']('fd')
end)

-- Config grep to be the same as my shell script frg (~/.config/fzf/fzfutils/frg).
-- It could run rg with its normal options and has two modes:
-- * RG mode (fzf will be just an interactive interface for RG) and
-- * FZF mode (fzf will be the fuzzy finder for the results of RG)

---Generate the fzf options for rg and fzf integration
---@param rg string The final rg command
---@param query string The initial query for rg
---@param name string The name of that keymap
---@return table
local function get_fzf_opts_for_RG(rg, query, name)
  name = name or ''
  return {
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
    'CTRL-R (RG mode), CTRL-F (FZF mode)',
    '--preview-window',
    '+{2}-/2',
  }
end

-- Define a new command :RGU (U for Ultimate) that supports rg options and the
-- two modes mentioned above
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
    vim.fn['fzf#vim#with_preview']({
      options = get_fzf_opts_for_RG(rg, query, 'RGU'),
    })
  )
end, { bang = true, nargs = '*' })
vim.keymap.set('n', '<Leader>gg', ':RGU ')

-- Live grep (:RG) for the nvim config
vim.keymap.set('n', '<Leader>gv', function()
  os.execute('rm -f /tmp/rg-fzf-vim-{r,f}')
  local rg = rg_prefix .. ' --glob=!minpac -- '
  local query = ''
  vim.fn['fzf#vim#grep2'](
    rg,
    query,
    vim.fn['fzf#vim#with_preview']({
      dir = '~/.config/nvim',
      options = get_fzf_opts_for_RG(rg, query, 'NvimConfig'),
    })
  )
end)

-- Grep (:Rg) for the current word (normal mode) or the current selection (visual mode)
vim.keymap.set({ 'n', 'x' }, '<Leader>gw', function()
  local query
  if vim.fn.mode() == 'v' then
    local saved_reg = vim.fn.getreg('v')
    vim.cmd([[noautocmd sil norm "vy]])
    query = vim.fn.getreg('v')
    vim.fn.setreg('v', saved_reg)
  else
    query = vim.fn.expand('<cword>')
  end
  query = vim.fn.escape(query, '.*+?()[]{}\\|^$')
  local rg = rg_prefix .. ' -- ' .. vim.fn['fzf#shellescape'](query)
  vim.fn['fzf#vim#grep'](
    rg,
    vim.fn['fzf#vim#with_preview']({
      options = {
        '--prompt',
        'Word> ',
      },
    })
  )
end)
