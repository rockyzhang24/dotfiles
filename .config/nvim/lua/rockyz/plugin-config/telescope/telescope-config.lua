local telescope = require("telescope")
local my_picker = require("rockyz.plugin-config.telescope.my_picker")
local map = require('rockyz.keymap').map
local api = vim.api
local fn = vim.fn

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

-- Files
map('n', '<C-p>', my_picker.git_files)
map('n', '<Leader>ff', my_picker.find_files)
map('n', '<Leader>fo', my_picker.oldfiles)
map('n', '<Leader>f.', my_picker.find_dotfiles)

-- Misc
map('n', '<Leader>fb', my_picker.buffers)
map('n', '<Leader>f?', my_picker.help_tags)
map('n', '<Leader>fh', my_picker.highlights)
map('n', '<Leader>fc', my_picker.commands)
map('n', '<Leader>fm', my_picker.marks)
map('n', '<Leader>fq', my_picker.quickfix)
map('n', '<Leader>f:', my_picker.command_history)
map('n', '<Leader>f/', my_picker.search_history)
map('n', '<Leader>fr', require("telescope.builtin").resume)

-- Grep
map('n', '<Leader>gl', my_picker.live_grep)
map('n', '<Leader>gv', my_picker.grep_nvim_config)
map('n', '<Leader>gs', my_picker.grep_string)
map('n', '<Leader>gw', my_picker.grep_word)
map('x', '<Leader>gw', my_picker.grep_selection)

-- Quickfix for this issue https://github.com/nvim-telescope/telescope.nvim/issues/2501
api.nvim_create_augroup('my_telescope', { clear = true })
api.nvim_create_autocmd({ 'WinLeave' }, {
  group = 'my_telescope',
  pattern = '*',
  callback = function()
    if vim.bo.ft == "TelescopePrompt" and fn.mode() == "i" then
			api.nvim_feedkeys(api.nvim_replace_termcodes("<Esc>", true, false, true), "i", false)
		end
  end,
})
