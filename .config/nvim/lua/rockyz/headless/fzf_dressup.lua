-- Get input lines from stdin. Decorate each line, e.g., prepend a devicon to the filename in each
-- line or ANSI color part of texts. And output processed lines to stdout.

local devicons = require('nvim-web-devicons')
local color = require('rockyz.utils.color_utils')

local source = vim.g.source

---@type table<string, string> A map from highlight group to ANSI color code
local cached_ansi = {}

local function ansi_string(string, hl)
    if not cached_ansi[hl] then
        cached_ansi[hl] = color.hl2ansi(hl)
    end
    return cached_ansi[hl] .. string .. '\x1b[m'
end

local function ansi_icon(filename)
    local ext = filename:match('^.+%.(.+)$')
    local icon, hl = devicons.get_icon(filename, ext, { default = true })
    return ansi_string(icon, hl)
end

for line in io.lines() do
    local output_line
    if source == 'fd' or source == 'git_ls_files' then
        -- lines are normal filenames. Prepend a devicon.
        local icon = ansi_icon(line)
        output_line = icon .. ' ' .. line
    elseif source == 'git_status' then
        -- lines are generated by `git status --porcelain=v1`. Each lines has one of these formats:
        -- XY FILENAME
        -- XY OLD_FILENAME -> NEW_FILENAME
        local f1, f2 = line:sub(4):gsub([["]], ''), nil
        if f1:match('%s%->%s') then
            f1, f2 = f1:match('(.*)%s%->%s(.*)')
        end
        local icon_f1 = f1 and (ansi_icon(f1) .. ' ' .. f1)
        local icon_f2 = f2 and (ansi_icon(f2) .. ' ' .. f2)
        local staged = ansi_string(line:sub(1, 1), 'GitStatusStaged')
        local unstaged = ansi_string(line:sub(2, 2), 'GitStatusUnstaged')
        -- \t as the delimiter for the finder "git status"
        output_line = string.format('[%s%s]  %s\t%s', staged, unstaged, (f2 and ('%s -> %s'):format(icon_f1, icon_f2) or icon_f1), f2 or f1)
    end

    io.stdout:write(output_line .. '\n')
end
