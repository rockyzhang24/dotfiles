local gitsigns = require('gitsigns')

gitsigns.setup({

    -- Experimental features
    _new_sign_calc = true,

    signs = {
        add = { show_count = false },
        change = { show_count = false },
        delete = { show_count = true },
        topdelete = { show_count = true },
        changedelete = { show_count = true },
        untracked = { show_count = false },
    },
    signcolumn = true,
    numhl = false,
    linehl = false,
    word_diff = false,
    attach_to_untracked = true,
    sign_priority = 6,
    preview_config = {
        -- Options passed to nvim_open_win
        border = vim.g.border_style,
        style = 'minimal',
        relative = 'cursor',
        row = 0,
        col = 1,
    },
    count_chars = {
        [1] = '₁',
        [2] = '₂',
        [3] = '₃',
        [4] = '₄',
        [5] = '₅',
        [6] = '₆',
        [7] = '₇',
        [8] = '₈',
        [9] = '₉',
        ['+'] = '₊',
    },

    on_attach = function(bufnr)

        local function buf_map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
        end

        -- Hunk navigation
        buf_map('n', ']h', function()
            gitsigns.nav_hunk('next', { target = 'all' })
        end)

        buf_map('n', '[h', function()
            gitsigns.nav_hunk('prev', { target = 'all' })
        end)

        -- Stage hunk or buffer
        -- To unstage, run it on a staged lines
        buf_map('n', '<Leader>hs', gitsigns.stage_hunk)
        buf_map('v', '<Leader>hs', function()
            gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end)
        buf_map('n', '<Leader>hS', gitsigns.stage_buffer)

        -- Reset
        buf_map('n', '<Leader>hr', gitsigns.reset_hunk)
        buf_map('v', '<Leader>hr', function()
            gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end)
        buf_map('n', '<Leader>hR', gitsigns.reset_buffer)

        -- Discard changes
        buf_map({ 'n', 'v' }, '<Leader>hr', ':Gitsigns reset_hunk<CR>')
        buf_map('n', '<Leader>hR', gitsigns.reset_buffer)

        -- Hunk preview
        buf_map('n', '<Leader>hp', gitsigns.preview_hunk)
        buf_map('n', '<Leader>hi', gitsigns.preview_hunk_inline)

        -- Blame
        buf_map('n', '<Leader>hb', function()
            gitsigns.blame_line({ full = true })
        end)

        -- Diff
        buf_map('n', '<Leader>hd', gitsigns.diffthis)
        buf_map('n', '<Leader>hD', function()
            gitsigns.diffthis('~')
        end)

        -- Toggle
        buf_map('n', '\\dw', gitsigns.toggle_word_diff) -- toggle the word_diff in the buffer
        buf_map('n', '\\b', gitsigns.toggle_current_line_blame) -- toggle displaying the blame for the current line

        -- Text object
        buf_map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')

        -- Populate quickfix with hunks
        buf_map('n', '<leader>hq', gitsigns.setqflist)

        buf_map('n', '<leader>hQ', function()
            -- all modified files for git dir
            gitsigns.setqflist('all')
        end)
    end,
})
