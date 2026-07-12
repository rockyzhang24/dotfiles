-- Display scrollbar in each window.
-- The scrollbar gutter is implemented using a floating window, and the thumb is drawn with extmarks.

-- NOTE:
-- To make scrollbar rendering as accurate as possible, we should use screen lines, not buffer
-- lines, because scrolling is done in units of screen lines, not buffer lines. When wrap is
-- enabled, a single buffer line may correspond to multiple screen lines; similarly, folds affect
-- screen lines rather than buffer lines; virtual text may also insert additional screen lines.
--
-- However, the API for obtaining screen-line counts, vim.api.nvim_win_text_height, has poor
-- performance because each call requires iterating over every line in the range. Therefore, to
-- maximize performance, we compromise by using buffer lines instead.

-- How do we calculate the scrollbar's size and position?
--
-- First, let's calculate two necessary metrics: viewport_height and buf_content_height.
-- (1) viewport_height = win_height - winbar_height. Viewport height is the number of lines that
-- display the actual content in the current window.
-- (2) buf_line_count is the total number of lines in the entire buffer.
--
-- We use the following proportional relationship to calculate the thumb size:
-- thumb_size / viewport_height = viewport_height / buf_line_count
-- ==> thumb_size = (viewport_height / buf_line_count) * viewport_height
--
-- Next, let's calculate the scrollbar's position (i.e., the line number in the viewport where the
-- top of the scrollbar is located). We need three more metrics: max_thumb_move, max_scroll, and
-- top_buffer_line.
-- (1) max_thumb_move = viewport_height - thumb_size. It is the maximum number of lines the thumb
-- can move.
-- (2) max_scroll = buf_line_count - viewport_height. It is the maximum number of lines the whole
-- buffer can scroll.
-- (3) top_buffer_line is the first buffer line in the current viewport.
--
-- We have the following proportional relationship:
-- position / max_thumb_move = top_buffer_line / max_scroll. Therefore,
-- position = (max_thumb_move / max_scroll) * top_buffer_line
--
-- We need to simplify it. Let's set V = viewport_height, B = buf_line_count, S = thumb_size. So
-- thumb_size = V^2 / B, max_thumb_move = V - V^2 / B, max_scroll = B - V. So
-- position = (V - V^2 / B) / (B - V) * top_buffer_line
--          = V / B * top_buffer_line
-- That is,
-- position = (viewport_height / buf_line_count) * top_buffer_line
--
-- How do we calculate the position of a diagnostic?
--
-- First, we should get the screen line of a given diagnostic. Then, just like calculating the
-- scrollbar's position, we use the following proportional relationship:
-- position / max_thumb_move = diagnostic_lnum / max_scroll. Therefore,
-- position = (max_thumb_move / max_scroll) * diagnostic_lnum
--
-- Similarly, the simplified result is
-- position = (viewport_height / buf_line_count) * diagnostic_lnum
--
-- How do we calculate the position of a Git diff or search result?
--
-- Similarly, position = (viewport_height / buf_line_count) * lnum

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
        TerminalPanel = true, -- the side panel of my own terminal module (./terminal.lua)
    },
    diagnostic = {
        symbol = icons.block.right_middle_half,
        hl = {
            'ScrollbarDiagnosticError',
            'ScrollbarDiagnosticWarn',
            'ScrollbarDiagnosticInfo',
            'ScrollbarDiagnosticHint',
        },
    },
    gitdiff = {
        symbol = icons.block.left_one_quarter,
        hl = {
            add = 'ScrollbarDiffAdded',
            change = 'ScrollbarDiffChanged',
            delete = 'ScrollbarDiffDeleted',
        },
    },
    search = {
        symbol = icons.block.right_middle_half,
        hl = 'ScrollbarSearch',
    },
}

---Scrollbar state associated with a specific window
---@class rockyz.scrollbar.State
---@field winid? integer Scrollbar floating-window ID
---@field bufnr? integer Scrollbar buffer ID
---@field last_viewport_height? integer Cached viewport height
---@field last_scrollbar_column? integer Cached scrollbar column
---@field is_enabled? boolean Whether the scrollbar is enabled for this window

local thumb_ns = vim.api.nvim_create_namespace('rockyz.scrollbar.thumb')
local diagnostic_ns = vim.api.nvim_create_namespace('rockyz.scrollbar.diagnostic')
local gitdiff_ns = vim.api.nvim_create_namespace('rockyz.scrollbar.gitdiff')
local search_ns = vim.api.nvim_create_namespace('rockyz.scrollbar.search')

local SCROLLBAR_WIDTH = 3

---Return whether the scrollbar should render for a window
---@param winid integer
---@return boolean
local function should_render(winid)
    local state = vim.w[winid].scrollbar_state
    if state and not state.is_enabled then
        return false
    end
    local win_config = vim.api.nvim_win_get_config(winid)
    if win_config.relative ~= '' then
        return false
    end
    local target_bufnr = vim.api.nvim_win_get_buf(winid)
    if config.exclude_filetypes[vim.bo[target_bufnr].filetype] then
        return false
    end
    return true
end

---Return the number of screen lines available for buffer content
---@param winid integer
---@return integer
local function get_viewport_height(winid)
    local viewport_height = vim.api.nvim_win_get_height(winid)
    if vim.wo[winid].winbar ~= '' then
        viewport_height = viewport_height - 1
    end
    return viewport_height
end

---Clamp a thumb size to the configured bounds
---@param thumb_size integer
---@param winid integer
---@return integer
local function clamp_thumb_size(thumb_size, winid)
    local viewport_height = get_viewport_height(winid)
    local max_size = math.min(config.max_size or viewport_height, viewport_height)
    local min_size = math.min(config.min_size, max_size)

    return math.max(min_size, math.min(max_size, thumb_size))
end

---Fill a scrollbar buffer with blank lines for extmark rendering
---@param bufnr integer
---@param line_count integer
local function ensure_valid_buffer(bufnr, line_count)
    local lines = {}
    for _ = 1, line_count do
        lines[#lines + 1] = string.rep(' ', SCROLLBAR_WIDTH)
    end
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
end

---Create and initialize a scrollbar buffer
---@param line_count integer
---@return integer bufnr
local function create_scrollbar_buffer(line_count)
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.bo[bufnr].filetype = 'scrollbar'
    ensure_valid_buffer(bufnr, line_count)
    return bufnr
end

---Clear a namespace from a window's scrollbar buffer.
---@param winid? integer
---@param ns integer
local function clear_extmarks(winid, ns)
    winid = winid or vim.api.nvim_get_current_win()
    local state = vim.w[winid].scrollbar_state
    if not state or not state.bufnr or not vim.api.nvim_buf_is_valid(state.bufnr) then
        return
    end
    vim.api.nvim_buf_clear_namespace(state.bufnr, ns, 0, -1)
end

---Ensure the scrollbar floating window exists and is up-to-date.
---
---This function creates the scrollbar buffer and floating window if they do not exist, or updates
---the window geometry (height and col) when the viewport changes.
---
---After this function returns true, the scrollbar window is guaranteed to be valid and correctly
---positioned. Other components (e.g., thumb, diagnostics, git, search matches, etc) can then be
---rendered their content into the scrollbar buffer via extmarks.
---@param winid? integer Target window ID
---@return boolean # If the essential floating window and the buffer are ready to use
local function ensure_scrollbar(winid)
    winid = winid or vim.api.nvim_get_current_win()
    local win_config = vim.api.nvim_win_get_config(winid)
    -- Ignore floating windows
    if win_config.relative ~= '' then
        return false
    end

    ---@type rockyz.scrollbar.State
    local state = vim.w[winid].scrollbar_state or {}

    local viewport_height = get_viewport_height(winid)
    if viewport_height < 1 then
        return false
    end

    if not state.bufnr or not vim.api.nvim_buf_is_valid(state.bufnr) then
        state.bufnr = create_scrollbar_buffer(viewport_height)
        vim.api.nvim_create_autocmd({ 'WinClosed' }, {
            pattern = '' .. winid,
            once = true,
            callback = function()
                if vim.api.nvim_buf_is_valid(state.bufnr) then
                    vim.api.nvim_buf_delete(state.bufnr, { force = true })
                end
            end,
        })
    end

    local width = vim.api.nvim_win_get_width(winid)
    local col = width - SCROLLBAR_WIDTH - config.right_offset

    local win_opts = {
        style = 'minimal',
        relative = 'win',
        win = winid,
        width = SCROLLBAR_WIDTH,
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
        if vim.api.nvim_buf_line_count(state.bufnr) < viewport_height then
            ensure_valid_buffer(state.bufnr, viewport_height)
        end
        if viewport_height ~= state.last_viewport_height or col ~= state.last_scrollbar_column then
            vim.api.nvim_win_set_config(state.winid, win_opts)
        end
    end

    state.last_viewport_height = viewport_height
    state.last_scrollbar_column = col
    state.is_enabled = true
    vim.w[winid].scrollbar_state = state
    return true
end

---Render the scrollbar thumb for a window
---@param winid? integer
function M.render_thumb(winid)
    winid = winid or vim.api.nvim_get_current_win()
    local state = vim.w[winid].scrollbar_state

    local target_bufnr = vim.api.nvim_win_get_buf(winid)
    local buffer_line_count = vim.api.nvim_buf_line_count(target_bufnr)
    local viewport_height = get_viewport_height(winid)

    -- Calculate the scrollbar's thumb size
    local thumb_size = math.ceil(viewport_height * viewport_height / buffer_line_count)
    thumb_size = clamp_thumb_size(thumb_size, winid)

    -- Calculate the scrollbar's position
    local top_buffer_line = vim.fn.line('w0', winid) - 1 -- 0-indexed

    local thumb_position -- 0-indexed
    if viewport_height >= buffer_line_count then
        thumb_position = 0
    else
        thumb_position = math.floor(top_buffer_line * viewport_height / buffer_line_count)
        -- It shouldn't be less than zero (viewport_height maybe less than thumb_size)
        thumb_position = math.max(math.min(thumb_position, viewport_height - thumb_size), 0)
    end

    clear_extmarks(winid, thumb_ns)

    vim.api.nvim_buf_set_extmark(state.bufnr, thumb_ns, thumb_position, 0, {
        end_row = thumb_position + thumb_size,
        virt_text = { { string.rep(' ', SCROLLBAR_WIDTH), config.thumb_hl } },
        virt_text_pos = 'overlay',
        hl_group = config.thumb_hl,
        priority = 10,
    })
end

---Render diagnostic markers for a window
---@param winid? integer
function M.render_diagnostics(winid)
    winid = winid or vim.api.nvim_get_current_win()

    local target_bufnr = vim.api.nvim_win_get_buf(winid)
    local diagnostics = vim.diagnostic.get(target_bufnr)

    local viewport_height = get_viewport_height(winid)
    local buffer_line_count = vim.api.nvim_buf_line_count(target_bufnr)

    ---On each row only display the diagnostic with the lowest severity
    ---@type table<integer, integer> Maps each scrollbar row to its most severe diagnostic
    local severity_by_row = {}
    for _, diagnostic in ipairs(diagnostics) do
        local diagnostic_row -- 0-indexed
        if viewport_height >= buffer_line_count then
            diagnostic_row = diagnostic.lnum
        else
            diagnostic_row = math.floor(diagnostic.lnum * viewport_height / buffer_line_count)
            -- Sometimes when a diagnostic is on the last line, diagnostic.lnum is
            -- buffer_line_count. It should be buffer_line_count - 1, but I don’t know why. As
            -- a result, diagnostic_row ends up being equal to viewport_height instead of viewport_height
            -- - 1.
            diagnostic_row = math.min(diagnostic_row, viewport_height - 1)
        end

        if not severity_by_row[diagnostic_row] or diagnostic.severity < severity_by_row[diagnostic_row] then
            severity_by_row[diagnostic_row] = diagnostic.severity
        end
    end

    -- Abort rendering only when diagnostics were produced for an older buffer state.
    -- An absent changedtick means there is no stale state to reject.
    local diagnostic_changedtick = vim.b[target_bufnr].scrollbar_diagnostic_changedtick
    if
        diagnostic_changedtick
        and diagnostic_changedtick ~= vim.api.nvim_buf_get_changedtick(target_bufnr)
    then
        return
    end

    clear_extmarks(winid, diagnostic_ns)

    local state = vim.w[winid].scrollbar_state
    local scrollbar_buffer_line_count = vim.api.nvim_buf_line_count(state.bufnr)
    for row, severity in pairs(severity_by_row) do
        -- Ensure extmarks never exceed the scrollbar buffer when the buffer shrinks during setting
        -- them.
        if row >= 0 and row < scrollbar_buffer_line_count then
            vim.api.nvim_buf_set_extmark(state.bufnr, diagnostic_ns, row, 2, {
                virt_text = { { config.diagnostic.symbol, config.diagnostic.hl[severity] } },
                virt_text_pos = 'overlay',
                hl_mode = 'combine',
                priority = 20,
            })
        end
    end
end

local git_diff_priority = { add = 1, change = 2, delete = 3 }

---Render Git diff markers for a window
---@param winid? integer
function M.render_git(winid)
    winid = winid or vim.api.nvim_get_current_win()
    local target_bufnr = vim.api.nvim_win_get_buf(winid)
    local git_hunks = gitsigns.get_hunks(target_bufnr)

    ---@type table<integer, string> Maps each scrollbar line to its highest-priority Git change type
    local change_type_by_line = {}

    ---@param line_number integer 1-indexed buffer line number
    ---@param change_type 'add'|'change'|'delete'
    local function record_git_mark(line_number, change_type)
        local viewport_height = get_viewport_height(winid)
        local buffer_line_count = vim.api.nvim_buf_line_count(target_bufnr)

        local scrollbar_line_number -- 1-indexed
        if viewport_height >= buffer_line_count then
            scrollbar_line_number = line_number
        else
            scrollbar_line_number = math.ceil(line_number * viewport_height / buffer_line_count)
        end

        if
            not change_type_by_line[scrollbar_line_number]
            or git_diff_priority[change_type_by_line[scrollbar_line_number]] < git_diff_priority[change_type]
        then
            change_type_by_line[scrollbar_line_number] = change_type
        end
    end

    for _, hunk in ipairs(git_hunks or {}) do
        if hunk.type == 'add' or hunk.type == 'change' then
            for line_offset = 0, hunk.added.count - 1 do
                local line_number = hunk.added.start + line_offset
                record_git_mark(line_number, hunk.type)
            end
        elseif hunk.type == 'delete' then
            local line_number = math.max(hunk.removed.start - 1, 1)
            record_git_mark(line_number, hunk.type)
        end
    end

    -- Abort rendering only when Git diffs were produced for an older buffer state.
    -- An absent changedtick means there is no stale state to reject.
    local git_changedtick = vim.b[target_bufnr].scrollbar_git_changedtick
    if git_changedtick and git_changedtick ~= vim.api.nvim_buf_get_changedtick(target_bufnr) then
        return
    end

    clear_extmarks(winid, gitdiff_ns)

    local state = vim.w[winid].scrollbar_state
    local scrollbar_buffer_line_count = vim.api.nvim_buf_line_count(state.bufnr)
    for line, change_type in pairs(change_type_by_line) do
        local row = line - 1
        -- Ensure extmarks never exceed the scrollbar buffer when the buffer shrinks during setting
        -- them.
        if row >= 0 and row < scrollbar_buffer_line_count then
            vim.api.nvim_buf_set_extmark(state.bufnr, gitdiff_ns, row, 0, {
                virt_text = { { config.gitdiff.symbol, config.gitdiff.hl[change_type] } },
                virt_text_pos = 'overlay',
                hl_mode = 'combine',
                priority = 20,
            })
        end
    end
end

---Render search-result markers for a window.
---@param winid? integer
function M.render_search(winid)
    winid = winid or vim.api.nvim_get_current_win()
    local target_bufnr = vim.api.nvim_win_get_buf(winid)
    local search_pattern = vim.fn.getreg('/')

    if search_pattern == '' or vim.v.hlsearch == 0 then
        clear_extmarks(winid, search_ns)
        return
    end

    local viewport_height = get_viewport_height(winid)
    local buffer_line_count = vim.api.nvim_buf_line_count(target_bufnr)

    ---@type table<integer, boolean> Matching 1-indexed buffer line numbers
    local matching_line_numbers = {}

    vim.api.nvim_win_call(winid, function()
        local saved_cursor_position = vim.fn.getpos('.')
        vim.fn.cursor(1, 1)
        while vim.fn.search(search_pattern, 'W') ~= 0 do
            local line_number = vim.fn.line('.') -- 1-indexed
            matching_line_numbers[line_number] = true
        end
        vim.fn.setpos('.', saved_cursor_position)
    end)

    clear_extmarks(winid, search_ns)

    local state = vim.w[winid].scrollbar_state
    local scrollbar_buffer_line_count = vim.api.nvim_buf_line_count(state.bufnr)

    for line_number in pairs(matching_line_numbers) do
        local scrollbar_line_number -- 1-indexed

        if viewport_height >= buffer_line_count then
            scrollbar_line_number = line_number
        else
            scrollbar_line_number = math.ceil(line_number * viewport_height / buffer_line_count)
        end

        local row = scrollbar_line_number - 1

        if row >= 0 and row < scrollbar_buffer_line_count then
            vim.api.nvim_buf_set_extmark(state.bufnr, search_ns, row, 1, {
                virt_text = { { config.search.symbol, config.search.hl } },
                virt_text_pos = 'overlay',
                hl_mode = 'combine',
                priority = 20,
            })
        end
    end
end

---Clear search markers from all windows displaying the current buffer
function M.clear_search()
    local current_bufnr = vim.api.nvim_get_current_buf()
    local winids = vim.fn.win_findbuf(current_bufnr)
    for _, winid in ipairs(winids) do
        clear_extmarks(winid, search_ns)
    end
end

local function create_dirty_component_sets()
    return {
        thumb = {},
        diagnostic = {},
        git = {},
        search = {},
    }
end

-- Per-component sets of windows (i.e., winids) that require scrollbar updates
local dirty = create_dirty_component_sets()

local function mark_all_components_dirty(winid)
    dirty.thumb[winid] = true
    dirty.diagnostic[winid] = true
    dirty.git[winid] = true
    dirty.search[winid] = true
end

-- Mapping from scrollbar components to their render functions
local renders = {
    thumb = M.render_thumb,
    diagnostic = M.render_diagnostics,
    git = M.render_git,
    search = M.render_search,
}

local timer
local debounce_delay_ms = 30

local function ensure_timer()
    if timer and not timer:is_closing() then
        return
    end
    timer = vim.uv.new_timer()
end

-- Debounce rendering across rapid events
local function schedule_flush()
    ensure_timer()
    timer:stop()
    timer:start(debounce_delay_ms, 0, vim.schedule_wrap(function()
        if
            not next(dirty.thumb)
            and not next(dirty.diagnostic)
            and not next(dirty.git)
            and not next(dirty.search)
        then
            return
        end

        M.flush()
    end))
end

---Render all dirty scrollbar components.
function M.flush()
    local dirty_components = dirty
    dirty = create_dirty_component_sets()

    for component, dirty_winids in pairs(dirty_components) do
        local render_component = renders[component]
        if render_component then
            for winid in pairs(dirty_winids) do
                if vim.api.nvim_win_is_valid(winid) and should_render(winid) then
                    -- Ensure the scrollbar's buffer and floating window exist and are correctly sized
                    -- before rendering other components on it.
                    if ensure_scrollbar(winid) then
                        render_component(winid)
                    end
                end
            end
        end
    end
end

---Disable the scrollbar for a window
---@param winid? integer
function M.disable(winid)
    winid = winid or vim.api.nvim_get_current_win()
    if not vim.api.nvim_win_is_valid(winid) then
        return
    end

    local state = vim.w[winid].scrollbar_state
    if not state or not state.is_enabled then
        return
    end

    if state.winid and vim.api.nvim_win_is_valid(state.winid) then
        vim.api.nvim_win_close(state.winid, true)
    end

    if state.bufnr and vim.api.nvim_buf_is_valid(state.bufnr) then
        vim.api.nvim_buf_delete(state.bufnr, { force = true })
    end

    state.is_enabled = false
    state.winid = nil
    state.bufnr = nil
    vim.w[winid].scrollbar_state = state
end

---Enable the scrollbar for a window
---@param winid? integer
function M.enable(winid)
    winid = winid or vim.api.nvim_get_current_win()
    if not vim.api.nvim_win_is_valid(winid) then
        return
    end

    local state = vim.w[winid].scrollbar_state
    if state == nil or state.is_enabled then
        return
    end

    state.is_enabled = true
    vim.w[winid].scrollbar_state = state

    mark_all_components_dirty(winid)

    schedule_flush()
end

local scrollbar_augroup = vim.api.nvim_create_augroup('rockyz.scrollbar', { clear = true })

vim.api.nvim_create_autocmd({ 'WinResized', 'BufWinEnter' }, {
    group = scrollbar_augroup,
    callback = function()
        for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if vim.api.nvim_win_get_config(winid).relative == '' then
                mark_all_components_dirty(winid)
            end
        end
        schedule_flush()
    end,
})

vim.api.nvim_create_autocmd({ 'WinScrolled' }, {
    group = scrollbar_augroup,
    callback = function(event)
        local winid = tonumber(event.match)
        if winid then
            dirty.thumb[winid] = true
        end
        schedule_flush()
    end,
})

vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
    group = scrollbar_augroup,
    callback = function(event)
        local winids = vim.fn.win_findbuf(event.buf)
        for _, winid in ipairs(winids) do
            dirty.thumb[winid] = true
        end
        schedule_flush()
    end,
})

vim.api.nvim_create_autocmd({ 'DiagnosticChanged' }, {
    group = scrollbar_augroup,
    callback = function(event)
        local target_bufnr = event.buf
        -- Record the buffer changedtick at the moment diagnostics are updated.
        -- Used to ensure we only render diagnostics for the same buffer state.
        vim.b[target_bufnr].scrollbar_diagnostic_changedtick = vim.api.nvim_buf_get_changedtick(target_bufnr)
        local winids = vim.fn.win_findbuf(target_bufnr)
        for _, winid in ipairs(winids) do
            dirty.diagnostic[winid] = true
        end
        schedule_flush()
    end,
})

-- After opening a buffer in a window, clear diagnostic markers. DiagnosticChanged does not trigger
-- when the buffer has no diagnostics.
vim.api.nvim_create_autocmd({ 'BufWinEnter' }, {
    group = scrollbar_augroup,
    callback = function()
        clear_extmarks(0, diagnostic_ns)
    end,
})

vim.api.nvim_create_autocmd({ 'User' }, {
    group = scrollbar_augroup,
    pattern = 'GitSignsUpdate',
    callback = function(event)
        local target_bufnr = event.data and event.data.buffer
        if not target_bufnr then
            return
        end
        -- Record the changedtick when Git diffs are updated
        -- Use it to render diffs only for the same buffer state
        vim.b[target_bufnr].scrollbar_git_changedtick = vim.api.nvim_buf_get_changedtick(target_bufnr)
        local winids = vim.fn.win_findbuf(target_bufnr)
        for _, winid in ipairs(winids) do
            dirty.git[winid] = true
        end
        schedule_flush()
    end,
})

vim.api.nvim_create_autocmd({ 'CmdlineLeave' }, {
    group = scrollbar_augroup,
    callback = function(event)
        local command_type = vim.fn.getcmdtype()
        if command_type ~= '/' and command_type ~= '?' then
            return
        end
        local winids = vim.fn.win_findbuf(event.buf)
        for _, winid in ipairs(winids) do
            dirty.search[winid] = true
        end
        schedule_flush()
    end,
})

local function mark_search_dirty()
    local current_bufnr = vim.api.nvim_get_current_buf()
    local winids = vim.fn.win_findbuf(current_bufnr)
    for _, winid in ipairs(winids) do
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
    group = scrollbar_augroup,
    callback = function()
        if vim.v.hlsearch == 1 and vim.fn.getreg('/') ~= '' then
            mark_search_dirty()
        end
    end,
})

return M
