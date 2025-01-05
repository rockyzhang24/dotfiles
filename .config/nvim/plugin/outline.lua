local icons = require('rockyz.icons')

require('outline').setup({
    outline_items = {
        show_symbol_lineno = true,
    },
    keymaps = {
        show_help = '?',
        close = 'q',
        goto_location = '<Enter>',
        peek_location = '<C-Enter>',
        goto_and_close = {},
        restore_location = '<C-g>',
        hover_symbol = 'K',
        toggle_preview = 'p',
        rename_symbol = 'r',
        code_actions = 'a',
        fold = 'h',
        unfold = 'l',
        fold_toggle = '<Tab>',
        fold_toggle_all = '<M-Tab>',
        fold_all = 'zR',
        unfold_all = 'zM',
        fold_reset = 'R',
        down_and_jump = '<C-n>',
        up_and_jump = '<C-p>',
    },
    providers = {
        priority = { 'lsp', 'markdown', 'man' },
    },
    symbols = {
        icon_fetcher = function(kind, bufnr, symbol)
            local icon = icons.symbol_kinds[kind]
            -- ctags provider might add an `access` key
            if symbol and symbol.access then
                return icon .. ' ' .. icons.access[symbol.access]
            end
            return icon
        end,
    },
})

-- Toggle
vim.keymap.set('n', 'yoo', '<Cmd>Outline<CR>')
