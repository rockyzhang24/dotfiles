-- Dotfiles mangement
-- My dotfiles are managed via a bare repository. To make Vim recognize them and git related plugins
-- work on them, two envs GIT_DIR and GIT_WORK_TREE should be set when the current buffer holds a
-- dotfile.
local dotfiles_under_HOME = {
  'exclude',
  'README.md',
  '.gitignore',
  '.gitignore_global',
  '.zshenv',
}
local old_git_dir = nil
local old_work_tree = nil
local dot_git_dir = vim.env.HOME .. '/dotfiles'
local dot_work_tree = vim.env.HOME

local function update_git_env()
  local bufname = vim.api.nvim_buf_get_name(0)
  local inside_config = vim.startswith(bufname, vim.env.XDG_CONFIG_HOME)
  local inside_pack = vim.startswith(bufname, vim.env.XDG_CONFIG_HOME .. '/nvim/pack')
  if
    inside_config
    and not inside_pack
    or vim.list_contains(dotfiles_under_HOME, vim.fn.fnamemodify(bufname, ':t'))
  then
    -- Store the old envs
    if vim.env.GIT_DIR ~= '' and vim.env.GIT_DIR ~= dot_git_dir then
      old_git_dir = vim.env.GIT_DIR
    end
    if vim.env.GIT_WORK_TREE ~= '' and vim.env.GIT_WORK_TREE ~= dot_work_tree then
      old_work_tree = vim.env.GIT_WORK_TREE
    end
    -- Set envs
    vim.env.GIT_DIR = dot_git_dir
    vim.env.GIT_WORK_TREE = dot_work_tree
    return
  end
  -- Restore envs
  vim.env.GIT_DIR = old_git_dir
  vim.env.GIT_WORK_TREE = old_work_tree
end
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead', 'BufEnter' }, {
  group = vim.api.nvim_create_augroup('rockyz/dotfiles', {}),
  callback = function()
    update_git_env()
  end
})

-- Overwrite default settings in runtime/ftplugin
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('rockyz/overwrite_default_sets', {}),
  pattern = '*',
  callback = function()
    vim.opt.formatoptions:remove('t')
    vim.opt.formatoptions:remove('o')
    vim.opt.formatoptions:append('rn')
  end,
})

-- Jump to the position where you last quit (:h last-position-jump)
vim.api.nvim_create_autocmd('BufRead', {
  group = vim.api.nvim_create_augroup('rockyz/last_position_restore', {}),
  callback = function()
    vim.api.nvim_create_autocmd('FileType', {
      buffer = 0,
      once = true,
      callback = function()
        local line = vim.fn.line('\'"')
        if
          line >= 1
          and line <= vim.fn.line('$')
          and string.find(vim.bo.filetype, 'commit') == nil
          and vim.fn.index({ 'xxd', 'gitrebase' }, vim.bo.filetype) == -1
        then
          vim.cmd([[normal! g`"]])
        end
      end,
    })
  end,
})

-- Auto-create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  pattern = '*',
  group = vim.api.nvim_create_augroup('rockyz/auto_create_dir', {}),
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
  group = vim.api.nvim_create_augroup('rockyz/highlight_yank', {}),
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
  group = vim.api.nvim_create_augroup('rockyz/buffer_reload', {}),
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
local rnu_augroup = vim.api.nvim_create_augroup('rockyz/toggle_relative_number', {})
-- Toggle relative number on
vim.api.nvim_create_autocmd({ 'BufEnter', 'FocusGained', 'InsertLeave', 'CmdlineLeave', 'WinEnter' }, {
  group = rnu_augroup,
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
  group = rnu_augroup,
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
  group = vim.api.nvim_create_augroup('rockyz/cmdwin', {}),
  callback = function(args)
    -- Delete <CR> mapping (defined in treesitter for incremental selection and not work in
    -- command-line window)
    vim.keymap.del('n', '<CR>', { buffer = args.buf })
    -- Create a keymap to execute command and stay in the command-line window
    vim.keymap.set({ 'n', 'i' }, '<S-CR>', '<CR>q:', { buffer = args.buf })
  end,
})

-- Terminal
vim.api.nvim_create_autocmd({ 'TermOpen', 'BufWinEnter', 'WinEnter' }, {
  group = vim.api.nvim_create_augroup('rockyz/terminal', {}),
  pattern = 'term://*',
  command = 'startinsert',
})

-- Automatically equalize splits when Vim is resized
vim.api.nvim_create_autocmd('VimResized', {
  group = vim.api.nvim_create_augroup('rockyz/balance_splits', {}),
  command = 'wincmd =',
})
