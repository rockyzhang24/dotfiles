local tele = require("telescope")

tele.setup {

  defaults = {
    prompt_prefix = "❯ ",
    selection_caret = "❯ ",
    winblend = 5,
    layout_strategy = "flex",
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


-- Extensions
tele.load_extension('fzf')
tele.load_extension('aerial')
tele.load_extension('harpoon')
tele.load_extension('projects')

-- Mappings
local map_opts = {
  silent = true,
}

local function my_picker(picker)
  require("rockyz.plugin-config.telescope.my_picker")[picker]()
end

-- Files
vim.keymap.set('n', '<C-f>', function() my_picker("git_files") end, map_opts)
vim.keymap.set('n', '<Leader>ff', function() require("telescope.builtin").find_files() end, map_opts)
vim.keymap.set('n', '<Leader>fo', function() my_picker("oldfiles") end, map_opts)
vim.keymap.set('n', '<Leader>f.', function() my_picker("find_dotfiles") end, map_opts)

-- Misc
vim.keymap.set('n', '<Leader>fb', function() require("telescope.builtin").buffers() end, map_opts)
vim.keymap.set('n', '<Leader>ft', function() require("telescope.builtin").tags() end, map_opts)
vim.keymap.set('n', '<Leader>f?', function() require("telescope.builtin").help_tags() end, map_opts)
vim.keymap.set('n', '<Leader>fr', function() require("telescope.builtin").resume() end, map_opts)
vim.keymap.set('n', '<Leader>fh', function() require("telescope.builtin").highlights() end, map_opts)

-- Grep
vim.keymap.set('n', '<Leader>gl', function() my_picker("live_grep") end, map_opts)
-- live_grep in nvim config files
vim.keymap.set('n', '<Leader>gv', function() my_picker("grep_nvim_config") end, map_opts)
-- grep by giving a query string
vim.keymap.set('n', '<Leader>gs', function() my_picker("grep_prompt") end, map_opts)
-- grep word under cursor or selected texts
vim.keymap.set('n', '<Leader>gw', function() my_picker("grep_word") end, map_opts)
vim.keymap.set('x', '<Leader>gw', function() my_picker("grep_selection") end, map_opts)

-- Other mappings regarding LSP picker are set in the nvim-lspconfig setup ~/.config/nvim/lua/plugin-config/lsp/lsp-config.lua
