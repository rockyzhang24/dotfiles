local M = {}
local builtin = require("telescope.builtin")
local themes = require("telescope.themes")

local no_preview = {
  previewer = false,
  layout_config = {
    height = 15,
  }
}

local theme_opts = themes.get_ivy {
  results_title = false,
  prompt_title = false,
  preview_title = "Preview",
  layout_config = {
    height = 40,
  },
}

local theme_opts_nopreview = vim.tbl_deep_extend("force", theme_opts, no_preview)

M.git_files = function()
  builtin.git_files(theme_opts_nopreview)
end

M.find_files = function()
  builtin.find_files(theme_opts_nopreview)
end

M.oldfiles = function()
  builtin.oldfiles(theme_opts_nopreview)
end

-- find_files for my dotfiles
M.find_dotfiles = function()
  local opts = {
    find_command = {
      "ls-dotfiles"
    },
  }
  builtin.find_files(vim.tbl_deep_extend("force", theme_opts_nopreview, opts), false)
end

M.buffers = function()
  builtin.buffers(theme_opts_nopreview)
end

M.help_tags = function()
  builtin.help_tags(theme_opts)
end

M.highlights = function()
  builtin.highlights(theme_opts)
end

M.commands = function()
  builtin.commands(theme_opts_nopreview)
end

M.marks = function()
  builtin.marks(theme_opts)
end

M.quickfix = function()
  builtin.quickfix(theme_opts)
end

M.command_history = function()
  builtin.command_history(theme_opts_nopreview)
end

M.search_history = function()
  builtin.search_history(theme_opts_nopreview)
end

M.live_grep = function()
  builtin.live_grep(theme_opts)
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
  builtin.live_grep(vim.tbl_deep_extend("force", theme_opts, opts))
end

-- Grep by giving a query string
M.grep_string = function()
  local input = vim.fn.input "Grep String > "
  if input == "" then
    return
  end
  local opts = {
    search = input,
    use_regex = true,
  }
  builtin.grep_string(vim.tbl_deep_extend("force", theme_opts, opts))
end

-- Grep by the word under cursor
M.grep_word = function()
  local opts = {
    search = vim.fn.expand("<cword>")
  }
  builtin.grep_string(vim.tbl_deep_extend("force", theme_opts, opts))
end

-- Helper function for getting the selected texts
local function getVisualSelection()
  local saved_unnamed_reg = vim.fn.getreg('@')
  vim.cmd('noau normal! y')
  local text = vim.fn.getreg('@')
  vim.fn.setreg('@', saved_unnamed_reg)

  text = string.gsub(text, "\n", "")
  if #text > 0 then
    return text
  else
    return ''
  end
end

-- Grep by the selection
M.grep_selection = function()
  local opts = {
    search = getVisualSelection(),
  }
  builtin.grep_string(vim.tbl_deep_extend("force", theme_opts, opts))
end

return M
