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
    exclude_filetypes = { -- e.g., outline = true
        term = true,
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

---Scrollbar state associated with a specific window
---@class rockyz.scrollbar.State
---@field winid integer The winid of the scrollbar's floating window
---@field bufnr integer The bufnr of the scrollbar's buffer
---@field last_viewport_height integer Cached viewport height
---@field last_win_col integer Cached column of the scrollbar's floating window
---@field is_enabled boolean Whether the scrollbar is enabled for this window

local thumb_ns = vim.api.nvim_create_namespace('rockyz.scrollbar.thumb')
local diagnostic_ns = vim.api.nvim_create_namespace('rockyz.scrollbar.diagnostic')
local gitdiff_ns = vim.api.nvim_create_namespace('rockyz.scrollbar.gitdiff')
local search_ns = vim.api.nvim_create_namespace('rockyz.scrollbar.search')

local scrollbar_width = 3

local function should_render(winid)
    local state = vim.w[winid].scrollbar_state
    if state and not state.is_enabled then
        return false
    end
    local win_config = vim.api.nvim_win_get_config(winid)
    if win_config.relative ~= '' then
        return false
    end
    local bufnr = vim.api.nvim_win_get_buf(winid)
    if config.exclude_filetypes[vim.bo[bufnr].filetype] then
        return false
    end
    return true
end

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

---Ensure the scrollbar floating window exists and is up-to-date.
---This function creates the scrollbar buffer and floating window if they do not exist, or updates
---the window geometry (height and col) when the viewport changes.
---After this function returns, the scrollbar window is guaranteed to be valid and correctly
---positioned. Other components (e.g., thumb, diagnostics, git, search matches, etc) can then be
---rendered their content into the scrollbar buffer via extmarks.
---@param winid? integer The winid of the floating window where the scrollbar resides
local function ensure_scrollbar(winid)
    winid = winid or vim.api.nvim_get_current_win()
    local win_config = vim.api.nvim_win_get_config(winid)
    -- Ignore floating window
    if win_config.relative ~= '' then
        return
    end

    ---@type rockyz.scrollbar.State
    local state = vim.w[winid].scrollbar_state or {}

    local viewport_height = get_viewport_height(winid)

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
        zindex = 20,
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
    state.is_enabled = true
    vim.w[winid].scrollbar_state = state
end

function M.render_thumb(winid)
    winid = winid or vim.api.nvim_get_current_win()
    local state = vim.w[winid].scrollbar_state

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
        local position -- 0-indexed
        if viewport_height >= buf_line_count then
            position = d.lnum
        else
            position = math.floor(d.lnum * viewport_height / buf_line_count)
            -- Sometimes when a diagnostic is on the last line, d.lnum is buf_line_count. It should be
            -- buf_line_count - 1, but I don’t know why. As a result, position ends up being equal
            -- to viewport_height instead of viewport_height - 1.
            position = math.min(position, viewport_height - 1)
        end

        if not marks[position] or d.severity < marks[position] then
            marks[position] = d.severity
        end
    end

    -- Abort rendering if the buffer has changed since diagnostics were produced to avoid drawing
    -- stale or out-of-range extmarks.
    if vim.b[bufnr].scrollbar_diagnostic_changedtick ~= vim.api.nvim_buf_get_changedtick(bufnr) then
        return
    end

    clear_extmarks(winid, diagnostic_ns)

    local state = vim.w[winid].scrollbar_state
    local sb_lines = vim.api.nvim_buf_line_count(state.bufnr)
    for line, severity in pairs(marks) do
        -- Ensure extmarks never exceed the scrollbar buffer when the buffer shrinks during setting
        -- them.
        if line >= 0 and line < sb_lines then
            vim.api.nvim_buf_set_extmark(state.bufnr, diagnostic_ns, line, 2, {
                virt_text = { { config.diagnostic.symbol, config.diagnostic.hl[severity] } },
                virt_text_pos = 'overlay',
                hl_mode = 'combine',
                priority = 20,
            })
        end
    end
end

local gitdiff_priority = { add = 1, change = 2, delete = 3 }

function M.render_git(winid)
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

    -- Abort if the buffer has changed since git diffs were update (stale hunk data)
    if vim.b[bufnr].scrollbar_git_changedtick ~= vim.api.nvim_buf_get_changedtick(bufnr) then
        return
    end

    clear_extmarks(winid, gitdiff_ns)

    local state = vim.w[winid].scrollbar_state
    local sb_lines = vim.api.nvim_buf_line_count(state.bufnr)
    for line, type in pairs(marks) do
        local row = line - 1
        -- Ensure extmarks never exceed the scrollbar buffer when the buffer shrinks during setting
        -- them.
        if row >=0 and row < sb_lines then
            vim.api.nvim_buf_set_extmark(state.bufnr, gitdiff_ns, row, 0, {
                virt_text = { { config.gitdiff.symbol, config.gitdiff.hl[type] } },
                virt_text_pos = 'overlay',
                hl_mode = 'combine',
                priority = 20,
            })
        end
    end
end

function M.render_search(winid)
    winid = winid or vim.api.nvim_get_current_win()
    local bufnr = vim.api.nvim_win_get_buf(winid)
    local pat = vim.fn.getreg('/')
    if pat == '' or vim.v.hlsearch == 0 then
        return
    end
    local viewport_height = get_viewport_height(winid)
    local buf_line_count = vim.api.nvim_buf_line_count(bufnr)
    local lnums = {}
    vim.api.nvim_win_call(winid, function()
        local save = vim.fn.getpos('.')
        vim.fn.cursor(1, 1)
        while vim.fn.search(pat, 'W') ~= 0 do
            local lnum = vim.fn.line('.') -- 1-indexed
            lnums[lnum] = true
        end
        vim.fn.setpos('.', save)
    end)

    clear_extmarks(winid, search_ns)

    local state = vim.w[winid].scrollbar_state
    local sb_lines = vim.api.nvim_buf_line_count(state.bufnr)
    for lnum, _ in pairs(lnums) do
        local position -- 1-indexed
        if viewport_height >= buf_line_count then
            position = lnum
        else
            position = math.ceil(lnum * viewport_height / buf_line_count)
        end
        local row = position - 1
        if row >= 0 and row < sb_lines then
            vim.api.nvim_buf_set_extmark(state.bufnr, search_ns, row, 1, {
                virt_text = { { config.search.symbol, config.search.hl } },
                virt_text_pos = 'overlay',
                hl_mode = 'combine',
                priority = 20,
            })
        end
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

-- Per-component sets of windows (i.e., winids) that require scrollbar updates
local dirty = {
    thumb = {},
    diagnostic = {},
    git = {},
    search = {},
}

-- Mapping from scrollbar components to their render functions
local renders = {
    thumb = M.render_thumb,
    diagnostic = M.render_diagnostics,
    git = M.render_git,
    search = M.render_search,
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
    timer:start(debounce_ms, 0, vim.schedule_wrap(function()
        if
            not next(dirty.thumb)
            and not next(dirty.diagnostic)
            and not next(dirty.git)
            and not next(dirty.search)
        then
            return
        end
        require('rockyz.scrollbar').flush()
    end))
end

function M.flush()
    for component, wins in pairs(dirty) do
        local render = renders[component]
        if render then
            for winid, _ in pairs(wins) do
                if vim.api.nvim_win_is_valid(winid) and should_render(winid) then
                    -- Ensure the scrollbar's buffer and floating window exist and are correctly sized
                    -- before rendering other components on it.
                    ensure_scrollbar(winid)
                    render(winid)
                end
            end
        end
    end

    dirty.thumb = {}
    dirty.diagnostic = {}
    dirty.git = {}
    dirty.search = {}
end

-- Disable the scrollbar of the given window
function M.disable(winid)
    winid = winid or vim.api.nvim_get_current_win()
    if not vim.api.nvim_win_is_valid(winid) then
        return
    end
    local state = vim.w[winid].scrollbar_state
    vim.api.nvim_win_close(state.winid, true)
    vim.api.nvim_buf_delete(state.bufnr, { force = true })
    state.is_enabled = false
    state.winid = nil
    state.bufnr = nil
    vim.w[winid].scrollbar_state = state
end

-- Enable the scrollbar of the given window
function M.enable(winid)
    winid = winid or vim.api.nvim_get_current_win()
    local state = vim.w[winid].scrollbar_state
    if state == nil or state.is_enabled then
        return
    end
    state.is_enabled = true
    vim.w[winid].scrollbar_state = state

    dirty.thumb[winid] = true
    dirty.diagnostic[winid] = true
    dirty.git[winid] = true
    dirty.search[winid] = true

    schedule_flush()
end

local group = vim.api.nvim_create_augroup('rockyz.scrollbar', { clear = true })

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

vim.api.nvim_create_autocmd({ 'WinScrolled' }, {
    group = group,
    callback = function(args)
        dirty.thumb[tonumber(args.match)] = true
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
        local bufnr = args.buf
        -- Record the buffer changedtick at the moment diagnostics are updated.
        -- Used to ensure we only render diagnostics for the same buffer state.
        vim.b[bufnr].scrollbar_diagnostic_changedtick = vim.api.nvim_buf_get_changedtick(bufnr)
        local wins = vim.fn.win_findbuf(bufnr)
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
        -- Record the buffer changedtick at the moment the git diffs are updated.
        -- Used to ensure we only render git diffs for the same buffer state.
        vim.b[bufnr].scrollbar_git_changedtick = vim.api.nvim_buf_get_changedtick(bufnr)
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

local function mark_search_dirty()
    local bufnr = vim.api.nvim_get_current_buf()
    local wins = vim.fn.win_findbuf(bufnr)
    for _, winid in ipairs(wins) do
        dirty.search[winid] = true
    end
    schedule_flush()
end

-- Handle normal-mode * and #
local on_key_search_cursor_word = vim.api.nvim_create_namespace('rockyz.scrollbar.on_key.search_cursor_word')
vim.on_key(function(key)
    if key ~= '*' and key ~= '#' then
        return
    end
    -- defer: let Neovim finish updating @/ and v:hlsearch
    vim.schedule(mark_search_dirty)
end, on_key_search_cursor_word)

-- Handle n and N
vim.api.nvim_create_autocmd({ 'CursorMoved' }, {
    group = group,
    callback = function()
        if vim.v.hlsearch == 1 and vim.fn.getreg('/') ~= '' then
            mark_search_dirty()
        end
    end,
})

return M
