local g = vim.g
local map = require('rockyz.keymap').map

g.grepper = {
  dir = 'repo,file',
  repo = { '.git', '.hg', '.svn' },
  tools = { 'rg', 'git' },
  searchreg = 1,
  prompt_mapping_tool = '<Leader>G',
  rg = {
    grepprg = 'rg -H --no-heading --vimgrep --smart-case',
    grepformat = '%f:%l:%c:%m,%f',
    escape = '\\^$.*+?()[]{}|',
  }
}

map({ 'n', 'x' }, 'gs', '<Plug>(GrepperOperator)', { remap = true }) -- operator
map('n', '<Leader>G', '<Cmd>Grepper<CR>')
