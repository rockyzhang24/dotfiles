require'nvim-lightbulb'.setup {
  sign = {
    enable = true,
  },
}

-- Modify the lightbulb sign (see :h sign-define)
vim.fn.sign_define('LightBulbSign', { text = "💡", texthl = "SignColumn", linehl="", numhl="" })

vim.cmd [[autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()]]
