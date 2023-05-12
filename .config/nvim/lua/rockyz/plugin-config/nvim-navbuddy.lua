local navbuddy = require("nvim-navbuddy")
local actions = require("nvim-navbuddy.actions")
local map = require("rockyz.keymap").map
local theme = require("rockyz.plugin-config.telescope.theme")

navbuddy.setup {
  window = {
    size = {height = "40%", width = "100%" },
    position = { row = "100%", col = "0%" },
  },
  node_markers = {
    enabled = true,
    icons = {
      leaf = "",
      leaf_selected = "",
      branch = " ",
    },
  },
  mappings = {
    ["<esc>"] = actions.close(), -- Close and cursor to original location
    ["q"] = actions.close(),

    ["j"] = actions.next_sibling(), -- down
    ["k"] = actions.previous_sibling(), -- up

    ["h"] = actions.parent(), -- Move to left panel
    ["l"] = actions.children(), -- Move to right panel
    ["0"] = actions.root(), -- Move to first panel

    ["v"] = actions.visual_name(), -- Visual selection of name
    ["V"] = actions.visual_scope(), -- Visual selection of scope

    ["y"] = actions.yank_name(), -- Yank the name to system clipboard "+
    ["Y"] = actions.yank_scope(), -- Yank the scope to system clipboard "+

    ["i"] = actions.insert_name(), -- Insert at start of name
    ["I"] = actions.insert_scope(), -- Insert at start of scope

    ["a"] = actions.append_name(), -- Insert at end of name
    ["A"] = actions.append_scope(), -- Insert at end of scope

    ["r"] = actions.rename(), -- Rename currently focused symbol

    ["d"] = actions.delete(), -- Delete scope

    ["f"] = actions.fold_create(), -- Create fold of current scope
    ["F"] = actions.fold_delete(), -- Delete fold of current scope

    ["c"] = actions.comment(), -- Comment out current scope

    ["<enter>"] = actions.select(), -- Goto selected symbol
    ["o"] = actions.select(),

    ["J"] = actions.move_down(), -- Move focused node down
    ["K"] = actions.move_up(), -- Move focused node up

    ["t"] = actions.telescope(theme.get_ivy(true, 0.4)), -- Fuzzy finder at current level

    ["g?"] = actions.help(), -- Open mappings help window
  }
}

map('n', '<Leader>n', navbuddy.open)
