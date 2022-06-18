local palette = require('nightfox.palette').load('nightfox')
local spec = require('nightfox.spec').load("nightfox")
local Color = require("nightfox.lib.color")
-- Color for nbsp, space, tab, trail in listchars
local whitespace = Color.from_hex(palette.bg2):shade(0.2):to_css()
-- Color for indent lines
local indentline = Color.from_hex(palette.bg2):shade(0.1):to_css()
-- Color for comments
local comment = Color.from_hex(spec.syntax.comment):shade(0.15):to_css()
-- Color for LSP references highlight
local lsp_references = indentline

require('nightfox').setup {
  options = {
    styles = {
      comments = "italic",
      types = "NONE",
      keywords = "NONE",
      functions = "NONE",
      numbers = "NONE",
      strings = "NONE",
      variables = "NONE",
    },
  },
  specs = {
    nightfox = {
      syntax = {
        comment = comment,
      },
    },
  },
  groups = {
    nightfox = {
      Whitespace = { fg = whitespace },
      CursorLine = { bg = "palette.bg2" },
      LspReferenceRead = { bg = lsp_references },
      LspReferenceText = { bg = lsp_references },
      LspReferenceWrite = { bg = lsp_references },
      IndentBlanklineChar = { fg = indentline },
      Visual = { bg = "#264F78" },
      IncSearch = { fg = "palette.black.dim", bg = "palette.red" },
      Search = { fg = "palette.black.dim", bg = "palette.green" },
      HlSearchLens = { fg = "palette.fg0", bg = "palette.sel1" },
    },
  },
}

-- Default palette shipped with nightfox

-- black   #393b44
-- red     #c94f6d
-- green   #81b29a
-- yellow  #dbc074
-- blue    #719cd6
-- magenta #9d79d6
-- cyan    #63cdcf
-- white   #dfdfe0
-- orange  #f4a261
-- pink    #d67ad2

-- comment #526176

-- bg0     #131a24
-- bg1     #192330
-- bg2     #212e3f
-- bg3     #29394e
-- bg4     #415166

-- fg0     #d6d6d7
-- fg1     #cdcecf
-- fg2     #aeafb0
-- fg3     #71839b

-- sel0    #223249
-- sel1    #3a567d
