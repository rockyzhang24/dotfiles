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

vim.g.tagbar_map_help = '?'
vim.g.tagbar_map_preview = '<C-Enter>'
vim.g.tagbar_map_previewwin = 'p'
vim.g.tagbar_map_nexttag = 'J'
vim.g.tagbar_map_prevtag = 'K'
vim.g.tagbar_map_showproto = '<Space>'
vim.g.tagbar_map_hidenonpublic = 'v'
vim.g.tagbar_map_openfold = 'zo'
vim.g.tagbar_map_closefold = 'zc'
vim.g.tagbar_map_togglefold = 'za'
vim.g.tagbar_map_openallfolds = 'zR'
vim.g.tagbar_map_closeallfolds = 'zM'
vim.g.tagbar_map_incrementfolds = 'zr'
vim.g.tagbar_map_decrementfolds = 'zm'
vim.g.tagbar_map_nextfold = 'zj'
vim.g.tagbar_map_prevfold = 'zk'
vim.g.tagbar_map_togglesort = 's'
vim.g.tagbar_map_toggleautoclose = ''
vim.g.tagbar_map_togglepause = ''
vim.g.tagbar_map_zoomwin = 'm'
vim.g.tagbar_map_close = 'q'

vim.keymap.set('n', 'yot', '<Cmd>TagbarToggle<CR>')
vim.keymap.set('n', '[t', '<Cmd>TagbarJumpPrev<CR>')
vim.keymap.set('n', ']t', '<Cmd>TagbarJumpNext<CR>')

-- Usages:
-- 1. Show help: ?
-- 2. Switch sorting between by name and by file order: pressing "s" in tagbar window
-- 3. Jump to the tag under the cursor, but stay in tagbar window: p
-- 4. Go to the next or previous top-level tag: <C-n>, <C-p>
-- 5. Normal fold functions work in tagbar window
