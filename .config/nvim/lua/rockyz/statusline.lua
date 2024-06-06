-- For aesthetic and stylistic consistency, add a space before each component in left section, and
-- after each component in the right section.
--
-- Ref:
-- MariaSolOs/dotfiles
-- echasnovski/mini.statusline
-- nvim-lualine/lualine.nvim

local icons = require('rockyz.icons')
local powerline_left = ' ' .. icons.separators.chevron_right
local powerline_right = icons.separators.chevron_left .. ' '
local special_filetypes = require('rockyz.special_filetypes')

local M = {}

-- Cache the highlight groups created for icons of different filetype
local cached_hls = {}

-- Decide whether to truncate
local function is_truncated(trunc_width)
  -- Use -1 to default to 'not truncated'
  return vim.o.columns < (trunc_width or -1)
end

---------------
-- Left section
---------------

function M.mode_component()
  -- See :h mode()
  -- Note that: \19 = ^S and \22 = ^V.
  local mode_to_str = {
    ['n'] = 'NORMAL',
    ['no'] = 'OP-PENDING',
    ['nov'] = 'OP-PENDING',
    ['noV'] = 'OP-PENDING',
    ['no\22'] = 'OP-PENDING',
    ['niI'] = 'NORMAL',
    ['niR'] = 'NORMAL',
    ['niV'] = 'NORMAL',
    ['nt'] = 'NORMAL',
    ['ntT'] = 'NORMAL',
    ['v'] = 'VISUAL',
    ['vs'] = 'VISUAL',
    ['V'] = 'V-LINE',
    ['Vs'] = 'VISUAL',
    ['\22'] = 'V-BLOCK',
    ['\22s'] = 'V-BLOCK',
    ['s'] = 'SELECT',
    ['S'] = 'S-LINE',
    ['\19'] = 'S-BLOCK',
    ['i'] = 'INSERT',
    ['ic'] = 'INSERT',
    ['ix'] = 'INSERT',
    ['R'] = 'REPLACE',
    ['Rc'] = 'REPLACE',
    ['Rx'] = 'REPLACE',
    ['Rv'] = 'VIRT REPLACE',
    ['Rvc'] = 'VIRT REPLACE',
    ['Rvx'] = 'VIRT REPLACE',
    ['c'] = 'COMMAND',
    ['cv'] = 'VIM EX',
    ['ce'] = 'EX',
    ['r'] = 'PROMPT',
    ['rm'] = 'MORE',
    ['r?'] = 'CONFIRM',
    ['!'] = 'SHELL',
    ['t'] = 'TERMINAL',
  }
  local mode = mode_to_str[vim.api.nvim_get_mode().mode] or 'UNKNOWN'
  -- Set the highlight group
  local hl = 'Normal'
  if mode:find('INSERT') or mode:find('SELECT') then
    hl = 'Insert'
  elseif mode:find('VISUAL') or mode:find('V-LINE') or mode:find('V-BLOCK') then
    hl = 'Visual'
  elseif mode:find('REPLACE') then
    hl = 'Replace'
  elseif mode:find('COMMAND') then
    hl = 'Command'
  elseif mode:find('TERMINAL') then
    hl = 'Terminal'
  elseif mode:find('PENDING') then
    hl = 'Pending'
  end
  return table.concat({
    string.format('%%#StlMode%s# %s ', hl, mode),
    string.format('%%#StlModeSep%s#%s%%*', hl, icons.separators.triangle_right),
  })
end

function M.git_branch_component(trunc_width)
  local head = vim.b.gitsigns_head
  if not head then
    return ''
  end
  -- Don't show icon when truncated
  if is_truncated(trunc_width) then
    return ' ' .. head
  end
  return string.format(' %%#StlIcon#%s%%*%s', icons.git.branch, head)
end

function M.git_diff_component(trunc_width)
  local status = vim.b.gitsigns_status_dict
  if not status or is_truncated(trunc_width) then
    return ''
  end
  local git_diff = {
    added = status.added,
    deleted = status.removed,
    modified = status.changed,
  }
  local result = {}
  for _, type in ipairs({ 'added', 'deleted', 'modified' }) do
    if git_diff[type] and git_diff[type] > 0 then
      local format_str = ' %%#StlGit' .. type .. '#%s%s%%*'
      table.insert(result, string.format(format_str, icons.git[type], git_diff[type]))
    end
  end
  if #result > 0 then
    return table.concat(result)
  else
    return ''
  end
end

-- LSP clients of all buffers
-- Mark (e.g., using green color) the clients attaching to the current buffer
function M.lsp_component(trunc_width)
  if is_truncated(trunc_width) then
    return ''
  end
  local clients = vim.lsp.get_clients()
  local client_names = {}
  for _, client in ipairs(clients) do
    if client and client.name ~= '' then
      local attached_buffers = client.attached_buffers
      if attached_buffers[vim.api.nvim_get_current_buf()] then
        table.insert(client_names, string.format('%%#StlComponentOn#%s%%*', client.name))
      else
        table.insert(client_names, client.name)
      end
    end
  end
  if next(client_names) == nil then
    return ' %#StlComponentInactive#[LS Inactive]%*'
  end
  return string.format(' [%s]', table.concat(client_names, ', '))
end

----------------
-- Right section
----------------

-- Search count
function M.search_component()
  if vim.v.hlsearch == 0 then
    return ''
  end
  local ok, s_count = pcall(vim.fn.searchcount, { recompute = true })
  if not ok or s_count.current == nil or s_count.total == 0 then
    return ''
  end
  if s_count.incomplete == 1 then
    return string.format('%%#StlSearchCnt#%s%s%%* ', icons.misc.search, '[?/?]')
  end
  local too_many = string.format('>%d', s_count.maxcount)
  local current = s_count.current > s_count.maxcount and too_many or s_count.current
  local total = s_count.total > s_count.maxcount and too_many or s_count.total
  return string.format('%%#StlSearchCnt#%s[%s/%s]%%* ', icons.misc.search, current, total)
end

-- Diagnostics
local diagnostic_levels = {
  { name = 'ERROR', icon = icons.diagnostics.ERROR, },
  { name = 'WARN', icon = icons.diagnostics.WARN, },
  { name = 'INFO', icon = icons.diagnostics.INFO, },
  { name = 'HINT', icon = icons.diagnostics.HINT, },
}
function M.diagnostic_component()
  local counts = vim.diagnostic.count(0)
  local res = {}
  for _, level in ipairs(diagnostic_levels) do
    local n = counts[vim.diagnostic.severity[level.name]] or 0
    if n > 0 then
      if vim.diagnostic.is_enabled() then
        table.insert(res, string.format('%%#StlDiagnostic%s#%s%s%%* ', level.name, level.icon, n))
      else
        -- Use gray color if diagnostic is disabled
        table.insert(res, string.format('%%#StlComponentInactive#%s%s%%* ', level.icon, n))
      end
    end
  end
  return table.concat(res, '')
end

function M.spell_component(trunc_width)
  if is_truncated(trunc_width) then
    return ''
  end
  if vim.o.spell then
    return string.format('%%#StlComponentOn#%s%%* ', icons.misc.check)
  end
  return ''
end

-- Treesitter status
-- Use different colors to denote whether it has a parser for the
-- current file and whether the highlight is enabled:
-- * gray  : no parser
-- * green : has parser and highlight is enabled
-- * red   : has parser but highlight is disabled
function M.treesitter_component()
  local res = icons.misc.tree
  local buf = vim.api.nvim_get_current_buf()
  local hl_enabled = vim.treesitter.highlighter.active[buf]
  local has_parser = require('nvim-treesitter.parsers').has_parser()
  if not has_parser then
    return string.format('%%#StlComponentInactive#%s%%* ', res)
  end
  local format_str = hl_enabled and '%%#StlComponentOn#%s%%* ' or '%%#StlComponentOff#%s%%* '
  return string.format(format_str, res)
end

-- Indent type (tab or space) and number of spaces
function M.indent_component(trunc_width)
  if is_truncated(trunc_width) then
    return ''
  end
  local get_local_option = function(option_name)
    return vim.api.nvim_get_option_value(option_name, { scope = 'local' })
  end
  local expandtab = get_local_option('expandtab')
  local spaces_cnt = expandtab and get_local_option('shiftwidth') or get_local_option('tabstop')
  local res = (expandtab and 'SP:' or 'TAB:') .. spaces_cnt
  return string.format('%%#StlIcon#%s%%*%s ', icons.misc.indent, res)
end

function M.encoding_component(trunc_width)
  if is_truncated(trunc_width) then
    return ''
  end
  local encoding = vim.bo.fileencoding
  return encoding ~= '' and encoding .. ' ' or ''
end

local function get_filesize()
  local file = vim.api.nvim_buf_get_name(0)
  if file == nil or #file == 0 then
    return ''
  end
  local size = vim.fn.getfsize(file)
  if size <= 0 then
    return ''
  end
  local suffixes = { 'b', 'k', 'm', 'g' }
  local i = 1
  while size > 1024 and i < #suffixes do
    size = size / 1024
    i = i + 1
  end
  local format = i == 1 and '%d%s' or '%.1f%s'
  return string.format(format, size, suffixes[i])
end

-- Icon, filetype and filesize
function M.fileinfo_component(trunc_width)
  local filetype = vim.bo.filetype
  local size = ''
  -- Only display size when not truncated
  if not is_truncated(trunc_width) then
    size = get_filesize()
    if size ~= '' then
      size = string.format(' [%s]', size)
    end
  end
  if filetype == '' then
    return string.format('%%#StlComponentInactive#%s%s%%*%s ', icons.misc.file, '[No File]', size)
  end
  local sp_ft = special_filetypes[filetype]
  if sp_ft then
    local icon = sp_ft.icon
    return string.format('%%#StlIcon#%s %%#StlFiletype#%s%%*%s ', icon, filetype, size)
  end
  local has_devicons, devicons = pcall(require, 'nvim-web-devicons')
  if has_devicons then
    local icon, icon_color = devicons.get_icon_color_by_filetype(filetype, { default = true })
    local icon_hl = 'StlIcon-' .. filetype
    if not cached_hls[icon_hl] then
      local bg_color = vim.api.nvim_get_hl(0, { name = 'StatusLine' }).bg
      vim.api.nvim_set_hl(0, icon_hl, { fg = icon_color, bg = bg_color })
      cached_hls[icon_hl] = true
    end
    return string.format('%%#%s#%s %%#StlFiletype#%s%%*%s ', icon_hl, icon, filetype, size)
  end
  return string.format('%s%%#StlFiletype#%s%%*%s ', icons.misc.file, filetype, size)
end

function M.location_component()
  local res = '%3l/%-3L:%-2v [%3p%%]'
  return table.concat({
    string.format('%%#StlLocComponentSep#%s', icons.separators.triangle_left),
    string.format('%%#StlLocComponent# %s%%*', res)
  })
end

function M.render()

  local function concat_components(components, sep)
    return vim.iter(components):fold('', function(acc, component)
      if #component > 0 then
        return #acc == 0 and component or string.format('%s%s%s', acc, sep, component)
      end
      return acc
    end)
  end

  return table.concat({
    M.mode_component(),
    concat_components({
      M.git_branch_component(120),
      M.git_diff_component(120),
      M.lsp_component(120),
    }, powerline_left),
    '%=',
    concat_components({
      M.search_component(),
      M.diagnostic_component(),
      M.spell_component(120),
      M.treesitter_component(),
      M.indent_component(120),
      M.encoding_component(120),
      M.fileinfo_component(120),
    }, powerline_right),
    M.location_component(),
  })
end

-- Refresh statusline right after gitsigns update
vim.api.nvim_create_autocmd('User', {
  group = vim.api.nvim_create_augroup('statusline_redraw', { clear = true }),
  pattern = 'GitSignsUpdate',
  callback = function()
    vim.cmd.redrawstatus()
  end,
})

vim.o.statusline = "%!v:lua.require('rockyz.statusline').render()"

return M
