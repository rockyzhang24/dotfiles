-- Indent scope
-- Highly inspired by mini.indentscope (https://github.com/echasnovski/mini.indentscope)
--
-- A scope consists of two parts: the body and the border.
--
-- get_scope(line) returns a table that contains the information about the scope of the line.
-- A scope may have top and bottom border, or just one top border (e.g., the scope in python)
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

-- Global config
-- Use vim.b.indentscope_config for buffer-local config, e.g., setting border_pos to 'top' for
-- filetype python.
local config = {
    -- Position of scope's border: both, top (for python)
    border_pos = 'both',
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

local ok, icons = pcall(require, 'rockyz.icons')
local symbol_icon = ok and icons.lines.double_dash_vertical or '╎'

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

local function get_config(new_conf)
    return vim.tbl_deep_extend('force', config, vim.b.indentscope_config or {}, new_conf or {})
end

local get_blank_indent_funcs = {
    ['both'] = function(top_indent, bottom_indent)
        return math.max(top_indent, bottom_indent)
    end,
    ['top'] = function(top_indent, bottom_indent)
        return bottom_indent
    end,
}

---Get the indent (a number) of the given line. For blank line, use the greater indent of the
---nearest non-blank line above or below it.
---@param line number Input line
---@param border_pos string
---@return number
local function get_line_indent(line, border_pos)
    local pre_nonblank_line = vim.fn.prevnonblank(line)
    local indent = vim.fn.indent(pre_nonblank_line)

    -- Compute the indent of the blank line
    if line ~= pre_nonblank_line then
        local next_indent = vim.fn.indent(vim.fn.nextnonblank(line))
        indent = get_blank_indent_funcs[border_pos](indent, next_indent)
    end

    -- Return -1 if line is invalid, i.e., line is less than 1 and larger than vim.fn.line('$')
    return indent
end

local border_adjuster_funcs = {
    ---If the line happens to be a scope border, return the line with greater indent between the two
    ---adjacent lines.
    ---@param line number
    ---@param border_pos string
    ---@return number
    ['both'] = function(line, border_pos)
        local prev_indent, cur_indent, next_indent =
        get_line_indent(line - 1, border_pos), get_line_indent(line, border_pos), get_line_indent(line + 1, border_pos)
        if prev_indent <= cur_indent and next_indent <= cur_indent then
            return line
        end
        if prev_indent <= next_indent then
            return line + 1
        end
        return line - 1
    end,
    ['top'] = function(line, border_pos)
        local cur_indent, next_indent = get_line_indent(line, border_pos), get_line_indent(line + 1, border_pos)
        return (cur_indent < next_indent) and (line + 1) or line
    end,
}

---Find the boundary of the scope that the input line belongs to.
---@param line number Input line number
---@param indent number Indent of the input line
---@param side string Which boundary to find, 'top' or 'bottom'
---@param border_pos string
---@return number # Line number of the boundary in the specified direction
local function search_scope_boundary(line, indent, side, border_pos)
    local final_line, increment = 1, -1
    if side == 'bottom' then
        final_line, increment = vim.fn.line('$'), 1
    end
    for l = line, final_line, increment do
        local new_indent = get_line_indent(l + increment, border_pos)
        if new_indent < indent then
            return l
        end
    end
    return final_line
end

-- Functions to get the scope borders given a scope body
local get_border_from_body_funcs = {
    ---@param body table Scope body
    ---@param border_pos string
    ---@return table
    ['both'] = function(body, border_pos)
        return {
            -- border's top can be line 0 (i.e., the line above the first line in the buffer)
            -- if body's top line is line 1 and border's bottom can be line vim.fn.line('$') +
            -- 1 (i.e., the line below the last line in the buffer) if body's bottom line is
            -- the last line. If both case are met, border's indent will be -1.
            -- In this special case, the body of this scope is the whole buffer (body.indent
            -- is 0).
            top = body.top - 1,
            bottom = body.bottom + 1,
            indent = math.max(get_line_indent(body.top - 1, border_pos), get_line_indent(body.bottom + 1, border_pos))
        }
    end,
    ['top'] = function(body, border_pos)
        return {
            top = body.top - 1,
            indent = get_line_indent(body.top - 1, border_pos),
        }
    end,
}

---@param line number? Input line number
---@param col number?
---@param opts table?
---@return table
local function get_scope(line, col, opts)
    opts = get_config(opts)
    if not (line and col) then
        local curpos = vim.fn.getcurpos()
        line = line or curpos[2]
        line = opts.show_body_at_border and border_adjuster_funcs[opts.border_pos](line, opts.border_pos) or line
        col = col or (opts.indent_at_cursor_col and curpos[5] or math.huge)
    end
    local line_indent = get_line_indent(line, opts.border_pos)
    local indent = math.min(col, line_indent)
    local body = {}
    if indent <= 0 then
        body.top, body.bottom, body.indent = 1, vim.fn.line('$'), line_indent
    else
        body.top = search_scope_boundary(line, indent, 'top', opts.border_pos)
        body.bottom = search_scope_boundary(line, indent, 'bottom', opts.border_pos)
        body.indent = indent
    end
    return {
        body = body,
        border = get_border_from_body_funcs[opts.border_pos](body, opts.border_pos),
        buf_id = vim.api.nvim_get_current_buf(),
    }
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
    return vim.b.indentscope_enabled == false or vim.g.indentscope_enabled == false
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
    -- This function is deferred to be called. When it gets called, a buffer with indentscope
    -- disabled maybe open.
    if is_disabled() then
        return
    end
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
        virt_text = { { symbol_icon, 'IndentScopeSymbol' } },
        virt_text_win_col = col,
        virt_text_pos = 'overlay',
        virt_text_repeat_linebreak = true,
    }
    local bufnr = vim.api.nvim_get_current_buf()
    for l = scope.body.top, scope.body.bottom do
        vim.api.nvim_buf_set_extmark(bufnr, ns_id, l - 1, 0, extmark_opts)
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
        -- Expand the scope to the outer scope
        scope = get_scope(scope.border[side], nil, { show_body_at_border = false })
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
    local ctrl_v = vim.api.nvim_replace_termcodes('<C-v>', true, false, true)
    local cur_mode = vim.fn.mode()
    if cur_mode == 'v' or cur_mode == 'V' or cur_mode == ctrl_v then vim.cmd('noautocmd normal! ' .. cur_mode) end
end

---@param from string Which border the visual selecton starts from
---@param to string Which border the visual selection ends at
local function visual_select_scope(scope, from, to, include_border)
    exit_visual_mode()
    jump_to_side(scope, from, include_border)
    vim.cmd('normal! V')
    jump_to_side(scope, to, include_border)
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

        -- Try to place cursor on border
        local from, to = 'bottom', 'top'
        if include_border and scope.border.bottom == nil then
            from, to = 'bottom', 'top'
        end

        visual_select_scope(scope, from, to, include_border)

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
-- <C-,> to expand
-- <C-.> to shrink
--

---Push when expand and pop when shrink
---Top refers to the scope that is currently selected
local stack = {}

-- Reset the stack when incremental selection finishes
local group = vim.api.nvim_create_augroup('rockyz.indentscope.reset_stack', { clear = true })
vim.api.nvim_create_autocmd('ModeChanged', {
    group = group,
    pattern = '[vV\x22]*:[ni]',
    callback = function()
        stack = {}
    end,
})

local function incremental_selection()
    local curr_select = stack[#stack]
    local next_scope
    local opts = {
        show_body_at_border = false,
        indent_at_cursor_col = false
    }
    local select_border = false
    if not curr_select then
        -- Empty stack means incremental selection hasn't started yet
        next_scope = get_scope(vim.fn.line('.'), nil, opts)
    elseif not curr_select.select_border then
        -- If current selection is the body of a scope, we select this entire scope including its
        -- borders
        next_scope = vim.deepcopy(curr_select.scope)
        select_border = true
    else
        -- If current selection is already an entire scope, we select its outer scope
        local top, bottom = curr_select.scope.border.top, curr_select.scope.border.bottom
        local line = vim.fn.indent(top) < vim.fn.indent(bottom) and top or bottom
        next_scope = get_scope(line, nil, opts)
    end
    -- Skip the special case where the body of the scope is the entire buffer
    if next_scope.border.indent < 0 then
        return
    end
    visual_select_scope(next_scope, 'top', 'bottom', select_border)
    stack[#stack + 1] = { scope = next_scope, select_border = select_border } -- push
end

-- Expand
vim.keymap.set({ 'n', 'x' }, '<C-,>', function()
    incremental_selection()
end)

-- Shrink
vim.keymap.set('x', '<C-.>', function()
    if #stack < 2 then
        return
    end
    stack[#stack] = nil -- pop
    local top = stack[#stack] -- peek
    visual_select_scope(top.scope, 'top', 'bottom', top.select_border)
end)

-- Exclude filetypes
local disabled_filetypes = {
    'floggraph',
    'fugitive',
    'fzf',
    'git',
    'help',
    'man',
    'minpac',
    'minpacprgs',
    'Outline',
    'tagbar',
    'term',
    'undotree',
}
vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('rockyz.indentscope.exclude', { clear = true }),
    callback = function(arg)
        local ft = vim.bo[arg.buf].filetype
        if vim.list_contains(disabled_filetypes, ft) then
            vim.b[arg.buf].indentscope_enabled = false
        end
    end,
})
