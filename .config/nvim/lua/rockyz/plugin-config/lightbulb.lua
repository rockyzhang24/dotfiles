require('nvim-lightbulb').setup {
  sign = {
    enabled = false,
    priority = 20,
  },
  float = {
    enabled = true,
    text = "💡",
    win_opts = {
      border = 'none',
    },
  },
  autocmd = {
    enabled = true,
  },
}

-- Modify the lightbulb sign (see :h sign-define)
vim.fn.sign_define('LightBulbSign', { text = "💡", texthl = "SignColumn", linehl = "", numhl = "" })
