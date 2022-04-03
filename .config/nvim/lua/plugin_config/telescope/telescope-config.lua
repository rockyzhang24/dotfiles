local tele = require("telescope")

tele.setup {

  defaults = {
    prompt_prefix = "❯ ",
    selection_caret = "❯ ",
    winblend = 5,
    layout_strategy = "flex",
    layout_config = {
      width = 0.95,
      height = 0.85,
    },
    file_ignore_patterns = { '%.jpg', '%.jpeg', '%.png', '%.avi', '%.mp4' },
    mappings = {
      i = {
        -- Consistent with fzf in terminal
        ["<C-j>"] = "move_selection_next",
        ["<C-k>"] = "move_selection_previous",
        ["<C-u>"] = "results_scrolling_up",
        ["<C-d>"] = "results_scrolling_down",
        ["<S-Up>"] = "preview_scrolling_up",
        ["<S-Down>"] = "preview_scrolling_down",
        ["<C-n>"] = "cycle_history_next",
        ["<C-p>"] = "cycle_history_prev",
        ["<C-a>"] = "toggle_all",
        ["<C-Enter>"] = "toggle_selection",
        ["<Esc>"] = "close",
        ["<M-Esc>"] = { "<Esc>", type = "command" },
        -- To disable builtin mappings
        ["<C-c>"] = false,
        ["<Down>"] = false,
        ["<Up>"] = false,
        ["<PageDown>"] = false,
        ["<PageUp>"] = false,
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

-- FZF as the sorter
tele.load_extension('fzf')

-- Aerial.nvim
tele.load_extension('aerial')

-- harpoon
tele.load_extension('harpoon')

-- Mappings
local map_options = {
  noremap = true,
  silent = true,
}

local keymap = vim.api.nvim_set_keymap

-- Files
keymap('n', '<Leader>ff', '<Cmd>lua require("telescope.builtin").find_files()<CR>', map_options)
-- find_files in dotfiles
keymap('n', '<Leader>f.', '<Cmd>lua require("plugin_config.telescope.my_picker").dotfiles()<CR>', map_options)
keymap('n', '<Leader>fo', '<Cmd>lua require("telescope.builtin").oldfiles()<CR>', map_options)
keymap('n', '<Leader>fg', '<Cmd>lua require("telescope.builtin").git_files()<CR>', map_options)

-- Misc
keymap('n', '<Leader>fb', '<Cmd>lua require("telescope.builtin").buffers()<CR>', map_options)
keymap('n', '<Leader>ft', '<Cmd>lua require("telescope.builtin").tags()<CR>', map_options)
keymap('n', '<Leader>f?', '<Cmd>lua require("telescope.builtin").help_tags()<CR>', map_options)
keymap('n', '<Leader>fr', '<Cmd>lua require("telescope.builtin").resume()<CR>', map_options)
keymap('n', '<Leader>fh', '<Cmd>lua require("telescope.builtin").highlights()<CR>', map_options)

-- Grep
keymap('n', '<Leader>g/', '<Cmd>lua require("telescope.builtin").live_grep()<CR>', map_options)
-- live_grep in nvim config files
keymap('n', '<Leader>gv', '<Cmd>lua require("plugin_config.telescope.my_picker").grep_nvim_config()<CR>', map_options)
-- grep by giving a query string
keymap('n', '<Leader>gs', '<Cmd>lua require("plugin_config.telescope.my_picker").grep_prompt()<CR>', map_options)

-- grep_string operator
keymap('n', '<Leader>g', '<Cmd>set operatorfunc=utils#TelescopeGrepOperator<CR>g@', map_options)
keymap('x', '<Leader>g', ':call utils#TelescopeGrepOperator(visualmode())<CR>', map_options)

-- Other mappings regarding LSP picker are set in the nvim-lspconfig setup ../lsp/lsp-config.lua
