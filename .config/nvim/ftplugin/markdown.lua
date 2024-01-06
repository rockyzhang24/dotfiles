-- Align the markdown table when typing |
vim.keymap.set('i', '<Bar>', "<Bar><Esc>:lua require('rockyz.utils').md_table_bar_align()<CR>a", {
  silent = true,
})
