-- Ref:
-- MariaSolOs/dotfiles
-- echasnovski/mini.statusline
-- nvim-lualine/lualine.nvim

local icons = require('rockyz.icons')
local special_filetypes = require('rockyz.special_filetypes')
local has_devicons, devicons = pcall(require, 'nvim-web-devicons')

local M = {}

---Cache statusline highlight groups created for filetype icons
---@type table<string, boolean>
local icon_highlight_cache = {}

---Hide less important statusline component when the screen is narrower than this
local truncation_width = 120

local diagnostic_levels = { 'ERROR', 'WARN', 'INFO', 'HINT' }

-- See :h mode()
-- Note that: \19 = ^S and \22 = ^V.
local mode_names = {
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

local mode_highlights = {
    NORMAL = 'Normal',

    INSERT = 'Insert',
    SELECT = 'Insert',
    ['S-LINE'] = 'Insert',
    ['S-BLOCK'] = 'Insert',

    VISUAL = 'Visual',
    ['V-LINE'] = 'Visual',
    ['V-BLOCK'] = 'Visual',

    REPLACE = 'Replace',
    ['VIRT REPLACE'] = 'Replace',

    COMMAND = 'Command',

    TERMINAL = 'Terminal',

    ['OP-PENDING'] = 'Pending',
}

---Return whether the screen is narrower than the given width threshold
---@param min_width? integer
---@return boolean
local function is_narrow(min_width)
    return min_width ~= nil and vim.o.columns < min_width
end

---Escape percent signs in dynamic statusline text
---@param text string
---@return string
local function escape_statusline(text)
    return text:gsub('%%', '%%%%')
end

---Return the current buffer file size formatted for the statusline
---@return string
local function format_file_size()
    local path = vim.api.nvim_buf_get_name(0)
    if path == '' then
        return ''
    end
    local size = vim.fn.getfsize(path)
    if size < 0 then
        return ''
    end
    local suffixes = { 'b', 'k', 'm', 'g' }
    local i = 1
    while size >= 1024 and i < #suffixes do
        size = size / 1024
        i = i + 1
    end
    local format = i == 1 and '%d%s' or '%.1f%s'
    return string.format(format, size, suffixes[i])
end

---Concatenate non-empty statusline components
---
---Special statusline items (`%<` and `%=`) are appended without separators
---
---@param components string[]
---@param separator string
---@return string
local function render_components(components, separator)
    return vim.iter(components):fold('', function(acc, component)
        if #acc == 0 then
            return component
        end
        if #component == 0 then
            return acc
        end
        return (component == '%<' or component == '%=') and acc .. component
        or acc .. separator .. component
    end)
end

--------------------------------------------------------------------------------
-- Left section
--------------------------------------------------------------------------------

---Render the current editor mode
---@return string
function M.mode()
    local mode_name = mode_names[vim.api.nvim_get_mode().mode] or 'UNKNOWN'
    local hl = mode_highlights[mode_name] or 'Normal'
    return string.format('%%#StlMode%s#[%s]%%*', hl, mode_name)
end

---Render the current Git branch
---@param min_width? integer
---@return string
function M.git_branch(min_width)
    local head = vim.b.gitsigns_head
    if not head then
        return ''
    end
    head = escape_statusline(head)
    -- Don't show icon when truncated
    if is_narrow(min_width) then
        return head
    end
    return string.format('%%#StlIcon#%s%%* %s', icons.git.branch, head)
end

---Return git diff statistics
---@param min_width? integer
---@return string
function M.git_diff(min_width)
    local git_status = vim.b.gitsigns_status_dict
    if not git_status or is_narrow(min_width) then
        return ''
    end

    local counts = {
        added = git_status.added,
        deleted = git_status.removed,
        modified = git_status.changed,
    }

    local items = {}

    for _, kind in ipairs({ 'added', 'deleted', 'modified' }) do
        if counts[kind] and counts[kind] > 0 then
            local format = '%%#StlGit' .. kind .. '#%s%s%%*'
            table.insert(items, string.format(format, icons.minimal.git[kind], counts[kind]))
        end
    end

    if #items > 0 then
        return '[' .. table.concat(items, ' ') .. ']'
    else
        return ''
    end
end

---Render active LSP clients attached to the current buffer
---@param min_width? integer
---@return string
function M.lsp_clients(min_width)
    if is_narrow(min_width) then
        return ''
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    if vim.tbl_isempty(clients) then
        return '%#StlComponentInactive#[LS Inactive]%*'
    end

    local names = {}

    for _, client in ipairs(clients) do
        if client and client.name ~= '' then
            table.insert(names, string.format('%%#StlComponentOn#%s%%*', escape_statusline(client.name)))
        end
    end

    return string.format('[%s]', table.concat(names, ', '))
end

---Record the cscope database build status
---@param min_width? integer
---@return string
function M.cscope(min_width)
    if is_narrow(min_width) then
        return ''
    end
    local indicator = vim.g.cscope_maps_statusline_indicator
    return indicator and indicator ~= '' and '[' .. indicator .. ']' or ''
end

--------------------------------------------------------------------------------
-- Middle section
--------------------------------------------------------------------------------

---Return the current buffer filename, file size, and state symbols
---@return string
function M.filename()
    local filetype = vim.bo.filetype
    if filetype == 'fzf' then
        return ''
    end

    local name = vim.fn.expand('%:~:.')
    if name == '' then
        name = '[No Name]'
    end

    name = escape_statusline(name)

    local size = format_file_size()
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

---Render the current argument list status
---@return string
function M.arglist()
    return '%-13a'
end

--------------------------------------------------------------------------------
-- Right section
--------------------------------------------------------------------------------

---Render the current search count
---@return string
function M.search()
    if vim.v.hlsearch == 0 then
        return ''
    end

    local ok, count = pcall(vim.fn.searchcount, { recompute = true })
    if not ok or count.current == nil or count.total == 0 then
        return ''
    end

    if count.incomplete == 1 then
        return string.format('%%#StlIcon#%s [?/?]%%*', icons.misc.search)
    end

    local current = count.current
    local total = count.total

    if count.incomplete == 2 then
        if current > count.maxcount then
            current = string.format('>%d', current)
        end
        if total > count.maxcount then
            total = string.format('>%d', total)
        end
    end

    return string.format('%%#StlIcon#%s [%s/%s]%%*', icons.misc.search, current, total)
end

---Render the format-on-save status
---@param min_width? integer
---@return string
function M.autoformat(min_width)
    if is_narrow(min_width) or (not vim.g.autoformat and not vim.b.autoformat) then
        return ''
    end
    -- Type of the autoformat: G for global and B for buffer-local
    local scope = vim.g.autoformat and '[G]' or '[B]'
    return string.format('%%#StlComponentOn#%s%%* %s', icons.misc.format, scope)
end

---Render diagnostic counts for the current buffer
---@return string
function M.diagnostics()
    local counts = vim.diagnostic.count(0)
    local diagnostic_enabled = vim.diagnostic.is_enabled({ bufnr = 0 })

    local items = {}

    for _, level in ipairs(diagnostic_levels) do
        local count = counts[vim.diagnostic.severity[level]] or 0
        if count > 0 then
            local icon = icons.diagnostics[level]
            if diagnostic_enabled then
                table.insert(items, string.format('%%#StlDiagnostic%s#%s %s%%*', level, icon, count))
            else
                -- Use gray color if diagnostic is disabled
                table.insert(items, string.format('%%#StlComponentInactive#%s %s%%*', icon, count))
            end
        end
    end
    return table.concat(items, ' ')
end

---Render the spell checking status
---@param min_width? integer
---@return string
function M.spell(min_width)
    if is_narrow(min_width) then
        return ''
    end
    return vim.wo.spell and string.format('%%#StlComponentOn#%s%%*', icons.misc.check) or ''
end

---Render the tpope/vim-obsession session status
---@return string
function M.obsession()
    local fmt = '[%%#%s#%s%%*]'
    return vim.fn.ObsessionStatus(string.format(fmt, 'StlComponentOn', '$'), string.format(fmt, 'StlComponentOff', 'S'))
end

---Render the treesitter parser and highlight status
---
---Use different colors to denote whether it has a parser for the
---current file and whether the highlight is enabled:
---  * gray  : no parser
---  * green : has parser and highlight is enabled
---  * red   : has parser but highlight is disabled
---@return string
function M.treesitter()
    local bufnr = vim.api.nvim_get_current_buf()
    local highlight_enabled = vim.treesitter.highlighter.active[bufnr]
    local has_parser = pcall(vim.treesitter.get_parser, bufnr)

    if not has_parser then
        return '[%#StlComponentInactive#TS%*]'
    end

    local hl = highlight_enabled and 'StlComponentOn' or 'StlComponentOff'
    return string.format('[%%#%s#TS%%*]', hl)
end

---Render the indentation style and width
---@param min_width? integer
---@return string
function M.indent(min_width)
    if is_narrow(min_width) then
        return ''
    end

    local expandtab = vim.bo.expandtab
    local shiftwidth = vim.bo.shiftwidth > 0 and vim.bo.shiftwidth or vim.bo.tabstop
    local tabstop = vim.bo.tabstop

    local width = expandtab and shiftwidth or tabstop
    return string.format('[%s:%s]', expandtab and 'S' or 'T', width)
end

---Render the current buffer file encoding
---@param min_width? integer
---@return string
function M.encoding(min_width)
    if is_narrow(min_width) then
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

---Render the current buffer filetype
---@return string
function M.filetype()
    local filetype = vim.bo.filetype
    if filetype == '' then
        return string.format('%%#StlComponentInactive#%s [Empty]%%*', icons.misc.file)
    end

    local escaped_filetype = escape_statusline(filetype)

    -- Special filetype

    ---@type rockyz.SpecialFiletype
    local special = special_filetypes[filetype]
    if special then
        local icon = special.icon
        local icon_hl = special.icon_hl or 'StlIcon'
        return string.format('%%#%s#%s %%#StlFiletype#%s%%*', icon_hl, icon, escaped_filetype)
    end

    -- Normal filetype

    if not has_devicons then
        return string.format('%s %%#StlFiletype#%s%%*', icons.misc.file, escaped_filetype)
    end

    local icon, icon_color = devicons.get_icon_color_by_filetype(filetype, { default = true })
    local icon_hl = 'StlIcon-' .. filetype

    if not icon_highlight_cache[icon_hl] then
        local bg_color = vim.api.nvim_get_hl(0, { name = 'StatusLine' }).bg
        vim.api.nvim_set_hl(0, icon_hl, { fg = icon_color, bg = bg_color })
        icon_highlight_cache[icon_hl] = true
    end

    return string.format('%%#%s#%s %%#StlFiletype#%s%%*', icon_hl, icon, escaped_filetype)
end

---Render the cursor location
---@return string
function M.location()
    local res = '%3l/%-3L:%-2v [%3p%%]'
    return string.format('%%#StlLocComponent# %s%%*', res)
end

---Render the full statusline
---@return string
function M.render()
    local left = {
        M.mode(),
        '%<',
        render_components({
            M.git_branch(truncation_width),
            M.git_diff(truncation_width),
        }, ''),
        M.lsp_clients(truncation_width),
        M.cscope(truncation_width),
    }

    local middle = {
        M.filename(),
        M.arglist(),
    }

    local right = {
        M.search(),
        M.diagnostics(),
        M.autoformat(truncation_width),
        M.spell(truncation_width),
        render_components({
            M.obsession(),
            M.treesitter(),
            M.indent(truncation_width),
            M.encoding(truncation_width),
        }, ''),
        M.filetype(),
        M.location(),
    }

    return render_components({
        render_components(left, ' '),
        '%=',
        render_components(middle, ' '),
        '%=',
        render_components(right, ' '),
    }, ' ')
end

local group = vim.api.nvim_create_augroup('rockyz.statusline.redraw', {})

-- Refresh after gitsigns update
vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'GitSignsUpdate',
    callback = function()
        vim.cmd.redrawstatus()
    end,
})

vim.api.nvim_create_autocmd('ColorScheme', {
    group = group,
    callback = function()
        vim.tbl_clear(icon_highlight_cache)
    end,
})

vim.o.statusline = "%!v:lua.require('rockyz.statusline').render()"

return M
