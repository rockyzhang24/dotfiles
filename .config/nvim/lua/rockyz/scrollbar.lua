-- Display scrollbar in each window.
-- The scrollbar gutter is implemented using a floating window and the thumb is drawn by extmarks.

-- NOTE:
-- To make scrollbar rendering as accurate as possible, we should use screen lines, not buffer
-- lines, because scrolling is done in units of screen lines, not buffer lines. When wrap is
-- enabled, a single buffer line may correspond to multiple screen lines; similarly, folds affect
-- screen lines rather than buffer lines; virtual text may also insert additional screen lines.
--
-- However, the API to obtaining the screen line, vim.api.nvim_win_text_height, has poor
-- performance, as each retrieval requires iterating over every line within the range. Therefore, in
-- pursuit of maximum performance, a compromise is made by using buffer lines instead.

-- How to calculate the scrollbar's size and position?
--
-- First, let's calculate two necessary metrics, viewport_heigth and buf_content_height.
-- (1). viewport_height = win_height - winbar_height. Viewport height is the number of lines that
-- display the actual content in the current window.
-- (2). buf_line_count. It is the total number of lines in the whole buffer.
--
-- We use the following proportional relationship to calculate the thumb size:
-- thumb_size / viewport_heigth = viewport_heigth / buf_line_count
-- ==> thumb_size = (viewport_height / buf_line_count) * viewport_heigth
--
-- Next, let's calculate the scrollbar's position (i.e., the line number in the viewport where the
-- top of the scrollbar is located). We need another three metrics, max_thumb_move, max_scroll and
-- top_buffer_line.
-- (1). max_thumb_move = viewport_height - thumb_size, it is the maximum lines the thumb can move.
-- (2). max_scroll = buf_line_count - viewport_height, it it the maximum lines the whole buffer can
-- scroll.
-- (3). top_buffer_line, it is the first buffer line in the current viewport.
--
-- We have this proportional relationship:
-- position / max_thumb_move = top_buffer_line / max_scroll. So we can get position by
-- position = (max_thumb_move / max_scroll) * top_buffer_line
--
-- We need to simplify it. Let's set V = viewport_height, B = buf_line_count, S = thumb_size. So
-- thumb_size = V^2 / B, max_thumb_move = V - V^2 / B, max_scroll = B - V. So
-- position = (V - V^2 / B) / (B - V) * top_buffer_line
--          = V / B * top_buffer_line
-- That is,
-- position = (viewport_heigth / buf_line_count) * top_buffer_line
--
-- How to calculate the position of a diagnostic?
--
-- First, we should get the screen line of a given diagnostic. Then, just like calculating the
-- scrollbar's position, we use the following proportional relationship:
-- position / max_thumb_move = diagnostic_lnum / max_scroll. So we can calculate the diagnostic's
-- position by
-- position = (max_thumb_move / max_scroll) * diagnostic_lnum
--
-- Similarly, the simplified result is
-- position = (viewport_heigth / buf_line_count) * diagnostic_lnum
--
-- How to calculate the position of a gitdiff or search result
--
-- Similarly, position = (viewport_heigth / buf_line_count) * lnum

local icons = require('rockyz.icons')
local gitsigns = require('gitsigns')

local M = {}

local config = {
    min_size = 3,
    right_offset = 0,
    winblend = 20,
    thumb_hl = 'ScrollbarSlider',
    exclude_filetypes = {
    },
    diagnostic = {
        symbol = icons.misc.vertical_rectangle,
        hl = {
            'DiagnosticError',
            'DiagnosticWarn',
            'DiagnosticInfo',
            'DiagnosticHint',
        },
    },
    gitdiff = {
        symbol = icons.lines.vertical_heavy,
        hl = {
            add = 'GutterGitAdded',
            change = 'GutterGitModified',
            delete = 'GutterGitDeleted',
        },
    },
    search = {
        symbol = icons.misc.vertical_rectangle,
        hl = 'ScrollbarSearch',
    },
}

---The state of the scrollbar in the current window
---@class rockyz.scrollbar.State
---@field winid integer The winid of the scrollbar's floating window
---@field bufnr integer The bufnr of the scrollbar's buffer
---@field last_viewport_height integer Cached viewport_height
---@field last_win_col integer Cached col of the scrollbar's floating window

local thumb_ns = vim.api.nvim_create_namespace('rockyz.scrollbar.thumb')
local diagnostic_ns = vim.api.nvim_create_namespace('rockyz.scrollbar.diagnostic')
local gitdiff_ns = vim.api.nvim_create_namespace('rockyz.scrollbar.gitdiff')
local search_ns = vim.api.nvim_create_namespace('rockyz.scrollbar.search')
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

local function clear_extmarks(winid, ns)
    winid = winid or vim.api.nvim_get_current_win()
    local state = vim.w[winid].scrollbar_state
    if not state or not state.bufnr then
        return
    end
    vim.api.nvim_buf_clear_namespace(state.bufnr, ns, 0, -1)
end

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

    local bufnr = vim.api.nvim_win_get_buf(winid)
    local buf_line_count = vim.api.nvim_buf_line_count(bufnr)
    local viewport_height = get_viewport_height(winid)

    -- Calculate the scrollbar's thumb size
    local thumb_size = math.ceil(viewport_height * viewport_height / buf_line_count)
    thumb_size = fix_size(thumb_size, winid)

    -- Calculate the scrollbar's position
    local top_buffer_line = vim.fn.line('w0', winid) -- The top buffer line in the viewport

    local position -- 0-indexed, range [0, ...]
    if viewport_height >= buf_line_count then
        position = 0
    else
        position = math.floor(top_buffer_line * viewport_height / buf_line_count)
        position = math.min(position, viewport_height - thumb_size)
    end

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
        if viewport_height ~= state.last_viewport_height or col ~= state.last_win_col then
            vim.api.nvim_win_set_config(state.winid, win_opts)
        end
    end

    state.last_viewport_height = viewport_height
    state.last_win_col = col
    vim.w[winid].scrollbar_state = state

    clear_extmarks(winid, thumb_ns)

    vim.api.nvim_buf_set_extmark(state.bufnr, thumb_ns, position, 0, {
        end_row = position + thumb_size,
        virt_text = { { string.rep(' ', scrollbar_width), config.thumb_hl } },
        virt_text_pos = 'overlay',
        hl_group = config.thumb_hl,
        priority = 10,
    })
end

function M.render_diagnostics(winid)
    winid = winid or vim.api.nvim_get_current_win()

    local bufnr = vim.api.nvim_win_get_buf(winid)
    local diagnostics = vim.diagnostic.get(bufnr)

    local viewport_height = get_viewport_height(winid)
    local buf_line_count = vim.api.nvim_buf_line_count(bufnr)

    ---On each position only display the diagnostic with the lowest severity
    ---@type table<integer, integer> position -> severity
    local marks = {}
    for _, d in ipairs(diagnostics) do
        local position -- 1-indexed, range [1, n] where n is the viewport_height
        if viewport_height >= buf_line_count then
            position = d.lnum
        else
            position = math.floor(d.lnum * viewport_height / buf_line_count)
        end

        if not marks[position] or d.severity < marks[position] then
            marks[position] = d.severity
        end
    end

    clear_extmarks(winid, diagnostic_ns)

    local state = vim.w[winid].scrollbar_state
    for line, severity in pairs(marks) do
        vim.api.nvim_buf_set_extmark(state.bufnr, diagnostic_ns, line, 2, {
            virt_text = { { config.diagnostic.symbol, config.diagnostic.hl[severity] } },
            virt_text_pos = 'overlay',
            hl_mode = 'combine',
            priority = 20,
        })
    end
end

local gitdiff_priority = { add = 1, change = 2, delete = 3 }

function M.render_gitdiffs(winid)
    winid = winid or vim.api.nvim_get_current_win()
    local bufnr = vim.api.nvim_win_get_buf(winid)
    local hunks = gitsigns.get_hunks(bufnr)

    ---@type table<integer, integer> position -> type
    local marks = {}

    ---@param lnum integer 1-indexed
    local function get_marks(lnum, type)
        local viewport_height = get_viewport_height(winid)
        local buf_line_count = vim.api.nvim_buf_line_count(bufnr)

        local position -- 1-indexed
        if viewport_height >= buf_line_count then
            position = lnum
        else
            position = math.ceil(lnum * viewport_height / buf_line_count)
        end

        if not marks[position] or gitdiff_priority[marks[position]] < gitdiff_priority[type] then
            marks[position] = type
        end
    end

    for _, h in ipairs(hunks or {}) do
        if h.type == 'add' or h.type == 'change' then
            for i = 0, h.added.count - 1 do
                local lnum = h.added.start + i
                get_marks(lnum, h.type)
            end
        elseif h.type == 'delete' then
            local lnum = math.max(h.removed.start - 1, 1)
            get_marks(lnum, h.type)
        end
    end

    clear_extmarks(winid, gitdiff_ns)

    local state = vim.w[winid].scrollbar_state
    for line, type in pairs(marks) do
        vim.api.nvim_buf_set_extmark(state.bufnr, gitdiff_ns, line - 1, 0, {
            virt_text = { { config.gitdiff.symbol, config.gitdiff.hl[type] } },
            virt_text_pos = 'overlay',
            hl_mode = 'combine',
            priority = 20,
        })
    end
end

function M.render_search(winid)
    local bufnr = vim.api.nvim_win_get_buf(winid)
    local pat = vim.fn.getreg('/')
    if pat == '' or vim.v.hlsearch == 0 then
        return
    end
    local viewport_height = get_viewport_height(winid)
    local buf_line_count = vim.api.nvim_buf_line_count(bufnr)
    local lnums = {}
    local save = vim.fn.getpos('.')
    vim.api.nvim_win_call(winid, function()
        vim.fn.cursor(1, 1)
        while vim.fn.search(pat, 'W') ~= 0 do
            local lnum = vim.fn.line('.') -- 1-indexed
            lnums[lnum] = true
        end
    end)
    vim.fn.setpos('.', save)

    clear_extmarks(winid, search_ns)

    local state = vim.w[winid].scrollbar_state
    for lnum, _ in pairs(lnums) do
        local position -- 1-indexed
        if viewport_height >= buf_line_count then
            position = lnum
        else
            position = math.ceil(lnum * viewport_height / buf_line_count)
        end
        vim.api.nvim_buf_set_extmark(state.bufnr, search_ns, position - 1, 1, {
            virt_text = { { config.search.symbol, config.search.hl } },
            virt_text_pos = 'overlay',
            hl_mode = 'combine',
            priority = 20,
        })
    end
end

-- Bind this to a keymap to clear the search marks
function M.clear_search()
    local bufnr = vim.api.nvim_get_current_buf()
    local wins = vim.fn.win_findbuf(bufnr)
    for _, winid in ipairs(wins) do
        clear_extmarks(winid, search_ns)
    end
end

-- Record all windows whose scrollbars need update
local dirty = {
    thumb = {},
    diagnostic = {},
    git = {},
    search = {},
}

local timer
local debounce_ms = 30

local function ensure_timer()
    if timer and not timer:is_closing() then
        return
    end
    timer = vim.uv.new_timer()
end

-- Debounce
local function schedule_flush()
    ensure_timer()
    timer:stop()
    timer:start(debounce_ms, 0, function()
        vim.schedule(function()
            if
                not next(dirty.thumb)
                and not next(dirty.diagnostic)
                and not next(dirty.git)
                and not next(dirty.search)
            then
                return
            end
            require('rockyz.scrollbar').flush()
        end)
    end)
end

function M.flush()
    for winid, _ in pairs(dirty.thumb) do
        if vim.api.nvim_win_is_valid(winid) then
            M.render_scrollbar(winid)
        end
    end

    for winid, _ in pairs(dirty.diagnostic) do
        if vim.api.nvim_win_is_valid(winid) then
            M.render_diagnostics(winid)
        end
    end

    for winid, _ in pairs(dirty.git) do
        if vim.api.nvim_win_is_valid(winid) then
            M.render_gitdiffs(winid)
        end
    end

    for winid, _ in pairs(dirty.search) do
        if vim.api.nvim_win_is_valid(winid) then
            M.render_search(winid)
        end
    end

    dirty.thumb = {}
    dirty.diagnostic = {}
    dirty.git = {}
    dirty.search = {}
end

local group = vim.api.nvim_create_augroup('rockyz.scrollbar', { clear = true })

vim.api.nvim_create_autocmd({ 'WinScrolled' }, {
    group = group,
    callback = function(args)
        dirty.thumb[tonumber(args.match)] = true
        schedule_flush()
    end,
})

vim.api.nvim_create_autocmd({ 'WinResized', 'BufWinEnter' }, {
    group = group,
    callback = function()
        for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if vim.api.nvim_win_get_config(winid).relative == '' then
                dirty.thumb[winid] = true
                dirty.diagnostic[winid] = true
                dirty.git[winid] = true
                dirty.search[winid] = true
            end
        end
        schedule_flush()
    end,
})

vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
    group = group,
    callback = function(args)
        local wins = vim.fn.win_findbuf(args.buf)
        for _, winid in ipairs(wins) do
            dirty.thumb[winid] = true
        end
        schedule_flush()
    end,
})

vim.api.nvim_create_autocmd({ 'DiagnosticChanged' }, {
    group = group,
    callback = function(args)
        local wins = vim.fn.win_findbuf(args.buf)
        for _, winid in ipairs(wins) do
            dirty.diagnostic[winid] = true
        end
        schedule_flush()
    end,
})

vim.api.nvim_create_autocmd({ 'User' }, {
    group = group,
    pattern = 'GitSignsUpdate',
    callback = function(args)
        local bufnr = args.data and args.data.buffer
        if not bufnr then
            return
        end
        local wins = vim.fn.win_findbuf(args.data.buffer)
        for _, winid in ipairs(wins) do
            dirty.git[winid] = true
        end
        schedule_flush()
    end,
})

vim.api.nvim_create_autocmd({ 'CmdlineLeave' }, {
    group = group,
    callback = function(args)
        local t = vim.fn.getcmdtype()
        if t ~= '/' and t ~= '?' then
            return
        end
        local wins = vim.fn.win_findbuf(args.buf)
        for _, winid in ipairs(wins) do
            dirty.search[winid] = true
            schedule_flush()
        end
    end,
})

-- Handle normal-mode * and #
local on_key_search_cursor_word = vim.api.nvim_create_namespace('rockyz.scrollbar.on_key.search_cursor_word')
vim.on_key(function(key)
    if key ~= '*' and key ~= '#' then
        return
    end
    -- defer: let Neovim finish updating @/ and v:hlsearch
    vim.schedule(function()
        if vim.v.hlsearch == 1 then
            local bufnr = vim.api.nvim_get_current_buf()
            local wins = vim.fn.win_findbuf(bufnr)
            for _, winid in ipairs(wins) do
                dirty.search[winid] = true
                schedule_flush()
            end
        end
    end)
end, on_key_search_cursor_word)

return M
