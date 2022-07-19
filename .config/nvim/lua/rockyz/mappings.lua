-- Use blackhole register if we delete empty line by dd
local function smart_dd()
  if vim.api.nvim_get_current_line():match("^%s*$") then
    return "\"_dd"
  else
    return "dd"
  end
end

vim.keymap.set("n", "dd", smart_dd, { expr = true })
