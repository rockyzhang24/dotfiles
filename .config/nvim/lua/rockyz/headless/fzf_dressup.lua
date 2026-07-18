-- Get input lines from stdin. Decorate each line, e.g., prepend a devicon to the filename in each
-- line or add ANSI colors to text, then write processed lines to stdout.

local M = {}

vim.cmd.packadd('nvim-web-devicons')

local devicons = require('nvim-web-devicons')
local color = require('rockyz.utils.color')

---@type table<string, string> Maps highlight group names to ANSI escape codes
local ansi_code_by_highlight = {}

---@param text string
---@param highlight_group string
---@return string
local function colorize_with_ansi(text, highlight_group)
    if not ansi_code_by_highlight[highlight_group] then
        ansi_code_by_highlight[highlight_group] = color.hl2ansi(highlight_group)
    end
    return ansi_code_by_highlight[highlight_group] .. text .. '\x1b[m'
end

---@param filename string
---@return string
local function get_ansi_icon(filename)
    local extension = filename:match('^.+%.(.+)$')
    local icon, highlight_group = devicons.get_icon(filename, extension, { default = true })
    return colorize_with_ansi(icon, highlight_group)
end

---@param source string Input source name used to select the line format
function M.dressup(source)
    local cwd = vim.uv.cwd()
    local has_dotfile_changes

    for line in io.lines() do
        local output_line
        if source == 'fd' then
            -- line is a filename
            -- output: <icon> <filename>\t<absolute_path>
            local ansi_icon = get_ansi_icon(line)
            output_line = ansi_icon .. ' ' .. line .. '\t' .. cwd .. '/' .. line
        elseif source == 'ls_gitfiles' then
            -- lines are output of `ls-gitfiles` (~/.config/bin/ls-gitfiles)
            -- (1) Some file changed, i.e., git status has output
            -- <status_code> <filename>\t<full_path> --> <status_code> <icon> <filename>\t<filename>\t<full_path>
            -- (2) No file changed, i.e., git status has no output
            -- <filename>\t<full_path> --> <icon> <filename>\t<filename>\t<full_path>
            --
            -- In fzf, we set \t as its delimiter, and then we can easily extract the filename and its
            -- full_path by the second and the third items.
            local filename, full_path = unpack(vim.split(line, '\t'))
            local status_code = filename:match('^(%[.*%])')
            if status_code then
                filename = line:match('^%[.*%]%s(.*)\t')
                has_dotfile_changes = true
            else
                filename = vim.trim(filename)
            end
            local ansi_icon = get_ansi_icon(full_path)
            if not has_dotfile_changes then
                -- For (2)
                output_line = ansi_icon .. ' ' .. filename .. '\t' .. filename .. '\t' .. full_path
            else
                -- For (1)
                output_line = string.format(
                    '%s %s %s\t%s\t%s',
                    status_code or string.rep(' ', 4),
                    ansi_icon,
                    filename,
                    filename,
                    full_path
                )
            end
        elseif source == 'git_lsfiles_fullname' then
            -- input line: <relative_path>\t<absolute_path>, where
            --   <relative_path> is the output of `git ls-files --full-name`
            --   <absolute_path> is <git_root>/<relative_path>
            -- Output: <icon> <relative_path>\t<relative_path>\t<absolute_path>
            local relative_path, absolute_path = unpack(vim.split(line, '\t'))
            local ansi_icon = get_ansi_icon(absolute_path)
            output_line = ansi_icon .. ' ' .. relative_path .. '\t' .. relative_path .. '\t' .. absolute_path
        elseif source == 'git_status' then
            -- lines are the output of `git status --porcelain=v1`. Each line has one of these formats:
            -- (1). XY FILENAME
            -- (2). XY OLD_FILENAME -> NEW_FILENAME
            -- output: [<staged><unstaged>] <git status text>\t<filename>
            local file_path = line:sub(4):gsub([["]], '')
            local old_path, new_path

            if line:sub(1, 2):find('[RC]') then
                old_path, new_path = file_path:match('(.*)%s%->%s(.*)')
            end

            local old_path_with_icon = old_path and (get_ansi_icon(old_path) .. ' ' .. old_path)
            local new_path_with_icon = new_path and (get_ansi_icon(new_path) .. ' ' .. new_path)

            local staged_indicator = colorize_with_ansi(line:sub(1, 1), 'GitStatusStaged')
            local unstaged_indicator = colorize_with_ansi(line:sub(2, 2), 'GitStatusUnstaged')

            local display_path = get_ansi_icon(file_path) .. ' ' .. file_path
            if new_path then
                display_path = ('%s -> %s'):format(old_path_with_icon, new_path_with_icon)
            end
            local selected_path = new_path or file_path
            -- \t as the delimiter for the finder "git status"
            output_line = string.format('[%s%s]  %s\t%s', staged_indicator, unstaged_indicator, display_path, selected_path)
        else
            -- Preserve lines from unrecognized sources unchanged
            output_line = line
        end

        io.stdout:write(output_line .. '\n')
    end
end

return M
