vim.g.no_plugin_maps = true

require('nvim-treesitter-textobjects').setup({
    select = {
        lookahead = true,
        include_surrounding_whitespace = false,
    },
    move = {
        set_jumps = true,
    },
})

-- Select

local select_textobject = require('nvim-treesitter-textobjects.select').select_textobject

vim.keymap.set({ 'x', 'o' }, 'aa', function()
    select_textobject('@parameter.outer')
end)
vim.keymap.set({ 'x', 'o' }, 'ia', function()
    select_textobject('@parameter.inner')
end)
vim.keymap.set({ 'x', 'o' }, 'af', function()
    select_textobject('@function.outer')
end)
vim.keymap.set({ 'x', 'o' }, 'if', function()
    select_textobject('@function.inner')
end)
vim.keymap.set({ 'x', 'o' }, 'ax', function() -- x for execute
    select_textobject('@call.outer')
end)
vim.keymap.set({ 'x', 'o' }, 'ix', function()
    select_textobject('@call.inner')
end)
vim.keymap.set({ 'x', 'o' }, 'aj', function() -- j for judge
    select_textobject('@conditional.outer')
end)
-- Used to select the boolean expression of the current if
--   - If the cursor is at the very beginning of the if, use vij directly
--   - If the cursor is inside the if block, use [jvij
vim.keymap.set({ 'x', 'o' }, 'ij', function()
    select_textobject('@conditional.inner')
end)
vim.keymap.set({ 'x', 'o' }, 'ao', function()
    select_textobject('@loop.outer')
end)
vim.keymap.set({ 'x', 'o' }, 'io', function()
    select_textobject('@loop.inner')
end)

-- Move

local move = require('nvim-treesitter-textobjects.move')

vim.keymap.set({ 'n', 'x',  'o' }, '[p', function()
    move.goto_previous_start('@parameter.inner')
end)
vim.keymap.set({ 'n', 'x',  'o' }, ']p', function()
    move.goto_next_start('@parameter.inner')
end)
vim.keymap.set({ 'n', 'x',  'o' }, '[f', function()
    move.goto_previous_start('@function.outer')
end)
vim.keymap.set({ 'n', 'x',  'o' }, ']f', function()
    move.goto_next_start('@function.outer')
end)
vim.keymap.set({ 'n', 'x',  'o' }, '[x', function()
    move.goto_previous_start('@call.outer')
end)
vim.keymap.set({ 'n', 'x',  'o' }, ']x', function()
    move.goto_next_start('@call.outer')
end)
vim.keymap.set({ 'n', 'x',  'o' }, '[j', function()
    move.goto_previous_start('@conditional.outer', 'textobjects')
end)
vim.keymap.set({ 'n', 'x',  'o' }, ']j', function()
    move.goto_next_start('@conditional.outer', 'textobjects')
end)
vim.keymap.set({ 'n', 'x',  'o' }, '[o', function()
    move.goto_previous_start('@loop.outer', 'textobjects')
end)
vim.keymap.set({ 'n', 'x',  'o' }, ']o', function()
    move.goto_next_start('@loop.outer', 'textobjects')
end)

-- Repeatable

local repeat_move = require('nvim-treesitter-textobjects.repeatable_move')

vim.keymap.set({ 'n', 'x', 'o' }, ';', repeat_move.repeat_last_move)
vim.keymap.set({ 'n', 'x', 'o' }, ',', repeat_move.repeat_last_move_opposite)

vim.keymap.set({ 'n', 'x', 'o' }, 'f', repeat_move.builtin_f_expr, { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, 'F', repeat_move.builtin_F_expr, { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, 't', repeat_move.builtin_t_expr, { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, 'T', repeat_move.builtin_T_expr, { expr = true })
