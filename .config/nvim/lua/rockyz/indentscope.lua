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

-- Default config
-- Use vim.b.indentscope_config for buffer-local config, e.g., setting border_pos to 'top' for
-- filetype python.
local default_config = {
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

local namespace = vim.api.nvim_create_namespace('rockyz.indentscope.symbols')

local current = {
    -- Rendering is deferred to avoid redrawing on every cursor event. Each scheduled render gets an
    -- id; when it runs, it is skipped if a newer render has already been scheduled.
    event_id = 0,
    -- The scope that has currently been rendered
    scope = {},
    -- Whether a scope is currently rendered
    is_drawn = false,
}

local function get_config(new_conf)
    return vim.tbl_deep_extend('force', vim.deepcopy(default_config), vim.b.indentscope_config or {}, new_conf or {})
end

local blank_indent_resolvers = {
    ['both'] = function(top_indent, bottom_indent)
        return math.max(top_indent, bottom_indent)
    end,
    ['top'] = function(top_indent, bottom_indent)
        return bottom_indent
    end,
}

---Get the effective indent of a line .
---For blank lines, derive the indent from adjacent non-blank lines according to `border.pos`.
---For example, if `border.pos = 'both'`, use the greater indent of the adjacent non-blank lines.
---Returns -1 when the requested side has no adjacent non-blank line.
---@param line integer Input line
---@param border_pos string
---@return integer
local function get_line_indent(line, border_pos)
    local prev_nonblank_line = vim.fn.prevnonblank(line)
    local indent = vim.fn.indent(prev_nonblank_line)

    -- Compute the indent of the blank line
    if line ~= prev_nonblank_line then
        local next_indent = vim.fn.indent(vim.fn.nextnonblank(line))
        indent = blank_indent_resolvers[border_pos](indent, next_indent)
    end

    -- `vim.fn.indent(0)` returns -1 when prevnonblank()/nextnonblank() finds no line.
    return indent
end

local border_line_resolvers = {
    ---If the line happens to be a scope border, return the line with greater indent between the two
    ---adjacent lines.
    ---@param line integer
    ---@param border_pos string
    ---@return integer
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
---@param line integer Input line number
---@param indent integer Indent of the input line
---@param side string Which boundary to find, 'top' or 'bottom'
---@param border_pos string
---@return integer # Line number of the boundary in the specified direction
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
local border_resolvers = {
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

---@param line? integer Input line number. Defaults to the cursor line.
---@param col? integer Input column. Defaults to the cursor column only when using the cursor line.
---@param opts? table
---@return table
local function get_scope(line, col, opts)
    opts = get_config(opts)

    if not (line and col) then
        local curpos = vim.fn.getcurpos()
        line = line or curpos[2]
        line = opts.show_body_at_border and border_line_resolvers[opts.border_pos](line, opts.border_pos) or line
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
        border = border_resolvers[opts.border_pos](body, opts.border_pos),
        bufnr = vim.api.nvim_get_current_buf(),
        winid = vim.api.nvim_get_current_win(),
    }
end

---Get the indent column where the scope symbol should be drawn.
---@param scope table
---@return integer
local function get_symbol_indent(scope)
    return scope.border.indent
end

---Check if two scopes are identical
---@param scope_1 table
---@param scope_2 table
---@return boolean
local function scopes_are_equal(scope_1, scope_2)
    return scope_1.bufnr == scope_2.bufnr
        and get_symbol_indent(scope_1) == get_symbol_indent(scope_2)
        and scope_1.body.top == scope_2.body.top
        and scope_1.body.bottom == scope_2.body.bottom
end

---Check whether two scopes overlap on the same drawn indent column
---@param scope_1 table
---@param scope_2 table
---@return boolean
local function scopes_overlap(scope_1, scope_2)
    if scope_1.bufnr ~= scope_2.bufnr or get_symbol_indent(scope_1) ~= get_symbol_indent(scope_2) then
        return false
    end
    local body_1, body_2 = scope_1.body, scope_2.body
    return (body_2.top <= body_1.top and body_1.top <= body_2.bottom)
        or (body_1.top <= body_2.top and body_2.top <= body_1.bottom)
end

---Check whether indent scope is disabled globally or for a given buffer
---@param bufnr? integer
---@return boolean
local function is_indentscope_disabled(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    return vim.b[bufnr].indentscope_enabled == false or vim.g.indentscope_enabled == false
end

local function undraw_scope(opts)
    opts = opts or {}
    if opts.event_id and opts.event_id ~= current.event_id then
        return
    end
    pcall(vim.api.nvim_buf_clear_namespace, current.scope.bufnr or 0, namespace, 0, -1)
    current.is_drawn = false
    current.scope = {}
end

local function draw_scope(scope, opts)
    scope = scope or {}
    opts = opts or {}

    -- This function runs later via vim.defer_fn(); by then, the source buffer may be invalid or
    -- disabled.
    if
        not scope.bufnr
        or not vim.api.nvim_buf_is_valid(scope.bufnr)
        or is_indentscope_disabled(scope.bufnr)
    then
        return
    end

    if
        not scope.winid
        or not vim.api.nvim_win_is_valid(scope.winid)
        or vim.api.nvim_win_get_buf(scope.winid) ~= scope.bufnr
    then
        return
    end

    local indent = get_symbol_indent(scope)
    if indent < 0 then
        return
    end

    local leftcol = vim.api.nvim_win_call(scope.winid, function()
        return vim.fn.winsaveview().leftcol
    end)

    local col = indent - leftcol
    if col < 0 then
        return
    end

    local extmark_opts = {
        hl_mode = 'combine',
        priority = opts.priority,
        right_gravity = false,
        virt_text = { { symbol_icon, 'IndentScopeSymbol' } },
        virt_text_win_col = col,
        virt_text_pos = 'overlay',
        virt_text_repeat_linebreak = true,
    }
    local bufnr = scope.bufnr
    for l = scope.body.top, scope.body.bottom do
        vim.api.nvim_buf_set_extmark(bufnr, namespace, l - 1, 0, extmark_opts)
    end
    current.is_drawn = true
end

local function auto_draw(opts)
    if is_indentscope_disabled() then
        undraw_scope()
        return
    end

    opts = opts or {}
    local conf = get_config()
    local scope = get_scope(nil, nil, conf)

    if opts.lazy and current.is_drawn and scopes_are_equal(scope, current.scope) then
        return
    end

    local render_id = current.event_id + 1
    current.event_id = render_id

    local draw_opts = {
        event_id = current.event_id,
        delay = conf.delay,
        priority = conf.priority,
    }
    if scopes_overlap(scope, current.scope) then
        draw_opts.delay = 0
    end

    if draw_opts.delay > 0 then
        undraw_scope(draw_opts)
    end

    vim.defer_fn(function()
        -- This rendering is obsolete (i.e., it's not the most recently scheduled one)
        if current.event_id ~= render_id then
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
    local target_line = include_border and scope.border[side] or nil
    target_line = target_line or scope.body[side]
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
    local current_line = vim.fn.line('.')
    if
        current_line == scope.border.top and side == 'top'
        or current_line == scope.border.bottom and side == 'bottom'
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
        if get_symbol_indent(scope) < 0 then
            return
        end
    end
end

local function exit_visual_mode()
    local ctrl_v = vim.api.nvim_replace_termcodes('<C-v>', true, false, true)
    local current_mode = vim.fn.mode()
    if current_mode == 'v' or current_mode == 'V' or current_mode == ctrl_v then
        vim.cmd('noautocmd normal! ' .. current_mode)
    end
end

---@param from string Which border the visual selection starts from
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

    if get_symbol_indent(scope) < 0 then
        return
    end

    -- Allow count only if the textobject includes border, i.e., `ai`
    local count = include_border and vim.v.count1 or 1

    for _ = 1, count do

        -- Try to place cursor on border
        local from, to = 'top', 'bottom'
        if include_border and scope.border.bottom == nil then
            from, to = 'bottom', 'top'
        end

        visual_select_scope(scope, from, to, include_border)

        -- Use `show_body_at_border = false` for continuous jump when count > 1
        scope = get_scope(nil, nil, { show_body_at_border = false })
        if get_symbol_indent(scope) < 0 then
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

---Selection history used by incremental expand/shrink.
---The top entry represents the currently selected scope.
local selection_stack = {}

-- Reset the selection stack when incremental selection finishes
local group = vim.api.nvim_create_augroup('rockyz.indentscope.reset_selection_stack', { clear = true })
vim.api.nvim_create_autocmd('ModeChanged', {
    group = group,
    pattern = '[vV\x22]*:[ni]',
    callback = function()
        selection_stack = {}
    end,
})

local function incremental_selection()
    local current_selection = selection_stack[#selection_stack]
    local next_scope
    local opts = {
        show_body_at_border = false,
        indent_at_cursor_col = false,
    }
    local include_border = false
    if not current_selection then
        -- Empty stack means incremental selection hasn't started yet
        next_scope = get_scope(vim.fn.line('.'), nil, opts)
    elseif not current_selection.include_border then
        -- If current selection is the body of a scope, we select this entire scope including its
        -- borders
        next_scope = vim.deepcopy(current_selection.scope)
        include_border = true
    else
        -- If current selection is already an entire scope, we select its outer scope
        local top, bottom = current_selection.scope.border.top, current_selection.scope.border.bottom
        local line = top
        if bottom then
            line = vim.fn.indent(top) < vim.fn.indent(bottom) and top or bottom
        end
        next_scope = get_scope(line, nil, opts)
    end
    -- Skip the special case where the body of the scope is the entire buffer
    if next_scope.border.indent < 0 then
        return
    end
    visual_select_scope(next_scope, 'top', 'bottom', include_border)
    selection_stack[#selection_stack + 1] = { scope = next_scope, include_border = include_border } -- push
end

-- Expand
vim.keymap.set({ 'n', 'x' }, '<C-,>', function()
    incremental_selection()
end)

-- Shrink
vim.keymap.set('x', '<C-.>', function()
    if #selection_stack < 2 then
        return
    end
    selection_stack[#selection_stack] = nil -- pop
    local top = selection_stack[#selection_stack] -- peek
    visual_select_scope(top.scope, 'top', 'bottom', top.include_border)
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
    'pager', -- vim._core.ui2
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
