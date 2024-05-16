local norm_fg = '#cccccc'
local norm_bg = '#1f1f1f'

local dark_red = '#D16969'
local orange = '#f9ae28'
local brown = '#CE9178'
local yellow = '#DCDCAA'
local yellow_orange = '#D7BA7D'
local green = '#6A9955'
local blue_green = '#4EC9B0'
local light_green = '#B5CEA8'
local blue = '#4fc1ff'
local blue2 = '#2aaaff'
local light_blue = '#9CDCFE'
local dark_blue = '#569CD6'
local cornflower_blue = '#6796E6'
local dark_pink = '#C586C0'
local bright_pink = '#f92672'
local purple = '#ae81ff'

local white = '#ffffff'
local gray = '#51504f' -- StatuslineNC's fg
local gray2 = '#6e7681' -- LineNr (editorLineNumber.foreground)
local gray3 = '#808080'
local gray4 = '#9d9d9d'
local black = '#2d2d2d' -- TabLine
local black2 = '#252526'
local black3 = '#282828' -- CursorLine (editor.lineHighlightBorder). Or use #2a2d2e (list.hoverBackground) for a brighter color
local black4 = '#181818' -- Statusline and Tabline
local pure_black = '#000000'

local error_red = '#F14C4C'
local warn_yellow = '#CCA700'
local info_blue = '#3794ff'
local hint_gray = '#B0B0B0'
local ok_green = '#89d185' -- color for success, so I use notebookStatusSuccessIcon.foreground

local gutter_git_added = '#2ea043'
local gutter_git_deleted = '#f85149'
local gutter_git_modified = '#0078d4'

local selection_blue = '#04395e'
local folded_blue = '#212d3a' -- editor.foldBackground
local float_border_fg = '#454545'
local indent_guide_fg = '#404040'
local indent_guide_scope_fg = '#707070'
local label_fg = '#c8c8c8'
local tab_border_fg = '#2b2b2b'

local statusline_blue = '#007acc'
local statusline_orange = '#cc6633'
local statusline_purple = '#68217a'
local statusline_pink = '#c586c0'
local statusline_green = '#16825d'
local statusline_violet = '#646695'
local statusline_red = '#c72e0f'
local statusline_yellow = '#E8AB53'
local statusline_gray = '#858585'

local groups = {

  --
  -- Preset
  --
  FloatBorder = { fg = float_border_fg },
  SelectionHighlightBackground = { bg = '#343a41' }, -- editor.selectionHighlightBackground
  LightBulb = { fg = '#ffcc00' }, -- editorLightBulb.foreground
  CodeLens = { fg = '#999999' }, -- editorCodeLens.foreground
  GutterGitAdded = { fg = gutter_git_added }, -- editorGutter.addedBackground
  GutterGitDeleted = { fg = gutter_git_deleted }, -- editorGutter.deletedBackground
  GutterGitModified = { fg = gutter_git_modified }, -- editorGutter.modifiedBackground
  Breadcrumb = { fg = '#a9a9a9', bg = norm_bg, underline = true, sp = pure_black }, -- breadcrumb.foreground/background
  ScrollbarSlider = { bg = '#434343' }, -- the slider on the scrollbar (scrollbarSlider.activeBackground)
  ScrollbarSliderHover = { bg = '#4f4f4f' }, -- scrollbarSlider.hoverBackground
  PeekViewBorder = { fg = '#3794ff' },
  PeekViewNormal = { bg = norm_bg }, -- peekViewEditor.background
  PeekViewTitle = { fg = white }, -- peekViewTitleLabel.foreground
  PeekViewCursorLine = { bg = black3 },
  PeekViewMatchHighlight = { bg ='#5d4616' }, -- peekViewEditor.matchHighlightBackground
  GhostText = { fg = '#6b6b6b' }, -- editorGhostText.foreground
  Icon = { fg = '#cccccc' }, -- icon.foreground
  Description = { fg = gray4 }, -- descriptionForeground
  ProgressBar = { fg = '#0078d4' }, -- progressBar.background
  MatchedCharacters = { fg = blue2 }, -- editorSuggestWidget.highlightForeground
  Hint = "MatchedCharacters", -- for the hint letter in options, e.g., the q in [q]uickfix
  -- For the unused code, use Identifier's fg (9cdcfe) as the base color,
  -- editorUnnecessaryCode.opacity is 000000aa (the alpha value is aa),
  -- so the color will be 9cdcfeaa. Converting hexa to hex gets 729db4.
  UnnecessaryCode = { fg = '#729db4' },
  -- Git diff
  DiffTextAdded = { bg = '#214d29' }, -- diffEditor.insertedTextBackground (DiffLineAdded as its background)
  DiffTextDeleted = { bg = '#712928' }, -- diffEditor.removedTextBackground (DiffLineDeleted as its background)
  DiffTextChanged = { bg = '#0E2FDC' },
  DiffLineAdded = { bg = '#203424' }, -- diffEditor.insertedLineBackground
  DiffLineDeleted = { bg = '#442423' }, -- diffEditor.removedLineBackground
  DiffLineChanged = { bg = '#0e2f44' },
  -- Quickfix list (can be used to define qf syntax, e.g.,
  -- ~/.config/nvim/syntax/qf.vim)
  QfFileName = { fg = white },
  QfSelection = { bg = '#3a3d41' }, -- terminal.inactiveSelectionBackground
  QfText = { fg = '#bbbbbb' }, -- normal text in quickfix list (peekViewResult.lineForeground)
  -- Inline hints
  InlayHint = { fg = '#969696', bg = '#242424' }, -- editorInlayHint.foreground/background
  InlayHintType = "InlayHint", -- editorInlayHint.typeBackground/typeForeground
  -- Winbar
  WinbarHeader = { fg = white, bg = statusline_blue }, -- the very beginning part of winbar
  WinbarTriangleSep = { fg = statusline_blue, underline = true, sp = pure_black }, -- the triangle separator in winbar
  WinbarModified = { fg = norm_fg, bg = norm_bg, underline = true, sp = pure_black }, -- the modification indicator

  --
  -- Editor
  --
  CursorLine = { bg = black3 },
  CursorColumn = { bg = black3 },
  ColorColumn = { bg = black2 }, -- #5a5a5a in VSCode (editorRuler.foreground) it's too bright
  Conceal = { fg = gray2 },
  Cursor = { fg = norm_bg, bg = norm_fg },
  -- lCursor = { },
  -- CursorIM = { },
  Directory = { fg = dark_blue },
  DiffAdd = "DiffLineAdded",
  DiffDelete = "DiffLineDeleted",
  DiffChange = "DiffLineChanged",
  DiffText = "DiffTextChanged",
  EndOfBuffer = { fg = norm_bg },
  -- TermCursor = { },
  -- TermCursorNC = { },
  ErrorMsg = { fg = error_red },
  WinSeparator = { fg = '#333333' }, -- editorGroup.border
  VirtSplit = "WinSeparator", -- deprecated and use WinSeparator instead
  LineNr = { fg = gray2 }, -- editorLineNumber.foreground
  CursorLineNr = { fg = '#cccccc' }, -- editorLineNumber.activeForeground
  Folded = { bg = folded_blue },
  CursorLineFold = "CursorLineNr",
  FoldColumn = "LineNr", -- #c5c5c5 in VSCode (editorGutter.foldingControlForeground) and it's too bright
  SignColumn = { bg = norm_bg },
  IncSearch = { bg = '#9e6a03' }, -- editor.findMatchBackground
  -- Substitute = { },
  MatchParen = { bg = gray, bold = true, underline = true },
  ModeMsg = { fg = norm_fg },
  MsgArea = { fg = norm_fg },
  -- MsgSeparator = { },
  MoreMsg = { fg = norm_fg },
  NonText = { fg = gray2 },
  Normal = { fg = norm_fg, bg = norm_bg },
  -- NormalNC = { },
  Pmenu = { fg = norm_fg, bg = norm_bg }, -- editorSuggestWidget.background/foreground
  PmenuSel = { fg = white, bg = selection_blue },
  PmenuSbar = { bg = norm_bg },
  PmenuThumb = "ScrollbarSlider",
  NormalFloat = "Pmenu",
  Question = { fg = dark_blue },
  QuickFixLine = "QfSelection",
  Search = { bg = '#623315' }, -- editor.findMatchHighlightBackground
  SpecialKey = "NonText",
  SpellBad = { undercurl = true, sp = error_red },
  SpellCap = { undercurl = true, sp = warn_yellow},
  SpellLocal = { undercurl = true, sp = info_blue },
  SpellRare  = { undercurl = true, sp = info_blue  },
  StatusLine = { bg = black4 },
  StatusLineNC = { fg = gray, bg = black4 },
  TabLine = { fg = gray4, bg = black4, underline = true, sp = tab_border_fg }, -- tab.inactiveBackground, tab.inactiveForeground
  TabLineFill = { fg = 'NONE', bg = black4, underline = true, sp = tab_border_fg }, -- editorGroupHeader.tabsBackground
  TabLineSel = { fg = white, bg = norm_bg, bold = true, underline = true, sp = tab_border_fg }, -- tab.activeBackground, tab.activeForeground
  Title = { fg = dark_blue, bold = true },
  Visual = { bg = '#264F78' }, -- editor.selectionBackground
  -- VisualNOS = { },
  WarningMsg = { fg = warn_yellow },
  Whitespace = { fg = '#3e3e3d' },
  WildMenu = "PmenuSel",
  Winbar = "Breadcrumb",
  WinbarNC = "Breadcrumb",

  --
  -- Statusline
  --
  StlModeNormal = { fg = white, bg = statusline_blue },
  StlModeInsert = { fg = white, bg = statusline_orange },
  StlModeVisual = { fg = white, bg = statusline_purple },
  StlModeReplace = { fg = white, bg = statusline_pink },
  StlModeCommand = { fg = white, bg = statusline_green },
  StlModeTerminal = { fg = white, bg = statusline_violet },
  StlModePending = { fg = white, bg = statusline_red },

  StlModeSepNormal = { fg = statusline_blue, bg = black4 },
  StlModeSepInsert = { fg = statusline_orange, bg = black4 },
  StlModeSepVisual = { fg = statusline_purple, bg = black4 },
  StlModeSepReplace = { fg = statusline_pink, bg = black4 },
  StlModeSepCommand = { fg = statusline_green, bg = black4 },
  StlModeSepTerminal = { fg = statusline_violet, bg = black4 },
  StlModeSepPending = { fg = statusline_red, bg = black4 },

  StlIcon = { fg = statusline_yellow, bg = black4 },

  -- The status of the component. E.g., for treesitter component
  -- * the current buffer has no treesitter parser: StlComponentInactive
  -- * it has treesitter parser, but treesitter highlight is on/off: StlComponentOn/StlComponentOff
  StlComponentInactive = { fg = statusline_gray, bg = black4 },
  StlComponentOn = { fg = statusline_green, bg = black4 },
  StlComponentOff = { fg = statusline_red, bg = black4 },

  StlGitadded = { fg = gutter_git_added, bg = black4 },
  StlGitdeleted = { fg = gutter_git_deleted, bg = black4 },
  StlGitmodified = { fg = gutter_git_modified, bg = black4 },

  StlDiagnosticERROR = "DiagnosticError",
  StlDiagnosticWARN = "DiagnosticWarn",
  StlDiagnosticINFO = "DiagnosticInfo",
  StlDiagnosticHINT = "DiagnosticHint",

  StlSearchCnt = { fg = statusline_orange, bg = black4 },

  StlMacroRecording = "StlComponentOff",
  StlMacroRecorded = "StlComponentOn",

  StlFiletype = { fg = white, bg = black4, bold = true },

  StlLocComponent = "StlModeNormal",
  StlLocComponentSep = "StlModeSepNormal",

  --
  -- Syntax
  --
  Comment = { fg = green, italic = true },

  Constant = { fg = dark_blue },
  String = { fg = brown },
  Character = "Constant",
  Number = { fg = light_green },
  Boolean = "Constant",
  Float = "Number",

  Identifier = { fg = light_blue },
  Function = { fg = yellow },

  Statement = { fg = dark_pink },
  Conditional = "Statement",
  Repeat = "Statement",
  Label = "Statement",
  Operator = { fg = norm_fg },
  Keyword = { fg = dark_blue },
  Exception = "Statement",

  PreProc = { fg = dark_pink },
  Include = "PreProc",
  Define = "PreProc",
  Macro = "PreProc",
  PreCondit = "PreProc",

  Type = { fg = dark_blue },
  StorageClass = "Type",
  Structure = "Type",
  Typedef = "Type",

  Special = { fg = yellow_orange },
  SpecialChar = "Special",
  Tag = "Special",
  Delimiter = "Special",
  SpecialComment = "Special",
  Debug = "Special",

  Underlined = { underline = true },
  -- Ignore = { },
  Error = { fg = error_red },
  Todo = { fg = norm_bg, bg = yellow_orange, bold = true },

  --
  -- diff
  --
  -- VSCode doesn't have foreground for git added/removed/changed, so here I
  -- use the corresponding colors for gutter instead.
  diffAdded = "GutterGitAdded",
  diffRemoved = "GutterGitDeleted",
  diffChanged = "GutterGitModified",

  --
  -- LSP
  --
  LspReferenceText = "SelectionHighlightBackground",
  LspReferenceRead = "SelectionHighlightBackground",
  LspReferenceWrite = "SelectionHighlightBackground",
  LspCodeLens = "CodeLens",
  -- LspCodeLensSeparator = { }, -- Used to color the seperator between two or more code lens.
  LspSignatureActiveParameter = "MatchedCharacters",
  LspInlayHint = "InlayHint",

  --
  -- Diagnostics
  --
  DiagnosticError = { fg = error_red },
  DiagnosticWarn = { fg = warn_yellow },
  DiagnosticInfo = { fg = info_blue },
  DiagnosticHint = { fg = hint_gray },
  DiagnosticOk = { fg = ok_green },
  DiagnosticVirtualTextError = { fg = error_red, bg = '#332323' },
  DiagnosticVirtualTextWarn = { fg = warn_yellow, bg = '#2f2c1b' },
  DiagnosticVirtualTextInfo = { fg = info_blue, bg = '#212a35' },
  DiagnosticVirtualTextHint = { fg = hint_gray, bg = black },
  DiagnosticVirtualTextOk = { fg = ok_green, bg = '#233323' },
  DiagnosticUnderlineError = { undercurl = true, sp = error_red },
  DiagnosticUnderlineWarn = { undercurl = true, sp = warn_yellow },
  DiagnosticUnderlineInfo = { undercurl = true, sp = info_blue },
  DiagnosticUnderlineHint = { undercurl = true, sp = hint_gray },
  DiagnosticUnderlineOk = { undercurl = true, sp = ok_green },
  DiagnosticFloatingError = "DiagnosticError",
  DiagnosticFloatingWarn = "DiagnosticWarn",
  DiagnosticFloatingInfo = "DiagnosticInfo",
  DiagnosticFloatingHint = "DiagnosticHint",
  DiagnosticFloatingOk = "DiagnosticOk",
  DiagnosticSignError = "DiagnosticError",
  DiagnosticSignWarn = "DiagnosticWarn",
  DiagnosticSignInfo = "DiagnosticInfo",
  DiagnosticSignHint = "DiagnosticHint",
  DiagnosticSignOk = "DiagnosticOk",
  DiagnosticUnnecessary = "UnnecessaryCode",
  DiagnosticDeprecated = { fg = gray3, strikethrough = true },

  --
  -- Treesitter
  --
  -- Now use the capture names directly as the highlight groups.
  -- To find all the capture names, see https://github.com/nvim-treesitter/nvim-treesitter/blob/master/CONTRIBUTING.md#highlights)

  -- Identifiers
  ["@variable"] = { fg = light_blue }, -- various variable names
  ["@variable.builtin"] = { fg = dark_blue }, -- built-in variable names (e.g. `this`)
  ["@variable.parameter"] = { fg = orange }, -- parameters of a function, use a conspicuous color (VSCode uses the common light_blue)
  ["@variable.parameter.builtin"] = "@variable.parameter", -- special parameters (e.g. `_`, `it`)
  ["@variable.member"] = { fg = light_blue }, -- object and struct fields

  ["@constant"] = "Constant", -- constant identifiers
  ["@constant.builtin"] = "Constant", -- built-in constant values
  ["@constant.macro"] = "Constant", -- constants defined by the preprocessor

  ["@module"] = { fg = blue_green }, -- modules or namespaces
  ["@module.builtin"] = "@module", -- built-in modules or namespaces
  ["@label"] = { fg = label_fg }, -- GOTO and other labels (e.g. `label:` in C), including heredoc labels

  -- Literals
  ["@string"] = "String", -- string literals
  ["@string.documentation"] = { fg = brown }, -- string documenting code (e.g. Python docstrings)
  ["@string.regexp"] = { fg = dark_red }, -- regular expressions
  ["@string.escape"] = { fg = yellow_orange }, -- escape sequences
  ["@string.special"] = "SpecialChar", -- other special strings (e.g. dates)
  ["@string.special.symbol"] = "@string.special", -- symbols or atoms
  ["@string.special.url"] = "@string.special", -- URIs (e.g. hyperlinks), it's url outside markup
  ["@string.special.path"] = "@string.special", -- filenames

  ["@character"] = "Character", -- character literals
  ["@character.special"] = "SpecialChar", -- special characters (e.g. wildcards)

  ["@boolean"] = "Boolean", -- boolean literals
  ["@number"] = "Number", -- numeric literals
  ["@number.float"] = "Float", -- floating-point number literals

  -- Types
  ["@type"] = { fg = blue_green }, -- type or class definitions and annotations
  ["@type.builtin"] = { fg = dark_blue }, -- built-in types
  ["@type.definition"] = { fg = blue_green }, -- identifiers in type definitions (e.g. `typedef <type> <identifier>` in C)

  ["@attribute"] = { fg = blue_green }, -- attribute annotations (e.g. Python decorators)
  ["@attribute.builtin"] = "@attribute", -- builtin annotations (e.g. `@property` in Python)
  ["@property"] = "@variable.member", -- the key in key/value pairs

  -- Function
  ["@function"] = "Function", -- function definitions
  ["@function.builtin"] = "Function", -- built-in functions
  ["@function.call"] = "Function", -- function calls
  ["@function.macro"] = "Function", -- preprocessor macros

  ["@function.method"] = "@function", -- method definitions
  ["@function.method.call"] = "@function.call", -- method calls

  ["@constructor"] = { fg = blue_green }, -- constructor calls and definitions
  ["@operator"] = "Operator", -- symbolic operators (e.g. `+` / `*`)

  -- Keyword
  ["@keyword"] = "Keyword", -- keywords not fitting into specific categories
  ["@keyword.coroutine"] = { fg = dark_pink }, -- keywords related to coroutines (e.g. `go` in Go, `async/await` in Python)
  ["@keyword.function"] = { fg = dark_blue }, -- keywords that define a function (e.g. `func` in Go, `def` in Python)
  ["@keyword.operator"] = "@operator", -- operators that are English words (e.g. `and` / `or`)
  ["@keyword.import"] = "Include", -- keywords for including modules (e.g. `import` / `from` in Python)
  ["@keyword.type"] = { fg = dark_blue }, -- keywords describing composite types (e.g. `struct`, `enum`)
  ["@keyword.modifier"] = { fg = dark_blue }, -- keywords modifying other constructs (e.g. `const`, `static`, `public`)
  ["@keyword.repeat"] = "Repeat", -- keywords related to loops (e.g. `for` / `while`)
  ["@keyword.return"] = { fg = dark_pink }, --  keywords like `return` and `yield`
  ["@keyword.debug"] = "Debug", -- keywords related to debugging
  ["@keyword.exception"] = "Exception", -- keywords related to exceptions (e.g. `throw` / `catch`)

  ["@keyword.conditional"] = "Conditional", -- keywords related to conditionals (e.g. `if` / `else`)
  ["@keyword.conditional.ternary"] = "@operator", -- ternary operator (e.g. `?` / `:`)

  ["@keyword.directive"] = "PreProc", -- various preprocessor directives & shebangs
  ["@keyword.directive.define"] = "@keyword.directive", -- preprocessor definition directives

  -- Punctuation
  ["@punctuation.delimiter"] = { fg = norm_fg }, -- delimiters (e.g. `;` / `.` / `,`)
  ["@punctuation.bracket"] = { fg = norm_fg }, -- brackets (e.g. `()` / `{}` / `[]`)
  ["@punctuation.special"] = { fg = dark_blue }, -- special symbols (e.g. `{}` in string interpolation)

  -- Comments
  ["@comment"] = "Comment", -- line and block comments
  ["@comment.documentation"] = "@comment", -- comments documenting code

  ["@comment.error"] = { fg = error_red }, -- error-type comments (e.g., `DEPRECATED:`)
  ["@comment.warning"] = { fg = warn_yellow }, -- warning-type comments (e.g., `WARNING:`, `FIX:`)
  ["@comment.hint"] = { fg = hint_gray },  -- note-type comments (e.g., `NOTE:`)
  ["@comment.info"] = { fg = info_blue }, -- info-type comments
  ["@comment.todo"] = "Todo", -- todo-type comments (e.g-, `TODO:`, `WIP:`)

  -- Markup
  ["@markup.strong"] = { fg = norm_fg, bold = true }, -- bold text
  ["@markup.italic"] = { fg = norm_fg, italic = true }, -- text with emphasis
  ["@markup.strikethrough"] = { fg = norm_fg, strikethrough = true }, -- strikethrough text
  ["@markup.underline"] = { fg = norm_fg, underline = true }, -- underlined text (only for literal underline markup!)

  ["@markup.heading"] = "Title", -- headings, titles (including markers)
  ["@markup.heading.1"] = "@markup.heading",
  ["@markup.heading.2"] = "@markup.heading",
  ["@markup.heading.3"] = "@markup.heading",
  ["@markup.heading.4"] = "@markup.heading",
  ["@markup.heading.5"] = "@markup.heading",
  ["@markup.heading.6"] = "@markup.heading",

  ["@markup.quote"] = { fg = green }, -- block quotes
  ["@markup.math"] = { fg = blue_green }, -- math environments (e.g. `$ ... $` in LaTeX)

  ["@markup.link"] = { fg = brown }, -- text references, footnotes, citations, etc.
  ["@markup.link.label"] = "@markup.link", -- non-url links
  ["@markup.link.url"] = "@markup.link", -- url links in markup

  ["@markup.raw"] = { fg = brown }, -- literal or verbatim text (e.g., inline code)
  ["@markup.raw.block"] = { fg = norm_fg }, -- literal or verbatim text as a stand-alone block

  ["@markup.list"] = { fg = cornflower_blue }, -- list markers
  -- ["@markup.list.checked"] = { }, -- checked todo-style list markers
  -- ["@markup.list.unchecked"] = { }, -- unchecked todo-style list markers

  ["@diff.plus"] = "DiffTextAdded", -- added text (for diff files)
  ["@diff.minus"] = "DiffTextDeleted", -- deleted text (for diff files)
  ["@diff.delta"] = "DiffTextChanged", -- changed text (for diff files)

  ["@tag"] = { fg = dark_blue }, -- XML tag names
  ["@tag.builtin"] = "@tag", -- builtin tag names (e.g. HTML5 tags)
  ["@tag.attribute"] = { fg = light_blue }, -- XML tag attributes
  ["@tag.delimiter"] = { fg = gray3 }, -- XML tag delimiters

  -- Language specific
  -- Lua
  ["@variable.member.lua"] = { fg = blue_green },

  --
  -- LSP semantic tokens
  --
  -- The help page :h lsp-semantic-highlight
  -- A short guide: https://gist.github.com/swarn/fb37d9eefe1bc616c2a7e476c0bc0316
  -- Token types and modifiers are described here: http://code.visualstudio.com/api/language-extensions/semantic-highlight-guide
  ["@lsp.type.namespace"] = "@module",
  ["@lsp.type.type"] = "@type",
  ["@lsp.type.class"] = "@type",
  ["@lsp.type.enum"] = "@keyword.type",
  ["@lsp.type.interface"] = "@type",
  ["@lsp.type.struct"] = "@type",
  ["@lsp.type.typeParameter"] = "@type.definition",
  ["@lsp.type.parameter"] = "@variable.parameter",
  ["@lsp.type.variable"] = "@variable",
  ["@lsp.type.property"] = "@property",
  ["@lsp.type.enumMember"] = { fg = blue },
  ["@lsp.type.event"] = "@type",
  ["@lsp.type.function"] = "@function",
  ["@lsp.type.method"] = "@function",
  ["@lsp.type.macro"] = "@constant.macro",
  ["@lsp.type.keyword"] = "@keyword",
  ["@lsp.type.comment"] = "@comment",
  ["@lsp.type.string"] = "@string",
  ["@lsp.type.number"] = "@number",
  ["@lsp.type.regexp"] = "@string.regexp",
  ["@lsp.type.operator"] = "@operator",
  ["@lsp.type.decorator"] = "@attribute",
  ["@lsp.type.escapeSequence"] = "@string.escape",
  ["@lsp.type.formatSpecifier"] = { fg = light_blue },
  ["@lsp.type.builtinType"] = "@type.builtin",
  ["@lsp.type.typeAlias"] = "@type.definition",
  ["@lsp.type.unresolvedReference"] = { undercurl = true, sp = error_red },
  ["@lsp.type.lifetime"] = "@keyword.modifier",
  ["@lsp.type.generic"] = "@variable",
  ["@lsp.type.selfKeyword"] = "@variable.buitin",
  ["@lsp.type.selfTypeKeyword"] = "@variable.buitin",
  ["@lsp.type.deriveHelper"] = "@attribute",
  ["@lsp.type.boolean"] = "@boolean",
  ["@lsp.type.modifier"] = "@keyword.modifier",
  ["@lsp.typemod.type.defaultLibrary"] = "@type.builtin",
  ["@lsp.typemod.typeAlias.defaultLibrary"] = "@type.builtin",
  ["@lsp.typemod.class.defaultLibrary"] = "@type.builtin",
  ["@lsp.typemod.variable.defaultLibrary"] = "@variable.builtin",
  ["@lsp.typemod.function.defaultLibrary"] = "@function.builtin",
  ["@lsp.typemod.method.defaultLibrary"] = "@function.builtin",
  ["@lsp.typemod.macro.defaultLibrary"] = "@function.builtin",
  ["@lsp.typemod.struct.defaultLibrary"] = "@type.builtin",
  ["@lsp.typemod.enum.defaultLibrary"] = "@type.builtin",
  ["@lsp.typemod.enumMember.defaultLibrary"] = "@constant.builtin",
  ["@lsp.typemod.variable.readonly"] = { fg = blue },
  ["@lsp.typemod.variable.callable"] = "@function",
  ["@lsp.typemod.variable.static"] = "@constant",
  ["@lsp.typemod.property.readonly"] = { fg = blue },
  ["@lsp.typemod.keyword.async"] = "@keyword.coroutine",
  ["@lsp.typemod.keyword.injected"] = "@keyword",
  -- Set injected highlights. Mainly for Rust doc comments and also works for
  -- other lsps that inject tokens in comments.
  -- Ref: https://github.com/folke/tokyonight.nvim/pull/340
  ["@lsp.typemod.operator.injected"] = "@operator",
  ["@lsp.typemod.string.injected"] = "@string",
  ["@lsp.typemod.variable.injected"] = "@variable",

  -- Language specific
  -- Lua
  ["@lsp.type.property.lua"] = "@variable.member.lua",

  --
  -- nvim-lspconfig
  --
  -- LspInfoTitle = { },
  -- LspInfoList = { },
  -- LspInfoFiletype = { },
  -- LspInfoTip = { },
  LspInfoBorder = "FloatBorder",

  --
  -- nvim-cmp
  --
  CmpItemAbbrDeprecated = { fg = gray3, bg = 'NONE', strikethrough = true },
  CmpItemAbbrMatch = { fg = blue2, bg = 'NONE' },
  CmpItemAbbrMatchFuzzy = "CmpItemAbbrMatch",
  CmpItemMenu = "Description",
  CmpItemKindText = { fg = norm_fg, bg = 'NONE' },
  CmpItemKindMethod = { fg = '#b180d7', bg = 'NONE' },
  CmpItemKindFunction = "CmpItemKindMethod",
  CmpItemKindConstructor = "CmpItemKindMethod",
  CmpItemKindField = { fg = '#75beff', bg = 'NONE' },
  CmpItemKindVariable = "CmpItemKindField",
  CmpItemKindClass = { fg = '#ee9d28', bg = 'NONE' },
  CmpItemKindInterface = "CmpItemKindField",
  CmpItemKindModule = "CmpItemKindText",
  CmpItemKindProperty = "CmpItemKindText",
  CmpItemKindUnit = "CmpItemKindText",
  CmpItemKindValue = "CmpItemKindText",
  CmpItemKindEnum = "CmpItemKindClass",
  CmpItemKindKeyword = "CmpItemKindText",
  CmpItemKindSnippet = "CmpItemKindText",
  CmpItemKindColor = "CmpItemKindText",
  CmpItemKindFile = "CmpItemKindText",
  CmpItemKindReference = "CmpItemKindText",
  CmpItemKindFolder = "CmpItemKindText",
  CmpItemKindEnumMember = "CmpItemKindField",
  CmpItemKindConstant = "CmpItemKindText",
  CmpItemKindStruct = "CmpItemKindText",
  CmpItemKindEvent = "CmpItemKindClass",
  CmpItemKindOperator = "CmpItemKindText",
  CmpItemKindTypeParameter = "CmpItemKindText",
  -- Other kinds from VSCode's symbolIcon.*
  CmpItemKindArray = "CmpItemKindText",
  CmpItemKindBoolean = "CmpItemKindText",
  CmpItemKindKey = "CmpItemKindText",
  CmpItemKindNamespace = "CmpItemKindText",
  CmpItemKindString = "CmpItemKindText",
  CmpItemKindNull = "CmpItemKindText",
  CmpItemKindNumber = "CmpItemKindText",
  CmpItemKindObject = "CmpItemKindText",
  CmpItemKindPackage = "CmpItemKindText",
  -- Predefined for the winhighlight config of cmp float window
  SuggestWidgetBorder = "FloatBorder",
  SuggestWidgetSelect = { bg = selection_blue },

  --
  -- Aerial
  --
  AerialTextIcon = "CmpItemKindText",
  AerialMethodIcon = "CmpItemKindMethod",
  AerialFunctionIcon = "CmpItemKindFunction",
  AerialConstructorIcon = "CmpItemKindConstructor",
  AerialFieldIcon = "CmpItemKindField",
  AerialVariableIcon = "CmpItemKindVariable",
  AerialClassIcon = "CmpItemKindClass",
  AerialInterfaceIcon = "CmpItemKindInterface",
  AerialModuleIcon = "CmpItemKindModule",
  AerialPropertyIcon = "CmpItemKindProperty",
  AerialUnitIcon = "CmpItemKindUnit",
  AerialValueIcon = "CmpItemKindValue",
  AerialEnumIcon = "CmpItemKindEnum",
  AerialKeywordIcon = "CmpItemKindKeyword",
  AerialSnippetIcon = "CmpItemKindSnippet",
  AerialColorIcon = "CmpItemKindColor",
  AerialFileIcon = "CmpItemKindFile",
  AerialReferenceIcon = "CmpItemKindReference",
  AerialFolderIcon = "CmpItemKindFolder",
  AerialEnumMemberIcon = "CmpItemKindEnumMember",
  AerialConstantIcon = "CmpItemKindConstant",
  AerialStructIcon = "CmpItemKindStruct",
  AerialEventIcon = "CmpItemKindEvent",
  AerialOperatorIcon = "CmpItemKindOperator",
  AerialTypeParameterIcon = "CmpItemKindTypeParameter",

  --
  -- nvim-navic
  --

  -- Consistent with nvim-cmp but has an additional black underline for winbar decoration
  NavicText = "Winbar",
  NavicSeparator = "NavicText",
  NavicIconsMethod = { fg = '#b180d7', bg = norm_bg, underline = true, sp = pure_black },
  NavicIconsFunction = "NavicIconsMethod",
  NavicIconsConstructor = "NavicIconsMethod",
  NavicIconsField = { fg = '#75beff', bg = norm_bg, underline = true, sp = pure_black },
  NavicIconsVariable = "NavicIconsField",
  NavicIconsClass = { fg = '#ee9d28', bg = norm_bg, underline = true, sp = pure_black },
  NavicIconsInterface = "NavicIconsField",
  NavicIconsModule = "NavicText",
  NavicIconsProperty = "NavicText",
  NavicIconsUnit = "NavicText",
  NavicIconsValue = "NavicText",
  NavicIconsEnum = "NavicIconsClass",
  NavicIconsKeyword = "NavicText",
  NavicIconsSnippet = "NavicText",
  NavicIconsColor = "NavicText",
  NavicIconsFile = "NavicText",
  NavicIconsReference = "NavicText",
  NavicIconsFolder = "NavicText",
  NavicIconsEnumMember = "NavicIconsField",
  NavicIconsConstant = "NavicText",
  NavicIconsStruct = "NavicText",
  NavicIconsEvent = "NavicIconsClass",
  NavicIconsOperator = "NavicText",
  NavicIconsTypeParameter = "NavicText",
  NavicIconsArray = "NavicText",
  NavicIconsBoolean = "NavicText",
  NavicIconsKey = "NavicText",
  NavicIconsNamespace = "NavicText",
  NavicIconsString = "NavicText",
  NavicIconsNull = "NavicText",
  NavicIconsNumber = "NavicText",
  NavicIconsObject = "NavicText",
  NavicIconsPackage = "NavicText",

  --
  -- Gitsigns
  --
  GitSignsAdd = "GutterGitAdded",
  GitSignsChange = "GutterGitModified",
  GitSignsDelete = "GutterGitDeleted",
  GitSignsAddNr = "GitSignsAdd",
  GitSignsChangeNr = "GitSignsChange",
  GitSignsDeleteNr = "GitSignsDelete",
  GitSignsAddLn = "DiffAdd",
  GitSignsChangeLn = "DiffChange",
  GitSignsDeleteLn = "DiffDelete",
  GitSignsAddInline = "DiffTextAdded",
  GitSignsChangeInline = "DiffTextChanged",
  GitSignsDeleteInline = "DiffTextDeleted",

  --
  -- vim-illuminate
  --
  IlluminatedWordText = "SelectionHighlightBackground",
  IlluminatedWordRead = "SelectionHighlightBackground",
  IlluminatedWordWrite = "SelectionHighlightBackground",

  --
  -- Telescope
  --
  TelescopeBorder = "FloatBorder",
  TelescopePromptBorder = "TelescopeBorder",
  TelescopeResultsBorder = "TelescopePromptBorder",
  TelescopePreviewBorder = "TelescopePromptBorder",
  TelescopeNormal = "Normal",
  TelescopeSelection = { fg = white, bg = selection_blue, bold = true },  -- fg and bg are the same as PmenuSel
  TelescopeSelectionCaret = "TelescopeSelection",
  TelescopeMultiSelection = "TelescopeNormal",
  TelescopeMultiIcon = { fg = blue_green },
  TelescopeMatching = "CmpItemAbbrMatch",
  TelescopePromptPrefix = { fg = '#cccccc', bold = true }, -- Same as Icon but bold

  --
  -- Harpoon
  --
  HarpoonBorder = "TelescopeBorder",
  HarpoonWindow = "TelescopeNormal",

  --
  -- fFHighlight
  --
  fFHintWords = { underline = true, sp = 'yellow' },
  fFHintCurrentWord = { undercurl = true, sp = 'yellow' },

  --
  -- indent-blankline
  --
  IblIndent = { fg = indent_guide_fg },
  IblScope = { fg = indent_guide_scope_fg },

  --
  -- hlslens
  --
  HlSearchNear = "IncSearch",
  HlSearchLens = "Description",
  HlSearchLensNear = "HlSearchLens",

  --
  -- nvim-ufo
  --
  UfoPreviewBorder = "PeekViewBorder",
  UfoPreviewNormal = "PeekViewNormal",
  UfoPreviewCursorLine = "PeekViewCursorLine",
  UfoFoldedFg = { fg = norm_fg },
  UfoFoldedBg = { bg = folded_blue },
  UfoCursorFoldedLine = { bg = '#2F3C48', bold = true, italic = true },
  UfoPreviewSbar = "PeekViewNormal",
  UfoPreviewThumb = "ScrollbarSlider",
  UfoFoldedEllipsis = { fg = '#989ca0' },

  --
  -- nvim-bqf
  --
  BqfPreviewFloat = "PeekViewNormal",
  BqfPreviewBorder = "PeekViewBorder",
  BqfPreviewTitle = "PeekViewTitle",
  BqfPreviewSbar = "PmenuSbar",
  BqfPreviewThumb = "PmenuThumb",
  BqfPreviewCursor = "Cursor",
  BqfPreviewCursorLine = "PeekViewCursorLine",
  BqfPreviewRange = "PeekViewMatchHighlight",
  BqfPreviewBufLabel = "Description",
  BqfSign = { fg = blue_green },

  --
  -- git-messenger.vim
  --
  gitmessengerHeader = { fg = '#4daafc' },  -- textLink.activeForeground
  gitmessengerPopupNormal = "NormalFloat",
  gitmessengerHash = "NormalFloat",
  gitmessengerHistory = "NormalFloat",
  gitmessengerEmail = "NormalFloat",

  --
  -- nvim-treesitter-context
  --
  -- TreesitterContext = { bg = black4 },
  TreesitterContextLineNumber = { fg = '#4d535a' }, -- 30% darker based on LineNr
  TreesitterContextBottom = { underline = true, sp = float_border_fg },

  --
  -- nvim-scrollview
  --
  ScrollView = "ScrollbarSlider",
  ScrollViewRestricted = "ScrollView",
  ScrollViewConflictsTop = "DiffAdd",
  ScrollViewConflictsMiddle = "DiffAdd",
  ScrollViewConflictsBottom = "DiffAdd",
  ScrollViewCursor = "CursorLineNr",
  ScrollViewDiagnosticsError = "DiagnosticError",
  ScrollViewDiagnosticsWarn = "DiagnosticWarn",
  ScrollViewDiagnosticsHint = "DiagnosticHint",
  ScrollViewDiagnosticsInfo = "DiagnosticInfo",
  ScrollViewSearch = { fg = '#9e6a03' },
  ScrollViewHover = "ScrollbarSliderHover",

  --
  -- vim-floaterm
  --
  Floaterm = "Normal",
  FloatermBorder = "FloatBorder",

  --
  -- quick-scope
  --
  QuickScopePrimary = { fg = bright_pink, underline = true, sp = bright_pink },
  QuickScopeSecondary = { fg = purple, underline = true, sp = purple },
}

for k, v in pairs(groups) do
  if type(v) == "string" then
    vim.api.nvim_set_hl(0, k, { link = v })
  else
    vim.api.nvim_set_hl(0, k, v)
  end
end
