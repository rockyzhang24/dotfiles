require "lsp_signature".setup {
  bind = true,
  handler_opts = {
    border = "rounded",
  },
  floating_window = true,
  hint_enable = false,
  -- highlight group used to highlight the current parameter
  hi_parameter = "LspSignatureActiveParameter",
  -- toggle signature on and off in insert mode
  toggle_key = "<M-x>",
}
