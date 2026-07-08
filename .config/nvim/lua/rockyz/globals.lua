-- UI theme
-- Available colorschemes: arctic, monokai, better_default_light, gruvbox
vim.g.colorscheme = 'gruvbox'
if vim.g.colorscheme == 'gruvbox' then
    vim.g.gruvbox_contrast = 'normal' -- 'normal', 'soft' or 'hard'
end
vim.g.dark_background = true
vim.g.italic_enabled = false
vim.g.transparent_background = false

-- UI chrome
vim.g.border_enabled = true
vim.g.border_style = vim.g.border_enabled and 'rounded' or 'none'

-- Feature toggles
vim.g.indentscope_enabled = true
vim.g.inlay_hint_enabled = false
vim.g.autoformat = false -- Format on save

-- Big files use 'bigfile' filetype when either the file size or average line length exceeds the
-- threshold below. This keeps builtin syntax highlighting but disables heavier features such as LSP
-- and Treesitter.
vim.g.bigfile_size_threshold = 1024 * 1024 * 1.5 -- 1.5 MB
vim.g.bigfile_line_length_threshold = 1000
