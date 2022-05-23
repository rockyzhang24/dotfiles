local cmd = vim.cmd
-- Better highlighting (highlight the range) for the quickfix stuffed by vim-grepper
cmd(([[
  aug Grepper
    au!
    au User Grepper ++nested %s
  aug END
]]):format([[call setqflist([], 'r', {'context': {'bqf': {'pattern_hl': '\%#' . getreg('/')}}})]]))

require('bqf').setup {
  filter = {
    fzf = {
      extra_opts = { '--delimiter', '│' }
    }
  }
}
