local M = {}

local icons = require('rockyz.icons')

--------------
-- Format item
--------------

local MAX_FILENAME_LEN = 50 -- threshold for filename length. 0 means no limit.
local TRUNCATE_PREFIX = icons.misc.ellipsis

local type_hl = {
    E = 'DiagnosticSignError',
    W = 'DiagnosticSignWarn',
    I = 'DiagnosticSignInfo',
    H = 'DiagnosticSignHint',
}
local fname_hl = 'QuickfixFilename'
local lnum_col_hl = 'QuickfixLnumCol'

-- Truncate the filename from the beginnign if its length exceeds the threshold
local function trim_path(path)
    local fname = vim.fn.fnamemodify(path, ':p:.:~')
    if fname == '' then
        fname = '[No Name]'
    end
    if MAX_FILENAME_LEN > 0 and #fname > MAX_FILENAME_LEN then
        fname = TRUNCATE_PREFIX .. ' ' .. fname:sub(-MAX_FILENAME_LEN)
    end
    return fname
end

---Format qf list item and return a transformed one with necessary information for constructing the
---entry in qf.
---@param raw table qf item, see :h getqflist
---@return table
function M.format_qf_item(raw)
    local item = {
        fname = '', -- filename
        lnum = '', -- <lnum>-<end_lnum>
        col = '', -- <col>-<end_col>
        type = raw.type,
        text = raw.text,
        fname_hl = fname_hl,
        lnum_col_hl = lnum_col_hl,
        type_hl = type_hl[raw.type],
    }
    --Filename
    if raw.bufnr > 0 then
        local fname = trim_path(vim.fn.bufname(raw.bufnr))
        item.fname = fname
    end
    -- Process line number, <lnum>-<end_lnum>
    if raw.lnum and raw.lnum > 0 then
        local lnum = raw.lnum
        local end_lnum = raw.end_lnum
        if end_lnum and end_lnum > 0 and end_lnum ~= lnum then
            lnum = lnum .. '-' .. end_lnum
        end
        item.lnum = lnum
        -- Handle col only if lnum exists, <col>-<end_col>
        if raw.col and raw.col > 0 then
            local col = raw.col
            local end_col = raw.end_col
            if end_col and end_col > 0 and end_col ~= col then
                col = col .. '-' .. end_col
            end
            item.col = col
        end
    end
    return item
end

return M
