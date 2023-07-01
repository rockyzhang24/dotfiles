local M = {}
local fn = vim.fn
local builtin = require("telescope.builtin")
local theme = require("rockyz.plugin-config.telescope.theme")

local ivy = theme.get_ivy(true)
local ivy_nopreview = theme.get_ivy(false)

M.git_files = function()
  builtin.git_files(ivy_nopreview)
end

M.find_files = function()
  builtin.find_files(ivy_nopreview)
end

M.oldfiles = function()
  builtin.oldfiles(ivy_nopreview)
end

-- find_files for my dotfiles
M.find_dotfiles = function()
  local opts = {
    find_command = {
      "ls-dotfiles"
    },
  }
  builtin.find_files(vim.tbl_deep_extend("force", ivy_nopreview, opts), false)
end

M.buffers = function()
  builtin.buffers(ivy_nopreview)
end

M.help_tags = function()
  builtin.help_tags(ivy)
end

M.highlights = function()
  builtin.highlights(ivy)
end

M.commands = function()
  builtin.commands(ivy_nopreview)
end

M.marks = function()
  builtin.marks(ivy)
end

M.quickfix = function()
  builtin.quickfix(ivy)
end

M.command_history = function()
  builtin.command_history(ivy_nopreview)
end

M.search_history = function()
  builtin.search_history(ivy_nopreview)
end

M.live_grep = function()
  builtin.live_grep(ivy)
end

-- live_grep in neovim config files
M.grep_nvim_config = function()
  local opts = {
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
  builtin.live_grep(vim.tbl_deep_extend("force", ivy, opts))
end

-- Grep by giving a query string
M.grep_string = function()
  local input = fn.input "Grep String > "
  if input == "" then
    return
  end
  local opts = {
    search = input,
    use_regex = true,
  }
  builtin.grep_string(vim.tbl_deep_extend("force", ivy, opts))
end

-- Grep by the current word or selection
M.grep_word = function()
  local opts = {
    search = fn.expand("<cword>")
  }
  builtin.grep_string(vim.tbl_deep_extend("force", ivy, opts))
end

return M
