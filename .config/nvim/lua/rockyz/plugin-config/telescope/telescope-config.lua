local telescope = require("telescope")
local my_picker = require("rockyz.plugin-config.telescope.my_picker")

telescope.setup {
  defaults = {
    prompt_prefix = " ",
    selection_caret = " ",
    multi_icon = ' ',
    -- winblend = 5,
    -- layout_strategy = "flex",
    file_ignore_patterns = { '%.jpg', '%.jpeg', '%.png', '%.avi', '%.mp4' },
    mappings = {
      i = {
        -- Consistent with fzf key bindings in terminal
        ["<C-j>"] = "move_selection_next",
        ["<C-k>"] = "move_selection_previous",
        ["<C-u>"] = "results_scrolling_up",
        ["<C-d>"] = "results_scrolling_down",
        ["<M-u>"] = "preview_scrolling_up",
        ["<M-d>"] = "preview_scrolling_down",
        ["<C-n>"] = "cycle_history_next",
        ["<C-p>"] = "cycle_history_prev",
        ["<M-a>"] = "toggle_all",
        ["<C-Enter>"] = "toggle_selection",
        ["<M-p>"] = require("telescope.actions.layout").toggle_preview,
        ["<Esc>"] = "close",
        ["<C-c>"] = { "<Esc>", type = "command" },
      },
    },
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--trim" -- Remove indentation for grep
    }
  },
  pickers = {
    buffers = {
      mappings = {
        i = {
          ["<M-d>"] = "delete_buffer",
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
      case_mode = "smart_case",
    },
  }
}

-- Extensions
telescope.load_extension('fzf')
telescope.load_extension('harpoon')
telescope.load_extension('projects')

-- Mappings
local map_opts = {
  silent = true,
}

-- Files
vim.keymap.set('n', '<C-p>', my_picker.git_files, map_opts)
vim.keymap.set('n', '<Leader>ff', my_picker.find_files, map_opts)
vim.keymap.set('n', '<Leader>fo', my_picker.oldfiles, map_opts)
vim.keymap.set('n', '<Leader>f.', my_picker.find_dotfiles, map_opts)

-- Misc
vim.keymap.set('n', '<Leader>fb', my_picker.buffers, map_opts)
vim.keymap.set('n', '<Leader>f?', my_picker.help_tags, map_opts)
vim.keymap.set('n', '<Leader>fh', my_picker.highlights, map_opts)
vim.keymap.set('n', '<Leader>fc', my_picker.commands, map_opts)
vim.keymap.set('n', '<Leader>fm', my_picker.marks, map_opts)
vim.keymap.set('n', '<Leader>fq', my_picker.quickfix, map_opts)
vim.keymap.set('n', '<Leader>f:', my_picker.command_history, map_opts)
vim.keymap.set('n', '<Leader>f/', my_picker.search_history, map_opts)
vim.keymap.set('n', '<Leader>fr', require("telescope.builtin").resume, map_opts)

-- Grep
vim.keymap.set('n', '<Leader>gl', my_picker.live_grep, map_opts)
vim.keymap.set('n', '<Leader>gv', my_picker.grep_nvim_config, map_opts)
vim.keymap.set('n', '<Leader>gs', my_picker.grep_string, map_opts)
vim.keymap.set('n', '<Leader>gw', my_picker.grep_word, map_opts)
vim.keymap.set('x', '<Leader>gw', my_picker.grep_selection, map_opts)
