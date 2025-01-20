-- Indent scope
-- Highly inspired by mini.indentscope (https://github.com/echasnovski/mini.indentscope)
--
-- A scope consists of two parts: the body and the border.
--
-- get_scope(line) returns a table that contains the information about the scope of the line
--
-- {
--     body = {
--         top: line number of top line in scope --------|-- scope boundaries
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

local ns_id = vim.api.nvim_create_namespace('rockyz.indentscope.symbols')

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

    -- Return -1 if line is invalid, i.e., line is less than 1 and larger than vim.fn.line('$')
    return indent
end

---If the line happens to be a scope border, return the line with greater indent between the two
---adjacent lines.
---@param line number
---@return number
local function adjust_border(line)
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
---@param side string Which boundary to find, 'top' or 'bottom'
---@return number # Line number of the boundary in the specified direction
local function search_scope_boundary(line, indent, side)
    local final_line, increment = 1, -1
    if side == 'bottom' then
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

---Get the complete scope from its body
---@param body table Scope body
---@return table
local function scope_from_body(body)
    return {
        body = body,
        border = {
            -- border's top can be 0 if body's top line is line 1 and border's bottom can
            -- be vim.fn.line('$') + 1 if body's bottom line is the last line. If both
            -- case are met, border's idnent will be -1.
            top = body.top - 1,
            bottom = body.bottom + 1,
            indent = math.max(get_line_indent(body.top - 1), get_line_indent(body.bottom + 1))
        },
        buf_id = vim.api.nvim_get_current_buf(),
    }
end

---@param line number? Input line number
---@param col number?
---@return table
local function get_scope(line, col, opts)
    opts = vim.tbl_extend('force', config, opts or {})
    if not (line and col) then
        local curpos = vim.fn.getcurpos()
        line = line or curpos[2]
        line = opts.show_body_at_border and adjust_border(line) or line
        col = col or (opts.indent_at_cursor_col and curpos[5] or math.huge)
    end
    local line_indent = get_line_indent(line)
    local indent = math.min(col, line_indent)
    local body = {}
    if indent <= 0 then
        body.top, body.bottom, body.indent = 1, vim.fn.line('$'), line_indent
    else
        body.top = search_scope_boundary(line, indent, 'top')
        body.bottom = search_scope_boundary(line, indent, 'bottom')
        body.indent = indent
    end
    return scope_from_body(body)
end

---Get the indent of the scope symbol
local function get_draw_indent(scope)
    return scope.border.indent
end

---Check if two scopes are identical
---@param scope_1 table
---@param scope_2 table
---@return boolean
local function scopes_are_equal(scope_1, scope_2)
    return scope_1.buf_id == scope_2.buf_id
        and get_draw_indent(scope_1) == get_draw_indent(scope_2)
        and scope_1.body.top == scope_2.body.top
        and scope_1.body.bottom == scope_2.body.bottom
end

---Check if two scopes have intersect
---@param scope_1 table
---@param scope_2 table
---@return boolean
local function scopes_have_intersect(scope_1, scope_2)
    if scope_1.buf_id ~= scope_2.buf_id or get_draw_indent(scope_1) ~= get_draw_indent(scope_2) then
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
    local indent = get_draw_indent(scope)
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

vim.api.nvim_create_augroup('rockyz.indentscope.draw', { clear = true })
vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI', 'ModeChanged' }, {
    group = 'rockyz.indentscope.draw',
    callback = function()
        auto_draw({ lazy = true })
    end,
})
vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI', 'TextChangedP', 'WinScrolled' }, {
    group = 'rockyz.indentscope.draw',
    callback = function()
        auto_draw()
    end,
})

--
-- Motions and text objects
--
-- [i, ]i
-- * Jump to the top or bottom border of the scope where the cursor is currently located. If the
-- cursor happens to be on the border, jump to the border of the parent scope.
-- * Both support count, e.g., 2[i
--
-- ii, ai
-- * ii (inner indent) selects the scope body
-- * ai (around indent) selects the whole scope (body + border)
-- * ai supports count, e.g., v2ai
-- * Support dot-repeat in operator-pending mode
--

---Expand the current scope from either side of its border and return the new scope
---@param scope table
---@param side string From which border to expand, 'top' or 'bottom'
---@return table # The newly expanded scope
local function scope_expand(scope, side)
    local new_body = {}
    local indent = vim.fn.indent(scope.border[side])
    new_body.top = search_scope_boundary(scope.border.top, indent, 'top')
    new_body.bottom = search_scope_boundary(scope.border.bottom, indent, 'bottom')
    new_body.indent = indent
    return scope_from_body(new_body)
end

---Jump to certain side of a scope. Cursor will be placed on the first non-blank character of the
---target line
---@param scope table
---@param side string 'top' or 'bottom'
---@param include_border boolean Whether to jump to the border or just to the boundary of the scope body
local function jump_to_side(scope, side, include_border)
    scope = scope or get_scope()
    local target_line = include_border and scope.border[side] or scope.body[side]
    target_line = math.min(math.max(target_line, 1), vim.fn.line('$'))
    vim.api.nvim_win_set_cursor(0, { target_line, 0 })
    -- Move to the first non-blank character to allow next jump if count > 1
    vim.cmd('normal! ^')
end

---@param side string 'top' or 'bottom'
---@param update_jumplist boolean? Whether to add movement to jumplist
local function jump(side, update_jumplist)
    local scope = get_scope()
    if scope.border.indent < 0 then
        return
    end
    -- If the current line happens to be a border of a scope, jump to the certain side of its
    -- surrounding scope
    local cur_line = vim.fn.line('.')
    if
        cur_line == scope.border.top and side == 'top'
        or cur_line == scope.border.bottom and side == 'bottom'
    then
        scope = scope_expand(scope, side)
    end
    -- Save count because add to jumplist will reset count1 to 1
    local count = vim.v.count1
    if update_jumplist then
        vim.cmd('normal! m`')
    end
    -- Jump
    for _ = 1, count do
        jump_to_side(scope, side, true)
        -- Use `show_body_at_border = false` for continuous jump when count > 1
        scope = get_scope(nil, nil, { show_body_at_border = false })
        if get_draw_indent(scope) < 0 then
            return
        end
    end
end

local function exit_visual_mode()
    local ctrl_v = vim.api.nvim_replace_termcodes('<C-v>', true, true, true)
    local cur_mode = vim.fn.mode()
    if cur_mode == 'v' or cur_mode == 'V' or cur_mode == ctrl_v then vim.cmd('noautocmd normal! ' .. cur_mode) end
end

local function visual_select_scope(scope, include_border)
    exit_visual_mode()
    jump_to_side(scope, 'top', include_border)
    vim.cmd('normal! V')
    jump_to_side(scope, 'bottom', include_border)
end

---@param include_border boolean Whether to include the border of the scope in textobject
local function textobject(include_border)
    local scope = get_scope()
    if get_draw_indent(scope) < 0 then
        return
    end

    -- Allow count only if the textobject includes border, i.e., `ai`
    local count = include_border and vim.v.count1 or 1

    for _ = 1, count do
        visual_select_scope(scope, include_border)

        -- Use `show_body_at_border = false` for continuous jump when count > 1
        scope = get_scope(nil, nil, { show_body_at_border = false })
        if get_draw_indent(scope) < 0 then
            return
        end
    end
end

vim.keymap.set('n', '[i', function()
    jump('top', true)
end)

vim.keymap.set('n', ']i', function()
    jump('bottom', true)
end)

vim.keymap.set({ 'x', 'o' }, '[i', function()
    jump('top')
end)

vim.keymap.set({ 'x', 'o' }, ']i', function()
    jump('bottom')
end)

vim.keymap.set({ 'x', 'o' }, 'ii', function()
    textobject(false)
end)

vim.keymap.set({ 'x', 'o' }, 'ai', function()
    textobject(true)
end)

--
-- Incremental selection
--
-- <C-i> to expand
-- <M-i> to shrink
--

---Push when expand and pop when shrink
local stack = {}

---Get the line with minimal indent within the given line range
---@param s_line number Start line
---@param e_line number End line
---@return number
local function line_with_min_indent(s_line, e_line)
    local line
    local min_indent = math.huge
    for l = s_line, e_line do
        local indent = vim.fn.indent(l)
        if indent < min_indent then
            min_indent = indent
            line = l
        end
    end
    return line
end

local function incremental_selection()
    local s_line = vim.fn.line('v')
    local e_line = vim.fn.line('.')
    local min_line = line_with_min_indent(s_line, e_line)
    local scope = get_scope(min_line, nil, {
        show_body_at_border = false,
        indent_at_cursor_col = false
    })
    local select_border = false
    if s_line == scope.body.top and e_line == scope.body.bottom then
        select_border = true
    end
    visual_select_scope(scope, select_border)
    stack[#stack + 1] = { scope, select_border }
end

-- Expand
vim.keymap.set({ 'n', 'x' }, '<C-i>', function()
    -- Reset the stack when incremental selection finishes
    local group = vim.api.nvim_create_augroup('rockyz.indentscope.reset_stack', { clear = true })
    vim.api.nvim_create_autocmd('ModeChanged', {
        group = group,
        pattern = '[vV\x22]*:[ni]',
        callback = function()
            stack = {}
            vim.api.nvim_del_augroup_by_name('rockyz.indentscope.reset_stack')
        end,
    })
    incremental_selection()
end)

-- Shrink
vim.keymap.set('x', '<M-i>', function()
    stack[#stack] = nil
    local top = stack[#stack]
    if not top then
        return
    end
    visual_select_scope(unpack(top))
end)
