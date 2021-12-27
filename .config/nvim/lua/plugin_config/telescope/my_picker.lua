local M = {}

-- find_files for dotfiles
function M.dotfiles()
  require("telescope.builtin").find_files {
    cwd = "~",
    hidden = true,
    find_command = {"git", "--git-dir=/Users/rockyzhang/dotfiles/", "--work-tree=/Users/rockyzhang/", "ls-files"},
    prompt_title = "~ dotfiles ~",
  }
end

return M
