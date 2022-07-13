require('fFHighlight').setup({
  disable_keymap = false,
  disable_words_hl = false,
  number_hint_threshold = 3,
  prompt_sign_define = { text = '' }
})

-- Make f and F back to normal in Macro recording and executing
local opts = { silent = true, expr = true }
vim.keymap.set({ 'n', 'x' }, 'f', function()
  local macro_reg = vim.fn.reg_recording() .. vim.fn.reg_executing()
  return macro_reg == "" and "<Cmd>lua require('fFHighlight').findChar()<CR>" or "f"
end, opts)
vim.keymap.set({ 'n', 'x' }, 'F', function()
  local macro_reg = vim.fn.reg_recording() .. vim.fn.reg_executing()
  return macro_reg == "" and "<Cmd>lua require('fFHighlight').findChar(true)<CR>" or "F"
end, opts)
