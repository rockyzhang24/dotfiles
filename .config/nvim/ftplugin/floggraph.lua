local map = require('rockyz.keymap').map

local opts = {
  buffer = 0
}

-- git reset --mixed/hard
map("n", "rl", "<Cmd>exec flog#Format('Git reset %h')<CR>", opts)
map("n", "rh", "<Cmd>exec flog#Format('Git reset --hard %h')<CR>", opts)
-- git diff for each changed file in a new tab
map("n", "dt", "<Cmd>exec flog#Format('Git difftool -y %h')<CR>", opts)
-- Open the current commit in the browser
map("n", "ob", "<Cmd>exec flog#Format('GBrowse %h')<CR>", opts)
-- Update the arguments passed to "git log"
map("n", "ur", ":Flogsetargs -raw-args=", opts)
