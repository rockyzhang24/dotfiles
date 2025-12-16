vim.g.colorscheme = 'monokai'
vim.g.transparent = false
vim.g.border_enabled = true
vim.g.border_style = vim.g.border_enabled and 'rounded' or 'none'
vim.g.indentscope_enabled = true
vim.g.inlay_hint_enabled = false
vim.g.autoformat = false -- global autoformat (format-on-save)
vim.g.scrollbar_enabled = true

-- Set filetype to 'bigfile' for files larger than the size threshold or the average line length
-- exceeds the line length threshold (useful for minified file).
-- Only vim builtin syntax highlight will be enabled (with correct filetype).
-- Some LSP and Treesitter features will be disabled.
vim.g.bigfile_size = 1024 * 1024 * 1.5 -- 1.5 MB
vim.g.bigfile_line_length = 1000

-- Can be 'default', 'ivy'
vim.g.fzf_theme = 'ivy'
