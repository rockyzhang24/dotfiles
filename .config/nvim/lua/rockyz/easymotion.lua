-- Reference: https://antonk52.github.io/webdevandstuff/post/2025-11-30-diy-easymotion.html

local label_ns = vim.api.nvim_create_namespace('rockyz.easymotion.labels')
-- Characters to use as labels. Note: we only use the letters from lower to upper case in ascending
-- order of how easy to type them in qwerty layout
local label_chars = vim.split('fjdkslgha;rueiwotyqpvbcnxmzFJDKSLGHARUEIWOTYQPVBCNXMZ', '')

---@return string
local function getcharstr()
    local char = vim.fn.getchar()
    if type(char) == 'number' then
        return vim.fn.nr2char(char)
    end
    return char
end

local function easy_motion()
    local first_char = getcharstr()
    local second_char = getcharstr()

    local first_visible_line = vim.fn.line('w0')
    local last_visible_line = vim.fn.line('w$')
    local bufnr = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_clear_namespace(bufnr, label_ns, 0, -1)

    -- Keep track of labels to use
    local label_idx = 1
    ---@type table<string, {line: integer, col: integer}>
    local label_positions = {}
    -- Lines on the screen
    local lines = vim.api.nvim_buf_get_lines(bufnr, first_visible_line - 1, last_visible_line, false)

    local needle = first_char .. second_char
    local is_case_sensitive = needle ~= string.lower(needle)

    if not is_case_sensitive then
        needle = string.lower(needle)
    end

    for lines_i, line_text in ipairs(lines) do
        if not is_case_sensitive then
            line_text = string.lower(line_text)
        end
        local line_idx = lines_i + first_visible_line - 1
        -- Skip folded lines
        if vim.fn.foldclosed(line_idx) == -1 then
            for i = 1, #line_text do
                -- Once we find a match, put an extmark there
                if line_text:sub(i, i + 1) == needle and label_idx <= #label_chars then
                    local overlay_char = label_chars[label_idx]
                    local linenr = first_visible_line + lines_i - 2
                    local col = i - 1
                    -- `col + 2` to place the extmark after the match
                    vim.api.nvim_buf_set_extmark(bufnr, label_ns, linenr, col + 2, {
                        virt_text = { { overlay_char, 'CurSearch' } },
                        virt_text_pos = 'overlay',
                        hl_mode = 'replace',
                    })
                    -- Save the label position for quick jumping
                    label_positions[overlay_char] = { line = linenr, col = col }
                    label_idx = label_idx + 1
                    if label_idx > #label_chars then
                        goto break_outer
                    end
                end
            end
        end
    end
    ::break_outer::

    if vim.tbl_isempty(label_positions) then
        return
    end

    vim.schedule(function()
        local next_char = getcharstr()
        if label_positions[next_char] then
            local pos = label_positions[next_char]
            -- Make <C-o> work
            vim.cmd("normal! m'")
            vim.api.nvim_win_set_cursor(0, { pos.line + 1, pos.col })
        end
        vim.api.nvim_buf_clear_namespace(bufnr, label_ns, 0, -1)
    end)
end

vim.keymap.set({ 'n', 'x' }, 's', easy_motion)
