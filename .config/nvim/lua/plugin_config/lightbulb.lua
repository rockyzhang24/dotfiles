require'nvim-lightbulb'.setup {
  sign = {
    enable = false,
  },
  float = {
        enabled = true,
        text = "💡",
        -- Available options see :h nvim_open_win()
        win_opts = {
          border = 'none',
        },
    },
}

vim.cmd [[autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()]]
