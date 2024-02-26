local opts = {
  buffer = true
}

-- git reset --mixed/hard
vim.keymap.set("n", "rm", "<Cmd>exec flog#Format('Git reset %h')<CR>", opts)
vim.keymap.set("n", "rh", "<Cmd>exec flog#Format('Git reset --hard %h')<CR>", opts)
-- git diff for each changed file in a new tab
vim.keymap.set("n", "dt", "<Cmd>exec flog#Format('Git difftool -y %h')<CR>", opts)
-- Open the current commit in the browser
vim.keymap.set("n", "o", "<Cmd>exec flog#Format('GBrowse %h')<CR>", opts)
-- Update the arguments passed to "git log" (ra for reset args)
vim.keymap.set("n", "ra", ":Flogsetargs -raw-args=", opts)
