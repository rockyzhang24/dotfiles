local telescope = require('telescope')
local builtin = require('telescope.builtin')
local actions = require('telescope.actions')

local M = {}

telescope.setup({
  defaults = {
    prompt_prefix = 'Telescope> ',
    selection_caret = ' ',
    multi_icon = ' ',
    layout_strategy = 'vertical',
    layout_config = {
      prompt_position = 'bottom',
      -- Make layout consistent with fzf.vim
      height = 0.83,
      width = 0.5,
      preview_height = 0.35,
    },
    results_title = false,
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
telescope.load_extension('projects')

--
-- Mappings
--

-- Highlight groups
vim.keymap.set('n', '<Leader>fg', function()
  builtin.highlights({
    prompt_prefix = 'Highlights> ',
    preview_title = false,
  })
end)

-- Help tags
vim.keymap.set('n', '<Leader>fh', function()
  builtin.help_tags({
    prompt_prefix = 'HelpTags> ',
    preview_title = false,
  })
end)

-- Marks
vim.keymap.set('n', '<Leader>fm', function()
  builtin.marks({
    prompt_prefix = 'Marks> ',
    preview_title = false,
  })
end)

-- LSP symbols in current buffer
vim.keymap.set('n', '<Leader>fs', function()
  builtin.lsp_document_symbols({
    prompt_prefix = 'Symbols [document]> ',
    preview_title = false,
  })
end)

-- LSP symbols in current workspace
vim.keymap.set('n', '<Leader>fS', function()
  builtin.lsp_workspace_symbols({
    prompt_prefix = 'Symbols [workspace]> ',
    preview_title = false,
  })
end)

-- Picker resume
vim.keymap.set('n', '<Leader>fr', builtin.resume)

return M
