local cmp = require('cmp')

local symbol_kinds = require('rockyz.icons').symbol_kinds
local ellipsis = require('rockyz.icons').misc.ellipsis

local winhighlight = 'FloatBorder:SuggestWidgetBorder,CursorLine:SuggestWidgetSelect,Search:None'
if vim.g.border_enabled then
    winhighlight = 'Normal:Normal,' .. winhighlight
else
    winhighlight = 'Normal:Pmenu,' .. winhighlight
end

cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    window = {
        completion = {
            winhighlight = winhighlight,
            border = vim.g.border_style,
        },
        documentation = {
            winhighlight = winhighlight,
            border = vim.g.border_style,
            focusable = true,
            max_height = math.floor(vim.o.lines * 0.5),
            max_width = math.floor(vim.o.columns * 0.4),
        },
    },
    view = {
        entries = {
            follow_cursor = true,
        },
    },
    -- Mappings
    -- Default mappings can be found here: https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/config/mapping.lua
    -- Ref: https://github.com/hrsh7th/nvim-cmp/issues/1027
    mapping = {
        ['<C-n>'] = {
            i = function()
                if cmp.visible() then
                    cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
                else
                    cmp.complete()
                end
            end,
        },
        ['<C-p>'] = {
            i = function()
                if cmp.visible() then
                    cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
                else
                    cmp.complete()
                end
            end,
        },
        ['<C-h>'] = {
            i = cmp.mapping.scroll_docs(-4),
        },
        ['<C-l>'] = {
            i = cmp.mapping.scroll_docs(4),
        },
        ['<C-Enter>'] = {
            i = cmp.mapping.complete(),
        },
        ['<C-e>'] = {
            i = cmp.mapping.abort(),
        },
        ['<C-y>'] = {
            i = cmp.mapping.confirm({ select = true }),
        },
        ['<C-f>'] = {
            i = cmp.mapping.complete({
                config = {
                    sources = {
                        { name = 'path' }
                    },
                },
            })
        },
        ['<Tab>'] = {
            c = function()
                if cmp.visible() then
                    cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
                else
                    cmp.complete()
                end
            end,
        },
        ['<M-Tab>'] = {
            c = function()
                if cmp.visible() then
                    cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
                else
                    cmp.complete()
                end
            end,
        },
    },
    sources = cmp.config.sources({
        {
            name = 'nvim_lsp',
            -- Filter out snippets from LSP
            -- entry_filter = function(entry, ctx)
                --   return types.lsp.CompletionItemKind[entry:get_kind()] ~= 'Snippet'
                -- end,
        },
        {
            name = 'luasnip',
            -- Disable snippets inside comments and strings
            entry_filter = function()
                local ctx = require('cmp.config.context')
                local in_string = ctx.in_syntax_group('String') or ctx.in_treesitter_capture('string')
                local in_comment = ctx.in_syntax_group('Comment') or ctx.in_treesitter_capture('comment')
                return not in_string and not in_comment
            end,
        },
        {
            name = 'buffer',
            keyword_length = 3,
            option = {
                -- Buffer completions from all visible buffers
                get_bufnrs = function()
                    return vim.iter(vim.api.nvim_list_wins()):map(function(win)
                        local buf = vim.api.nvim_win_get_buf(win)
                        if vim.bo[buf].filetype ~= 'bigfile' then
                            return buf
                        end
                    end):totable()
                end,
            },
        },
        { name = 'path' },
    }),
    formatting = {
        format = function(entry, vim_item)
            local MAX_ABBR_WIDTH, MAX_MENU_WIDTH = 25, 30
            -- Prepend icons to item.kind
            -- For kind from path source (i.e., all kinds of files), use devicons to get icons and
            -- highlight groups. For other kinds, use codicons.
            local file_icon
            if vim.tbl_contains({ 'path' }, entry.source.name) then
                local icon, hl_group = require('nvim-web-devicons').get_icon(entry:get_completion_item().label)
                if icon then
                    file_icon = icon .. ' '
                    vim_item.kind_hl_group = hl_group
                end
            end
            vim_item.kind = string.format('%s %s', file_icon or symbol_kinds[vim_item.kind] or symbol_kinds.Text, vim_item.kind)
            -- Truncate the label
            if vim.api.nvim_strwidth(vim_item.abbr) > MAX_ABBR_WIDTH then
                vim_item.abbr = vim.fn.strcharpart(vim_item.abbr, 0, MAX_ABBR_WIDTH) .. ellipsis
            end
            -- Truncate the description part
            if vim.api.nvim_strwidth(vim_item.menu or '') > MAX_MENU_WIDTH then
                vim_item.menu = vim.fn.strcharpart(vim_item.menu, 0, MAX_MENU_WIDTH) .. ellipsis
            end
            return vim_item
        end,
        -- Adjust the order of completion menu fields
        fields = {
            'kind',
            'abbr',
            'menu',
        },
    },
    experimental = {
        ghost_text = {
            hl_group = 'GhostText',
        },
    },
})

-- For search forward
cmp.setup.cmdline('/', {
    sources = {
        {
            name = 'buffer',
            option = {
                get_bufnrs = function()
                    local buf = vim.api.nvim_get_current_buf()
                    return vim.bo[buf] == 'bigfile' and {} or { buf }
                end,
            },
        },
    },
    view = {
        entries = { name = 'wildmenu', separator = ' | ' },
    },
})

-- For search backward
cmp.setup.cmdline('?', {
    sources = {
        {
            name = 'buffer',
            option = {
                get_bufnrs = function()
                    local buf = vim.api.nvim_get_current_buf()
                    return vim.bo[buf] == 'bigfile' and {} or { buf }
                end,
            },
        },
    },
    view = {
        entries = { name = 'wildmenu', separator = ' | ' },
    },
})

-- For cmdline
cmp.setup.cmdline(':', {
    sources = cmp.config.sources({
        { name = 'path' },
    }, {
        { name = 'cmdline' },
    }),
    formatting = {
        format = function(_, vim_item)
            local MAX_ABBR_WIDTH = 50
            if vim.api.nvim_strwidth(vim_item.abbr) > MAX_ABBR_WIDTH then
                vim_item.abbr = vim.fn.strcharpart(vim_item.abbr, 0, MAX_ABBR_WIDTH) .. ellipsis
            end
            return vim_item
        end,
        fields = {
            'abbr',
        },
    },
})
