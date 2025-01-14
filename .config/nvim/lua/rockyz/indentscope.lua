-- Indent scope
-- Highly inspired by mini.indentscope (https://github.com/echasnovski/mini.indentscope)
--
-- A scope consists of two parts: the body and the border.
--
-- get_scope(line) returns a table that contains the information about the scope of the line
--
-- {
--     body = {
--         top: line number of top line in scope --------|__ scope boundaries
--         bottom: line number of bottom line in scope --|
--         indent: minimum indent within the scope
--     },
--     border = {
--         top: line number of top border
--         bottom: line number of bottom border
--         indent: indent of the border
--     },
-- }
--
-- Example: cursor is at line3, represented by `#`.
--
-- 1| function bar()      <-- border.top
-- 2|                     <-- body.top
-- 3|     p#rint('hello')
-- 4|                     <-- body.bottom
-- 5| end                 <-- border.bottom
--

local config = {
    -- Symbol priority. Increase to display on top of more symbols.
    priority = 2,
    -- Delay (in ms) between event and start of drawing scope indicator
    delay = 100,
    --
    -- When the cursor is on the line that happens to be the border of a scope, display that
    -- scope instead of the scope the line itself belongs to.
    -- For example, when the cursor is on a function header, display the function body instead
    -- of the scope the function header line belongs to.
    --
    -- For example:
    --
    -- 1  function foo()
    -- 2      fun#ction bar()
    -- 3      |
    -- 4      |   print('hello')
    -- 5      |
    -- 6      end
    -- 7  end
    --
    -- Cursor is at line2 (denoted by `#`) on the function header. The indent scope is from line3 to
    -- line5, not from line2 to line6.
    --
    show_body_at_border = true,
    --
    -- Show the indent scope based on the column where the cursor is located, not just its line
    --
    -- For example, if `indent_at_cursor_col` is true
    --
    -- 1  function foo()
    -- 2  |   function bar()
    -- 3  |
    -- 4  | #     print('hello')
    -- 5  |
    -- 6  |   end
    -- 7  end
    --
    -- If `indent_at_cursor_col` is false
    --
    -- 1  function foo()
    -- 2      fun|ction bar()
    -- 3      |
    -- 4    # |   print('hello')
    -- 5      |
    -- 6      end
    -- 7  end
    --
    indent_at_cursor_col = true,
}

local symbol = require('rockyz.icons').lines.indentscope

local ns_id = vim.api.nvim_create_namespace('rockyz_indentscope')

local current = {
    -- Rendering has two steps: undraw the old scope line and draw the new scope. As the cursor
    -- moves aground, the renderings are scheduled by vim.defer_fn. Only the most recently scheduled
    -- rendering event will be executed; those scheduled before it will not be executed. Each
    -- rendering is assigned an unique id, which is used to determine whether the rendering event
    -- being executing is the most recent one or not.
    event_id = 0,
    -- The scope that has currently been rendered
    scope = {
    },
    -- 'none' or 'finished'
    draw_status = 'none',
}

---Get the indent (a number) of the given line. For blank line, use the greater indent of the
---nearest non-blank line above or below it.
---@param line number Input line
---@return number
local function get_line_indent(line)
    local pre_nonblank_line = vim.fn.prevnonblank(line)
    local indent = vim.fn.indent(pre_nonblank_line)

    -- Compute the indent of the blank line
    if line ~= pre_nonblank_line then
        local next_indent = vim.fn.indent(vim.fn.nextnonblank(line))
        indent = math.max(indent, next_indent)
    end

    return indent
end

---If the line happens to be a scope border, return the line with greater indent between the two
---adjacent lines.
---@param line number
---@return number
local function line_corrector(line)
    local prev_indent, cur_indent, next_indent =
        get_line_indent(line - 1), get_line_indent(line), get_line_indent(line + 1)
    if prev_indent <= cur_indent and next_indent <= cur_indent then
        return line
    end
    if prev_indent <= next_indent then
        return line + 1
    end
    return line - 1
end

---Find the boundary of the scope that the input line belongs to.
---@param line number Input line number
---@param indent number Indent of the input line
---@param direction string Search direction from the input line, either 'up' or 'down'
---@return number # Line number of the boundary in the specified direction
local function search_scope_boundary(line, indent, direction)
    local final_line, increment = 1, -1
    if direction == 'down' then
        final_line, increment = vim.fn.line('$'), 1
    end
    for l = line, final_line, increment do
        local new_indent = get_line_indent(l + increment)
        if new_indent < indent then
            return l
        end
    end
    return final_line
end

---@param line number? Input line number
---@param col number?
---@return table
local function get_scope(line, col)
    if not (line and col) then
        local curpos = vim.fn.getcurpos()
        line = line or curpos[2]
        line = config.show_body_at_border and line_corrector(line) or line
        col = col or (config.indent_at_cursor_col and curpos[5] or math.huge)
    end
    local line_indent = get_line_indent(line)
    local indent = math.min(col, line_indent)
    local body = {}
    if indent <= 0 then
        body.top, body.bottom, body.indent = 1, vim.fn.line('$'), line_indent
    else
        body.top = search_scope_boundary(line, indent, 'up')
        body.bottom = search_scope_boundary(line, indent, 'down')
        body.indent = indent
    end
    return {
        body = body,
        border = {
            top = body.top - 1,
            bottom = body.bottom + 1,
            indent = math.max(get_line_indent(body.top - 1), get_line_indent(body.bottom + 1))
        },
        buf_id = vim.api.nvim_get_current_buf(),
        reference = {
            line = line,
            column = col,
            indent = indent,
        },
    }
end

---Check if two scopes are identical
---@param scope_1 table
---@param scope_2 table
---@return boolean
local function scopes_are_equal(scope_1, scope_2)
    return scope_1.buf_id == scope_2.buf_id
        and scope_1.border.indent == scope_2.border.indent
        and scope_1.body.top == scope_2.body.top
        and scope_1.body.bottom == scope_2.body.bottom
end

---Check if two scopes have intersect
---@param scope_1 table
---@param scope_2 table
---@return boolean
local function scopes_have_intersect(scope_1, scope_2)
    if scope_1.buf_id ~= scope_2.buf_id or scope_1.border.indent ~= scope_2.border.indent then
        return false
    end
    local body_1, body_2 = scope_1.body, scope_2.body
    return (body_2.top <= body_1.top and body_1.top <= body_2.bottom)
        or (body_1.top <= body_2.top and body_2.top <= body_1.bottom)
end

---Check whether or not displaying indent scope is enabled globally/buffer-locally
local function is_disabled()
    return not vim.g.indentscope_enabled and not vim.b.indentscope_enabled
end

local function undraw_scope(opts)
    opts = opts or {}
    if opts.event_id and opts.event_id ~= current.event_id then
        return
    end
    pcall(vim.api.nvim_buf_clear_namespace, current.scope.buf_id or 0, ns_id, 0, -1)
    current.draw_status = 'none'
    current.scope = {}
end

local function draw_scope(scope, opts)
    scope = scope or {}
    opts = opts or {}
    local indent = scope.border.indent
    if indent < 0 then
        return
    end
    local col = indent - vim.fn.winsaveview().leftcol
    if col < 0 then
        return
    end
    local extmark_opts = {
        hl_mode = 'combine',
        priority = config.priority,
        right_gravity = false,
        virt_text = { { symbol, 'IndentScopeSymbol' } },
        virt_text_win_col = col,
        virt_text_pos = 'overlay',
        virt_text_repeat_linebreak = true,
    }
    for l = scope.body.top, scope.body.bottom do
        vim.api.nvim_buf_set_extmark(vim.api.nvim_get_current_buf(), ns_id, l - 1, 0, extmark_opts)
    end
    current.draw_status = 'finished'
end

local function auto_draw(opts)
    if is_disabled() then
        undraw_scope()
        return
    end

    opts = opts or {}
    local scope = get_scope()

    if opts.lazy and current.draw_status ~= 'none' and scopes_are_equal(scope, current.scope) then
        return
    end

    local local_event_id = current.event_id + 1
    current.event_id = local_event_id

    local draw_opts = {
        event_id = current.event_id,
        delay = config.delay,
    }
    if scopes_have_intersect(scope, current.scope) then
        draw_opts.delay = 0
    end

    if draw_opts.delay > 0 then
        undraw_scope(draw_opts)
    end

    vim.defer_fn(function()
        -- This rendering is obsolete (i.e., it's not the most recently scheduled one)
        if current.event_id ~= local_event_id then
            return
        end
        undraw_scope(draw_opts)
        current.scope = scope
        draw_scope(scope, draw_opts)
    end, draw_opts.delay)
end

vim.api.nvim_create_augroup('rockyz/indentscope', { clear = true })
vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI', 'ModeChanged' }, {
    group = 'rockyz/indentscope',
    callback = function()
        auto_draw({ lazy = true })
    end,
})
vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI', 'TextChangedP', 'WinScrolled' }, {
    group = 'rockyz/indentscope',
    callback = function()
        auto_draw()
    end,
})
