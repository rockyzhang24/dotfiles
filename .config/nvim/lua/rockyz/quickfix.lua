-- Setting quickfixtextfunc to decorate the quickfix is inspired by yorickpeterse/nvim-pqf
-- (yorickpeterse/nvim-pqf)

local M = {}

local qf_utils = require('rockyz.utils.qf_utils')

local ns = vim.api.nvim_create_namespace('quickfix-highlight')

local function list_items(info)
    local what = { id = info.id, items = 0, qfbufnr = 0 }
    if info.quickfix == 1 then
        return vim.fn.getqflist(what)
    else
        return vim.fn.getloclist(info.winid, what)
    end
end

local function apply_highlights(bufnr, highlights)
    for _, hl in ipairs(highlights) do
        vim.hl.range(bufnr, ns, hl.group, { hl.line, hl.col }, { hl.line, hl.end_col })
    end
end

function M.qftf(info)
    local list = list_items(info)
    local qf_bufnr = list.qfbufnr
    local raw_items = list.items

    local highlights = {}
    local entries = {}

    -- If we're adding a new list rather than appending to an existing one, we
    -- need to clear existing highlights.
    if info.start_idx == 1 then
        vim.api.nvim_buf_clear_namespace(qf_bufnr, ns, 0, -1)
    end

    -- Construct an entry for each list item in the format below and apply highlights
    -- <filename> <lnum>-<end_lnum>:<col>-<end_col> [<type>] <text>
    for i = info.start_idx, info.end_idx do
        local raw_item = raw_items[i]
        if raw_item then
            local item = qf_utils.format_qf_item(raw_item)
            local entry = {}
            local line_idx = i - 1
            -- Initialize the start col and end col for highlighting. Update them in each section that
            -- will be highlighted.
            local hl_col_start = 0
            local hl_col_end = -1
            -- Filename
            local fname = item.fname
            if fname ~= '' then
                table.insert(entry, fname)
                hl_col_start = hl_col_end + 1
                hl_col_end = hl_col_start + #fname
                table.insert(highlights, {
                    group = item.fname_hl,
                    line = line_idx,
                    col = hl_col_start,
                    end_col = hl_col_end,
                })
            end
            -- Line number and column number
            local lnum_col = item.lnum
            if item.col ~= '' then
                lnum_col = item.lnum .. ':' .. item.col
            end
            if lnum_col ~= '' then
                table.insert(entry, lnum_col)
                hl_col_start = hl_col_end + 1
                hl_col_end = hl_col_start + #tostring(lnum_col)
                table.insert(highlights, {
                    group = item.lnum_col_hl,
                    line = line_idx,
                    col = hl_col_start,
                    end_col = hl_col_end,
                })
            end
            -- Type
            local type = item.type ~= '' and '[' .. item.type .. ']' or ''
            if type ~= '' then
                table.insert(entry, type)
                hl_col_start = hl_col_end + 1
                hl_col_end = hl_col_start + #type
                table.insert(highlights, {
                    group = item.type_hl,
                    line = line_idx,
                    col = hl_col_start,
                    end_col = hl_col_end,
                })
            end
            -- Text
            local text = item.text
            if text ~= '' then
                table.insert(entry, text)
                hl_col_start = hl_col_end + 1
                hl_col_end = hl_col_start + #text
                table.insert(highlights, {
                    group = item.type_hl,
                    line = line_idx,
                    col = hl_col_start,
                    end_col = hl_col_end,
                })
            end

            table.insert(entries, table.concat(entry, ' '))
        end
    end

    -- Apply highlights
    vim.schedule(function()
        apply_highlights(qf_bufnr, highlights)
    end)

    return entries
end

vim.o.quickfixtextfunc = [[{info -> v:lua.require('rockyz.quickfix').qftf(info)}]]
-- NOTE: if we use a normal function as the value of quickfixtextfunc instead of this lambda, only
-- single quote form to get the package is allowed:
-- vim.o.quickfixtextfunc = "v:lua.require'rockyz.quickfix'.qftf"

return M
