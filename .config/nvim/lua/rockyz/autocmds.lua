-- Dotfiles mangement
-- My dotfiles are managed via a bare repository. To make Vim recognize them and git related plugins
-- work on them, the git-dir and work-tree should be set (via GIT_DIR and GIT_WORK_TREE env) when
-- the current buffer contains dotfile. We should also reset them when entering other buffers so
-- that the normal repository will be recognized.
local dotfiles_under_HOME = {
  'exclude',
  'README.md',
  '.gitignore',
  '.gitignore_global',
  '.zshenv',
}
local function update_git_env()
  local bufname = vim.api.nvim_buf_get_name(0)
  local ok, inside_config = pcall(vim.startswith, bufname, vim.env.XDG_CONFIG_HOME)
  if
    ok and inside_config
    or vim.list_contains(dotfiles_under_HOME, vim.fn.fnamemodify(bufname, ':t'))
  then
    -- Set git env
    vim.env.GIT_DIR = vim.env.HOME .. '/dotfiles'
    vim.env.GIT_WORK_TREE = vim.env.HOME
    return
  end
  -- Reset
  vim.env.GIT_DIR = nil
  vim.env.GIT_WORK_TREE = nil
end
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead', 'BufEnter' }, {
  group = vim.api.nvim_create_augroup('rockyz/dotfiles', { clear = true }),
  callback = function()
    update_git_env()
  end
})

-- Auto-create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  pattern = '*',
  group = vim.api.nvim_create_augroup('auto_create_dir', { clear = true }),
  callback = function(ctx)
    -- Prevent oil.nivm from creating an extra oil:/ dir when we create a
    -- file/dir
    if vim.bo.ft == 'oil' then
      return
    end
    local dir = vim.fn.fnamemodify(ctx.file, ':p:h')
    local res = vim.fn.isdirectory(dir)
    if res == 0 then
      vim.fn.mkdir(dir, 'p')
    end
  end,
})

-- Highlight the selections on yank
vim.api.nvim_create_autocmd({ 'TextYankPost' }, {
  group = vim.api.nvim_create_augroup('highlight_yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank({ timeout = 300 })
  end,
})

-- Reload buffer if it is modified outside neovim
vim.api.nvim_create_autocmd({
  'FocusGained',
  'BufEnter',
  'CursorHold',
}, {
  group = vim.api.nvim_create_augroup('buffer_reload', { clear = true }),
  callback = function()
    if vim.fn.getcmdwintype() == '' then
      vim.cmd('checktime')
    end
  end,
})

-- Automatically toggle relative number
-- Ref: https://github.com/MariaSolOs/dotfiles
local exclude_ft = {
  'qf',
}
local function tbl_contains(t, value)
  for _, v in ipairs(t) do
    if v == value then
      return true
    end
  end
  return false
end
local relative_number_group = vim.api.nvim_create_augroup('toggle_relative_number', {})
-- Toggle relative number on
vim.api.nvim_create_autocmd({ 'BufEnter', 'FocusGained', 'InsertLeave', 'CmdlineLeave', 'WinEnter' }, {
  group = relative_number_group,
  callback = function()
    if tbl_contains(exclude_ft, vim.bo.filetype) then
      return
    end
    if vim.wo.nu and not vim.startswith(vim.api.nvim_get_mode().mode, 'i') then
      vim.wo.relativenumber = true
    end
  end,
})
-- Toggle relative number off
vim.api.nvim_create_autocmd({ 'BufLeave', 'FocusLost', 'InsertEnter', 'CmdlineEnter', 'WinLeave' }, {
  group = relative_number_group,
  callback = function(args)
    if tbl_contains(exclude_ft, vim.bo.filetype) then
      return
    end
    if vim.wo.nu then
      vim.wo.relativenumber = false
    end
    -- Redraw here to avoid having to first write something for the line numbers to update.
    if args.event == 'CmdlineEnter' then
      vim.cmd.redraw()
    end
  end,
})

-- Command-line window
vim.api.nvim_create_autocmd('CmdWinEnter', {
  group = vim.api.nvim_create_augroup('execute_cmd_and_stay', { clear = true }),
  callback = function(args)
    -- Delete <CR> mapping (defined in treesitter for incremental selection and not work in
    -- command-line window)
    vim.keymap.del('n', '<CR>', { buffer = args.buf })
    -- Create a keymap to execute command and stay in the command-line window
    vim.keymap.set({ 'n', 'i' }, '<S-CR>', '<CR>q:', { buffer = args.buf })
  end,
})
