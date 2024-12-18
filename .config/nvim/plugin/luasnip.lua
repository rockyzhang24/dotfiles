-- An offcial example to demo the basic config and how to create snippets:
-- https://github.com/L3MON4D3/LuaSnip/blob/master/Examples/snippets.lua

local ls = require('luasnip')
local types = require('luasnip.util.types')

ls.setup({
    history = true,
    delete_check_events = 'TextChanged',
    update_events = 'TextChanged, TextChangedI',
    region_check_events = 'CursorHold',
    enable_autosnippets = true,
    store_selection_keys = '<TAB>',
    ext_opts = {
        [types.choiceNode] = {
            -- active = {
            --     virt_text = { { '|', 'Operator' } },
            --     virt_text_pos = 'inline',
            -- },
            unvisited = {
                virt_text = { { '|', 'Conceal' } },
                virt_text_pos = 'inline',
            },
        },
        [types.insertNode] = {
            -- active = {
            --     virt_text = { { '|', 'Keyword' } },
            --     virt_text_pos = 'inline',
            -- },
            unvisited = {
                virt_text = { { '|', 'Conceal' } },
                virt_text_pos = 'inline',
            },
        },
        [types.exitNode] = {
            unvisited = {
                virt_text = { { '|', 'Conceal' } },
                virt_text_pos = 'inline',
            },
        },
    },
})

-- Expand the current item or jump to the next item within the snippet.
vim.keymap.set({ 'i', 's' }, '<C-j>', function()
    if ls.expand_or_jumpable() then
        ls.expand_or_jump()
    end
end)

-- Jump to the previous item within the snippet
vim.keymap.set({ 'i', 's' }, '<C-k>', function()
    if ls.jumpable(-1) then
        ls.jump(-1)
    end
end)

-- Change the choice in current choiceNode
vim.keymap.set({ 'i', 's' }, '<C-l>', function()
    if ls.choice_active() then
        ls.change_choice(1)
    end
end)
vim.keymap.set({ 'i', 's' }, '<C-h>', function()
    if ls.choice_active() then
        ls.change_choice(-1)
    end
end)
-- Open a picker to select a choice in current choiceNode
vim.keymap.set({ 'i', 's' }, '<C-c>', function()
    if ls.choice_active() then
        require('luasnip.extras.select_choice')()
    end
end)

-- Insert on-the-fly snippet previously stored in register s
vim.keymap.set('i', '<C-r>s', function()
    require('luasnip.extras.otf').on_the_fly('s')
end)

-- Cancel the snippet session when leaving insert mode
-- Ref: https://github.com/L3MON4D3/LuaSnip/issues/656#issuecomment-1407098013
vim.api.nvim_create_autocmd('CursorMovedI', {
    group = vim.api.nvim_create_augroup('rockyz/unlink_snippet', { clear = true }),
    pattern = '*',
    callback = function(ev)
        if not ls.session or not ls.session.current_nodes[ev.buf] or ls.session.jump_active then
            return
        end

        local current_node = ls.session.current_nodes[ev.buf]
        local current_start, current_end = current_node:get_buf_position()
        current_start[1] = current_start[1] + 1 -- (1, 0) indexed
        current_end[1] = current_end[1] + 1 -- (1, 0) indexed
        local cursor = vim.api.nvim_win_get_cursor(0)

        if
            cursor[1] < current_start[1]
            or cursor[1] > current_end[1]
            or cursor[2] < current_start[2]
            or cursor[2] > current_end[2]
        then
            ls.unlink_current()
        end
    end,
})

-- Load my custom snippets
require('luasnip.loaders.from_lua').lazy_load({
    paths = { vim.fn.stdpath('config') .. '/luasnippets' },
})
require('luasnip.loaders.from_vscode').lazy_load({
    paths = { vim.fn.stdpath('config') .. '/codesnippets' },
})

-- Create a command to edit the snippet file associated with the current
-- filetype type
vim.api.nvim_create_user_command(
    'SnipEdit',
    ':lua require("luasnip.loaders").edit_snippet_files()',
    {}
)
