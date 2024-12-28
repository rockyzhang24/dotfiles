vim.g.colorscheme = 'arctic'
vim.g.transparent = false
vim.g.border_enabled = true
vim.g.border_style = vim.g.border_enabled and 'rounded' or 'none'
vim.g.indentline_char = '|'

-- Set filetype to 'bigfile' for files larger than 1.5 MB
-- Only vim syntax will be enabled (with correct filetype)
-- LSP, treesitter and other ft plugins will be disabled.
vim.g.bigfile_size = 1024 * 1024 * 1.5

-- Global autoformat (format-on-save)
vim.g.autoformat = false
