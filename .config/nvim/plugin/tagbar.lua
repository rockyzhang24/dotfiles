local icons = require('rockyz.icons')

vim.g.tagbar_width = 50
vim.g.tagbar_autofocus = 1
vim.g.tagbar_sort = 0 -- sorted by order
vim.g.tagbar_compact = 2 -- don't show the help at the top
vim.g.tagbar_show_data_type = 1
vim.g.tagbar_scrolloff = 3
vim.g.tagbar_iconchars = {
    icons.caret.right,
    icons.caret.down,
}

vim.keymap.set('n', 'yot', '<Cmd>TagbarToggle<CR>')
vim.keymap.set('n', '[t', '<Cmd>TagbarJumpPrev<CR>')
vim.keymap.set('n', ']t', '<Cmd>TagbarJumpNext<CR>')

-- Usages:
-- 1. Show help: ?
-- 2. Switch sorting between by name and by file order: pressing "s" in tagbar window
-- 3. Jump to the tag under the cursor, but stay in tagbar window: p
-- 4. Go to the next or previous top-level tag: <C-n>, <C-p>
-- 5. Normal fold functions work in tagbar window
