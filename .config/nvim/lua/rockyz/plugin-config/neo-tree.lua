local utils = require("neo-tree.utils")
local inputs = require("neo-tree.ui.inputs")
local cmds = require("neo-tree.sources.filesystem.commands")

-----------------------------
-- Some helper functions here
-----------------------------

-- Custom commands

-- Open the target in the default application (bind to "o")
local function system_open(state)
  local node = state.tree:get_node()
  local path = node:get_id()
  vim.api.nvim_command("silent !open -g " .. path)
end

-- Trash the target
local function trash(state)
  local tree = state.tree
  local node = tree:get_node()
  if node.type == "message" then
    return
  end
  local _, name = utils.split_path(node.path)
  local msg = string.format("Are you sure you want to trash '%s'?", name)
  inputs.confirm(msg, function(confirmed)
    if not confirmed then
      return
    end
    vim.api.nvim_command("silent !trash -F " .. node.path)
    cmds.refresh(state)
  end)
end

-- Trash the selections (visual mode)
local function trash_visual(state, selected_nodes)
  local paths_to_trash = {}
  for _, node in ipairs(selected_nodes) do
    if node.type ~= 'message' then
      table.insert(paths_to_trash, node.path)
    end
  end
  local msg = "Are you sure you want to trash " .. #paths_to_trash .. " items?"
  inputs.confirm(msg, function(confirmed)
    if not confirmed then
      return
    end
    for _, path in ipairs(paths_to_trash) do
      vim.api.nvim_command("silent !trash -F " .. path)
    end
    cmds.refresh(state)
  end)
end

-- Custom components

-- A custom component providing the index number of a file marked by Harpoon
local function harpoon_index(config, node, state)
  local Marked = require("harpoon.mark")
  local path = node:get_id()
  local succuss, index = pcall(Marked.get_index_of, path)
  if succuss and index and index > 0 then
    return {
      text = string.format("  %d", index),
      highlight = config.highlight or "NeoTreeDirectoryIcon",
    }
  else
    return {}
  end
end

-- Event handlers

-- Set neo-tree bufer local options
local function set_buffer_local_options(arg)
  vim.wo.signcolumn = 'no'
end

------------------
-- Neo-tree config
------------------

require("neo-tree").setup {
  use_default_mappings = false,
  close_if_last_window = true,
  nesting_rules = {
    ["ts"] = { "cjs", "cjs.map", "js", "js.map", "d.ts" },
  },
  window = {
    mappings = {
      ["\\"] = "toggle_node",
      ["<CR>"] = "open",
      ["<C-x>"] = "open_split",
      ["<C-v>"] = "open_vsplit",
      ["<C-t>"] = "open_tabnew",
      ["w"] = "open_with_window_picker",
      ["a"] = {
        "add",
        config = {
          show_path = "absolute",
        }
      },
      ["A"] = {
        "add_directory",
        config = {
          show_path = "absolute",
        },
      },
      ["d"] = "delete",
      ["r"] = "rename",
      ["y"] = "copy_to_clipboard",
      ["x"] = "cut_to_clipboard",
      ["p"] = "paste_from_clipboard",
      ["c"] = "copy",
      ["m"] = "move",
      ["R"] = "refresh",
      ["zc"] = "close_node",
      ["zM"] = "close_all_nodes",
      ["q"] = "close_window",
      ["?"] = "show_help",
    },
  },
  filesystem = {
    filtered_items = {
      hide_dotfiles = false,
    },
    window = {
      mappings = {
        ["[g"] = "prev_git_modified",
        ["]g"] = "next_git_modified",
        ["."] = "set_root",
        ["<BS>"] = "navigate_up",
        ["zh"] = "toggle_hidden",
        ["/"] = "fuzzy_finder",
        ["f"] = "filter_on_submit",
        ["<C-c>"] = "clear_filter",
        ["o"] = "system_open",
        ["T"] = "trash",
      },
    },
    commands = {
      system_open = system_open,
      trash = trash,
      trash_visual = trash_visual
    },
    components = {
      -- Custom component for showing the harpoon index
      harpoon_index = harpoon_index,
    },
    renderers = {
      -- Add harpoon index
      file = {
        { "indent" },
        { "icon" },
        {
          "container",
          width = "100%",
          right_padding = 1,
          content = {
            {
              "name",
              use_git_status_colors = true,
              zindex = 10
            },
            { "harpoon_index", zindex = 10 },
            { "clipboard", zindex = 10 },
            { "bufnr", zindex = 10 },
            { "modified", zindex = 20, align = "right" },
            { "diagnostics", zindex = 20, align = "right" },
            { "git_status", zindex = 20, align = "right" },
          },
        },
      },
    },
  },
  event_handlers = {
    {
      event = "neo_tree_buffer_enter",
      handler = set_buffer_local_options,
    },
  },
}

-----------
-- Mappings
-----------

local map_ops = { silent = true }

vim.keymap.set('n', '<BS>t', ':Neotree toggle show<CR>', map_ops)
vim.keymap.set('n', '<Leader>tt', ':Neotree focus<CR>', map_ops)
vim.keymap.set('n', '<Leader>tf', ':Neotree reveal<CR>', map_ops)
vim.keymap.set('n', '<Leader>tr', function() require("neo-tree.sources.manager").refresh("filesystem") end, map_ops) -- refresh

----------------------------
-- nvim-window-picker config
----------------------------
require 'window-picker'.setup {
  filter_rules = {
    bo = {
      filetype = { 'aerial', 'neo-tree', 'neo-tree-popup', 'notify', 'qf' },
      buftype = { 'terminal' },
    },
  },
  other_win_hl_color = '#e35e4f',
}
