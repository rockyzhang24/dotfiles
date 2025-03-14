--
-- Inspired by VSCode's Dark Modern theme
-- Author: Rocky Zhang (@rockyzhang24)
--
-- References:
-- 1. Scope naming: https://www.sublimetext.com/docs/scope_naming.html
-- 2. VSCode theme color: https://code.visualstudio.com/api/references/theme-color
--

local util = require('rockyz.utils.color_utils')

local red = '#f44747'
local dark_red = '#d16969'
local orange = '#f9ae28'
local brown = '#ce9178'
local yellow = '#dcdcaa'
local yellow_orange = '#d7ba7d'
local green = '#6a9955'
local blue_green = '#4ec9b0'
local blue = '#4fc1ff'
local light_blue = '#9cdcfe'
local dark_blue = '#569cd6'
local dark_pink = '#c586c0'

local gray = '#51504f' -- StatuslineNC's fg
local gray2 = '#6e7681' -- LineNr (editorLineNumber.foreground)
local gray3 = '#808080'

local black = '#2d2d2d' -- TabLine
local black2 = '#252526'
local black3 = '#282828' -- CursorLine (editor.lineHighlightBorder). Or use #2a2d2e (list.hoverBackground) for a brighter color
local black4 = '#181818' -- Statusline and Tabline (editorGroupHeader.tabsBackground, tab.inactiveBackground)

local white = '#ffffff'

local norm_fg = '#cccccc'
local norm_bg = '#1f1f1f'

-- Signs for git in signcolumn
local gutter_git_added = '#2ea043' -- editorGutter.addedBackground
local gutter_git_deleted = '#f85149' -- editorGutter.deletedBackground
local gutter_git_modified = '#0078d4' -- editorGutter.modifiedBackground

-- Undercurl for diagnostics
local error_red = '#f14c4c'
local warn_yellow = '#cca700'
local info_blue = '#3794ff'
local hint_gray = '#b0b0b0'
local ok_green = '#89d185' -- color for success, so i use notebookstatussuccessicon.foreground

local error_list = '#f88070' -- list.errorForeground, for list items (like files in file explorer) containing errors
local warn_list = '#cca700' -- list.warningForeground, for list items containing warnings

local hint_virtualtext_bg = '#262626'

local selected_item_bg = '#04395e' -- editorSuggestWidget.selectedBackground
local matched_chars = '#2aaaff' -- editorSuggestWidget.focusHighlightForeground, color for the matched characters in the autocomplete menu
local folded_line_bg = '#212d3a' -- editor.foldBackground
local floatwin_border = '#454545' -- fg for the border of any floating window
local scrollbar = '#434343' -- scrollbarSlider.activeBackground
local indent_guide_fg = '#404040'
local indent_guide_scope_fg = '#707070'
local win_separator = '#333333' -- editorGroup.border
local icon_fg = '#d7ba7d' -- fg for icons on tabline, winbar and statusline
local directory = dark_blue
local winbar_fg = '#a9a9a9' -- breadcrumb.foreground

-- Tabline
local tab_bg = black4 -- editorGroupHeader.tabsBackground
local tab_active_fg = white -- tab.activeForeground
local tab_active_bg = util.lighten(norm_bg, 0.15) -- tab.activeBackground
local tab_inactive_fg = '#ccccc7' -- tab.inactiveForeground
local tab_inactive_bg = tab_bg -- tab.inactiveBackground
local tab_indicator_active_fg = '#0078d4' -- indicator for the active tab, a bar on the leftmost of the current tab
local tab_indicator_inactive_fg = util.lighten(tab_active_bg, 0.1)

-- Statusline
local stl_fg = white -- statusBar.foreground
local stl_bg = black4 -- statusBar.background
local stl_normal = '#007acc'
local stl_insert = '#cc6633'
local stl_visual = '#68217a'
local stl_replace = '#c586c0'
local stl_command = '#16825d'
local stl_terminal = '#646695'
local stl_pending = '#c72e0f'
local stl_inactive = '#858585' -- component is inactive (e.g., treesitter is inactive if no parser)
local stl_on = '#16825d' -- component is on (e.g., treesitter highlight is on)
local stl_off = '#c72e0f' -- component is off (e.g., treesitter highlight is off)

-- 256 colros
local colors256_110_blue = '#87afd7' -- 110
local colors256_144_brown = '#afaf87' -- 144
local colors256_161_pink = '#d7005f' -- 161
local colors256_168_pink2 = '#d75f87' -- 168

-- Colors used in quickfix and fzf finders
local filename = dark_pink -- filename
local lnum = '#90ee8f' -- line number
local col = '#97f5ff' -- column number

local groups = {

    --
    -- Preset
    --

    -- Use a more noticeable color for the floating window border because the edges of floating
    -- windows in Neovim don't have shadows. Using the same border color as in VSCode is too subtle.
    -- And for aesthetics, set the scrollbar to the same color as the border.
    FloatBorder = { fg = norm_fg }, -- VSCode uses color floatwin_border
    ScrollbarSlider = { bg = norm_fg }, -- VSCode uses color scrollbar
    ScrollbarGutter = { bg = norm_bg },
    SelectionHighlightBackground = { bg = '#343a41' }, -- editor.selectionHighlightBackground
    LightBulb = { fg = '#ffcc00' }, -- editorLightBulb.foreground
    CodeLens = { fg = '#999999' }, -- editorCodeLens.foreground
    GutterGitAdded = { fg = gutter_git_added }, -- editorGutter.addedBackground
    GutterGitDeleted = { fg = gutter_git_deleted }, -- editorGutter.deletedBackground
    GutterGitModified = { fg = gutter_git_modified }, -- editorGutter.modifiedBackground
    Breadcrumb = { fg = winbar_fg, bg = norm_bg }, -- breadcrumb.foreground/background
    ScrollbarSliderHover = { bg = '#4f4f4f' }, -- scrollbarSlider.hoverBackground
    PeekViewBorder = { fg = '#3794ff' }, -- peekView.border
    PeekViewNormal = { bg = norm_bg }, -- peekViewEditor.background
    PeekViewTitle = { fg = white }, -- peekViewTitleLabel.foreground
    PeekViewCursorLine = { bg = black3 }, -- same with CursorLine
    PeekViewMatchHighlight = { bg = '#5d4616' }, -- peekViewEditor.matchHighlightBackground
    GhostText = { fg = '#6b6b6b' }, -- editorGhostText.foreground
    Icon = { fg = '#cccccc' }, -- icon.foreground
    Description = { fg = '#9d9d9d' }, -- descriptionForeground
    ProgressBar = { fg = '#0078d4' }, -- progressBar.background
    MatchedCharacters = { fg = matched_chars }, -- editorSuggestWidget.highlightForeground
    Hint = 'MatchedCharacters', -- for the hint letter in options, e.g., the q in [q]uickfix
    -- Git diff
    DiffLineAdded = { bg = '#203424' }, -- diffEditor.insertedLineBackground
    DiffLineDeleted = { bg = '#442423' }, -- diffEditor.removedLineBackground
    DiffLineChanged = { bg = '#0e2f44' },
    DiffTextAdded = { bg = '#214d29' }, -- diffEditor.insertedTextBackground (DiffLineAdded as its background)
    DiffTextDeleted = { bg = '#712928' }, -- diffEditor.removedTextBackground (DiffLineDeleted as its background)
    DiffTextChanged = { bg = '#0E2FDC' },
    -- Quickfix list
    QfSelection = { bg = '#3a3d41', bold = true }, -- terminal.inactiveSelectionBackground
    -- Inline hints
    InlayHint = { fg = '#969696', bg = '#242424' }, -- editorInlayHint.foreground/background
    InlayHintType = 'InlayHint', -- editorInlayHint.typeBackground/typeForeground
    -- Winbar
    WinbarHeader = { fg = white, bg = stl_normal }, -- the very beginning part of winbar
    WinbarTriangleSep = { fg = stl_normal }, -- the triangle separator in winbar
    WinbarPath = { fg = icon_fg, bg = norm_bg, italic = true },
    WinbarFilename = { fg = winbar_fg, bg = norm_bg }, -- filename
    WinbarModified = { fg = norm_fg, bg = norm_bg }, -- the modification indicator
    WinbarError = { fg = error_list, bg = norm_bg }, -- the filename color if the current buffer has errors
    WinbarWarn = { fg = warn_list, bg = norm_bg }, -- the filename color if the current buffer has warnings
    WinbarQuickfixTitle = { fg = orange }, -- the title of the quickfix
    -- Tabline
    TabDefaultIcon = { fg = icon_fg, bg = tab_inactive_bg }, -- icon for special filetype on inactive tab
    TabDefaultIconActive = { fg = icon_fg, bg = tab_active_bg }, -- icon for special filetype on active tab
    TabError = { fg = error_list, bg = tab_inactive_bg },
    TabErrorActive = { fg = error_list, bg = tab_active_bg },
    TabWarn = { fg = warn_list, bg = tab_inactive_bg },
    TabWarnActive = { fg = warn_list, bg = tab_active_bg },
    TabIndicatorActive = { fg = tab_indicator_active_fg, bg = tab_active_bg },
    TabIndicatorInactive = { fg = tab_indicator_inactive_fg, bg = tab_inactive_bg },
    -- Indent scope
    IndentScopeSymbol = 'Delimiter',

    --
    -- diff
    --
    -- VSCode doesn't have foreground for git added/removed/changed, so here I use the corresponding
    -- colors for gutter instead.
    --

    diffAdded = 'GutterGitAdded',
    diffRemoved = 'GutterGitDeleted',
    diffChanged = 'GutterGitModified',

    --
    -- LSP
    --

    LspReferenceText = 'SelectionHighlightBackground',
    LspReferenceRead = 'SelectionHighlightBackground',
    LspReferenceWrite = 'SelectionHighlightBackground',
    LspCodeLens = 'CodeLens',
    -- LspCodeLensSeparator = { }, -- color the seperator between two or more code lens.
    LspSignatureActiveParameter = 'MatchedCharacters',
    LspInlayHint = 'InlayHint',

    --
    -- Diagnostics
    --

    DiagnosticError = { fg = error_red },
    DiagnosticWarn = { fg = warn_yellow },
    DiagnosticInfo = { fg = info_blue },
    DiagnosticHint = { fg = hint_gray },
    DiagnosticOk = { fg = ok_green },
    DiagnosticVirtualTextError = { fg = error_red, bg = '#332323', italic = true },
    DiagnosticVirtualTextWarn = { fg = warn_yellow, bg = '#2f2c1b', italic = true },
    DiagnosticVirtualTextInfo = { fg = info_blue, bg = '#212a35', italic = true },
    DiagnosticVirtualTextHint = { fg = util.lighten(hint_virtualtext_bg, 0.3), bg = hint_virtualtext_bg, italic = true },
    DiagnosticVirtualTextOk = { fg = ok_green, bg = '#233323', italic = true },
    DiagnosticVirtualLinesError = 'DiagnosticVirtualTextError',
    DiagnosticVirtualLinesWarn = 'DiagnosticVirtualTextWarn',
    DiagnosticVirtualLinesInfo = 'DiagnosticVirtualTextInfo',
    DiagnosticVirtualLinesHint = 'DiagnosticVirtualTextHint',
    DiagnosticVirtualLinesOk = 'DiagnosticVirtualTextOk',
    DiagnosticUnderlineError = { undercurl = true, sp = error_red },
    DiagnosticUnderlineWarn = { undercurl = true, sp = warn_yellow },
    DiagnosticUnderlineInfo = { undercurl = true, sp = info_blue },
    DiagnosticUnderlineHint = { undercurl = true, sp = hint_gray },
    DiagnosticUnderlineOk = { undercurl = true, sp = ok_green },
    DiagnosticFloatingError = 'DiagnosticError',
    DiagnosticFloatingWarn = 'DiagnosticWarn',
    DiagnosticFloatingInfo = 'DiagnosticInfo',
    DiagnosticFloatingHint = 'DiagnosticHint',
    DiagnosticFloatingOk = 'DiagnosticOk',
    DiagnosticSignError = 'DiagnosticError',
    DiagnosticSignWarn = 'DiagnosticWarn',
    DiagnosticSignInfo = 'DiagnosticInfo',
    DiagnosticSignHint = 'DiagnosticHint',
    DiagnosticSignOk = 'DiagnosticOk',
    DiagnosticUnnecessary = {}, -- don't gray the unused code
    DiagnosticDeprecated = { fg = gray3, strikethrough = true },

    --
    -- Symbol kinds
    --

    SymbolKindText = { fg = norm_fg, bg = 'NONE' },
    SymbolKindMethod = { fg = '#b180d7', bg = 'NONE' },
    SymbolKindFunction = 'SymbolKindMethod',
    SymbolKindConstructor = 'SymbolKindMethod',
    SymbolKindField = { fg = '#75beff', bg = 'NONE' },
    SymbolKindVariable = 'SymbolKindField',
    SymbolKindClass = { fg = '#ee9d28', bg = 'NONE' },
    SymbolKindInterface = 'SymbolKindField',
    SymbolKindModule = 'SymbolKindText',
    SymbolKindProperty = 'SymbolKindText',
    SymbolKindUnit = 'SymbolKindText',
    SymbolKindValue = 'SymbolKindText',
    SymbolKindEnum = 'SymbolKindClass',
    SymbolKindKeyword = 'SymbolKindText',
    SymbolKindSnippet = 'SymbolKindText',
    SymbolKindColor = 'SymbolKindText',
    SymbolKindFile = 'SymbolKindText',
    SymbolKindReference = 'SymbolKindText',
    SymbolKindFolder = 'SymbolKindText',
    SymbolKindEnumMember = 'SymbolKindField',
    SymbolKindConstant = 'SymbolKindText',
    SymbolKindStruct = 'SymbolKindText',
    SymbolKindEvent = 'SymbolKindClass',
    SymbolKindOperator = 'SymbolKindText',
    SymbolKindTypeParameter = 'SymbolKindText',
    -- Other kinds from VSCode's symbolIcon.*
    SymbolKindArray = 'SymbolKindText',
    SymbolKindBoolean = 'SymbolKindText',
    SymbolKindKey = 'SymbolKindText',
    SymbolKindNamespace = 'SymbolKindText',
    SymbolKindString = 'SymbolKindText',
    SymbolKindNull = 'SymbolKindText',
    SymbolKindNumber = 'SymbolKindText',
    SymbolKindObject = 'SymbolKindText',
    SymbolKindPackage = 'SymbolKindText',

    --
    -- Editor
    --

    CursorLine = { bg = black3 },
    CursorColumn = { bg = black3 },
    ColorColumn = { bg = black2 }, -- editorRuler.foreground (vscodes uses #5a5a5a but it's too bright)
    Conceal = { fg = gray2 },
    Cursor = { fg = norm_bg, bg = norm_fg },
    CurSearch = { fg = norm_bg, bg = '#ff966c' }, -- editor.findMatchBackground. Take the color from tokyonight moon.
    -- lCursor = { },
    -- CursorIM = { },
    Directory = { fg = directory },
    DiffAdd = 'DiffLineAdded',
    DiffDelete = 'DiffLineDeleted',
    DiffChange = 'DiffLineChanged',
    DiffText = 'DiffTextChanged',
    EndOfBuffer = { fg = norm_bg },
    TermCursor = { fg = norm_bg, bg = '#ffdd33' },
    -- TermCursorNC = { },
    ErrorMsg = { fg = error_red },
    WinSeparator = { fg = norm_fg }, -- VSCode uses color win_separator
    VirtSplit = 'WinSeparator', -- deprecated and use WinSeparator instead
    LineNr = { fg = gray2 }, -- editorLineNumber.foreground
    CursorLineNr = { fg = '#cccccc' }, -- editorLineNumber.activeForeground
    Folded = { bg = folded_line_bg },
    CursorLineFold = 'CursorLineNr',
    FoldColumn = 'LineNr', -- editorGutter.foldingControlForeground (vscode uses #c5c5c5 but it's too bright)
    SignColumn = 'LineNr',
    IncSearch = 'CurSearch', -- editor.findMatchBackground (vscode uses #9e6a03)
    -- Substitute = { },
    MatchParen = { fg = norm_fg, bg = '#5a9ed1', bold = true, underline = true }, -- editorBracketMatch.background (vscode uses a bg '#7a7a7a', replace it with a more noticeable blue color)
    ModeMsg = { fg = norm_fg },
    MsgArea = { fg = norm_fg },
    -- MsgSeparator = { },
    MoreMsg = { fg = norm_fg },
    NonText = { fg = gray2 },
    Normal = { fg = norm_fg, bg = norm_bg },
    -- NormalNC = { },
    Pmenu = { fg = norm_fg, bg = norm_bg }, -- editorSuggestWidget.background/foreground
    PmenuSel = { fg = white, bg = selected_item_bg }, -- editorSuggestWidget.selectedForeground/selectedBackground
    -- PmenuKind = {},
    -- PmenuKindSel = {},
    -- PmenuExtra = {},
    -- PmenuExtraSel = {},
    PmenuSbar = 'ScrollbarGutter',
    PmenuThumb = 'ScrollbarSlider',
    PmenuMatch = { fg = matched_chars, bg = norm_bg },
    PmenuMatchSel = { fg = matched_chars, bg = selected_item_bg },
    NormalFloat = 'Pmenu',
    Question = { fg = warn_yellow },
    QuickFixLine = 'QfSelection',
    Search = { fg = norm_fg, bg = '#3e68d7' }, -- editor.findMatchHighlightBackground (vscode uses #623315). Take the color from tokyonight moon.
    SpecialKey = 'NonText',
    SpellBad = { undercurl = true, sp = error_red },
    SpellCap = { undercurl = true, sp = warn_yellow },
    SpellLocal = { undercurl = true, sp = info_blue },
    SpellRare = { undercurl = true, sp = info_blue },
    StatusLine = { bg = stl_bg },
    StatusLineNC = { fg = gray, bg = stl_bg },
    TabLine = { fg = tab_inactive_fg, bg = tab_inactive_bg }, -- tab.inactiveBackground, tab.inactiveForeground
    TabLineFill = { fg = 'NONE', bg = tab_bg }, -- editorGroupHeader.tabsBackground
    TabLineSel = { fg = tab_active_fg, bg = tab_active_bg }, -- tab.activeBackground, tab.activeForeground
    Title = { fg = dark_blue, bold = true },
    Visual = { bg = '#264F78' }, -- editor.selectionBackground
    -- VisualNOS = { },
    WarningMsg = { fg = warn_yellow },
    Whitespace = { fg = indent_guide_fg },
    WildMenu = 'PmenuSel',
    Winbar = 'Breadcrumb',
    WinbarNC = 'Breadcrumb',

    --
    -- Statusline
    --

    StlModeNormal = { fg = stl_fg, bg = stl_normal },
    StlModeInsert = { fg = stl_fg, bg = stl_insert },
    StlModeVisual = { fg = stl_fg, bg = stl_visual },
    StlModeReplace = { fg = stl_fg, bg = stl_replace },
    StlModeCommand = { fg = stl_fg, bg = stl_command },
    StlModeTerminal = { fg = stl_fg, bg = stl_terminal },
    StlModePending = { fg = stl_fg, bg = stl_pending },

    StlModeSepNormal = { fg = stl_normal, bg = stl_bg },
    StlModeSepInsert = { fg = stl_insert, bg = stl_bg },
    StlModeSepVisual = { fg = stl_visual, bg = stl_bg },
    StlModeSepReplace = { fg = stl_replace, bg = stl_bg },
    StlModeSepCommand = { fg = stl_command, bg = stl_bg },
    StlModeSepTerminal = { fg = stl_terminal, bg = stl_bg },
    StlModeSepPending = { fg = stl_pending, bg = stl_bg },

    StlIcon = { fg = icon_fg, bg = stl_bg },

    -- The status of the component. E.g., for treesitter component
    -- * the current buffer has no treesitter parser: StlComponentInactive
    -- * it has treesitter parser, but treesitter highlight is on/off: StlComponentOn/StlComponentOff
    StlComponentInactive = { fg = stl_inactive, bg = stl_bg },
    StlComponentOn = { fg = stl_on, bg = stl_bg },
    StlComponentOff = { fg = stl_off, bg = stl_bg },

    StlGitadded = { fg = gutter_git_added, bg = stl_bg },
    StlGitdeleted = { fg = gutter_git_deleted, bg = stl_bg },
    StlGitmodified = { fg = gutter_git_modified, bg = stl_bg },

    StlDiagnosticERROR = { fg = error_red, bg = stl_bg },
    StlDiagnosticWARN = { fg = warn_yellow, bg = stl_bg },
    StlDiagnosticINFO = { fg = info_blue, bg = stl_bg },
    StlDiagnosticHINT = { fg = hint_gray, bg = stl_bg },

    StlMacroRecording = 'StlComponentOff',
    StlMacroRecorded = 'StlComponentOn',

    StlFiletype = { fg = stl_fg, bg = stl_bg, bold = true },

    StlLocComponent = 'StlModeNormal',
    StlLocComponentSep = 'StlModeSepNormal',

    --
    -- Quickfix
    --

    QuickfixFilename = { fg = filename },
    QuickfixSeparatorLeft = { fg = norm_fg },
    QuickfixLnum = { fg = lnum },
    QuickfixCol = { fg = col },
    QuickfixSeparatorRight = { fg = norm_fg },
    QuickfixError = 'DiagnosticError',
    QuickfixWarn = 'DiagnosticWarn',
    QuickfixInfo = 'DiagnosticInfo',
    QuickfixHint = 'DiagnosticHint',

    --
    -- Syntax
    --
    -- There are the common vim syntax groups.
    --

    Comment = { fg = green },

    Constant = { fg = dark_blue },
    String = { fg = brown },
    Character = 'Constant',
    Number = { fg = '#b5cea8' },
    Boolean = 'Constant',
    Float = 'Number',

    Identifier = { fg = light_blue },
    Function = { fg = yellow },

    Statement = { fg = dark_blue },
    Conditional = { fg = dark_pink },
    Repeat = 'Conditional',
    Label = 'Conditional',
    Operator = { fg = norm_fg },
    Keyword = { fg = dark_blue },
    Exception = 'Conditional',

    PreProc = { fg = dark_pink },
    Include = 'PreProc',
    Define = 'PreProc',
    Macro = 'PreProc',
    PreCondit = 'PreProc',

    Type = { fg = dark_blue },
    StorageClass = 'Type',
    Structure = 'Type',
    Typedef = 'Type',

    Special = { fg = yellow_orange },
    SpecialChar = 'Special',
    Tag = 'Special',
    Delimiter = 'Special',
    SpecialComment = 'Special',
    Debug = 'Special',

    Underlined = { underline = true },
    -- Ignore = { },
    Error = { fg = error_red },
    Todo = { fg = norm_bg, bg = yellow_orange, bold = true },

    --
    -- Treesitter
    --
    -- To find all the capture names, see
    -- https://github.com/nvim-treesitter/nvim-treesitter/blob/master/CONTRIBUTING.md#highlights)
    --

    -- Identifiers
    ['@variable'] = 'Identifier', -- various variable names
    ['@variable.builtin'] = { fg = dark_blue }, -- built-in variable names (e.g. `this`)
    ['@variable.parameter'] = { fg = orange }, -- parameters of a function
    ['@variable.parameter.builtin'] = '@variable.parameter', -- special parameters (e.g. `_`, `it`)
    ['@variable.member'] = { fg = blue_green }, -- object and struct fields

    ['@constant'] = 'Constant', -- constant identifiers
    ['@constant.builtin'] = '@constant', -- built-in constant values
    ['@constant.macro'] = '@function', -- constants defined by the preprocessor

    ['@module'] = { fg = blue_green }, -- modules or namespaces (entity.name.namespace)
    ['@module.builtin'] = '@module', -- built-in modules or namespaces
    ['@label'] = { fg = '#c8c8c8' }, -- GOTO and other labels (e.g. `label:` in C), including heredoc labels

    -- Literals
    ['@string'] = 'String', -- string literals
    ['@string.documentation'] = '@string', -- string documenting code (e.g. Python docstrings)
    ['@string.regexp'] = { fg = dark_red }, -- regular expressions
    ['@string.escape'] = { fg = yellow_orange }, -- escape sequences
    ['@string.special'] = 'SpecialChar', -- other special strings (e.g. dates)
    ['@string.special.symbol'] = '@string.special', -- symbols or atoms
    ['@string.special.url'] = '@string.special', -- URIs (e.g. hyperlinks), it's url outside markup
    ['@string.special.path'] = '@string.special', -- filenames

    ['@character'] = 'Character', -- character literals
    ['@character.special'] = 'SpecialChar', -- special characters (e.g. wildcards)

    ['@boolean'] = 'Boolean', -- boolean literals
    ['@number'] = 'Number', -- numeric literals
    ['@number.float'] = 'Float', -- floating-point number literals

    -- Types
    ['@type'] = { fg = blue_green }, -- type or class definitions and annotations (entity.name.type)
    ['@type.builtin'] = 'Type', -- built-in types (storage.type)
    ['@type.builtin.go'] = { fg = blue_green },
    ['@type.builtin.java'] = { fg = blue_green },
    ['@type.builtin.cs'] = { fg = blue_green },
    ['@type.builtin.groovy'] = { fg = blue_green },
    ['@type.definition'] = { fg = blue_green }, -- identifiers in type definitions (e.g. `typedef <type> <identifier>` in C)

    ['@attribute'] = { fg = blue_green }, -- attribute annotations (e.g. Python decorators)
    ['@attribute.builtin'] = '@attribute', -- builtin annotations (e.g. `@property` in Python)
    ['@property'] = '@variable.member', -- the key in key/value pairs

    -- Function
    ['@function'] = 'Function', -- function definitions
    ['@function.builtin'] = '@function', -- built-in functions
    ['@function.call'] = '@function', -- function calls
    ['@function.macro'] = '@function', -- preprocessor macros

    ['@function.method'] = '@function', -- method definitions
    ['@function.method.call'] = '@function.call', -- method calls

    ['@constructor'] = { fg = blue_green }, -- constructor calls and definitions
    ['@operator'] = 'Operator', -- symbolic operators (e.g. `+` / `*`)

    -- Keyword
    ['@keyword'] = 'Keyword', -- keywords not fitting into specific categories
    ['@keyword.coroutine'] = { fg = dark_pink }, -- keywords related to coroutines (e.g. `go` in Go, `async/await` in Python)
    ['@keyword.function'] = 'Type', -- keywords that define a function (e.g. `func` in Go, `def` in Python)
    ['@keyword.operator'] = '@operator', -- operators that are English words (e.g. `and` / `or`)
    ['@keyword.import'] = 'Include', -- keywords for including modules (e.g. `import` / `from` in Python)
    ['@keyword.type'] = 'Type', -- keywords describing composite types (e.g. `struct`, `enum`)
    ['@keyword.modifier'] = { fg = dark_blue }, -- keywords modifying other constructs (e.g. `const`, `static`, `public`)
    ['@keyword.repeat'] = 'Repeat', -- keywords related to loops (e.g. `for` / `while`)
    ['@keyword.return'] = { fg = dark_pink }, --  keywords like `return` and `yield`
    ['@keyword.debug'] = 'Debug', -- keywords related to debugging
    ['@keyword.exception'] = 'Exception', -- keywords related to exceptions (e.g. `throw` / `catch`)

    ['@keyword.conditional'] = 'Conditional', -- keywords related to conditionals (e.g. `if` / `else`)
    ['@keyword.conditional.ternary'] = '@operator', -- ternary operator (e.g. `?` / `:`)

    ['@keyword.directive'] = 'PreProc', -- various preprocessor directives & shebangs
    ['@keyword.directive.define'] = '@keyword.directive', -- preprocessor definition directives

    -- Punctuation
    ['@punctuation.delimiter'] = { fg = norm_fg }, -- delimiters (e.g. `;` / `.` / `,`)
    ['@punctuation.bracket'] = { fg = norm_fg }, -- brackets (e.g. `()` / `{}` / `[]`)
    ['@punctuation.special'] = { fg = dark_blue }, -- special symbols (e.g. `{}` in string interpolation)
    ['@punctuation.special.markdown'] = { fg = green }, -- quote mark `>` in markdown

    -- Comments
    ['@comment'] = 'Comment', -- line and block comments
    ['@comment.documentation'] = '@comment', -- comments documenting code

    ['@comment.error'] = { fg = error_red }, -- error-type comments (e.g., `DEPRECATED:`)
    ['@comment.warning'] = { fg = warn_yellow }, -- warning-type comments (e.g., `WARNING:`, `FIX:`)
    ['@comment.hint'] = { fg = hint_gray }, -- note-type comments (e.g., `NOTE:`)
    ['@comment.info'] = { fg = info_blue }, -- info-type comments
    ['@comment.todo'] = 'Todo', -- todo-type comments (e.g-, `TODO:`, `WIP:`)

    -- Markup
    ['@markup.strong'] = { fg = dark_blue, bold = true }, -- bold text
    ['@markup.italic'] = { fg = norm_fg, italic = true }, -- text with emphasis
    ['@markup.strikethrough'] = { fg = norm_fg, strikethrough = true }, -- strikethrough text
    ['@markup.underline'] = { fg = norm_fg, underline = true }, -- underlined text (only for literal underline markup!)

    ['@markup.heading'] = 'Title', -- headings, titles (including markers)
    ['@markup.heading.1'] = '@markup.heading',
    ['@markup.heading.2'] = '@markup.heading',
    ['@markup.heading.3'] = '@markup.heading',
    ['@markup.heading.4'] = '@markup.heading',
    ['@markup.heading.5'] = '@markup.heading',
    ['@markup.heading.6'] = '@markup.heading',

    ['@markup.quote'] = { fg = norm_fg }, -- block quotes
    ['@markup.math'] = { fg = blue_green }, -- math environments (e.g. `$ ... $` in LaTeX)

    ['@markup.link'] = '@markup.underline', -- text references, footnotes, citations, etc.
    ['@markup.link.label'] = { fg = brown }, -- non-url links
    ['@markup.link.url'] = '@markup.link', -- url links in markup

    ['@markup.raw'] = { fg = brown }, -- literal or verbatim text (e.g., inline code)
    ['@markup.raw.block'] = { fg = norm_fg }, -- literal or verbatim text as a stand-alone block

    ['@markup.list'] = { fg = '#6796e6' }, -- list markers
    -- ["@markup.list.checked"] = { }, -- checked todo-style list markers
    -- ["@markup.list.unchecked"] = { }, -- unchecked todo-style list markers

    ['@diff.plus'] = 'DiffTextAdded', -- added text (for diff files)
    ['@diff.minus'] = 'DiffTextDeleted', -- deleted text (for diff files)
    ['@diff.delta'] = 'DiffTextChanged', -- changed text (for diff files)

    ['@tag'] = { fg = dark_blue }, -- XML tag names
    ['@tag.css'] = { fg = yellow_orange },
    ['@tag.less'] = { fg = yellow_orange },
    ['@tag.builtin'] = '@tag', -- builtin tag names (e.g. HTML5 tags)
    ['@tag.attribute'] = { fg = light_blue }, -- XML tag attributes
    ['@tag.delimiter'] = { fg = gray3 }, -- XML tag delimiters

    --
    -- LSP semantic tokens
    --
    -- The help page :h lsp-semantic-highlight
    -- A short guide: https://gist.github.com/swarn/fb37d9eefe1bc616c2a7e476c0bc0316
    -- Token types and modifiers are described here: http://code.visualstudio.com/api/language-extensions/semantic-highlight-guide
    --

    -- Standard token types
    ['@lsp.type.namespace'] = '@module', -- entity.name.namespace
    ['@lsp.type.class'] = { fg = blue_green }, -- entity.name.class
    ['@lsp.type.enum'] = '@type', -- entity.name.type.enum
    ['@lsp.type.interface'] = '@type',
    ['@lsp.type.struct'] = '@type',
    ['@lsp.type.typeParameter'] = '@type.definition',
    ['@lsp.type.type'] = '@type', -- entity.name.type
    ['@lsp.type.parameter'] = '@variable.parameter', -- variable.parameter
    ['@lsp.type.variable'] = '@variable',
    ['@lsp.type.property'] = '@property',
    ['@lsp.type.enumMember'] = { fg = blue }, -- variable.other.enummember
    ['@lsp.type.decorator'] = '@attribute',
    ['@lsp.type.event'] = '@property',
    ['@lsp.type.function'] = {},
    ['@lsp.type.method'] = {},
    ['@lsp.type.macro'] = '@constant.macro',
    ['@lsp.type.label'] = '@label',
    ['@lsp.type.comment'] = '@comment',
    ['@lsp.type.string'] = '@string',
    ['@lsp.type.keyword'] = {},
    ['@lsp.type.number'] = '@number',
    ['@lsp.type.regexp'] = '@string.regexp',
    ['@lsp.type.operator'] = '@operator',
    ['@lsp.type.modifier'] = '@keyword.modifier',

    -- Standard token modifiers
    -- ["@lsp.mod.declaration"] = "", -- declarations of symbols.
    -- ["@lsp.mod.definition"] = "", -- definitions of symbols, for example, in header files.
    -- ["@lsp.mod.readonly"] = "", -- readonly variables and member fields (constants).
    -- ["@lsp.mod.static"] = "", -- class members (static members).
    ['@lsp.mod.deprecated'] = { strikethrough = true }, -- symbols that should no longer be used.
    -- ["@lsp.mod.abstract"] = "", -- types and member functions that are abstract.
    -- ["@lsp.mod.async"] = "", -- functions that are marked async.
    -- ["@lsp.mod.modification"] = "", -- variable references where the variable is assigned to.
    -- ["@lsp.mod.documentation"] = "", -- occurrences of symbols in documentation.
    -- ["@lsp.mod.defaultLibrary"] = "", -- symbols that are part of the standard library. (support.*)

    -- Predefined in vscode
    -- (https://code.visualstudio.com/api/language-extensions/semantic-highlight-guide#predefined-textmate-scope-mappings)
    ['@lsp.typemod.type.defaultLibrary'] = { fg = blue_green }, -- (support.type)
    ['@lsp.typemod.class.defaultLibrary'] = { fg = blue_green }, -- (support.class)
    ['@lsp.typemod.function.defaultLibrary'] = { fg = yellow }, -- (support.function)
    ['@lsp.typemod.variable.readonly'] = { fg = blue }, -- (variable.other.constant, or entity.name.constant)
    ['@lsp.typemod.variable.readdonly.defaultLibrary'] = { fg = blue }, -- (support.constant)
    ['@lsp.typemod.property.readonly'] = { fg = blue }, -- (variable.other.constant.property)

    -- Others
    ['@lsp.type.escapeSequence'] = '@string.escape',
    ['@lsp.type.builtinType'] = '@type.builtin',
    ['@lsp.type.selfParamete'] = '@variable.parameter',
    ['@lsp.type.boolean'] = '@boolean',
    ['@lsp.typemod.class.constructorOrDestructor'] = { fg = blue_green },

    -- Set injected highlights. Mainly for Rust doc comments and also works for other lsps that inject
    -- tokens in comments.
    -- Ref: https://github.com/folke/tokyonight.nvim/pull/340
    ['@lsp.typemod.operator.injected'] = '@operator',
    ['@lsp.typemod.string.injected'] = '@string',
    ['@lsp.typemod.variable.injected'] = '@variable',

    --
    -- nvim-lspconfig
    --

    -- LspInfoTitle = { },
    -- LspInfoList = { },
    -- LspInfoFiletype = { },
    -- LspInfoTip = { },
    LspInfoBorder = 'FloatBorder',

    --
    -- nvim-cmp
    --

    CmpItemAbbrDeprecated = { fg = gray3, bg = 'NONE', strikethrough = true },
    CmpItemAbbrMatch = { fg = matched_chars, bg = 'NONE' },
    CmpItemAbbrMatchFuzzy = 'CmpItemAbbrMatch',
    CmpItemMenu = 'Description',
    CmpItemKindText = 'SymbolKindText',
    CmpItemKindMethod = 'SymbolKindMethod',
    CmpItemKindFunction = 'SymbolKindFunction',
    CmpItemKindConstructor = 'SymbolKindConstructor',
    CmpItemKindField = 'SymbolKindField',
    CmpItemKindVariable = 'SymbolKindVariable',
    CmpItemKindClass = 'SymbolKindClass',
    CmpItemKindInterface = 'SymbolKindInterface',
    CmpItemKindModule = 'SymbolKindModule',
    CmpItemKindProperty = 'SymbolKindProperty',
    CmpItemKindUnit = 'SymbolKindUnit',
    CmpItemKindValue = 'SymbolKindValue',
    CmpItemKindEnum = 'SymbolKindEnum',
    CmpItemKindKeyword = 'SymbolKindKeyword',
    CmpItemKindSnippet = 'SymbolKindSnippet',
    CmpItemKindColor = 'SymbolKindColor',
    CmpItemKindFile = 'SymbolKindFile',
    CmpItemKindReference = 'SymbolKindReference',
    CmpItemKindFolder = 'SymbolKindFolder',
    CmpItemKindEnumMember = 'SymbolKindEnumMember',
    CmpItemKindConstant = 'SymbolKindConstant',
    CmpItemKindStruct = 'SymbolKindStruct',
    CmpItemKindEvent = 'SymbolKindEvent',
    CmpItemKindOperator = 'SymbolKindOperator',
    CmpItemKindTypeParameter = 'SymbolKindTypeParameter',
    -- Other kinds from VSCode's symbolIcon.*
    CmpItemKindArray = 'SymbolKindArray',
    CmpItemKindBoolean = 'SymbolKindBoolean',
    CmpItemKindKey = 'SymbolKindKey',
    CmpItemKindNamespace = 'SymbolKindNamespace',
    CmpItemKindString = 'SymbolKindString',
    CmpItemKindNull = 'SymbolKindNull',
    CmpItemKindNumber = 'SymbolKindNumber',
    CmpItemKindObject = 'SymbolKindObject',
    CmpItemKindPackage = 'SymbolKindPackage',
    -- Predefined for the winhighlight config of cmp float window
    SuggestWidgetBorder = 'FloatBorder',
    SuggestWidgetSelect = { bg = selected_item_bg },

    --
    -- blink.cmp
    --

    -- Completion menu window
    BlinkCmpMenu = 'Normal',
    BlinkCmpMenuBorder = 'FloatBorder',
    BlinkCmpMenuSelection = { bg = selected_item_bg },
    BlinkCmpScrollBarThumb = 'ScrollbarSlider',
    BlinkCmpScrollBarGutter = 'ScrollbarGutter',
    -- Document window
    BlinkCmpDoc = 'BlinkCmpMenu',
    BlinkCmpDocBorder = 'BlinkCmpMenuBorder',
    BlinkCmpDocSeparator = 'BlinkCmpDocBorder',
    BlinkCmpDocCursorLine = 'BlinkCmpMenuSelection',
    -- Signature help window
    BlinkCmpSignatureHelp = 'BlinkCmpMenu',
    BlinkCmpSignatureHelpBorder = 'BlinkCmpMenuBorder',
    BlinkCmpSignatureHelpActiveParameter = 'LspSignatureActiveParameter',
    -- Label
    BlinkCmpLabel = { fg = norm_fg },
    BlinkCmpLabelDeprecated = { fg = gray3, bg = 'NONE', strikethrough = true },
    BlinkCmpLabelMatch = { fg = matched_chars, bg = 'NONE' },
    BlinkCmpLabelDetail = { fg = gray3, bg = 'NONE' },
    BlinkCmpLabelDescription = 'BlinkCmpLabelDetail',
    -- Source
    BlinkCmpSource = 'BlinkCmpLabelDetail',
    BlinkCmpGhostText = 'BlinkCmpLabelDetail',
    -- Kinds
    BlinkCmpKindText = 'SymbolKindText',
    BlinkCmpKindMethod = 'SymbolKindMethod',
    BlinkCmpKindFunction = 'SymbolKindFunction',
    BlinkCmpKindConstructor = 'SymbolKindConstructor',
    BlinkCmpKindField = 'SymbolKindField',
    BlinkCmpKindVariable = 'SymbolKindVariable',
    BlinkCmpKindClass = 'SymbolKindClass',
    BlinkCmpKindInterface = 'SymbolKindInterface',
    BlinkCmpKindModule = 'SymbolKindModule',
    BlinkCmpKindProperty = 'SymbolKindProperty',
    BlinkCmpKindUnit = 'SymbolKindUnit',
    BlinkCmpKindValue = 'SymbolKindValue',
    BlinkCmpKindEnum = 'SymbolKindEnum',
    BlinkCmpKindKeyword = 'SymbolKindKeyword',
    BlinkCmpKindSnippet = 'SymbolKindSnippet',
    BlinkCmpKindColor = 'SymbolKindColor',
    BlinkCmpKindFile = 'SymbolKindFile',
    BlinkCmpKindReference = 'SymbolKindReference',
    BlinkCmpKindFolder = 'SymbolKindFolder',
    BlinkCmpKindEnumMember = 'SymbolKindEnumMember',
    BlinkCmpKindConstant = 'SymbolKindConstant',
    BlinkCmpKindStruct = 'SymbolKindStruct',
    BlinkCmpKindEvent = 'SymbolKindEvent',
    BlinkCmpKindOperator = 'SymbolKindOperator',
    BlinkCmpKindTypeParameter = 'SymbolKindTypeParameter',
    -- Other kinds from VSCode's symbolIcon.*
    BlinkCmpKindArray = 'SymbolKindArray',
    BlinkCmpKindBoolean = 'SymbolKindBoolean',
    BlinkCmpKindKey = 'SymbolKindKey',
    BlinkCmpKindNamespace = 'SymbolKindNamespace',
    BlinkCmpKindString = 'SymbolKindString',
    BlinkCmpKindNull = 'SymbolKindNull',
    BlinkCmpKindNumber = 'SymbolKindNumber',
    BlinkCmpKindObject = 'SymbolKindObject',
    BlinkCmpKindPackage = 'SymbolKindPackage',

    --
    -- Aerial
    --

    AerialTextIcon = 'SymbolKindText',
    AerialMethodIcon = 'SymbolKindMethod',
    AerialFunctionIcon = 'SymbolKindFunction',
    AerialConstructorIcon = 'SymbolKindConstructor',
    AerialFieldIcon = 'SymbolKindField',
    AerialVariableIcon = 'SymbolKindVariable',
    AerialClassIcon = 'SymbolKindClass',
    AerialInterfaceIcon = 'SymbolKindInterface',
    AerialModuleIcon = 'SymbolKindModule',
    AerialPropertyIcon = 'SymbolKindProperty',
    AerialUnitIcon = 'SymbolKindUnit',
    AerialValueIcon = 'SymbolKindValue',
    AerialEnumIcon = 'SymbolKindEnum',
    AerialKeywordIcon = 'SymbolKindKeyword',
    AerialSnippetIcon = 'SymbolKindSnippet',
    AerialColorIcon = 'SymbolKindColor',
    AerialFileIcon = 'SymbolKindFile',
    AerialReferenceIcon = 'SymbolKindReference',
    AerialFolderIcon = 'SymbolKindFolder',
    AerialEnumMemberIcon = 'SymbolKindEnumMember',
    AerialConstantIcon = 'SymbolKindConstant',
    AerialStructIcon = 'SymbolKindStruct',
    AerialEventIcon = 'SymbolKindEvent',
    AerialOperatorIcon = 'SymbolKindOperator',
    AerialTypeParameterIcon = 'SymbolKindTypeParameter',

    --
    -- nvim-navic
    --

    NavicText = 'Winbar',
    NavicSeparator = 'NavicText',
    NavicIconsMethod = 'SymbolKindMethod',
    NavicIconsFunction = 'SymbolKindFunction',
    NavicIconsConstructor = 'SymbolKindConstructor',
    NavicIconsField = 'SymbolKindField',
    NavicIconsVariable = 'SymbolKindVariable',
    NavicIconsClass = 'SymbolKindClass',
    NavicIconsInterface = 'SymbolKindInterface',
    NavicIconsModule = 'SymbolKindModule',
    NavicIconsProperty = 'SymbolKindProperty',
    NavicIconsUnit = 'SymbolKindUnit',
    NavicIconsValue = 'SymbolKindValue',
    NavicIconsEnum = 'SymbolKindEnum',
    NavicIconsKeyword = 'SymbolKindKeyword',
    NavicIconsSnippet = 'SymbolKindSnippet',
    NavicIconsColor = 'SymbolKindColor',
    NavicIconsFile = 'SymbolKindFile',
    NavicIconsReference = 'SymbolKindReference',
    NavicIconsFolder = 'SymbolKindFolder',
    NavicIconsEnumMember = 'SymbolKindEnumMember',
    NavicIconsConstant = 'SymbolKindConstant',
    NavicIconsStruct = 'SymbolKindStruct',
    NavicIconsEvent = 'SymbolKindEvent',
    NavicIconsOperator = 'SymbolKindOperator',
    NavicIconsTypeParameter = 'SymbolKindTypeParameter',
    NavicIconsArray = 'SymbolKindArray',
    NavicIconsBoolean = 'SymbolKindBoolean',
    NavicIconsKey = 'SymbolKindKey',
    NavicIconsNamespace = 'SymbolKindNamespace',
    NavicIconsString = 'SymbolKindString',
    NavicIconsNull = 'SymbolKindNull',
    NavicIconsNumber = 'SymbolKindNumber',
    NavicIconsObject = 'SymbolKindObject',
    NavicIconsPackage = 'SymbolKindPackage',

    --
    -- Gitsigns
    --

    GitSignsAdd = 'GutterGitAdded',
    GitSignsChange = 'GutterGitModified',
    GitSignsDelete = 'GutterGitDeleted',
    GitSignsAddNr = 'GitSignsAdd',
    GitSignsChangeNr = 'GitSignsChange',
    GitSignsDeleteNr = 'GitSignsDelete',
    GitSignsAddLn = 'DiffAdd',
    GitSignsChangeLn = 'DiffChange',
    GitSignsDeleteLn = 'DiffDelete',
    GitSignsAddInline = 'DiffTextAdded',
    GitSignsChangeInline = 'DiffTextChanged',
    GitSignsDeleteInline = 'DiffTextDeleted',

    --
    -- vim-illuminate
    --

    IlluminatedWordText = 'SelectionHighlightBackground',
    IlluminatedWordRead = 'SelectionHighlightBackground',
    IlluminatedWordWrite = 'SelectionHighlightBackground',

    --
    -- Telescope
    -- Consistent with fzf
    -- Find all the default highlight groups
    -- https://github.com/nvim-telescope/telescope.nvim/blob/master/plugin/telescope.lua
    --

    TelescopeBorder = 'FloatBorder',
    TelescopePromptBorder = 'TelescopeBorder',
    TelescopeResultsBorder = 'TelescopePromptBorder',
    TelescopePreviewBorder = 'TelescopePromptBorder',
    TelescopeNormal = 'Normal',
    TelescopeSelection = { fg = white, bg = selected_item_bg },
    TelescopeSelectionCaret = { fg = colors256_161_pink },
    TelescopeMultiSelection = 'TelescopeNormal',
    TelescopeMultiIcon = { fg = colors256_168_pink2 },
    TelescopeMatching = 'CmpItemAbbrMatch',
    TelescopePromptPrefix = { fg = colors256_110_blue, bold = true },
    TelescopePromptCounter = { fg = colors256_144_brown },

    --
    -- Harpoon
    --

    HarpoonBorder = 'TelescopeBorder',
    HarpoonWindow = 'TelescopeNormal',

    --
    -- indent-blankline
    --

    IblIndent = { fg = indent_guide_fg },
    IblScope = { fg = indent_guide_scope_fg },

    --
    -- hlslens
    --

    HlSearchNear = 'IncSearch',
    HlSearchLens = 'Description',
    HlSearchLensNear = 'HlSearchLens',

    --
    -- nvim-ufo
    --
    UfoPreviewBorder = 'PeekViewBorder',
    UfoPreviewNormal = 'PeekViewNormal',
    UfoPreviewCursorLine = 'PeekViewCursorLine',
    UfoFoldedFg = { fg = norm_fg },
    UfoFoldedBg = { bg = folded_line_bg },
    UfoCursorFoldedLine = { bg = '#2F3C48', bold = true, italic = true },
    UfoPreviewSbar = 'PeekViewNormal',
    UfoPreviewThumb = 'ScrollbarSlider',
    UfoFoldedEllipsis = { fg = '#989ca0' },

    --
    -- nvim-bqf
    --

    BqfPreviewFloat = 'PeekViewNormal',
    BqfPreviewBorder = 'PeekViewBorder',
    BqfPreviewTitle = 'PeekViewTitle',
    BqfPreviewSbar = 'PmenuSbar',
    BqfPreviewThumb = 'PmenuThumb',
    BqfPreviewCursor = 'Cursor',
    BqfPreviewCursorLine = 'PeekViewCursorLine',
    BqfPreviewRange = 'PeekViewMatchHighlight',
    BqfPreviewBufLabel = 'Description',
    BqfSign = { fg = blue_green },

    --
    -- nvim-treesitter-context
    --

    -- TreesitterContext = {},
    TreesitterContextLineNumber = 'LineNr',
    -- TreesitterContextSeparator = {},
    TreesitterContextBottom = { underline = true, sp = '#000000' },
    -- TreesitterContextLineNumberBottom = {},

    --
    -- nvim-scrollview
    --

    ScrollView = 'ScrollbarSlider',
    ScrollViewRestricted = 'ScrollView',
    ScrollViewConflictsTop = 'DiffAdd',
    ScrollViewConflictsMiddle = 'DiffAdd',
    ScrollViewConflictsBottom = 'DiffAdd',
    ScrollViewCursor = 'CursorLineNr',
    ScrollViewDiagnosticsError = 'DiagnosticError',
    ScrollViewDiagnosticsWarn = 'DiagnosticWarn',
    ScrollViewDiagnosticsHint = 'DiagnosticHint',
    ScrollViewDiagnosticsInfo = 'DiagnosticInfo',
    ScrollViewSearch = { fg = '#ff966c' }, -- same with IncSearch
    ScrollViewHover = 'ScrollbarSliderHover',

    --
    -- vim-floaterm
    --

    Floaterm = 'Normal',
    FloatermBorder = 'FloatBorder',

    --
    -- quick-scope
    --

    QuickScopePrimary = { fg = '#f92472', bold = true, underline = true, sp = '#f92472' },
    QuickScopeSecondary = { fg = '#ac80ff', bold = true, underline = true, sp = '#ac80ff' },

    --
    -- Tagbar
    --

    TagbarType = 'Comment',
    TagbarSignature = 'Normal',
    TagbarFoldIcon = 'Normal',

    --
    -- Fzf
    --

    FzfFilename = { fg = filename },
    FzfLnum = { fg = lnum },
    FzfCol = { fg = col },
    FzfDesc = { fg = util.lighten(norm_bg, 0.4) },
    FzfRgQuery = { fg = red },
    FzfTagsPattern = { fg = dark_blue },

    GitStatusStaged = { fg = green },
    GitStatusUnstaged = { fg = red },
}

for k, v in pairs(groups) do
    if type(v) == 'string' then
        vim.api.nvim_set_hl(0, k, { link = v })
    else
        vim.api.nvim_set_hl(0, k, v)
    end
end
