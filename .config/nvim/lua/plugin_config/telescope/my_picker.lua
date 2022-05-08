-- Examples can be found here:
-- https://github.com/tjdevries/config_manager/blob/master/xdg_config/nvim/lua/tj/telescope/init.lua

local M = {}
local builtin = require("telescope.builtin")

-- live_grep in neovim config files
function M.grep_nvim_config()
  builtin.live_grep {
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
end

-- grep by giving a query string
function M.grep_prompt()
  builtin.grep_string {
    -- path_display = { "shorten" },
    search = vim.fn.input "Grep String > ",
    use_regex = true,
  }
end

-- git_files with my dotfiles bare repo support
function M.git_files()
  local opts = {}
  if (vim.env.GIT_DIR == "/Users/rockyzhang/dotfiles" and vim.env.GIT_WORK_TREE == "/Users/rockyzhang") then
    opts.show_untracked = false
    opts.prompt_title = "< Find dotfiles >"
  end
  builtin.git_files(opts)
end

return M
