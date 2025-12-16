-- Reference: https://github.com/Xuyuanp/scrollbar.nvim

local M = {}

local config = {
    max_size = 10,
    min_size = 3,
    width = 1,
    right_offset = 0,
    winblend = 20,
    exclude_filetypes = {
    },
}

---@class rockyz.scrollbar.State
---@field winid integer
---@field bufnr integer
---@field size integer

local function gen_bar_lines(size)
    local lines = {}
    for _ = 1, size do
        table.insert(lines, ' ')
    end
    return lines
end

local function fix_size(size)
    return math.max(config.min_size, math.min(config.max_size, size))
end

local function create_scrollbar_buffer(lines)
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.bo[bufnr].filetype = 'scrollbar'
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    return bufnr
end

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
        M.clear()
        return
    end

    -- Use viewport as scroll anchor
    local curr_line = vim.fn.line('w$') - win_height
    local rel_total = total - win_height

    local bar_size = math.ceil(win_height * win_height / rel_total)
    bar_size = fix_size(bar_size)

    local width = vim.api.nvim_win_get_width(winid)
    local col = width - config.width - config.right_offset
    local row = math.floor((win_height - bar_size) * (curr_line / rel_total))

    local opts = {
        style = 'minimal',
        relative = 'win',
        win = winid,
        width = config.width,
        height = bar_size,
        row = row,
        col = col,
        focusable = false,
        zindex = 1,
        border = 'none',
    }

    local state = vim.w[winid].scrollbar_state or {}
    if not state.bufnr then
        local bar_lines = gen_bar_lines(bar_size)
        state.bufnr = create_scrollbar_buffer(bar_lines)
        vim.api.nvim_create_autocmd({ 'WinClosed' }, {
            pattern = '' .. winid,
            once = true,
            callback = function()
                vim.api.nvim_buf_delete(state.bufnr, { force = true })
            end,
        })
    end

    if state.winid and vim.api.nvim_win_is_valid(state.winid) then
        if state.size ~= bar_size then
            vim.api.nvim_buf_set_lines(state.bufnr, 0, -1, false, {})
            local bar_lines = gen_bar_lines(bar_size)
            vim.api.nvim_buf_set_lines(state.bufnr, 0, -1, false, bar_lines)
            state.size = bar_size
        end
        vim.api.nvim_win_set_config(state.winid, opts)
    else
        state.winid = vim.api.nvim_open_win(state.bufnr, false, opts)
        vim.wo[state.winid].winhighlight = 'Normal:ScrollbarSlider'
        vim.wo[state.winid].winblend = config.winblend
    end

    vim.w[winid].scrollbar_state = state
end

function M.clear(winid)
    winid = winid or vim.api.nvim_get_current_win()
    local state = vim.w[winid].scrollbar_state
    if not state or not state.winid then
        return
    end
    if vim.api.nvim_win_is_valid(state.winid) then
        vim.api.nvim_win_hide(state.winid)
    end
    vim.w[winid].scrollbar_state = {
        size = state.size,
        bufnr = state.bufnr,
    }
end

vim.api.nvim_create_autocmd({ 'BufEnter', 'WinScrolled', 'WinResized' }, {
    group = vim.api.nvim_create_augroup('rockyz.scrollbar', { clear = true }),
    callback = function()
        for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            require('rockyz.scrollbar').show(winid)
        end
    end,
})

return M
