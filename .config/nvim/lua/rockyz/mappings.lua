local api = vim.api
local map = require("rockyz.keymap").map

-- Use blackhole register if we delete empty line by dd
local smart_dd = function()
  if api.nvim_get_current_line():match("^%s*$") then
    return "\"_dd"
  else
    return "dd"
  end
end
map("n", "dd", smart_dd, { expr = true })

-- Make i indent properly on empty line
local smart_i = function()
  if #vim.fn.getline(".") == 0 then
    return [["_cc]]
  else
    return "i"
  end
end
map("n", "i", smart_i, { expr = true })

-- Toggle the layout (horizontal and vertical) of the TWO windows
local toggle_win_layout = function()
  local wins = api.nvim_tabpage_list_wins(0)
  if #wins > 2 then
    print("Layout toggling only works for two windows.")
    return
  end
  -- pos is {row, col}
  local pos1 = api.nvim_win_get_position(wins[1])
  local pos2 = api.nvim_win_get_position(wins[2])
  local key_codes = ""
  if pos1[1] == pos2[1] then
    key_codes = api.nvim_replace_termcodes("<C-w>t<C-w>K", true, false, true)
  else
    key_codes = api.nvim_replace_termcodes("<C-w>t<C-w>H", true, false, true)
  end
  api.nvim_feedkeys(key_codes, "m", false)
end
map("n", "<Leader>wl", toggle_win_layout)

map("n", "qc", require("rockyz.qf").close) -- close quickfix or location list window
map("n", "qd", require("rockyz.utils").close_diff)  -- close diff windows
map('n', 'qD', [[<Cmd>tabdo lua require("rockyz.utils").close_diff()<CR>]]) -- close diff windows in all tabs

-- Show a prompt to open quickfix and/or location list
map('n', '<Leader>o', require('rockyz.qf').open)

-- Use %% to get the absolute filepath of the current buffer in command-line
-- mode
local get_abs_path = function()
  vim.api.nvim_feedkeys(vim.fn.expand('%:p:h') .. '/', 'c', false)
end
map("c", "%%", get_abs_path)
