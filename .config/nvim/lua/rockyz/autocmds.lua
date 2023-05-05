local fn = vim.fn
local api = vim.api
local cmd = vim.cmd

-- Auto-create dir when saving a file, in case some intermediate directory does not exist
api.nvim_create_augroup("auto_create_dir", {
  clear = true
})
api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = "*",
  group = "auto_create_dir",
  callback = function(ctx)
    local dir = fn.fnamemodify(ctx.file, ":p:h")
    local res = fn.isdirectory(dir)
    if res == 0 then
      fn.mkdir(dir, 'p')
    end
  end
})

-- Automatically toggle the relative and absolute numbers
-- Copy the code from https://github.com/sitiom/nvim-numbertoggle
local augroup = api.nvim_create_augroup("numbertoggle", { clear = true })
api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "CmdlineLeave", "WinEnter" }, {
  pattern = "*",
  group = augroup,
  callback = function()
    if vim.o.nu and api.nvim_get_mode().mode ~= "i" then
      vim.opt.relativenumber = true
    end
  end,
})
api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "CmdlineEnter", "WinLeave" }, {
  pattern = "*",
  group = augroup,
  callback = function()
    if vim.o.nu then
      vim.opt.relativenumber = false
      cmd("redraw")
    end
  end,
})
