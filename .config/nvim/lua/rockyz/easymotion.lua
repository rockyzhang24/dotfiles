-- Reference: https://antonk52.github.io/webdevandstuff/post/2025-11-30-diy-easymotion.html

local ns = vim.api.nvim_create_namespace('rockyz.easymotion.labels')
-- Characters to use as labels. Note: we only use the letters from lower to upper case in ascending
-- order of how easy to type them in qwerty layout
local chars = vim.split('fjdkslgha;rueiwotyqpvbcnxmzFJDKSLGHARUEIWOTYQPVBCNXMZ', '')

local function easy_motion()
    local char1 = vim.fn.nr2char( vim.fn.getchar() --[[@as number]] )
    local char2 = vim.fn.nr2char( vim.fn.getchar() --[[@as number]] )
    local line_idx_start, line_idx_end = vim.fn.line('w0'), vim.fn.line('w$')
    local bufnr = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

    -- to keep track of labels to use
    local char_idx = 1
    ---@type table<string, {line: integer, col: integer, id: integer}> Dictionary of extmarks so we can refer back to picked location, from label char to location
    local extmarks = {}
    -- lines on the screen
    local lines = vim.api.nvim_buf_get_lines(bufnr, line_idx_start - 1, line_idx_end, false)

    local needle = char1 .. char2
    local is_case_sensitive = needle ~= string.lower(needle)

    for lines_i, line_text in ipairs(lines) do
        if not is_case_sensitive then
            line_text = string.lower(line_text)
        end
        local line_idx = lines_i + line_idx_start - 1
        -- Skip folded lines
        if vim.fn.foldclosed(line_idx) == -1 then
            for i = 1, #line_text do
                -- Once we find a match, put an extmark there
                if line_text:sub(i, i + 1) == needle and char_idx <= #chars then
                    local overlay_char = chars[char_idx]
                    local linenr = line_idx_start + lines_i - 2
                    local col = i - 1
                    -- `col + 2` to place the extmark after the match
                    local id = vim.api.nvim_buf_set_extmark(bufnr, ns, linenr, col + 2, {
                        virt_text = { { overlay_char, 'CurSearch' } },
                        virt_text_pos = 'overlay',
                        hl_mode = 'replace',
                    })
                    -- save the extmark info for quick jumping
                    extmarks[overlay_char] = { line = linenr, col = col, id = id }
                    char_idx = char_idx + 1
                    if char_idx > #chars then
                        goto break_outer
                    end
                end
            end
        end
    end
    ::break_outer::

    vim.schedule(function()
        local next_char = vim.fn.nr2char(vim.fn.getchar() --[[@as number]])
        if extmarks[next_char] then
            local pos = extmarks[next_char]
            -- to make <C-o> work
            vim.cmd("normal! m'")
            vim.api.nvim_win_set_cursor(0, { pos.line + 1, pos.col })
        end
        vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
    end)
end

vim.keymap.set({ 'n', 'x' }, 's', easy_motion)
