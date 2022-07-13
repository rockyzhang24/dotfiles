-- Examples can be found here:
-- https://github.com/tjdevries/config_manager/blob/master/xdg_config/nvim/lua/tj/telescope/init.lua

local M = {}
local builtin = require("telescope.builtin")
local themes = require("telescope.themes")

-- live_grep
M.live_grep = function()
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
M.grep_nvim_config = function()
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

-- Helper function for executing telescope grep_string by a given query
local function grep_string_by_query(query)
  local opts = {
    layout_strategy = "vertical",
    layout_config = {
      prompt_position = "top",
    },
    sorting_strategy = "ascending",
    search = query,
    use_regex = true,
  }
  builtin.grep_string(opts)
end

-- grep by giving a query string
M.grep_prompt = function()
  grep_string_by_query(vim.fn.input "Grep String > ")
end

-- grep the word under cursor
M.grep_word = function()
  grep_string_by_query(vim.fn.expand("<cword>"))
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

-- grep the selections
M.grep_selection = function()
  grep_string_by_query(getVisualSelection())
end

-- git_files with my dotfiles bare repo support
M.git_files = function()
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

-- find_files for my dotfiles
M.find_dotfiles = function()
  local opts = themes.get_dropdown {
    previewer = false,
    layout_config = {
      height = 20,
    },
    find_command = { "ls-dotfiles" },
  }
  builtin.find_files(opts)
end

-- oldfiles
M.oldfiles = function()
  local opts = themes.get_dropdown {
    previewer = false,
    layout_config = {
      height = 20,
    },
  }
  builtin.oldfiles(opts)
end

return M
