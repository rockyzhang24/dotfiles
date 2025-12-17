-- Display scrollbar in each window.
-- The scrollbar gutter is implemented using a floating window and the thumb is drawn by extmarks.
--
-- Inspired by https://github.com/Xuyuanp/scrollbar.nvim

local M = {}

local config = {
    max_size = 10,
    min_size = 3,
    width = 1,
    right_offset = 0,
    winblend = 20,
    hl_group = 'ScrollbarSlider',
    exclude_filetypes = {
    },
}

---The state of the scrollbar in the current window
---@class rockyz.scrollbar.State
---@field winid integer The winid of the scrollbar's floating window
---@field bufnr integer The bufnr of the scrollbar's buffer
---@field size integer The size (i.e., the height) of the scrollbar
---@field offset integer The offset of the scrollbar based on the top of the window

local ns = vim.api.nvim_create_namespace('rockyz.scrollbar')

local function fix_size(size)
    return math.max(config.min_size, math.min(config.max_size, size))
end

local function create_scrollbar_buffer(line_count)
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.bo[bufnr].filetype = 'scrollbar'
    local lines = {}
    for _ = 1, line_count do
        lines[#lines + 1] = ' '
    end
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    return bufnr
end

---@param winid? integer The winid of the window in which the scrollbar resides
function M.show(winid)
    if not vim.g.scrollbar_enabled then
        return
    end

    winid = winid or vim.api.nvim_get_current_win()
    local win_config = vim.api.nvim_win_get_config(winid)
    -- Ignore floating window
    if win_config.relative ~= '' then
        return
    end

    if vim.tbl_contains(config.exclude_filetypes, vim.bo.filetype) then
        return
    end

    local total = vim.fn.line('$')
    local win_height = vim.api.nvim_win_get_height(winid) - vim.o.cmdheight

    if total <= win_height then
        M.clear_extmarks(winid)
        return
    end

    local curr_line = vim.fn.line('w$') - win_height
    -- Use viewport as scroll anchor
    local rel_total = total - win_height

    local bar_size = math.ceil(win_height * win_height / rel_total)
    bar_size = fix_size(bar_size)

    local width = vim.api.nvim_win_get_width(winid)
    local col = width - config.width - config.right_offset

    local win_opts = {
        style = 'minimal',
        relative = 'win',
        win = winid,
        width = config.width,
        height = win_height,
        row = 0,
        col = col,
        focusable = false,
        zindex = 1,
        border = 'none',
    }

    ---@type rockyz.scrollbar.State
    local state = vim.w[winid].scrollbar_state or {}

    state.size = bar_size
    state.offset = math.floor((win_height - bar_size) * (curr_line / rel_total))

    if not state.bufnr then
        state.bufnr = create_scrollbar_buffer(win_height)
        vim.api.nvim_create_autocmd({ 'WinClosed' }, {
            pattern = '' .. winid,
            once = true,
            callback = function()
                vim.api.nvim_buf_delete(state.bufnr, { force = true })
            end,
        })
    end

    if not state.winid or not vim.api.nvim_win_is_valid(state.winid) then
        state.winid = vim.api.nvim_open_win(state.bufnr, false, win_opts)
        vim.wo[state.winid].winblend = config.winblend
    else
        vim.api.nvim_win_set_config(state.winid, win_opts)
    end

    vim.w[winid].scrollbar_state = state

    M.clear_extmarks(winid)
    M.set_extmarks(winid)
end

function M.clear_extmarks(winid)
    winid = winid or vim.api.nvim_get_current_win()
    local state = vim.w[winid].scrollbar_state
    if not state or not state.bufnr then
        return
    end
    vim.api.nvim_buf_clear_namespace(state.bufnr, ns, 0, -1)
end

function M.set_extmarks(winid)
    winid = winid or vim.api.nvim_get_current_win()
    local state = vim.w[winid].scrollbar_state
    for l = state.offset, state.offset + state.size - 1 do
        vim.api.nvim_buf_set_extmark(state.bufnr, ns, l, 0, {
            end_col = 1,
            hl_group = config.hl_group,
        })
    end
end

vim.api.nvim_create_autocmd({ 'BufEnter', 'WinScrolled', 'WinResized', 'CursorHold', 'CursorHoldI' }, {
    group = vim.api.nvim_create_augroup('rockyz.scrollbar', { clear = true }),
    callback = function()
        for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            vim.api.nvim_win_call(winid, function()
                require('rockyz.scrollbar').show(winid)
            end)
        end
    end,
})

return M
