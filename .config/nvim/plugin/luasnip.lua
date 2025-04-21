-- An offcial example to demo the basic config and how to create snippets:
-- https://github.com/L3MON4D3/LuaSnip/blob/master/Examples/snippets.lua

local luasnip = require('luasnip')
local types = require('luasnip.util.types')

luasnip.setup({
    history = true,
    delete_check_events = 'TextChanged',
    update_events = 'TextChanged, TextChangedI',
    region_check_events = 'CursorHold',
    enable_autosnippets = true,
    store_selection_keys = '<TAB>',
    ext_opts = {
        [types.choiceNode] = {
            active = {
                virt_text = { { '(snippet) choice node', 'LspInlayHint' } },
            },
            -- unvisited = {
            --     virt_text = { { '|', 'Conceal' } },
            --     virt_text_pos = 'inline',
            -- },
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
    if luasnip.expand_or_jumpable() then
        return '<Cmd>lua require("luasnip").expand_or_jump()<CR>'
    elseif vim.snippet.active({ direction = 1 }) then
        -- For builtin snippet
        return '<Cmd>lua vim.snippet.jump(1)<CR>'
    else
        return '<C-j>'
    end
end, { expr = true })

-- Jump to the previous item within the snippet
vim.keymap.set({ 'i', 's' }, '<C-k>', function()
    if luasnip.jumpable(-1) then
        return '<Cmd>lua require("luasnip").jump(-1)<CR>'
    elseif vim.snippet.active({ direction = -1 }) then
        -- For builtin snippet
        return '<Cmd>lua vim.snippet.jump(-1)<CR>'
    else
        return '<C-k>'
    end
end, { expr = true })

-- Change the choice in current choiceNode
vim.keymap.set({ 'i', 's' }, '<C-l>', function()
    if luasnip.choice_active() then
        return '<Cmd>lua require("luasnip").change_choice(1)<CR>'
    else
        return '<C-l>'
    end
end, { expr = true })
vim.keymap.set({ 'i', 's' }, '<C-h>', function()
    if luasnip.choice_active() then
        return '<Cmd>lua require("luasnip").change_choice(-1)<CR>'
    else
        return '<C-h>'
    end
end, { expr = true })
-- Open a picker to select a choice in current choiceNode
vim.keymap.set({ 'i', 's' }, '<C-c>', function()
    if luasnip.choice_active() then
        return '<Cmd>lua require("luasnip.extras.select_choice")()<CR>'
    else
        return '<C-c>'
    end
end, { expr = true })

-- Insert on-the-fly snippet previously stored in register s
vim.keymap.set('i', '<C-r>s', function()
    require('luasnip.extras.otf').on_the_fly('s')
end)

-- Cancel the snippet session when the cursor is out of the scope of the snippet
-- Ref: https://github.com/L3MON4D3/LuaSnip/issues/656#issuecomment-1407098013
vim.api.nvim_create_autocmd('CursorMovedI', {
    group = vim.api.nvim_create_augroup('rockyz.luasnip.unlink_snippet', { clear = true }),
    pattern = '*',
    callback = function(ev)
        if not luasnip.session or not luasnip.session.current_nodes[ev.buf] or luasnip.session.jump_active then
            return
        end

        local current_node = luasnip.session.current_nodes[ev.buf]
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
            luasnip.unlink_current()
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
