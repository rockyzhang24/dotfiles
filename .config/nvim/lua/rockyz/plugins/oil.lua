require('oil').setup({
  delete_to_trash = true,
  trash_command = 'trash -F',
  use_default_keymaps = false,
  keymaps = {
    ['g?'] = 'actions.show_help',
    ['<CR>'] = 'actions.select',
    ['<C-x>'] = 'actions.select_split',
    ['<C-v>'] = 'actions.select_vsplit',
    ['<C-t>'] = function()
      local cwd = require('oil').get_current_dir()
      local entry = require('oil').get_cursor_entry()
      vim.cmd('tab drop ' .. vim.fs.joinpath(cwd, entry.name))
    end,
    ['<C-_>'] = 'actions.preview',
    ['<C-c>'] = 'actions.close',
    ['<C-l>'] = 'actions.refresh',
    ['-'] = 'actions.parent',
    ['_'] = 'actions.open_cwd',
    ['`'] = 'actions.cd',
    ['~'] = 'actions.tcd',
    ['gs'] = 'actions.change_sort',
    ['g.'] = 'actions.toggle_hidden',
    ['gx'] = function()
      local cwd = require('oil').get_current_dir()
      local entry = require('oil').get_cursor_entry()
      vim.ui.open(vim.fs.joinpath(cwd, entry.name))
      vim.print(vim.fs.joinpath(cwd, entry.name))
    end,
  },
  view_options = {
    show_hidden = true,
  },
  float = {
    border = vim.g.border_style,
  },
  preview = {
    border = vim.g.border_style,
  },
  progress = {
    border = vim.g.border_style,
  },
})

-- Open Oil showing the parent directory of the file in the current buffer
vim.keymap.set('n', '-', '<Cmd>Oil<CR>')
