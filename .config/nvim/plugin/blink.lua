local kind_icons = require('rockyz.icons').symbol_kinds

require('blink.cmp').setup({
    keymap = {
        ['<C-Enter>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-e>'] = { 'cancel', 'fallback' },
        ['<C-\\>'] = { 'hide', 'fallback' },
        ['<C-y>'] = { 'select_and_accept' },

        ['<C-p>'] = {
            function(cmp)
                if cmp.is_visible() then
                    cmp.select_prev()
                else
                    cmp.show()
                end
            end,
        },
        ['<C-n>'] = {
            function(cmp)
                if cmp.is_visible() then
                    cmp.select_next()
                else
                    cmp.show()
                end
            end,
        },

        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },

        -- NOTE:
        -- keymaps for snippet jumping forward and backward are defined in luasnip config

        cmdline = {
            ['<Tab>'] = {
                function(cmp)
                    if cmp.is_visible() then
                        cmp.select_next()
                    else
                        cmp.show()
                    end
                end
            },
            ['<M-Tab>'] = {
                function(cmp)
                    if cmp.is_visible() then
                        cmp.select_prev()
                    else
                        cmp.show()
                    end
                end
            },
        },
    },
    sources = {
        default = { 'lsp', 'snippets', 'buffer', 'path' },
        providers = {
            lsp = {
                -- By default it fallbacks to 'buffer'. It means buffer items will only be listed
                -- when lsp returns 0 items. Remove 'buffer' from the fallbacks to make buffer items
                -- be always listed.
                fallbacks = {},
            },
            buffer = {
                min_keyword_length = 4,
            },
        },
    },
    snippets = {
        preset = 'luasnip',
    },
    completion = {
        list = {
            selection = {
                preselect = function(ctx)
                    return ctx.mode ~= 'cmdline'
                end,
                auto_insert = function(ctx)
                    return ctx.mode == 'cmdline'
                end,
            },
        },
        accept = {
            auto_brackets = {
                enabled = false,
            },
        },
        menu = {
            border = vim.g.border_style,
            draw = {
                columns = {
                    { 'kind_icon' },
                    { 'label', 'label_description', gap = 1 },
                },
            },
        },
        documentation = {
            auto_show = true,
            auto_show_delay_ms = 0,
            update_delay_ms = 0,
            window = {
                border = vim.g.border_style,
                max_height = math.floor(vim.o.lines * 0.5),
                max_width = math.floor(vim.o.columns * 0.4),
            },
        },
        ghost_text = {
            enabled = true,
        },
    },
    appearance = {
        kind_icons = kind_icons,
    },
})
