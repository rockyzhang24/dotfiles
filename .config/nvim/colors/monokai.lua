--
-- I created this theme out of nostalgia. When I first started programming ten years ago, I used
-- Sublime Text, and the theme was Monokai.
--
-- Inspired by Monokai theme from Sublime Text and VSCode
-- Also I cherry-picked some colors from Tsoding's gruber-darker-theme
--
-- Created: July 2024
-- Author: Rocky Zhang (@rockyzhang24)
--
-- References:
-- 1. Scope naming: https://www.sublimetext.com/docs/scope_naming.html
-- 2. VSCode theme color: https://code.visualstudio.com/api/references/theme-color
--

local util = require('rockyz.utils.color_utils')

-- Colors from Monokai
local pink = '#f92472'
local yellow = '#e7db74'
local yellow2 = '#ffdd33'
local orange = '#fd9621'
local green = '#a6e22c'
local blue = '#67d8ef'
local purple = '#ac80ff'
local brown = '#75715e'
local brown2 = '#88846f'
local brown3 = '#74705d'

local gray = '#7a7a77' -- disabledForeground
local gray2 = '#90908a'
local gray3 = '#2f302b'
local gray4 = '#34352f'
local gray5 = '#b3b3b1'

local white = '#ffffff'
local black = '#000000'

local norm_fg = '#f8f8f2' -- editor.foreground
local norm_bg = '#272822' -- editor.background

-- Signs for git in signcolumn
local gutter_git_added = '#2ea043' -- editorGutter.addedBackground
local gutter_git_deleted = '#f85149' -- editorGutter.deletedBackground
local gutter_git_modified = '#0078d4' -- editorGutter.modifiedBackground

-- Undercurl for diagnostics
local error_red = '#f14c4c' -- editorError.foreground
local warn_yellow = '#cca700' -- editorWarning.foreground
local info_blue = '#3794ff' -- editorInfo.foreground
local hint_gray = '#b2b3b1' -- editorHint.foreground
local ok_green = '#89d185' -- color for success, so I use notebookStatusSuccessIcon.foreground

local error_list = '#f88070' -- list.errorForeground, for list items (like files in file explorer) containing errors
local warn_list = '#cca700' -- list.warningForeground, for list items containing warnings

local selected_item_bg = '#414339' -- editorSuggestWidget.selectedBackground
local matched_chars = pink -- editorSuggestWidget.focusHighlightForeground, color for the matched characters in the autocomplete menu
local folded_line_bg = '#353733' -- editor.foldBackground
local floatwin_border = '#454545' -- editorWidget.border, fg for the border of any floating window
local scrollbar = '#646461' -- scrollbarSlider.activeBackground
local indent_guide_fg = '#464741' -- editorIndentGuide.background
local indent_guide_scope_fg = '#767771' -- editorIndentGuide.activeBackground
local win_separator = gray4 -- editorGroup.border
local icon_fg = '#ffcc00' -- fg for icons on tabline, winbar and statusline
local directory = '#569CD6'
local winbar_fg = '#ababaa' -- breadcrumb.foreground

-- Tabline
local tab_bg = norm_bg -- editorGroupHeader.tabsBackground
local tab_active_fg = white -- tab.activeForeground
local tab_active_bg = util.lighten(norm_bg, 0.15) -- tab.activeBackground
local tab_inactive_fg = '#ccccc7' -- tab.inactiveForeground
local tab_inactive_bg = tab_bg -- tab.inactiveBackground
local tab_indicator_active_fg = '#0078d4' -- indicator for the active tab, a bar on the leftmost of the current tab
local tab_indicator_inactive_fg = util.lighten(tab_active_bg, 0.1)

-- Statusline
local stl_fg = white -- statusBar.foreground
local stl_bg = util.lighten(norm_bg, 0.05) -- statusBar.background
local stl_mode_fg = '#282828'
local stl_normal = '#a89984'
local stl_insert = '#83a598'
local stl_visual = '#fe8019'
local stl_replace = '#c586c0'
local stl_command = '#b8bb26'
local stl_terminal = '#fabd2f'
local stl_pending = '#fb3934'
local stl_inactive = '#858585' -- component is inactive (e.g., treesitter is inactive if no parser)
local stl_on = '#2ea043' -- component is on (e.g., treesitter highlight is on)
local stl_off = '#f85149' -- component is off (e.g., treesitter highlight is off)

-- 256 colros
local colors256_110_blue = '#87afd7' -- 110
local colors256_144_brown = '#afaf87' -- 144
local colors256_161_pink = '#d7005f' -- 161
local colors256_168_pink2 = '#d75f87' -- 168

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
    SelectionHighlightBackground = { bg = '#3f4242' }, -- editor.selectionHighlightBackground
    LightBulb = { fg = '#ffcc00' }, -- editorLightBulb.foreground
    CodeLens = { fg = '#999999' }, -- editorCodeLens.foreground
    GutterGitAdded = { fg = gutter_git_added }, -- editorGutter.addedBackground
    GutterGitDeleted = { fg = gutter_git_deleted }, -- editorGutter.deletedBackground
    GutterGitModified = { fg = gutter_git_modified }, -- editorGutter.modifiedBackground
    Breadcrumb = { fg = winbar_fg, bg = norm_bg }, -- breadcrumb.foreground/background
    ScrollbarSliderHover = { bg = '#525250' }, -- scrollbarSlider.hoverBackground
    PeekViewBorder = { fg = brown }, -- peekView.border
    PeekViewNormal = { bg = norm_bg }, -- peekViewEditor.background
    PeekViewTitle = { fg = white }, -- peekViewTitleLabel.foreground
    PeekViewCursorLine = { bg = gray3 }, -- same with CursorLine
    PeekViewMatchHighlight = { bg = brown }, -- peekViewEditor.matchHighlightBackground
    GhostText = { fg = '#70716d' }, -- editorGhostText.foreground
    Icon = { fg = '#c5c5c5' }, -- icon.foreground
    Description = { fg = '#9a9b99' }, -- descriptionForeground
    ProgressBar = { fg = brown }, -- progressBar.background
    MatchedCharacters = { fg = matched_chars }, -- editorSuggestWidget.highlightForeground
    Hint = 'MatchedCharacters', -- for the hint letter in options, e.g., the q in [q]uickfix
    -- Git diff
    DiffLineAdded = { bg = '#374026' }, -- diffEditor.insertedLineBackground
    DiffLineDeleted = { bg = '#432f31' }, -- diffEditor.removedLineBackground
    DiffLineChanged = { bg = '#2b3a46' }, -- Thanks ChatGPT
    DiffTextAdded = { bg = '#495e21' }, -- diffEditor.insertedTextBackground (DiffLineAdded as its background)
    DiffTextDeleted = { bg = '#642f3e' }, -- diffEditor.removedTextBackground (DiffLineDeleted as its background)
    DiffTextChanged = { bg = '#3f5a6b' },
    -- Quickfix list
    QfSelection = { bg = '#3f413e', bold = true }, -- terminal.inactiveSelectionBackground
    -- Inline hints
    InlayHint = { fg = '#969696', bg = '#2f2f28' }, -- editorInlayHint.foreground/background
    InlayHintType = 'InlayHint', -- editorInlayHint.typeBackground/typeForeground
    -- Winbar
    WinbarHeader = { fg = stl_mode_fg, bg = stl_normal }, -- the very beginning part of winbar
    WinbarTriangleSep = { fg = stl_normal }, -- the triangle separator in winbar
    WinbarPath = { fg = icon_fg, bg = norm_bg, bold = true },
    WinbarSpecialIcon = { fg = icon_fg, bg = norm_bg }, -- icon for special filetype
    WinbarFilename = { fg = winbar_fg, bg = norm_bg, bold = true }, -- filename
    WinbarModified = { fg = norm_fg, bg = norm_bg }, -- the modification indicator
    WinbarError = { fg = error_list, bg = norm_bg, bold = true }, -- the filename color if the current buffer has errors
    WinbarWarn = { fg = warn_list, bg = norm_bg, bold = true }, -- the filename color if the current buffer has warnings
    -- Tabline
    TabDefaultIcon = { fg = icon_fg, bg = tab_inactive_bg }, -- icon for special filetype on inactive tab
    TabDefaultIconActive = { fg = icon_fg, bg = tab_active_bg }, -- icon for special filetype on active tab
    TabError = { fg = error_list, bg = tab_inactive_bg },
    TabErrorActive = { fg = error_list, bg = tab_active_bg },
    TabWarn = { fg = warn_list, bg = tab_inactive_bg },
    TabWarnActive = { fg = warn_list, bg = tab_active_bg },
    TabIndicatorActive = { fg = tab_indicator_active_fg, bg = tab_active_bg },
    TabIndicatorInactive = { fg = tab_indicator_inactive_fg, bg = tab_inactive_bg },

    --
    -- diff
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
    DiagnosticVirtualTextError = { fg = error_red, bg = util.blend(error_red, 0.9, norm_bg) },
    DiagnosticVirtualTextWarn = { fg = warn_yellow, bg = util.blend(warn_yellow, 0.9, norm_bg) },
    DiagnosticVirtualTextInfo = { fg = info_blue, bg = util.blend(info_blue, 0.9, norm_bg) },
    DiagnosticVirtualTextHint = { fg = hint_gray, bg = util.blend(hint_gray, 0.9, norm_bg) },
    DiagnosticVirtualTextOk = { fg = ok_green, bg = '#31392c' },
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
    DiagnosticDeprecated = { fg = gray, strikethrough = true },

    --
    -- Symbol kinds
    --

    SymbolKindText = { fg = norm_fg, bg = 'NONE' },
    SymbolKindMethod = '@function.method',
    SymbolKindFunction = '@function',
    SymbolKindConstructor = '@constructor',
    SymbolKindField = '@variable.member',
    SymbolKindVariable = '@variable',
    SymbolKindClass = '@type',
    SymbolKindInterface = '@lsp.type.interface',
    SymbolKindModule = '@module',
    SymbolKindProperty = '@property',
    SymbolKindUnit = '@lsp.type.struct',
    SymbolKindValue = '@string',
    SymbolKindEnum = '@lsp.type.enum',
    SymbolKindKeyword = '@lsp.type.keyword',
    SymbolKindSnippet = 'Conceal',
    SymbolKindColor = 'Special',
    SymbolKindFile = 'Normal',
    SymbolKindReference = '@markup.link',
    SymbolKindFolder = 'Directory',
    SymbolKindEnumMember = '@lsp.type.enumMember',
    SymbolKindConstant = '@constant',
    SymbolKindStruct = '@lsp.type.struct',
    SymbolKindEvent = 'Special',
    SymbolKindOperator = 'Operator',
    SymbolKindTypeParameter = '@lsp.type.typeParameter',
    -- Other kinds from VSCode's symbolIcon.*
    SymbolKindArray = '@punctuation.bracket',
    SymbolKindBoolean = '@boolean',
    SymbolKindKey = '@variable.member',
    SymbolKindNamespace = '@module',
    SymbolKindString = '@string',
    SymbolKindNull = '@constant.builtin',
    SymbolKindNumber = '@number',
    SymbolKindObject = '@constant',
    SymbolKindPackage = '@module',

    --
    -- Editor
    --

    CursorLine = { bg = gray3 },
    CursorColumn = { bg = gray3 },
    ColorColumn = { bg = '#5a5a5a' }, -- editorRuler.foreground
    Conceal = { fg = gray2 },
    Cursor = { fg = norm_bg, bg = '#f8f8f0' },
    CurSearch = { fg = norm_bg, bg = '#ff966c' }, -- editor.findMatchBackground. Take the color from tokyonight moon.
    -- lCursor = { },
    -- CursorIM = { },
    Directory = { fg = directory },
    DiffAdd = 'DiffLineAdded',
    DiffDelete = 'DiffLineDeleted',
    DiffChange = 'DiffLineChanged',
    DiffText = 'DiffTextChanged',
    EndOfBuffer = { fg = norm_bg },
    TermCursor = { fg = norm_bg, bg = yellow2 },
    -- TermCursorNC = { },
    ErrorMsg = { fg = error_red },
    WinSeparator = { fg = norm_fg }, -- VSCode uses color win_separator
    VirtSplit = 'WinSeparator', -- deprecated and use WinSeparator instead
    LineNr = { fg = gray2 }, -- editorLineNumber.foreground
    CursorLineNr = { fg = yellow2 }, -- editorLineNumber.activeForeground
    Folded = { bg = folded_line_bg },
    CursorLineFold = 'CursorLineNr',
    FoldColumn = 'LineNr',
    SignColumn = { bg = norm_bg },
    IncSearch = 'CurSearch',
    -- Substitute = { },
    MatchParen = { fg = norm_fg, bg = '#5a9ed1' }, -- editorBracketMatch.background
    ModeMsg = { fg = norm_fg },
    MsgArea = { fg = norm_fg },
    -- MsgSeparator = { },
    MoreMsg = { fg = norm_fg },
    NonText = { fg = gray2 },
    Normal = { fg = norm_fg, bg = norm_bg },
    -- NormalNC = { },
    Pmenu = { fg = norm_fg, bg = norm_bg }, -- editorSuggestWidget.background/foreground
    PmenuSel = { fg = white, bg = selected_item_bg, bold = true }, -- editorSuggestWidget.selectedForeground/selectedBackground
    -- PmenuKind = {},
    -- PmenuKindSel = {},
    -- PmenuExtra = {},
    -- PmenuExtraSel = {},
    PmenuSbar = 'ScrollbarGutter',
    PmenuThumb = 'ScrollbarSlider',
    PmenuMatch = { fg = matched_chars, bg = norm_bg, bold = true },
    PmenuMatchSel = { fg = matched_chars, bg = selected_item_bg, bold = true },
    NormalFloat = 'Pmenu',
    Question = { fg = warn_yellow },
    QuickFixLine = 'QfSelection',
    Search = { fg = norm_fg, bg = '#3e68d7' }, -- editor.findMatchHighlightBackground. Take the color from tokyonight moon.
    SpecialKey = 'NonText',
    SpellBad = { undercurl = true, sp = error_red },
    SpellCap = { undercurl = true, sp = warn_yellow },
    SpellLocal = { undercurl = true, sp = info_blue },
    SpellRare = { undercurl = true, sp = info_blue },
    StatusLine = { bg = stl_bg },
    -- StatusLineNC = { },
    TabLine = { fg = tab_inactive_fg, bg = tab_inactive_bg }, -- tab.inactiveBackground, tab.inactiveForeground
    TabLineFill = { fg = 'NONE', bg = tab_bg }, -- editorGroupHeader.tabsBackground
    TabLineSel = { fg = tab_active_fg, bg = tab_active_bg }, -- tab.activeBackground, tab.activeForeground
    Title = { fg = orange, bold = true },
    Visual = { bg = '#555449' }, -- editor.selectionBackground, use the selection color in Sublime Text
    -- VisualNOS = { },
    WarningMsg = { fg = warn_yellow },
    Whitespace = { fg = indent_guide_fg },
    WildMenu = 'PmenuSel',
    Winbar = 'Breadcrumb',
    WinbarNC = 'Breadcrumb',

    --
    -- Statusline
    --

    StlModeNormal = { fg = stl_mode_fg, bg = stl_normal },
    StlModeInsert = { fg = stl_mode_fg, bg = stl_insert },
    StlModeVisual = { fg = stl_mode_fg, bg = stl_visual },
    StlModeReplace = { fg = stl_mode_fg, bg = stl_replace },
    StlModeCommand = { fg = stl_mode_fg, bg = stl_command },
    StlModeTerminal = { fg = stl_mode_fg, bg = stl_terminal },
    StlModePending = { fg = stl_mode_fg, bg = stl_pending },

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

    StlSearchCnt = { fg = icon_fg, bg = stl_bg },

    StlMacroRecording = 'StlComponentOff',
    StlMacroRecorded = 'StlComponentOn',

    StlFiletype = { fg = stl_fg, bg = stl_bg, bold = true },

    StlLocComponent = 'StlModeNormal',
    StlLocComponentSep = 'StlModeSepNormal',

    --
    -- Syntax
    --
    -- There are the common vim syntax groups.
    --

    Comment = { fg = brown2 },

    Constant = { fg = purple }, -- Any constant. (constant.other)
    String = { fg = yellow }, -- A string constant: "this is a string". (string)
    Character = 'String', -- A character constant: 'c', '\n'. (constant.character)
    Number = 'Constant', -- A number constant: 234, 0xff. (constant.numeric)
    Boolean = 'Constant', -- A boolean constant: TRUE, false. (constant.language)
    Float = 'Number', -- A floating point constant: 2.3e10. (constant.numeric)

    Identifier = { fg = norm_fg }, -- Any variable name (variable)
    Function = { fg = green }, -- Function name (also: methods for classes). (entity.name.function)

    Statement = { fg = pink }, -- Any statement. (keyword)
    Conditional = 'Statement', -- if, then, else, endif, switch, etc.
    Repeat = 'Statement', -- for, do, while, etc.
    Label = 'Statement', -- case, default, etc.
    Operator = { fg = pink }, -- "sizeof", "+", "*", etc. (keyword.operator)
    Keyword = { fg = pink }, -- any other keyword. (keyword.other)
    Exception = 'Statement', -- try, catch, throw.

    PreProc = { fg = pink }, -- Generic Preprocessor. (keyword)
    Include = 'PreProc', -- Preprocessor #include.
    Define = 'PreProc', -- Preprocessor #define.
    Macro = 'PreProc', -- Same as Define.
    PreCondit = 'PreProc', -- Preprocessor #if, #else, #endif, etc.

    Type = { fg = blue, italic = true }, -- int, long, char, etc. (storage.type)
    StorageClass = { fg = pink, italic = true }, -- static, register, volatile, etc. (storage.modifier)
    Structure = 'Type', -- struct, union, enum, etc.
    Typedef = 'Keyword', -- A typedef

    Special = { fg = orange }, -- Any special symbol.
    SpecialChar = 'Special', -- Special character in a constant.
    Tag = 'Special', -- You can use CTRL-] on this.
    Delimiter = 'Special', -- Character that needs attention.
    SpecialComment = 'Special', -- Special things inside a comment (e.g. '\n').
    Debug = 'Special', -- Debugging statements.

    Underlined = { underline = true }, -- Text that stands out, HTML links
    -- Ignore = { }, -- Left blank, hidden |hl-Ignore| (NOTE: May be invisible here in template)
    Error = { fg = error_red }, -- Any erroneous construct
    Todo = { fg = norm_bg, bg = orange, bold = true }, -- Anything that needs extra attention; mostly the keywords TODO FIXME and XXX

    --
    -- Treesitter
    --
    -- To find all the capture names, see
    -- https://github.com/nvim-treesitter/nvim-treesitter/blob/master/CONTRIBUTING.md#highlights)
    --

    -- Identifiers
    ['@variable'] = 'Identifier', -- various variable names
    ['@variable.builtin'] = { fg = orange }, -- built-in variable names (e.g. `this`). (variable.language)
    ['@variable.parameter'] = { fg = orange, italic = true }, -- parameters of a function. (variable.parameter)
    ['@variable.parameter.builtin'] = '@variable.parameter', -- special parameters (e.g. `_`, `it`)
    ['@variable.member'] = '@variable', -- object and struct fields. (variable.other.member)

    ['@constant'] = 'Constant', -- constant identifiers
    ['@constant.builtin'] = '@constant', -- built-in constant values. (constant.language)
    ['@constant.macro'] = '@function', -- constants defined by the preprocessor. (entity.name.function)

    ['@module'] = { fg = green }, -- modules or namespaces. (entity.name.namespace)
    ['@module.builtin'] = { fg = blue }, -- built-in modules or namespaces
    ['@label'] = { fg = norm_fg }, -- GOTO and other labels (e.g. `label:` in C), including heredoc labels. (entity.name.label)
    ['@label.markdown'] = { fg = purple }, -- label for code block

    -- Literals
    ['@string'] = 'String', -- string literals
    ['@string.documentation'] = '@comment', -- string documenting code (e.g. Python docstrings). (string.quoted.docstring)
    ['@string.regexp'] = { fg = pink }, -- regular expressions. (string.regexp)
    ['@string.escape'] = { fg = purple }, -- escape sequences. (constant.character.escape)
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
    ['@type'] = { fg = green }, -- type or class definitions and annotations, e.g., the type defined by typedef. (entity.name.type)
    ['@type.builtin'] = 'Type', -- built-in types. (storage.type)
    ['@type.definition'] = { fg = green }, -- identifiers in type definitions (e.g. `typedef <type> <identifier>` in C). (entity.name.type)

    ['@attribute'] = { fg = green }, -- attribute annotations (e.g. Python decorators)
    ['@attribute.builtin'] = '@attribute', -- builtin annotations (e.g. `@property` in Python)
    ['@property'] = '@variable.member', -- the key in key/value pairs.

    -- Function
    ['@function'] = 'Function', -- function definitions. (entity.name.function)
    ['@function.builtin'] = { fg = blue }, -- built-in functions
    ['@function.call'] = { fg = blue }, -- function calls. (variable.function)
    ['@function.macro'] = '@function', -- preprocessor macros, e.g., the function name after #define in C++, #define foo() (...)

    ['@function.method'] = '@function', -- method definitions
    ['@function.method.call'] = '@function.call', -- method calls

    ['@constructor'] = '@function.call', -- constructor calls and definitions, e.g., Car::Car() { ... } in C++.
    ['@operator'] = 'Operator', -- symbolic operators (e.g. `+` / `*`)

    -- Keyword
    ['@keyword'] = 'Keyword', -- keywords not fitting into specific categories
    ['@keyword.coroutine'] = '@keyword', -- keywords related to coroutines (e.g. `go` in Go, `async/await` in Python).
    ['@keyword.function'] = 'Type', -- keywords that define a function (e.g. `func` in Go, `def` in Python). (should be keyword.declaration.function, but falls back to storage.type)
    ['@keyword.operator'] = '@keyword', -- operators that are English words (e.g. `and` / `or`). (keyword.operator.word)
    ['@keyword.import'] = '@keyword', -- keywords for including modules (e.g. `import` / `from` in Python). (keyword.control.import)
    ['@keyword.type'] = 'Type', -- keywords describing composite types (e.g. `struct`, `enum`). (keyword.declaration.struct, falls back to storage.type.struct)
    ['@keyword.modifier'] = { fg = pink, italic = true }, -- keywords modifying other constructs (e.g. `const`, `static`, `public`). (storage.modifier)
    ['@keyword.repeat'] = 'Repeat', -- keywords related to loops (e.g. `for` / `while`)
    ['@keyword.return'] = '@keyword', --  keywords like `return` and `yield`
    ['@keyword.debug'] = 'Debug', -- keywords related to debugging
    ['@keyword.exception'] = 'Exception', -- keywords related to exceptions (e.g. `throw` / `catch`)

    ['@keyword.conditional'] = 'Conditional', -- keywords related to conditionals (e.g. `if` / `else`)
    ['@keyword.conditional.ternary'] = '@operator', -- ternary operator (e.g. `?` / `:`)

    ['@keyword.directive'] = 'PreProc', -- various preprocessor directives & shebangs
    ['@keyword.directive.define'] = '@keyword.directive', -- preprocessor definition directives

    -- Punctuation
    ['@punctuation.delimiter'] = { fg = norm_fg }, -- delimiters (e.g. `;` / `.` / `,`)
    ['@punctuation.bracket'] = { fg = norm_fg }, -- brackets (e.g. `()` / `{}` / `[]`)
    ['@punctuation.special'] = { fg = pink }, -- special symbols (e.g. `{}` in string interpolation)
    ['@punctuation.special.markdown'] = { fg = brown3 }, -- quote mark `>` in markdown

    -- Comments
    ['@comment'] = 'Comment', -- line and block comments
    ['@comment.documentation'] = '@comment', -- comments documenting code

    ['@comment.error'] = { fg = error_red }, -- error-type comments (e.g., `DEPRECATED:`)
    ['@comment.warning'] = { fg = warn_yellow }, -- warning-type comments (e.g., `WARNING:`, `FIX:`)
    ['@comment.hint'] = { fg = hint_gray }, -- note-type comments (e.g., `NOTE:`)
    ['@comment.info'] = { fg = info_blue }, -- info-type comments
    ['@comment.todo'] = 'Todo', -- todo-type comments (e.g-, `TODO:`, `WIP:`)

    -- Markup
    ['@markup.strong'] = { fg = blue, bold = true }, -- bold text. (markup.bold)
    ['@markup.italic'] = { fg = blue, italic = true }, -- text with emphasis. (markup.italic)
    ['@markup.strikethrough'] = { fg = norm_fg, strikethrough = true }, -- strikethrough text. (markup.strikethrough)
    ['@markup.underline'] = { fg = norm_fg, underline = true }, -- underlined text (only for literal underline markup!)

    ['@markup.heading'] = 'Title', -- headings, titles (including markers). (markup.heading)
    ['@markup.heading.1'] = '@markup.heading',
    ['@markup.heading.2'] = '@markup.heading',
    ['@markup.heading.3'] = '@markup.heading',
    ['@markup.heading.4'] = '@markup.heading',
    ['@markup.heading.5'] = '@markup.heading',
    ['@markup.heading.6'] = '@markup.heading',

    ['@markup.quote'] = { fg = norm_fg }, -- block quotes. (markup.quote)
    ['@markup.math'] = { fg = blue, italic = true }, -- math environments (e.g. `$ ... $` in LaTeX)

    ['@markup.link'] = { fg = blue }, -- text references, footnotes, citations, etc. (markup.underline.link)
    ['@markup.link.label'] = '@markup.link', -- non-url links
    ['@markup.link.url'] = '@markup.link', -- url links in markup

    ['@markup.raw'] = { fg = norm_fg, bg = '#3b3c37' }, -- literal or verbatim text (e.g., inline code). (markup.inline.raw)
    ['@markup.raw.block'] = { fg = gray5 }, -- literal or verbatim text as a stand-alone block

    ['@markup.list'] = { fg = yellow }, -- list markers. (markup.list)
    -- ["@markup.list.checked"] = { }, -- checked todo-style list markers
    -- ["@markup.list.unchecked"] = { }, -- unchecked todo-style list markers

    ['@diff.plus'] = 'DiffTextAdded', -- added text (for diff files)
    ['@diff.minus'] = 'DiffTextDeleted', -- deleted text (for diff files)
    ['@diff.delta'] = 'DiffTextChanged', -- changed text (for diff files)

    ['@tag'] = { fg = pink }, -- XML tag names. (entity.name.tag)
    ['@tag.builtin'] = '@tag', -- builtin tag names (e.g. HTML5 tags)
    ['@tag.attribute'] = { fg = green }, -- XML tag attributes. (entity.other.attribute-name)
    ['@tag.delimiter'] = { fg = norm_fg }, -- XML tag delimiters

    ['@conceal.markdown_inline'] = { fg = gray5 }, -- backtick of the inline code

    --
    -- LSP semantic tokens
    --
    -- * The help page :h lsp-semantic-highlight
    -- * A short guide: https://gist.github.com/swarn/fb37d9eefe1bc616c2a7e476c0bc0316
    -- * Token types and modifiers are described here: http://code.visualstudio.com/api/language-extensions/semantic-highlight-guide
    --

    -- Standard token types
    ['@lsp.type.namespace'] = '@module', -- identifiers that declare or reference a namespace, module, or package. (entiry.name.namespace)
    ['@lsp.type.class'] = '@type', -- identifiers that declare or reference a class type. (entity.name.class)
    ['@lsp.type.enum'] = '@type', -- identifiers that declare or reference an enumeration type. (entity.name.enum, or entity.name.type.enum)
    ['@lsp.type.interface'] = '@type', -- identifiers that declare or reference an interface type.
    ['@lsp.type.struct'] = '@type', -- identifiers that declare or reference a struct type.
    ['@lsp.type.typeParameter'] = '@type.definition', -- identifiers that declare or reference a type parameter.
    ['@lsp.type.type'] = '@type', -- identifiers that declare or reference a type that is not covered above. (entity.name.type)
    ['@lsp.type.parameter'] = '@variable.parameter', --  identifiers that declare or reference a function or method parameters. (variable.parameter)
    ['@lsp.type.variable'] = '@variable', -- identifiers that declare or reference a local or global variable.
    ['@lsp.type.property'] = '@property', -- identifiers that declare or reference a member property, member field, or member variable.
    ['@lsp.type.enumMember'] = '@variable', -- identifiers that declare or reference an enumeration property, constant, or member. (variable.other.enummember)
    ['@lsp.type.decorator'] = '@attribute', -- identifiers that declare or reference decorators and annotations.
    ['@lsp.type.event'] = '@property', --  identifiers that declare an event property.
    ['@lsp.type.function'] = {}, -- identifiers that declare a function.
    ['@lsp.type.method'] = {}, -- identifiers that declare a member function or method.
    ['@lsp.type.macro'] = '@constant.macro', --  identifiers that declare a macro.
    ['@lsp.type.label'] = '@label', -- identifiers that declare a label.
    ['@lsp.type.comment'] = '@comment', -- tokens that represent a comment.
    ['@lsp.type.string'] = '@string', -- tokens that represent a string literal.
    ['@lsp.type.keyword'] = {}, -- tokens that represent a language keyword.
    ['@lsp.type.number'] = '@number', -- tokens that represent a number literal.
    ['@lsp.type.regexp'] = '@string.regexp', -- tokens that represent a regular expression literal.
    ['@lsp.type.operator'] = '@operator', -- tokens that represent an operator.
    ['@lsp.type.modifier'] = '@keyword.modifier', -- tokens that represent a modifier.

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
    ['@lsp.mod.defaultLibrary'] = { fg = blue }, -- symbols that are part of the standard library. (support.*)

    -- Predefined in vscode
    -- (https://code.visualstudio.com/api/language-extensions/semantic-highlight-guide#predefined-textmate-scope-mappings)
    ['@lsp.typemod.type.defaultLibrary'] = { fg = blue, italic = true }, -- (support.type)
    ['@lsp.typemod.class.defaultLibrary'] = { fg = blue, italic = true }, -- (support.class)
    ['@lsp.typemod.function.defaultLibrary'] = { fg = blue }, -- (support.function)
    ['@lsp.typemod.variable.readonly'] = '@variable', -- immutable variables, often via const. (variable.other.constant, or entity.name.constant)
    ['@lsp.typemod.variable.readonly.defaultLibrary'] = { fg = blue }, -- (support.constant)
    ['@lsp.typemod.property.readonly'] = '@property', -- (variable.other.constant.property)

    -- Others
    ['@lsp.type.escapeSequence'] = '@string.escape',
    ['@lsp.type.builtinType'] = '@type.builtin',
    ['@lsp.type.selfParamete'] = '@variable.parameter',
    ['@lsp.type.boolean'] = '@boolean',

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

    CmpItemAbbrDeprecated = { fg = gray, bg = 'NONE', strikethrough = true },
    CmpItemAbbrMatch = { fg = matched_chars, bg = 'NONE', bold = true }, -- editorSuggestWidget.focusHighlightForeground
    CmpItemAbbrMatchFuzzy = 'CmpItemAbbrMatch',
    CmpItemMenu = 'Description',
    -- Kinds
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
    BlinkCmpMenuSelection = { bg = selected_item_bg, bold = true },
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
    BlinkCmpLabelDeprecated = { fg = gray, bg = 'NONE', strikethrough = true },
    BlinkCmpLabelMatch = { fg = matched_chars, bg = 'NONE', bold = true },
    BlinkCmpLabelDetail = { fg = gray, bg = 'NONE' },
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
    --
    -- Consistent with fzf
    -- Find all the default highlight groups
    -- https://github.com/nvim-telescope/telescope.nvim/blob/master/plugin/telescope.lua
    --

    TelescopeBorder = 'FloatBorder',
    TelescopePromptBorder = 'TelescopeBorder',
    TelescopeResultsBorder = 'TelescopePromptBorder',
    TelescopePreviewBorder = 'TelescopePromptBorder',
    TelescopeNormal = 'Normal',
    TelescopeSelection = { fg = white, bg = selected_item_bg, bold = true },
    TelescopeSelectionCaret = { fg = colors256_161_pink },
    TelescopeMultiSelection = 'TelescopeNormal',
    TelescopeMultiIcon = { fg = colors256_168_pink2 },
    TelescopeMatching = { fg = yellow2, bold = true },
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
    UfoCursorFoldedLine = { bg = gray3, bold = true, italic = true },
    UfoPreviewSbar = 'PeekViewNormal',
    UfoPreviewThumb = 'ScrollbarSlider',
    UfoFoldedEllipsis = 'Whitespace',

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
    -- BqfSign = { },

    --
    -- nvim-treesitter-context
    --

    -- TreesitterContext = { bg = norm_bg },
    TreesitterContextLineNumber = { fg = util.darken(gray2, 0.3) }, -- 30% darker than LineNr
    TreesitterContextBottom = { underline = true, sp = floatwin_border },

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
    -- ScrollViewSearch = { },
    ScrollViewHover = 'ScrollbarSliderHover',

    --
    -- vim-floaterm
    --

    Floaterm = 'Normal',
    FloatermBorder = 'FloatBorder',

    --
    -- quick-scope
    --

    QuickScopePrimary = { fg = '#00ffff', bold = true, underline = true, sp = '#00ffff' },
    QuickScopeSecondary = { fg = '#ff00ff', bold = true, underline = true, sp = '#ff00ff' },

    --
    -- Tagbar
    --
    TagbarFoldIcon = 'Normal',
    TagbarType = 'Comment',

    --
    -- Ripgrep
    --

    RipgrepQuery = { fg = pink },
    RipgrepFilename = { fg = purple },
    RipgrepLineNum = { fg = green },
    RipgrepColNum = { fg = blue },
}

for k, v in pairs(groups) do
    if type(v) == 'string' then
        vim.api.nvim_set_hl(0, k, { link = v })
    else
        vim.api.nvim_set_hl(0, k, v)
    end
end
