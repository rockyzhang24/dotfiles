local M = {}
local builtin = require("telescope.builtin")

-- find_files for dotfiles
function M.dotfiles()
  builtin.find_files {
    cwd = "~",
    hidden = true,
    find_command = {"git", "--git-dir=/Users/rockyzhang/dotfiles/", "--work-tree=/Users/rockyzhang/", "ls-files"},
    prompt_title = "~ dotfiles ~",
  }
end

-- live_grep in neovim config files
function M.grep_nvim_config()
  builtin.live_grep {
    prompt_title = "live grep in nvim config files",
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
      "--trim",  -- Remove indentation for grep
      "--glob=!minpac", -- exclude directories
    },
  }
end

return M
