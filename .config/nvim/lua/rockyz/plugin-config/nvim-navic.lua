local navic = require("nvim-navic")
local codicon = require("rockyz.icons").codicon

navic.setup {
  -- Use codicon (VSCode like icons)
  icons = codicon,
  highlight = true,
  separator = "  ",
}
