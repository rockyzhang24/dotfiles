local opts = {
  buffer = true,
  silent = true,
}

-- Align the markdown table when typing |
vim.keymap.set('i', '<Bar>', "<Bar><Esc>:lua require('rockyz.utils').md_table_bar_align()<CR>a", opts)

-- Open the current markdown via Marked 2 for preview
vim.keymap.set('n', '<Leader>v', function()
  vim.system({ 'open', '-a', 'Marked 2', vim.fn.bufname() }, {}, nil)
end, opts)
