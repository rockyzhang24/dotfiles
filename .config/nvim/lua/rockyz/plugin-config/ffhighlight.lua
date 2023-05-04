local map = require('rockyz.keymap').map
local fn = vim.fn

require('fFHighlight').setup({
  disable_keymap = false,
  disable_words_hl = false,
  number_hint_threshold = 3,
  prompt_sign_define = { text = '' }
})

-- Make f and F back to normal in Macro recording and executing
local opts = { expr = true }
map({ 'n', 'x' }, 'f', function()
  local macro_reg = fn.reg_recording() .. fn.reg_executing()
  return macro_reg == "" and "<Cmd>lua require('fFHighlight').findChar()<CR>" or "f"
end, opts)
map({ 'n', 'x' }, 'F', function()
  local macro_reg = fn.reg_recording() .. fn.reg_executing()
  return macro_reg == "" and "<Cmd>lua require('fFHighlight').findChar(true)<CR>" or "F"
end, opts)
