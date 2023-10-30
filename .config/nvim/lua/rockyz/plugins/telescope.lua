local telescope = require('telescope')
local builtin = require('telescope.builtin')
local actions = require('telescope.actions')

local M = {}

telescope.setup({
  defaults = {
    prompt_prefix = 'Telescope> ',
    selection_caret = ' ',
    multi_icon = ' ',
    -- winblend = 5,
    -- layout_strategy = "flex",
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
        ['<C-_>'] = require('telescope.actions.layout').toggle_preview,
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

-- Mappings

function M.get_ivy(extra_opts)
  extra_opts = extra_opts or {}
  -- The default opts for ivy theme can be found here https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/themes.lua
  local opts = {
    results_title = false,
    prompt_title = false,
    previewer = true,
    preview_title = '',
    borderchars = {
      -- Left border only
      preview = { '', '', '', '│', '│', '', '', '│' },
    },
    layout_config = {
      height = 0.6,
    },
  }
  return require('telescope.themes').get_ivy(vim.tbl_deep_extend('force', opts, extra_opts))
end

vim.keymap.set('n', '<Leader>fh', function()
  builtin.help_tags(M.get_ivy({
    prompt_prefix = 'HelpTags> ',
  }))
end)
vim.keymap.set('n', '<Leader>fg', function() -- g for groups
  builtin.highlights(M.get_ivy({
    prompt_prefix = 'Highlights> ',
  }))
end)
vim.keymap.set('n', '<Leader>fm', function()
  builtin.marks(M.get_ivy({
    prompt_prefix = 'Marks> ',
  }))
end)
vim.keymap.set('n', '<Leader>fq', function()
  builtin.quickfix(M.get_ivy({
    prompt_prefix = 'Quickfix> ',
  }))
end)
vim.keymap.set('n', '<Leader>fl', function()
  builtin.loclist(M.get_ivy({
    prompt_prefix = 'LocationList> ',
  }))
end)
vim.keymap.set('n', '<Leader>fr', builtin.resume)
-- LSP symbols
vim.keymap.set('n', '<Leader>fs', function()
  builtin.lsp_document_symbols(M.get_ivy({
    prompt_prefix = 'Symbols(document)> ',
  }))
end)
vim.keymap.set('n', '<Leader>fS', function()
  builtin.lsp_workspace_symbols(M.get_ivy({
    prompt_prefix = 'Symbols(workspace)> ',
  }))
end)

return M
