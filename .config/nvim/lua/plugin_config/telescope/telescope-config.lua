require('telescope').setup {

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
require('telescope').load_extension('fzf')
