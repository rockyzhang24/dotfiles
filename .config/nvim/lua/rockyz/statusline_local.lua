local icons = require('rockyz.icons')
local special_filetypes = require('rockyz.special_filetypes')
local has_devicons, devicons = pcall(require, 'nvim-web-devicons')

local M = {}

local icon_highlight_cache = {}
local diagnostic_levels = { 'ERROR', 'WARN', 'INFO', 'HINT' }

local function escape_statusline(text)
    return text:gsub('%%', '%%%%')
end

local function join(components)
    local result = {}
    for _, component in ipairs(components) do
        if component ~= '' then
            result[#result + 1] = component
        end
    end
    return table.concat(result, ' ')
end

function M.git_branch()
    local head = vim.b.gitsigns_head
    if not head or head == '' then
        return ''
    end
    return icons.git.branch .. ' ' .. escape_statusline(head)
end

function M.git_diff()
    local git_status = vim.b.gitsigns_status_dict
    if not git_status then
        return ''
    end

    local counts = {
        added = git_status.added,
        deleted = git_status.removed,
        modified = git_status.changed,
    }

    local items = {}

    for _, kind in ipairs({ 'added', 'deleted', 'modified' }) do
        local count = counts[kind] or 0
        if count > 0 then
            items[#items + 1] = icons.minimal.git[kind] .. count
        end
    end

    return #items > 0 and table.concat(items, ' ') or ''
end

function M.diagnostics()
    local counts = vim.diagnostic.count(0)
    local enabled = vim.diagnostic.is_enabled({ bufnr = 0 })

    local items = {}

    for _, level in ipairs(diagnostic_levels) do
        local count = counts[vim.diagnostic.severity[level]] or 0
        if count > 0 then
            local hl = enabled and 'StlDiagnostic' .. level or 'StlComponentInactive'
            items[#items + 1] = string.format(
                '%%#%s#%s %s%%*',
                hl,
                icons.diagnostics[level],
                count
            )
        end
    end

    return table.concat(items, ' ')
end

function M.indent()
    local shiftwidth = vim.bo.shiftwidth > 0 and vim.bo.shiftwidth or vim.bo.tabstop
    local width = vim.bo.expandtab and shiftwidth or vim.bo.tabstop

    return string.format('[%s:%s]', vim.bo.expandtab and 'S' or 'T', width)
end

function M.filetype()
    local filetype = vim.bo.filetype
    if filetype == '' then
        return icons.misc.file .. ' [Empty]'
    end

    local escaped_filetype = escape_statusline(filetype)
    local special = special_filetypes[filetype]

    if special then
        return special.icon .. ' ' .. escaped_filetype
    end

    if not has_devicons then
        return icons.misc.file .. ' ' .. escaped_filetype
    end

    local icon, color = devicons.get_icon_color_by_filetype(
        filetype,
        { default = true }
    )
    local hl = 'StlIcon-' .. filetype

    if not icon_highlight_cache[hl] then
        vim.api.nvim_set_hl(0, hl, { fg = color })
        icon_highlight_cache[hl] = true
    end

    return string.format(
        '%%#%s#%s%%* %s',
        hl,
        icon,
        escaped_filetype
    )
end

function M.location()
    return '%3l/%-3L:%-2v [%3p%%]'
end

function M.render()
    local left = join({
        '%f%( %h%w%m%r%)',
        M.git_branch(),
        M.git_diff(),
    })

    local right = join({
        M.diagnostics(),
        M.indent(),
        M.filetype(),
        M.location(),
    })

    return '%<' .. left .. '%= ' .. right
end

local group = vim.api.nvim_create_augroup('rockyz.statusline_local', {})

vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'GitSignsUpdate',
    callback = function(event)
        vim.api.nvim__redraw({ win = event.win, statusline = true })
    end,
})

vim.api.nvim_create_autocmd('ColorScheme', {
    group = group,
    callback = function()
        icon_highlight_cache = {}
    end,
})

vim.o.statusline = "%{%v:lua.require('rockyz.statusline_local').render()%}"

return M
