require('nvim-tree').setup {
  hijack_cursor = true,
  update_cwd = true,
  filters = {
    custom = { '.DS_Store' },
  },
  trash = {
    cmd = 'trash -F', -- for macOS https://hasseg.org/trash/
    require_confirm = true,
  },
  actions = {
    open_file = {
      window_picker = {
        enable = true,
        exclude = {
          filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame", "aerial" },
          buftype  = { "nofile", "terminal", "help", },
        },
      },
    },
  },
  view = {
    width = 40,
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
        { key = "<BS>", action = "dir_up" },
        { key = ".", action = "cd" },
        { key = "zi", action = "toggle_ignored" }, -- toggle visibility of files or directories in filters.custom list
        { key = "zh", action = "toggle_dotfiles" },
        { key = "T", action = "trash" },
        { key = "d", action = "remove" },
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
        { key = "zM", action = "collapse_all" },
        { key = "S", action = "search_node" },
        { key = "q", action = "close" },
        { key = "?", action = "toggle_help" },
      },
    },
  },
  renderer = {
    indent_markers = {
      enable = true,
    },
  },
  diagnostics = {
    enable = true,
  },
}

-- Mappings

local function find_file_no_focus()
  require "nvim-tree".find_file(true)
  vim.cmd "noautocmd wincmd p"
end

-- Toggle the tree
-- Two arguments in toggle() control whether the current file will be revealed,
-- and whether the tree is not focused.
vim.keymap.set('n', '<BS>t', function() require('nvim-tree').toggle(false, true) end, { silent = true })

vim.keymap.set('n', '<Leader>tt', '<Cmd>NvimTreeFocus<CR>', { silent = true })
vim.keymap.set('n', '<Leader>tf', find_file_no_focus, { silent = true })
vim.keymap.set('n', '<Leader>tr', '<Cmd>NvimTreeRefresh<CR>', { silent = true })
