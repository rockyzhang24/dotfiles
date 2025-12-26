-- Display scrollbar in each window.
-- The scrollbar gutter is implemented using a floating window and the thumb is drawn by extmarks.

local icons = require('rockyz.icons')
local M = {}

local config = {
    min_size = 3,
    right_offset = 0,
    winblend = 20,
    thumb_hl = 'ScrollbarSlider',
    exclude_filetypes = {
    },
    diagnostic = {
        symbol = icons.misc.vertical_rectangle
    }
}

---The state of the scrollbar in the current window
---@class rockyz.scrollbar.State
---@field winid integer The winid of the scrollbar's floating window
---@field bufnr integer The bufnr of the scrollbar's buffer
---@field max_thumb_move integer The maximum distance (screen lines) the thumb can move
---@field max_scroll integer The maximum distance (screen lines) the whole buffer can scroll
---@field size integer The size (i.e., the height) of the scrollbar's thumb
---@field position integer The position of the scrollbar's thumb, i.e., the row of the gutter where
---the top of the thumb is

local thumb_ns = vim.api.nvim_create_namespace('rockyz.scrollbar.thumb')
local diagnostic_ns = vim.api.nvim_create_namespace('rocky.scrollbar.diagnostics')
local scrollbar_width = 3

-- Get the number of screen lines that can be displayed
local function get_viewport_height(winid)
    local viewport_height = vim.api.nvim_win_get_height(winid)
    if vim.o.winbar ~= '' then
        viewport_height = viewport_height - 1
    end
    return viewport_height
end

-- Fix the scrollbar size by constraining it to the min_size and max_size set in the config. If
-- max_size is not specified, its maximum size is the viewport height of the window.
local function fix_size(size, winid)
    local max_size = config.max_size
    local viewport_height = get_viewport_height(winid)
    if not max_size or max_size > viewport_height then
        max_size = viewport_height
    end
    return math.max(config.min_size, math.min(max_size, size))
end

-- extmarks can't be set on an empty cell, so we put whitespaces on each line.
local function ensure_valid_buffer(bufnr, line_count)
    local lines = {}
    for _ = 1, line_count do
        lines[#lines + 1] = string.rep(' ', scrollbar_width)
    end
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
end

local function create_scrollbar_buffer(line_count)
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.bo[bufnr].filetype = 'scrollbar'
    ensure_valid_buffer(bufnr, line_count)
    return bufnr
end

-- Get the total number of screen lines by giving a range of buffer lines in a given window
local function get_screen_line_height(winid, range)
    local text_height = vim.api.nvim_win_text_height(winid, range)
    return text_height.all
end

---NOTE: To implement scrollbar correctly, we should use screen lines, not buffer lines, because
---scrolling is done in units of screen lines, not buffer lines. When wrap is enabled, a single
---buffer line may correspond to multiple screen lines; similarly, folds affect screen lines rather
---than buffer lines; virtual text may also insert additional screen lines.
---@param winid? integer The winid of the window in which the scrollbar resides
function M.render_scrollbar(winid)
    winid = winid or vim.api.nvim_get_current_win()
    local win_config = vim.api.nvim_win_get_config(winid)
    -- Ignore floating window
    if win_config.relative ~= '' then
        return
    end

    if vim.tbl_contains(config.exclude_filetypes, vim.bo.filetype) then
        return
    end

    ---@type rockyz.scrollbar.State
    local state = vim.w[winid].scrollbar_state or {}

    -- Now let's calculate the scrollbar'size and position

    local buf_content_height = get_screen_line_height(winid, {}) -- The number of screen lines of the whole buffer
    local viewport_height = get_viewport_height(winid)

    -- (1). Calculate the scrollbar's thumb size
    -- We have this proportional relationship:
    -- thumb_size / viewport_height = viewport_height / buf_content_height
    local thumb_size = math.ceil(viewport_height * viewport_height / buf_content_height)
    thumb_size = fix_size(thumb_size, winid)

    state.size = thumb_size

    -- (2). Calculate the scrollbar's position
    local wininfo = vim.fn.getwininfo(winid)[1]
    local buffer_topline = wininfo.topline -- The top buffer line in the window
    local screen_topline = get_screen_line_height(winid, { -- Get the top screen line
        start_row = 0,
        end_row = buffer_topline - 1
    })

    local position -- range [0, ...]
    local max_thumb_move = viewport_height - thumb_size -- The maximum distance the thumb can move
    local max_scroll = math.max(buf_content_height - viewport_height, 0) -- The maximum distance the whole buffer can scroll
    if max_scroll == 0 then
        position = 0
    else
        -- We have this proportional relationship:
        -- thumb_position / max_thumb_move = screen_topline / max_scroll
        position = math.floor((screen_topline / max_scroll) * max_thumb_move)
    end

    state.max_thumb_move = max_thumb_move
    state.max_scroll = max_scroll
    state.position = position

    if not state.bufnr then
        state.bufnr = create_scrollbar_buffer(viewport_height)
        vim.api.nvim_create_autocmd({ 'WinClosed' }, {
            pattern = '' .. winid,
            once = true,
            callback = function()
                vim.api.nvim_buf_delete(state.bufnr, { force = true })
            end,
        })
    end

    local width = vim.api.nvim_win_get_width(winid)
    local col = width - scrollbar_width - config.right_offset

    local win_opts = {
        style = 'minimal',
        relative = 'win',
        win = winid,
        width = scrollbar_width,
        height = viewport_height,
        row = 0,
        col = col,
        focusable = false,
        zindex = 1,
        border = 'none',
    }

    if not state.winid or not vim.api.nvim_win_is_valid(state.winid) then
        state.winid = vim.api.nvim_open_win(state.bufnr, false, win_opts)
        vim.wo[state.winid].winblend = config.winblend
    else
        if vim.api.nvim_win_get_height(state.winid) < viewport_height then
            ensure_valid_buffer(state.bufnr, viewport_height)
        end
        vim.api.nvim_win_set_config(state.winid, win_opts)
    end

    vim.w[winid].scrollbar_state = state

    M.clear_extmarks(winid, thumb_ns)

    -- Set extmarks
    for l = state.position, state.position + state.size - 1 do
        M.set_extmark(winid, thumb_ns, l, 0, string.rep(' ', scrollbar_width), config.thumb_hl)
    end
end

function M.clear_extmarks(winid, ns)
    winid = winid or vim.api.nvim_get_current_win()
    local state = vim.w[winid].scrollbar_state
    if not state or not state.bufnr then
        return
    end
    vim.api.nvim_buf_clear_namespace(state.bufnr, ns, 0, -1)
end

function M.set_extmark(winid, ns, lnum, col, text, highlight)
    winid = winid or vim.api.nvim_get_current_win()
    local state = vim.w[winid].scrollbar_state
    vim.api.nvim_buf_set_extmark(state.bufnr, ns, lnum, col, {
        virt_text = {
            { text, highlight },
        },
        virt_text_pos = 'overlay',
        hl_mode = 'combine',
    })
end

local diagnostic_levels = { 'Error', 'Warn', 'Info', 'Hint' }

function M.render_diagnostics(winid)
    winid = winid or vim.api.nvim_get_current_win()
    local state = vim.w[winid].scrollbar_state or {}

    local bufnr = vim.api.nvim_win_get_buf(winid)
    local diagnostics = vim.diagnostic.get(bufnr)

    local max_thumb_move = state.max_thumb_move
    local max_scroll = state.max_scroll
    local buf_line_count = vim.api.nvim_buf_line_count(bufnr)

    -- On each position only display the diagnostic with the lowest severity
    local filtered = {}
    for _, d in ipairs(diagnostics) do
        -- The screen line number of the diagnostic
        local diagnostic_screen_line = get_screen_line_height(winid, {
            start_row = 0,
            -- Sometimes d.lnum exceeds the buffer line count, and I don’t know why.
            -- For example, earlier when editing a Go file, I deleted all the contents and left only
            -- the first comment line. I then got an error, but since d.lnum is 0-indexed, it should
            -- have been 0, yet it was 2.
            end_row = d.lnum >= buf_line_count and buf_line_count - 1 or d.lnum,
        })

        local position -- 0-indexed, range [0, n - 1] where n is the last line in the current viewport
        if max_scroll == 0 then
            position = diagnostic_screen_line - 1
        else
            -- We have this proportional relationship:
            -- position / max_thumb_move = diagnostic_screen_line / max_scroll
            position = math.floor(diagnostic_screen_line / max_scroll * max_thumb_move)
        end

        if not filtered[position] or d.severity < filtered[position] then
            filtered[position] = d.severity
        end
    end

    M.clear_extmarks(winid, diagnostic_ns)

    -- Set extmarks
    for line, severity in pairs(filtered) do
        M.set_extmark(winid, diagnostic_ns, line, 2, config.diagnostic.symbol, 'Diagnostic' .. diagnostic_levels[severity])
    end
end

local group = vim.api.nvim_create_augroup('rockyz.scrollbar', { clear = true })

vim.api.nvim_create_autocmd({ 'WinScrolled' }, {
    group = group,
    callback = function(args)
        require('rockyz.scrollbar').render_scrollbar(tonumber(args.match))
    end,
})

vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
    group = group,
    callback = function()
        require('rockyz.scrollbar').render_scrollbar()
    end,
})

vim.api.nvim_create_autocmd({ 'BufEnter', 'WinResized' }, {
    group = group,
    callback = function()
        for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            vim.api.nvim_win_call(winid, function()
                require('rockyz.scrollbar').render_scrollbar(winid)
                require('rockyz.scrollbar').render_diagnostics(winid)
            end)
        end
    end,
})

vim.api.nvim_create_autocmd({ 'DiagnosticChanged' }, {
    group = group,
    callback = function(args)
        local wins = vim.fn.win_findbuf(args.buf)
        for _, winid in ipairs(wins) do
            require('rockyz.scrollbar').render_diagnostics(winid)
        end
    end,
})

return M
