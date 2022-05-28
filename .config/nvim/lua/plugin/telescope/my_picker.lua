-- Examples can be found here:
-- https://github.com/tjdevries/config_manager/blob/master/xdg_config/nvim/lua/tj/telescope/init.lua

local M = {}
local builtin = require("telescope.builtin")
local themes = require("telescope.themes")

function M.live_grep()
  local opts = {
    layout_strategy = "vertical",
    layout_config = {
      prompt_position = "top",
    },
    sorting_strategy = "ascending",
  }
  builtin.live_grep(opts)
end

-- live_grep in neovim config files
function M.grep_nvim_config()
  local opts = {
    layout_strategy = "vertical",
    layout_config = {
      prompt_position = "top",
    },
    sorting_strategy = "ascending",
    prompt_title = "< Live Grep in Neovim Config Files >",
    search_dirs = {
      "~/.config/nvim/"
    },
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--trim", -- Remove indentation for grep
      "--glob=!minpac", -- exclude directories
    },
  }
  builtin.live_grep(opts)
end

-- grep by giving a query string
function M.grep_prompt()
  local opts = {
    layout_strategy = "vertical",
    layout_config = {
      prompt_position = "top",
    },
    sorting_strategy = "ascending",
    -- path_display = { "shorten" },
    search = vim.fn.input "Grep String > ",
    use_regex = true,
  }
  builtin.grep_string(opts)
end

-- git_files with my dotfiles bare repo support
function M.git_files()
  local opts = themes.get_dropdown {
    previewer = false,
    layout_config = {
      height = 20,
    },
  }
  if (vim.env.GIT_DIR == "/Users/rockyzhang/dotfiles" and vim.env.GIT_WORK_TREE == "/Users/rockyzhang") then
    opts.show_untracked = false
    opts.prompt_title = "< Find dotfiles >"
  end
  builtin.git_files(opts)
end

function M.oldfiles()
  local opts = themes.get_dropdown {
    previewer = false,
    layout_config = {
      height = 20,
    },
  }
  builtin.oldfiles(opts)
end

return M
