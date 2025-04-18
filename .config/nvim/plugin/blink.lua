local kind_icons = require('rockyz.icons').symbol_kinds

require('blink.cmp').setup({
    -- NOTE:
    -- keymaps for snippet jumping forward and backward are defined in luasnip config
    keymap = {
        preset = 'none',
        ['<C-Enter>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-e>'] = { 'cancel', 'fallback' },
        ['<C-\\>'] = { 'hide', 'fallback' },
        ['<C-y>'] = {
            function(cmp)
                if vim.fn.pumvisible() == 1 then
                    -- For vim's builtin ins-completion
                    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-y>', true, false, true), 'n', false)
                elseif cmp.is_menu_visible() then
                    cmp.select_and_accept()
                end
            end,
        },

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
    },
    sources = {
        default = { 'lsp', 'snippets', 'buffer', 'path' },
        providers = {
            -- lsp = {
            --     -- By default it fallbacks to 'buffer'. It means buffer items will only be listed
            --     -- when lsp returns 0 items. Remove 'buffer' from the fallbacks to make buffer items
            --     -- be always listed.
            --     fallbacks = {},
            -- },
            -- buffer = {
            --     min_keyword_length = 4,
            -- },
        },
    },
    snippets = {
        preset = 'luasnip',
    },
    completion = {
        list = {
            selection = {
                preselect = false,
                auto_insert = true,
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
            update_delay_ms = 50,
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
    fuzzy = {
        max_typos = function()
            return 0
        end,
    },
    appearance = {
        kind_icons = kind_icons,
    },

    -- Command line
    cmdline = {
        enabled = true,
        completion = {
            menu = {
                auto_show = function(_)
                    local cmdtype = vim.fn.getcmdtype()
                    return cmdtype == ':' or cmdtype == '/' or cmdtype == '?'
                end,
            },
            list = {
                selection = {
                    preselect = false,
                    auto_insert = true,
                },
            },
        },
        keymap = {
            preset = 'none',
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
})
