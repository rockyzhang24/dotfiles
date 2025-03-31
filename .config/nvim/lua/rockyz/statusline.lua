-- Ref:
-- MariaSolOs/dotfiles
-- echasnovski/mini.statusline
-- nvim-lualine/lualine.nvim

local icons = require('rockyz.icons')
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

function M.mode()
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
    return string.format('%%#StlMode%s#[%s]%%*', hl, mode)
end

function M.git_branch(trunc_width)
    local head = vim.b.gitsigns_head
    if not head then
        return ''
    end
    -- Don't show icon when truncated
    if is_truncated(trunc_width) then
        return head
    end
    return string.format('%%#StlIcon#%s%%* %s', icons.git.branch, head)
end

function M.git_diff(trunc_width)
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
            local format_str = '%%#StlGit' .. type .. '#%s%s%%*'
            table.insert(result, string.format(format_str, icons.minimal.git[type], git_diff[type]))
        end
    end
    if #result > 0 then
        return '[' .. table.concat(result, ' ') .. ']'
    else
        return ''
    end
end

-- LSP clients in the current buffer
function M.lsp_clients(trunc_width)
    if is_truncated(trunc_width) then
        return ''
    end
    local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
    if next(clients) == nil then
        return '%#StlComponentInactive#[LS Inactive]%*'
    end
    local client_names = {}
    for _, client in ipairs(clients) do
        if client and client.name ~= '' then
            table.insert(client_names, string.format('%%#StlComponentOn#%s%%*', client.name))
        end
    end
    return string.format('[%s]', table.concat(client_names, ', '))
end

-- Cscope DB build status
function M.cscope(trunc_width)
    if is_truncated(trunc_width) then
        return ''
    end
    local indicator = vim.g.cscope_maps_statusline_indicator
    return indicator and indicator ~= '' and '[' .. indicator .. ']' or ''
end

-----------------
-- Middle section
-----------------

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

function M.filename()
    local ft = vim.bo.filetype
    if ft == 'fzf' then
        return ''
    end
    local name = vim.fn.expand('%:~:.')
    if name == '' then
        name = '[No Name]'
    end
    local size = get_filesize()
    if size ~= '' then
        size = '[' .. size .. ']'
    end
    local symbols = {}
    if vim.bo.modified then
        table.insert(symbols, '[+]')
    end
    if not vim.bo.modifiable or vim.bo.readonly then
        table.insert(symbols, '[-]')
    end
    return name .. size .. (#symbols > 0 and table.concat(symbols, '') or '')
end

----------------
-- Right section
----------------

-- Search count
function M.search()
    if vim.v.hlsearch == 0 then
        return ''
    end
    local ok, s_count = pcall(vim.fn.searchcount, { recompute = true })
    if not ok or s_count.current == nil or s_count.total == 0 then
        return ''
    end
    if s_count.incomplete == 1 then
        return string.format('%%#StlIcon#%s [?/?]%%*', icons.misc.search)
    end
    local too_many = string.format('>%d', s_count.maxcount)
    local current = s_count.current > s_count.maxcount and too_many or s_count.current
    local total = s_count.total > s_count.maxcount and too_many or s_count.total
    return string.format('%%#StlIcon#%s [%s/%s]%%*', icons.misc.search, current, total)
end

-- Autoformat (format-on-save) on/off indicator
function M.autoformat(trunc_width)
    if is_truncated(trunc_width) or (not vim.g.autoformat and not vim.b.autoformat) then
        return ''
    end
    -- Type of the autoformat: G for global and B for buffer-local
    local type = vim.g.autoformat and '[G]' or (vim.b.autoformat and '[B]' or '')
    return type ~= '' and string.format('%%#StlComponentOn#%s%%* %s', icons.misc.format, type) or ''
end

-- Diagnostics
local diagnostic_levels = { 'ERROR', 'WARN', 'INFO', 'HINT' }
function M.diagnostic()
    local counts = vim.diagnostic.count(0)
    local res = {}
    for _, level in ipairs(diagnostic_levels) do
        local n = counts[vim.diagnostic.severity[level]] or 0
        if n > 0 then
            local icon = icons.diagnostics[level]
            if vim.diagnostic.is_enabled() then
                table.insert(res, string.format('%%#StlDiagnostic%s#%s %s%%*', level, icon, n))
            else
                -- Use gray color if diagnostic is disabled
                table.insert(res, string.format('%%#StlComponentInactive#%s %s%%*', icon, n))
            end
        end
    end
    return table.concat(res, ' ')
end

function M.spell(trunc_width)
    if is_truncated(trunc_width) then
        return ''
    end
    return vim.o.spell and string.format('%%#StlComponentOn#%s%%*', icons.misc.check) or ''
end

-- Treesitter status
-- Use different colors to denote whether it has a parser for the
-- current file and whether the highlight is enabled:
-- * gray  : no parser
-- * green : has parser and highlight is enabled
-- * red   : has parser but highlight is disabled
function M.treesitter()
    local buf = vim.api.nvim_get_current_buf()
    local hl_enabled = vim.treesitter.highlighter.active[buf]
    local has_parser = require('nvim-treesitter.parsers').has_parser()
    return not has_parser and '[%#StlComponentInactive#TS%*]'
        or string.format('[%%#%s#TS%%*]', hl_enabled and 'StlComponentOn' or 'StlComponentOff')
end

-- Indent type (tab or space) and number of spaces
function M.indent(trunc_width)
    if is_truncated(trunc_width) then
        return ''
    end
    local get_local_option = function(option_name)
        return vim.api.nvim_get_option_value(option_name, { scope = 'local' })
    end
    local expandtab = get_local_option('expandtab')
    local spaces_cnt = expandtab and get_local_option('shiftwidth') or get_local_option('tabstop')
    local res = (expandtab and 'S:' or 'T:') .. spaces_cnt
    return '[' .. res .. ']'
end

function M.encoding(trunc_width)
    if is_truncated(trunc_width) then
        return ''
    end
    local encoding = vim.bo.fileencoding:upper()
    if encoding == '' then
        return ''
    end
    if vim.bo.bomb then
        encoding = encoding .. ' BOM'
    end
    return '[' .. encoding .. ']'
end

-- Filetype
function M.filetype()
    local filetype = vim.bo.filetype
    -- No file
    if filetype == '' then
        return string.format('%%#StlComponentInactive#%s [No File]%%*', icons.misc.file)
    end
    -- Handle special filetype
    local sp_ft = special_filetypes[filetype]
    if sp_ft then
        local icon = sp_ft.icon
        return string.format('%%#StlIcon#%s %%#StlFiletype#%s%%*', icon, filetype)
    end
    -- Normal filetype
    local has_devicons, devicons = pcall(require, 'nvim-web-devicons')
    if has_devicons then
        local icon, icon_color = devicons.get_icon_color_by_filetype(filetype, { default = true })
        local icon_hl = 'StlIcon-' .. filetype
        if not cached_hls[icon_hl] then
            local bg_color = vim.api.nvim_get_hl(0, { name = 'StatusLine' }).bg
            vim.api.nvim_set_hl(0, icon_hl, { fg = icon_color, bg = bg_color })
            cached_hls[icon_hl] = true
        end
        return string.format('%%#%s#%s %%#StlFiletype#%s%%*', icon_hl, icon, filetype)
    end
    return string.format('%s %%#StlFiletype#%s%%*', icons.misc.file, filetype)
end

function M.location()
    local res = '%3l/%-3L:%-2v [%3p%%]'
    return string.format('%%#StlLocComponent# %s%%*', res)
end

function M.render()

    ---Concatenate the non-empty items in the list
    ---@param components table
    ---@param sep string The separator
    ---@return string
    local function concat_components(components, sep)
        return vim.iter(components):fold('', function(acc, component)
            if #acc == 0 then
                return component
            end
            if #component == 0 then
                return acc
            end
            return (component == '%<' or component == '%=') and acc .. component
                or acc .. sep .. component
        end)
    end

    return concat_components({
        M.mode(),
        '%<',
        concat_components({
            M.git_branch(120),
            M.git_diff(120),
        }, ''),
        M.lsp_clients(120),
        M.cscope(120),
        '%=',
        M.filename(),
        '%=',
        M.search(),
        M.diagnostic(),
        M.autoformat(120),
        M.spell(120),
        concat_components({
            M.treesitter(),
            M.indent(120),
            M.encoding(120),
        }, ''),
        M.filetype(),
        M.location(),
    }, ' ')
end

-- Refresh
local group = vim.api.nvim_create_augroup('rockyz.statusline.redraw', {})
-- After gitsigns update
vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'GitSignsUpdate',
    callback = function()
        vim.cmd.redrawstatus()
    end,
})

vim.o.statusline = "%!v:lua.require('rockyz.statusline').render()"

return M
