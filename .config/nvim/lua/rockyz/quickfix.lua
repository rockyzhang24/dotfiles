local M = {}

local icons = require('rockyz.icons')

local MAX_FNAME_LEN = 50
local TRUNCATE_PREFIX = icons.misc.ellipsis

function M.normalize(item)
    local fname_fmt1 = '%-' .. MAX_FNAME_LEN .. 's'
    local fname_fmt2 = TRUNCATE_PREFIX .. ' %.' .. (MAX_FNAME_LEN - 2) .. 's'
    local fname = ''
    if item.bufnr > 0 then
        fname = vim.api.nvim_buf_get_name(item.bufnr)
        if fname == '' then
            fname = '[No Name]'
        else
            fname = fname:gsub('^' .. vim.env.HOME, '~')
        end
        if #fname <= MAX_FNAME_LEN then
            fname = fname_fmt1:format(fname)
        else
            fname = fname_fmt2:format(fname)
        end
    end
    -- Is showing end_lnum and end_col in quickfix helpful? I don't think so!
    return {
        filename = fname,
        lnum = item.lnum or -1,
        col = item.col or -1,
        type = item.type == '' and '' or item.type:sub(1, 1):upper(),
        text = item.text:gsub('\n', ' '),
    }
end

-- To avoid performance issue, qftf should be kept as simple as possible
function M.qftf(info)
    local items
    local lines = {}
    if info.quickfix == 1 then
        items = vim.fn.getqflist({ id = info.id, items = 0 }).items
    else
        items = vim.fn.getloclist(info.winid, { id = info.id, items = 0 }).items
    end
    local fmt = '%s |%5d:%-3d|%s %s'
    for i = info.start_idx, info.end_idx do
        local item = M.normalize(items[i])
        local line
        if items[i].valid == 1 then
            line = fmt:format(item.filename, item.lnum, item.col, item.type == '' and '' or ' ' .. item.type, item.text)
        else
            line = item.text
        end
        table.insert(lines, line)
    end
    return lines
end

vim.o.quickfixtextfunc = [[{info -> v:lua.require('rockyz.quickfix').qftf(info)}]]
-- NOTE: if we use a normal function as the value of quickfixtextfunc instead of this lambda, only
-- single quote form to get the package is allowed:
-- vim.o.quickfixtextfunc = "v:lua.require'rockyz.quickfix'.qftf"

return M
