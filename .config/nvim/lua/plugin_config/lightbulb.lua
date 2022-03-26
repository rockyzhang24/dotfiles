require'nvim-lightbulb'.setup {
  sign = {
    enabled = false,
    priority = 99,
  },
  float = {
    enabled = true,
    text = "💡",
    win_opts = {
      border = 'none',
    },
  },
}

-- Modify the lightbulb sign (see :h sign-define)
vim.fn.sign_define('LightBulbSign', { text = "💡", texthl = "SignColumn", linehl = "", numhl = "" })

vim.cmd [[autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()]]
