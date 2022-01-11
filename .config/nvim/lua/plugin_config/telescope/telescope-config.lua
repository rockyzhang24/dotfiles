local tele = require("telescope")
local api = vim.api

tele.setup {

  defaults = {
    prompt_prefix = "❯ ",
    selection_caret = "❯ ",

    winblend = 10,

    layout_strategy = "flex",
    layout_config = {
      width = 0.95,
      height = 0.85,
    },

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
        ["<Esc>"] = "close",
        ["<M-Esc>"] = { "<Esc>", type = "command" },
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
      "--trim"  -- Remove indentation for grep
    }
  },

  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    }
  }
}

-- FZF as the sorter
tele.load_extension('fzf')

-- Mappings
local map_options = {
  noremap = true,
  silent = true,
}

api.nvim_set_keymap('n', '<Leader>ff', '<Cmd>lua require("telescope.builtin").find_files()<CR>', map_options)
api.nvim_set_keymap('n', '<Leader>fb', '<Cmd>lua require("telescope.builtin").buffers()<CR>', map_options)
api.nvim_set_keymap('n', '<Leader>fg', '<Cmd>lua require("telescope.builtin").live_grep()<CR>', map_options)
api.nvim_set_keymap('n', '<Leader>ft', '<Cmd>lua require("telescope.builtin").tags()<CR>', map_options)
api.nvim_set_keymap('n', '<Leader>f?', '<Cmd>lua require("telescope.builtin").help_tags()<CR>', map_options)
api.nvim_set_keymap('n', '<Leader>fo', '<Cmd>lua require("telescope.builtin").oldfiles()<CR>', map_options)

api.nvim_set_keymap('n', '<Leader>f.', '<Cmd>lua require("plugin_config.telescope.my_picker").dotfiles()<CR>', map_options)

-- Other mappings regarding LSP picker are set in the nvim-lspconfig setup ../lsp/lsp-config.lua
