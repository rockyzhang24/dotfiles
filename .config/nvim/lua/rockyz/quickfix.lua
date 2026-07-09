local M = {}

local ok, icons = pcall(require, 'rockyz.icons')

local MAX_FILENAME_WIDTH = 50
local TRUNCATE_PREFIX = ok and icons.misc.ellipsis or ''

local FILENAME_FORMAT = '%-' .. MAX_FILENAME_WIDTH .. 's'
local TRUNCATED_FILENAME_FORMAT = TRUNCATE_PREFIX .. ' %.' .. (MAX_FILENAME_WIDTH - 2) .. 's'

local QUICKFIX_LINE_FORMAT = '%s |%5d:%-3d|%s %s'

function M.normalize_item(item)
    local filename = ''
    if item.bufnr > 0 then
        filename = vim.api.nvim_buf_get_name(item.bufnr)
        if filename == '' then
            filename = '[No Name]'
        else
            local home = vim.env.HOME
            local home_relative_path = home and vim.fs.relpath(home, filename)
            filename = home_relative_path and ('~/' .. home_relative_path) or filename
        end
        if #filename <= MAX_FILENAME_WIDTH then
            filename = FILENAME_FORMAT:format(filename)
        else
            filename = TRUNCATED_FILENAME_FORMAT:format(filename)
        end
    end

    local item_type = item.type or ''
    local item_text = item.text or ''

    -- Is showing end_lnum and end_col in quickfix helpful? I don't think so!
    return {
        filename = filename,
        lnum = item.lnum or -1,
        col = item.col or -1,
        type = item_type == '' and '' or item_type:sub(1, 1):upper(),
        text = item_text:gsub('\n', ' '),
    }
end

-- To avoid performance issues, quickfixtextfunc should be kept as simple as possible
function M.quickfix_textfunc(info)
    local items
    local lines = {}
    if info.quickfix == 1 then
        items = vim.fn.getqflist({ id = info.id, items = 0 }).items
    else
        items = vim.fn.getloclist(info.winid, { id = info.id, items = 0 }).items
    end
    for i = info.start_idx, info.end_idx do
        local qf_item = items[i]
        local item = M.normalize_item(qf_item)
        local item_type = item.type == '' and '' or ' ' .. item.type
        local line

        if qf_item.valid == 1 then
            line = QUICKFIX_LINE_FORMAT:format(item.filename, item.lnum, item.col, item_type, item.text)
        else
            line = item.text
        end

        table.insert(lines, line)
    end
    return lines
end

vim.o.quickfixtextfunc = [[{info -> v:lua.require('rockyz.quickfix').quickfix_textfunc(info)}]]
-- NOTE: if we use a normal function as the value of quickfixtextfunc instead of this lambda, only
-- single quote form to get the package is allowed:
-- vim.o.quickfixtextfunc = "v:lua.require'rockyz.quickfix'.quickfix_textfunc"

return M
