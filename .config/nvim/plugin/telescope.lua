local telescope = require('telescope')
local builtin = require('telescope.builtin')
local actions = require('telescope.actions')

telescope.setup({
    defaults = {
        prompt_prefix = 'Telescope> ',
        selection_caret = '▌ ',
        multi_icon = '┃',
        layout_strategy = 'horizontal',
        layout_config = {
            prompt_position = 'top',
            -- Make layout consistent with fzf.vim
            width = 0.8,
            height = 0.88,
            preview_width = 0.6
        },
        results_title = false,
        dynamic_preview_title = true,
        sorting_strategy = "ascending",
        file_ignore_patterns = { '%.jpg', '%.jpeg', '%.png', '%.avi', '%.mp4' },
        mappings = {
            i = {
                -- Consistent with fzf key bindings in terminal
                ['<C-x>'] = 'select_horizontal',
                ['<C-v>'] = 'select_vertical',
                ['<C-t>'] = 'select_tab_drop',
                ['<C-j>'] = 'move_selection_next',
                ['<C-k>'] = 'move_selection_previous',
                ['<C-u>'] = 'results_scrolling_up',
                ['<C-d>'] = 'results_scrolling_down',
                ['<M-u>'] = 'preview_scrolling_up',
                ['<M-d>'] = 'preview_scrolling_down',
                ['<C-n>'] = 'cycle_history_next',
                ['<C-p>'] = 'cycle_history_prev',
                ['<C-a>'] = 'toggle_all',
                ['<C-Enter>'] = 'toggle_selection',
                ['<C-r>'] = 'to_fuzzy_refine',
                ['<C-/>'] = require('telescope.actions.layout').toggle_preview,
                ['<C-_>'] = require('telescope.actions.layout').toggle_preview, -- alacritty uses <C-_> as <C-/>
                ['<C-h>'] = 'which_key',
                ['<Esc>'] = 'close',
                ['<C-c>'] = { '<Esc>', type = 'command' },
                ['<C-q>'] = actions.send_selected_to_qflist + actions.open_qflist,
                ['<M-q>'] = actions.send_to_qflist + actions.open_qflist,
                -- Disable unused keymaps
                ['<Down>'] = false,
                ['<Up>'] = false,
                ['<PageDown>'] = false,
                ['<PageUp>'] = false,
            },
        },
        vimgrep_arguments = {
            'rg',
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case',
            '--trim', -- Remove indentation for grep
        },
    },
    pickers = {
        buffers = {
            mappings = {
                i = {
                    ['<M-d>'] = 'delete_buffer',
                },
            },
        },
    },
    extensions = {
        -- telescope-fzf-native as the sorter
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = 'smart_case',
        },
    },
})

-- Extensions
telescope.load_extension('fzf')

--
-- Mappings
--

-- Highlight groups
vim.keymap.set('n', '<Leader>fg', function()
    builtin.highlights({
        prompt_prefix = 'Highlights> ',
    })
end)
