require "lsp_signature".setup {
  bind = true,
  handler_opts = {
    border = "rounded",
  },
  floating_window = true,
  hint_enable = false,  -- disable virtual text hint
  hi_parameter = "IncSearch", -- highlight group used to highlight the current parameter
  toggle_key = "<M-x>", -- toggle signature on and off in insert mode
}
