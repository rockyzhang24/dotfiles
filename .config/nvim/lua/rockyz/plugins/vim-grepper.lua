vim.g.grepper = {
  dir = 'repo,file',
  repo = { '.git', '.hg', '.svn' },
  tools = { 'rg', 'git' },
  searchreg = 1,
  -- <C-/> to switch the tool
  prompt_mapping_tool = '<Leader>G',
  rg = {
    grepprg = 'rg -H --no-heading --vimgrep --smart-case',
    grepformat = '%f:%l:%c:%m,%f',
    escape = '\\^$.*+?()[]{}|',
  },
}

-- Keymaps
vim.keymap.set('n', '<Leader>G', '<Cmd>Grepper<CR>')
vim.keymap.set({ 'n', 'x' }, 'gs', '<Plug>(GrepperOperator)', { remap = true }) -- operator
