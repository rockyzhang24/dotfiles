vim.cmd([[
let g:nvim_tree_indent_markers = 1
]])

require'nvim-tree'.setup {
  auto_close = true,
  hijack_cursor = true,
  filters = {
    custom = {'.DS_Store'},
  },
  diagnostics = {
    enable = true,
    show_on_dirs = true,
  },
  view = {
    mappings = {
      custom_only = true,
      list = {
        -- Mappings to suit my taste and be consistent with lf
        { key = "<CR>", action = "edit" },
        { key = "O", action = "edit_no_picker" },
        { key = "<C-v>", action = "vsplit" },
        { key = "<C-x>", action = "split" },
        { key = "<C-t>", action = "tabnew" },
        { key = "<", action = "prev_sibling" },
        { key = ">", action = "next_sibling" },
        { key = "P", action = "parent_node" },
        { key = "zc", action = "close_node" },
        { key = "<Tab>", action = "preview" },
        { key = "K", action = "first_sibling" },
        { key = "J", action = "last_sibling" },
        { key = "R", action = "refresh" },
        { key = "h", action = "dir_up" },
        { key = "l", action = "cd" },
        { key = "zi", action = "toggle_ignored" },  -- toggle visibility of files or directories in filters.custom list
        { key = "zh", action = "toggle_dotfiles" },
        { key = "T", action = "trash" },
        { key = "D", action = "remove" },
        { key = "yy", action = "copy" },
        { key = "x", action = "cut" },
        { key = "p", action = "paste" },
        { key = "<C-n>", action = "create" }, -- create a file, or a directory by appending `/`
        { key = "r", action = "rename" },
        { key = "<C-r>", action = "full_rename" },
        { key = "[g", action = "prev_git_item" },
        { key = "]g", action = "next_git_item" },
        { key = "o", action = "system_open" },
        { key = "yn", action = "copy_name" },
        { key = "yp", action = "copy_path" },
        { key = "yP", action = "copy_absolute_path" },
        { key = "q", action = "close" },
        { key = "?", action = "toggle_help" },
      },
    },
  },
}

vim.keymap.set('n', '\\t', '<Cmd>NvimTreeToggle<CR>', {silent = true})
vim.keymap.set('n', '<Leader>tt', '<Cmd>NvimTreeFocus<CR>', {silent = true})
vim.keymap.set('n', '<Leader>tf', '<Cmd>NvimTreeFindFile<CR>', {silent = true})
