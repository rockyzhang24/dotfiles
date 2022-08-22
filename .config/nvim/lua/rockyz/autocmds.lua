local fn = vim.fn
local api = vim.api

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
