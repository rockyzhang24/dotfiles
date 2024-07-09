local M = {}

local navic = require('nvim-navic')
local icons  = require('rockyz.icons')
local delimiter = icons.misc.delimiter

-- Cache the highlight groups created for different icons
local cached_hls = {}

local function header_component()
  local items = {}
  -- Window number: used for window switching
  local winnr = string.format('[%s]', vim.api.nvim_win_get_number(0))
  table.insert(items, winnr)
  -- "Maximized" indicator
  if vim.w.maximized == 1 then
    table.insert(items, icons.misc.maximized)
  end

  local header = string.format(
    '%%#WinbarHeader# %s %%#WinbarTriangleSep#%s%%*',
    table.concat(items, ' '),
    icons.separators.triangle_right
  )
  return header
end

local function special_buffer_component()
  local ft = vim.bo.filetype
  local winid = vim.api.nvim_get_current_win()
  local path = vim.fn.expand('%')

  if ft == 'aerial' or ft == 'Outline' then
    return 'Outline'
  elseif ft == 'fugitive' then
    local git_path = string.match(path, 'fugitive://(.*)//')
    git_path = vim.fn.fnamemodify(git_path, ':~:.')
    return string.format('Fugitive [%s]', git_path)
  elseif ft == 'fugitiveblame' then
    return 'Fugitive Blame'
  elseif ft == 'git' then
    if string.find(path, '^fugitive://') then
      local git_path = string.match(path, 'fugitive://(.*)')
      git_path = vim.fn.fnamemodify(git_path, ':~:.')
      return string.format('Fugitive [%s]', git_path)
    end
    return path
  elseif ft == 'oil' then
    return 'Oil: ' .. string.match(path, 'oil://(.*)')
  elseif ft == 'qf' then
    local is_loclist = vim.fn.getloclist(0, { filewinid = 0 }).filewinid ~= 0
    local list_type = is_loclist and 'Location List' or 'Quickfix List'
    local what = { title = 0, size = 0, idx = 0 }
    local list = is_loclist and vim.fn.getloclist(0, what) or vim.fn.getqflist(what)
    -- The output format is {list type} > {list title} > {current idx}
    -- E.g., "Quickfix List > Diagnostics > [1/10]"
    local items = {}
    table.insert(items, list_type)
    if list.title ~= '' then
      table.insert(items, list.title)
    end
    table.insert(items, string.format('[%s/%s]', list.idx, list.size))
    return table.concat(items, ' ' .. delimiter .. ' ')
  elseif ft == 'tagbar' then
    return 'Tagbar'
  elseif ft == 'term' then
    return path
  elseif vim.fn.win_gettype(winid) == 'command' then
    return 'Command-line Window'
  end

  return ''
end

local function path_component()
  local items = {}
  local fullpath = vim.fn.expand('%')
  local path
  -- Handle specials
  if string.find(fullpath, '^fugitive://') then
    -- The window of fugitive diff is a regular buffer but with 'diff' set. Its bufname is like
    -- "fugitive:///Users/xxx/demo/.git//92eb3dd/src/core.go".
    local git_path, file_path = string.match(fullpath, '^fugitive://(%S+//%w+)/(.*)')
    git_path = vim.fn.fnamemodify(git_path, ':~:.')
    path = vim.fn.fnamemodify(file_path, ':~:.:h')
    table.insert(items, string.format('Fugitive [%s]', git_path))
  elseif string.find(fullpath, '^gitsigns://') then
    -- For the window running gitsigns.diffthis, its bufname is like
    -- "gitsigns:///Users/xxx/demo/.git/HEAD~2:src/core.go", or
    -- "gitsigns:///Users/xxx/demo/.git/:0:src/core.go".
    local git_path, file_path = string.match(fullpath, '^gitsigns://([^:]*:?%w+):(.*)')
    git_path = vim.fn.fnamemodify(git_path, ':~:.')
    path = vim.fn.fnamemodify(file_path, ':~:.:h')
    table.insert(items, string.format('Gitsigns [%s]', git_path))
  else
    path = vim.fn.expand('%:~:.:h')
  end
  -- Normal path
  if path ~= '' and path ~= '.' then
    if vim.api.nvim_win_get_width(0) < math.floor(vim.o.columns / 3) then
      path = vim.fn.pathshorten(path)
    else
      path = path:gsub('^~', 'HOME'):gsub('^/', 'ROOT/'):gsub('/', ' ' .. delimiter .. ' ')
    end
    table.insert(items, path)
  end
  return table.concat(items, ' ')
end

local function icon_component()
  local has_devicons, devicons = pcall(require, 'nvim-web-devicons')
  if has_devicons then
    local ft = vim.bo.filetype
    local icon, icon_color = devicons.get_icon_color_by_filetype(ft, { default = true })
    local icon_hl = 'WinbarFileIconFor' .. ft
    if not cached_hls[icon_hl] then
      local bg_color = vim.api.nvim_get_hl(0, { name = 'Winbar' }).bg
      vim.api.nvim_set_hl(0, icon_hl, { fg = icon_color, bg = bg_color })
      cached_hls[icon_hl] = true
    end
    return string.format('%%#%s#%s%%*', icon_hl, icon)
  end
  return icons.misc.file
end

local function filename_component()
  local filename = vim.fn.expand('%:t')
  if filename == '' then
    filename = '[No Name]'
  end
  return filename
end

M.render = function()
  local items = {}

  -- Header
  -- It is the first part of the winbar with powerline style
  local header = header_component()
  table.insert(items, header)

  -- Special buffer
  local special_ft = special_buffer_component()
  if special_ft ~= '' then
    table.insert(items, special_ft)
    return table.concat(items, ' ')
  end

  -- Path
  local path = path_component()
  if path ~= '' then
    table.insert(items, path)
    table.insert(items, delimiter)
  end

  -- File icon
  local icon = icon_component()
  table.insert(items, icon)

  local diag_cnt = vim.diagnostic.count(0)
  local error_cnt = diag_cnt[vim.diagnostic.severity.ERROR] or 0
  local warn_cnt = diag_cnt[vim.diagnostic.severity.WARN] or 0
  local hl = error_cnt > 0 and 'WinbarError' or (warn_cnt > 0 and 'WinbarWarn' or 'Winbar')

  -- Filename
  local filename = filename_component()
  table.insert(items, string.format('%%#%s#%s%%*', hl, filename))

  -- Diagnostic count
  local diag_total = error_cnt + warn_cnt
  if diag_total ~= 0 then
    table.insert(items, string.format('%%#%s#(%s)%%*', hl, diag_total))
  end

  -- "Modified" indicator
  local bufnr = vim.api.nvim_get_current_buf()
  local mod = vim.fn.getbufvar(bufnr, '&mod')
  if mod ~= 0 then
    local hl_mod = diag_total == 0 and 'WinbarModified' or hl
    table.insert(items, string.format('%%#%s#%s%%*', hl_mod, icons.misc.circle_filled))
  end

  -- Truncate if too long
  items[#items] = items[#items] .. '%<'

  -- Breadcrumbs
  if navic.is_available() then
    local context = navic.get_location()
    local breadcrumbs = delimiter .. ' ' .. (context == '' and icons.misc.ellipsis or context)
    table.insert(items, breadcrumbs)
  end

  return table.concat(items, ' ')
end

vim.o.winbar = "%{%v:lua.require('rockyz.winbar').render()%}"

return M
