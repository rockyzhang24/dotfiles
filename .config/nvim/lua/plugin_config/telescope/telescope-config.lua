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
local map_opts = {
  silent = true,
}

-- Files
vim.keymap.set('n', '<Leader>ff', function() require("telescope.builtin").find_files() end, map_opts)
-- find_files in dotfiles
vim.keymap.set('n', '<Leader>f.', function() require("plugin_config.telescope.my_picker").dotfiles() end, map_opts)
vim.keymap.set('n', '<Leader>fo', function() require("telescope.builtin").oldfiles() end, map_opts)
vim.keymap.set('n', '<Leader>fg', function() require("telescope.builtin").git_files() end, map_opts)

-- Misc
vim.keymap.set('n', '<Leader>fb', function() require("telescope.builtin").buffers() end, map_opts)
vim.keymap.set('n', '<Leader>ft', function() require("telescope.builtin").tags() end, map_opts)
vim.keymap.set('n', '<Leader>f?', function() require("telescope.builtin").help_tags() end, map_opts)
vim.keymap.set('n', '<Leader>fr', function() require("telescope.builtin").resume() end, map_opts)
vim.keymap.set('n', '<Leader>fh', function() require("telescope.builtin").highlights() end, map_opts)

-- Grep
vim.keymap.set('n', '<Leader>g/', function() require("telescope.builtin").live_grep() end, map_opts)
-- live_grep in nvim config files
vim.keymap.set('n', '<Leader>gv', function() require("plugin_config.telescope.my_picker").grep_nvim_config() end, map_opts)
-- grep by giving a query string
vim.keymap.set('n', '<Leader>gs', function() require("plugin_config.telescope.my_picker").grep_prompt() end, map_opts)


-- grep_string operator
vim.keymap.set('n', '<Leader>g', '<Cmd>set operatorfunc=utils#TelescopeGrepOperator<CR>g@', map_opts)
vim.keymap.set('x', '<Leader>g', ':call utils#TelescopeGrepOperator(visualmode())<CR>', map_opts)

-- Other mappings regarding LSP picker are set in the nvim-lspconfig setup ../lsp/lsp-config.lua
