-- References:
-- https://github.com/neovim/neovim/blob/master/src/nvim/highlight_group.c
-- https://github.com/neovim/neovim/pull/26334

vim.o.background = 'light'

-- Colors from Neovim's builtin default light

local light_blue = '#a6dbff'
local light_cyan = '#8cf8f7'
local light_gray1 = '#eef1f8'
local light_gray2 = '#e0e2ea'
local light_gray3 = '#c4c6cd'
local light_gray4 = '#9b9ea4'
local light_green = '#b3f6c0'
local light_magenta = '#ffcaff'
local light_red = '#ffc0b9'
local light_yellow = '#fce094'

local dark_blue = '#004c73'
local dark_cyan = '#007373'
local dark_gray1 = '#07080d'
local dark_gray2 = '#14161b'
local dark_gray3 = '#2c2e33'
local dark_gray4 = '#4f5258'
local dark_green = '#005523'
local dark_magenta = '#470045'
local dark_red = '#590008'
local dark_yellow = '#6b5300'

-- Extra colors
-- Same hue spacing as base dark colors above, with slightly higher lightness to separate them from
-- Normal fg (dark_gray2), while keeping consistent contrast on Normal bg (light_gray2).

local dark_brown    = '#53342a'
local dark_gold     = '#8f6a00'
local dark_olive    = '#445414'
local dark_orange   = '#7d3b0b'
local dark_purple   = '#3b245f'
local dark_steel    = '#2f3e57'
local dark_tealblue = '#154a5a'

local norm_fg = dark_gray2
local norm_bg = light_gray2


local winbar_fg = dark_gray4
local winbar_bg = light_gray1

local statusline_fg = dark_gray2
local statusline_bg = light_gray4

local tab_fg = dark_gray3
local tab_active_bg = winbar_bg
local tab_inactive_bg = light_gray3

local filename = dark_blue
local line_number = dark_green
local column_number = dark_cyan

local float_norm_bg = norm_bg
if not vim.g.border_enabled then
    float_norm_bg = light_gray3
end

-- Some colors vary depending on whether the border is enabled or not
-- local float_norm_bg = norm_bg -- normal bg of float win
-- local float_scrollbar_gutter = float_norm_bg -- bg of scrollbar gutter in float win
-- if not vim.g.border_enabled then
--     float_norm_bg = utils.darken(norm_bg, 0.4)
--     float_scrollbar_gutter = utils.lighten(float_norm_bg, 0.2)
-- end

local groups = {

    Normal = { fg = norm_fg, bg = norm_bg },

    -- UI
    Added = { fg = dark_green },
    Changed = { fg = dark_cyan },
    ColorColumn = { bg = light_gray4 },
    Conceal = { fg = light_gray4 },
    CurSearch = { fg = light_gray1, bg = dark_yellow },
    CursorColumn = { bg = light_gray3 },
    CursorLine = { bg = light_gray3 },
    DiffAdd = { fg = dark_gray1, bg = light_green },
    DiffChange = { fg = dark_gray1, bg = light_gray4 },
    DiffDelete = { fg = dark_red, bold = true },
    DiffText = { fg = dark_gray1, bg = light_cyan },
    Directory = { fg = dark_cyan },
    ErrorMsg = { fg = dark_red },
    FloatShadow = { bg = light_gray4 },
    FloatShadowThrough = { bg = light_gray4 },
    Folded = { fg = dark_gray4, bg = light_gray1 },
    LineNr = { fg = light_gray4 },
    MatchParen = { bg = light_gray4, bold = true },
    ModeMsg = { fg = dark_green },
    MoreMsg = { fg = dark_cyan },
    NonText = { fg = light_gray4 },
    NormalFloat = 'Pmenu',
    OkMsg = { fg = dark_green },
    Pmenu = { bg = float_norm_bg },
    PmenuThumb = { bg = dark_gray4 },
    Question = { fg = dark_cyan },
    QuickFixLine = { fg = dark_cyan },
    RedrawDebugClear = { bg = light_yellow },
    RedrawDebugComposed = { bg = light_green },
    RedrawDebugRecompose = { bg = light_red },
    Removed = { fg = dark_red },
    Search = { fg = dark_gray1, bg = light_yellow },
    SignColumn = { fg = light_gray4 },
    SpecialKey = { fg = light_gray4 },
    SpellBad = { undercurl = true, sp = dark_red },
    SpellCap = { undercurl = true, sp = dark_yellow },
    SpellLocal = { undercurl = true, sp = dark_green },
    SpellRare = { undercurl = true, sp = dark_cyan },
    StatusLine = { fg = statusline_fg, bg = statusline_bg },
    StatusLineNC = { fg = dark_gray3, bg = light_gray3 },
    Title = { fg = dark_gray2, bold = true },
    Visual = { bg = light_gray4 },
    WarningMsg = { fg = dark_yellow },
    WinBar = { fg = winbar_fg, bg = winbar_bg, bold = true },
    WinBarNC = { fg = winbar_fg, bg = winbar_bg },

    -- Syntax
    Constant = { fg = dark_gray2 },
    Operator = { fg = dark_gray2 },
    PreProc = { fg = dark_gray2 },
    Type = { fg = dark_gray2 },
    Delimiter = { fg = dark_gray2 },

    Comment = { fg = dark_gray4 },
    String = { fg = dark_green },
    Identifier = { fg = dark_blue },
    Function = { fg = dark_cyan },
    Statement = { fg = dark_gray2, bold = true },
    Special = { fg = dark_cyan },
    Error = { fg = dark_gray1, bg = light_red },
    Todo = { fg = dark_gray2, bold = true },

    -- Diagnostics
    DiagnosticError = { fg = dark_red },
    DiagnosticWarn = { fg = dark_yellow },
    DiagnosticInfo = { fg = dark_cyan },
    DiagnosticHint = { fg = dark_blue },
    DiagnosticOk = { fg = dark_green },
    DiagnosticUnderlineError = { undercurl = true, sp = dark_red },
    DiagnosticUnderlineWarn = { undercurl = true, sp = dark_yellow },
    DiagnosticUnderlineInfo = { undercurl = true, sp = dark_cyan },
    DiagnosticUnderlineHint = { undercurl = true, sp = dark_blue },
    DiagnosticUnderlineOk = { undercurl = true, sp = dark_green },
    DiagnosticDeprecated = { strikethrough = true, sp = dark_red },

    -- Treesitter standard groups
    ['@variable'] = { fg = dark_gray2 },

    Cursor = { fg = 'bg', bg = 'fg' },
    CursorLineNr = { bold = true },
    PmenuMatch = { fg = dark_gold, bold = true },
    PmenuMatchSel = { fg = dark_gold, bold = true },
    PmenuSel = { bg = light_gray4 },
    RedrawDebugNormal = { reverse = true },
    TabLineSel = { bg = tab_active_bg, bold = true },
    TermCursor = { reverse = true },
    Underlined = { underline = true },
    lCursor = { fg = 'bg', bg = 'fg' },

    -- UI
    CursorIM = 'Cursor',
    CursorLineFold = 'FoldColumn',
    CursorLineSign = 'SignColumn',
    DiffTextAdd = 'DiffText',
    EndOfBuffer = 'NonText',
    FloatBorder = 'NormalFloat',
    FloatFooter = 'FloatTitle',
    FloatTitle = 'Title',
    FoldColumn = 'SignColumn',
    IncSearch = 'CurSearch',
    LineNrAbove = 'LineNr',
    LineNrBelow = 'LineNr',
    MsgSeparator = 'StatueLine',
    MsgArea = 'NONE',
    NormalNC = 'NONE',
    PmenuExtra = 'Pmenu',
    PmenuExtraSel = 'PmenuSel',
    PmenuKind = 'Pmenu',
    PmenuKindSel = 'PmenuSel',
    PmenuSbar = 'Pmenu',
    PmenuBorder = 'Pmenu',
    PmenuShadow = 'FloatShadow',
    PmenuShadowThrough = 'FloatShadowThrough',
    PreInsert = 'Added',
    ComplMatchIns = 'NONE',
    ComplHint = 'NonText',
    ComplHintMore = 'MoreMsg',
    Substitute = 'Search',
    StatusLineTerm = 'StatusLine',
    StatusLineTermNC = 'StatusLineNC',
    StderrMsg = 'ErrorMsg',
    StdoutMsg = 'NONE',
    TabLine = 'StatusLineNC',
    TabLineFill = 'TabLine',
    VertSplit = 'WinSeparator',
    VisualNOS = 'Visual',
    Whitespace = 'NonText',
    WildMenu = 'PmenuSel',
    WinSeparator = 'Normal',

    -- Syntax
    Character = 'Constant',
    Number = 'Constant',
    Boolean = 'Constant',
    Float = 'Number',
    Conditional = 'Statement',
    Repeat = 'Statement',
    Label = 'Statement',
    Keyword = 'Statement',
    Exception = 'Statement',
    Include = 'PreProc',
    Define = 'PreProc',
    Macro = 'PreProc',
    PreCondit = 'PreProc',
    StorageClass = 'Type',
    Structure = 'Type',
    Typedef = 'Type',
    Tag = 'Special',
    SpecialChar = 'Special',
    SpecialComment = 'Special',
    Debug = 'Special',
    Ignore = 'Normal',

    -- Built-in LSP
    LspCodeLens = 'NonText',
    LspCodeLensSeparator = 'LspCodeLens',
    LspInlayHint = 'NonText',
    LspReferenceRead = 'LspReferenceText',
    LspReferenceText = 'Visual',
    LspReferenceWrite = 'LspReferenceText',
    LspReferenceTarget = 'LspReferenceText',
    LspSignatureActiveParameter = 'Visual',
    SnippetTabstop = 'Visual',
    SnippetTabstopActive = 'SnippetTabstop',

    -- Diagnostics
    DiagnosticFloatingError = 'DiagnosticError',
    DiagnosticFloatingWarn = 'DiagnosticWarn',
    DiagnosticFloatingInfo = 'DiagnosticInfo',
    DiagnosticFloatingHint = 'DiagnosticHint',
    DiagnosticFloatingOk = 'DiagnosticOk',
    DiagnosticVirtualTextError = 'DiagnosticError',
    DiagnosticVirtualTextWarn = 'DiagnosticWarn',
    DiagnosticVirtualTextInfo = 'DiagnosticInfo',
    DiagnosticVirtualTextHint = 'DiagnosticHint',
    DiagnosticVirtualTextOk = 'DiagnosticOk',
    DiagnosticVirtualLinesError = 'DiagnosticError',
    DiagnosticVirtualLinesWarn = 'DiagnosticWarn',
    DiagnosticVirtualLinesInfo = 'DiagnosticInfo',
    DiagnosticVirtualLinesOk = 'DiagnosticOk',
    DiagnosticSignError = 'DiagnosticError',
    DiagnosticSignWarn = 'DiagnosticWarn',
    DiagnosticSignInfo = 'DiagnosticInfo',
    DiagnosticSignHint = 'DiagnosticHint',
    DiagnosticSignOk = 'DiagnosticOk',
    DiagnosticUnnecessary = 'Comment',

    -- Treesitter standard groups
    -- To find all the capture names and their descriptions, see
    -- https://github.com/nvim-treesitter/nvim-treesitter/blob/master/CONTRIBUTING.md#highlights)
    ['@variable.builtin'] = 'Special',
    ['@variable.parameter.builtin'] = 'Special',

    ['@constant'] = 'Constant',
    ['@constant.builtin'] = 'Special',

    ['@module'] = 'Structure',
    ['@module.builtin'] = 'Special',
    ['@label'] = 'Label',

    ['@string'] = 'String',
    ['@string.regexp'] = '@string.special',
    ['@string.escape'] = '@string.special',
    ['@string.special'] = 'SpecialChar',
    ['@string.special.url'] = 'Underlined',

    ['@character'] = 'Character',
    ['@character.special'] = 'SpecialChar',

    ['@boolean'] = 'Boolean',
    ['@number'] = 'Number',
    ['@number.float'] = 'Float',

    ['@type'] = 'Type',
    ['@type.builtin'] = 'Special',

    ['@attribute'] = 'Macro',
    ['@attribute.builtin'] = 'Special',
    ['@property'] = 'Identifier',

    ['@function'] = 'Function',
    ['@function.builtin'] = 'Special',

    ['@constructor'] = 'Special',
    ['@operator'] = 'Operator',

    ['@keyword'] = 'Keyword',

    ['@punctuation'] = 'Delimiter',
    ['@punctuation.special'] = 'Special',

    ['@comment'] = 'Comment',

    ['@comment.error'] = 'DiagnosticError',
    ['@comment.warning'] = 'DiagnosticWarn',
    ['@comment.note'] = 'DiagnosticInfo',
    ['@comment.todo'] = 'Todo',

    ['@markup.strong'] = { bold = true },
    ['@markup.italic'] = { italic = true },
    ['@markup.strikethrough'] = { strikethrough = true },
    ['@markup.underline'] = { underline = true },

    ['@markup'] = 'Special',
    ['@markup.heading'] = 'Title',
    ['@markup.link'] = 'Underlined',

    ['@diff.plus'] = 'Added',
    ['@diff.minus'] = 'Removed',
    ['@diff.delta'] = 'Changed',

    ['@tag'] = 'Tag',
    ['@tag.builtin'] = 'Special',

    ['@markup.heading.1.delimiter.vimdoc'] = { bg = 'bg', fg = 'bg', sp = 'fg', underdouble = true, nocombine = true },
    ['@markup.heading.2.delimiter.vimdoc'] = { bg = 'bg', fg = 'bg', sp = 'fg', underline = true, nocombine = true },

    -- LSP semantic tokens
    -- Token types and modifiers are described here:
    -- http://code.visualstudio.com/api/language-extensions/semantic-highlight-guide
    ['@lsp.type.class'] = '@type',
    ['@lsp.type.comment'] = '@comment',
    ['@lsp.type.decorator'] = '@attribute',
    ['@lsp.type.enum'] = '@type',
    ['@lsp.type.enumMember'] = '@constant',
    ['@lsp.type.event'] = '@type',
    ['@lsp.type.function'] = '@function',
    ['@lsp.type.interface'] = '@type',
    ['@lsp.type.keyword'] = '@keyword',
    ['@lsp.type.macro'] = '@constant.macro',
    ['@lsp.type.method'] = '@function.method',
    ['@lsp.type.modifier'] = '@type.qualifier',
    ['@lsp.type.namespace'] = '@module',
    ['@lsp.type.number'] = '@number',
    ['@lsp.type.operator'] = '@operator',
    ['@lsp.type.parameter'] = '@variable.parameter',
    ['@lsp.type.property'] = '@property',
    ['@lsp.type.regexp'] = '@string.regexp',
    ['@lsp.type.string'] = '@string',
    ['@lsp.type.struct'] = '@type',
    ['@lsp.type.type'] = '@type',
    ['@lsp.type.typeParameter'] = '@type.definition',
    ['@lsp.type.variable'] = '@variable',

    ['@lsp.mod.deprecated'] = 'DiagnosticDeprecated',

    -- Predefined in vscode
    -- (https://code.visualstudio.com/api/language-extensions/semantic-highlight-guide#predefined-textmate-scope-mappings)
    -- ['@lsp.typemod.type.defaultLibrary'] = {},
    -- ['@lsp.typemod.class.defaultLibrary'] = {},
    -- ['@lsp.typemod.function.defaultLibrary'] = {},
    -- ['@lsp.typemod.variable.readonly'] = {},
    -- ['@lsp.typemod.variable.readdonly.defaultLibrary'] = {},
    -- ['@lsp.typemod.property.readonly'] = {},

    -- Others
    -- ['@lsp.type.escapeSequence'] = '@string.escape',
    -- ['@lsp.type.builtinType'] = '@type.builtin',
    -- ['@lsp.type.selfParamete'] = '@variable.parameter',
    -- ['@lsp.type.boolean'] = '@boolean',
    -- ['@lsp.typemod.class.constructorOrDestructor'] = {},
    -- ['@lsp.typemod.const.declaration'] = {},

    -- Set injected highlights. Mainly for Rust doc comments and also works for other lsps that inject
    -- tokens in comments.
    -- Ref: https://github.com/folke/tokyonight.nvim/pull/340
    ['@lsp.typemod.operator.injected'] = '@operator',
    ['@lsp.typemod.string.injected'] = '@string',
    ['@lsp.typemod.variable.injected'] = '@variable',

    -- Tabline
    TabDefaultIcon = { fg = tab_fg, bg = tab_inactive_bg }, -- icon for special filetype on inactive tab
    TabDefaultIconActive = { fg = tab_fg, bg = tab_active_bg }, -- icon for special filetype on active tab
    TabError = { fg = dark_red, bg = tab_inactive_bg },
    TabErrorActive = { fg = dark_red, bg = tab_active_bg, bold = true },
    TabWarn = { fg = dark_yellow, bg = tab_inactive_bg },
    TabWarnActive = { fg = dark_yellow, bg = tab_active_bg, bold = true },
    TabIndicatorActive = { fg = dark_gold, bg = tab_active_bg },
    TabIndicatorInactive = { fg = light_gray4, bg = tab_inactive_bg },

    -- Winbar
    WinbarHeader = 'WinBar',
    WinbarPath = { fg = winbar_fg, bg = winbar_bg, italic = true },
    WinbarFilename = 'WinBar',
    WinbarModified = 'WinBar',
    WinbarError = { fg = dark_red, bg = winbar_bg },
    WinbarWarn = { fg = dark_yellow, bg = winbar_bg },
    WinbarQuickfixTitle = 'WinBar',
    WinbarComponentInactive = { fg = light_gray4, bg = winbar_bg },
    WinbarComponentOn = { fg = dark_green, bg = winbar_bg },
    WinbarComponentOff = { fg = dark_red, bg = winbar_bg },

    -- Statusline
    StlModeNormal = 'StatusLine',
    StlModeInsert = 'StatusLine',
    StlModeVisual = 'StatusLine',
    StlModeReplace = 'StatusLine',
    StlModeCommand = 'StatusLine',
    StlModeTerminal = 'StatusLine',
    StlModePending = 'StatusLine',

    StlIcon = 'StatusLine',

    StlComponentInactive = { fg = dark_gray4, bg = statusline_bg },
    StlComponentOn = { fg = dark_green, bg = statusline_bg },
    StlComponentOff = { fg = dark_red, bg = statusline_bg },

    StlGitadded = 'StatusLine',
    StlGitdeleted = 'StatusLine',
    StlGitmodified = 'StatusLine',

    StlDiagnosticERROR = 'StatusLine',
    StlDiagnosticWARN = 'StatusLine',
    StlDiagnosticINFO = 'StatusLine',
    StlDiagnosticHINT = 'StatusLine',

    StlMacroRecording = 'StlComponentOff',
    StlMacroRecorded = 'StlComponentOn',

    StlFiletype = 'StatusLine',

    StlLocComponent = 'StlModeNormal',

    -- Quickfix
    QuickfixFilename = { fg = filename },
    QuickfixSeparatorLeft = { fg = norm_fg },
    QuickfixLnum = { fg = line_number },
    QuickfixCol = { fg = column_number },
    QuickfixSeparatorRight = { fg = norm_fg },
    QuickfixError = 'DiagnosticError',
    QuickfixWarn = 'DiagnosticWarn',
    QuickfixInfo = 'DiagnosticInfo',
    QuickfixHint = 'DiagnosticHint',

    -- Gitsigns
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

    -- nvim-treesitter-context
    TreesitterContext = 'Normal',
    TreesitterContextLineNumber = 'LineNr',
    -- TreesitterContextSeparator = {},
    TreesitterContextBottom = { underline = true, sp = light_gray3 },
    -- TreesitterContextLineNumberBottom = {},

    -- git-messenger
    gitmessengerPopupNormal = 'NormalFloat',
    gitmessengerHeader = 'Identifier',
    gitmessengerHash = 'Number',
    gitmessengerHistory = 'Constant',
    gitmessengerEmail = 'String',

    -- Fzf
    FzfFilename = { fg = filename },
    FzfLnum = { fg = line_number },
    FzfCol = { fg = column_number },
    FzfDesc = { fg = light_gray4 },
    FzfRgQuery = { fg = dark_red },
    FzfTagsPattern = { fg = dark_blue },

    GitStatusStaged = { fg = dark_green },
    GitStatusUnstaged = { fg = dark_red },

    -- Scrollbar
    ScrollbarSlider = { bg = light_gray4 },
    ScrollbarSearch = { fg = light_yellow },

    -- Misc
    CursorLineNC = { bg = light_gray3, underdashed = true, sp = light_gray4 },
    Description = { fg = light_gray4 },
    GutterGitAdded = 'Added',
    GutterGitDeleted = 'Removed',
    GutterGitModified = 'Changed',
    IndentScopeSymbol = 'Delimiter',
    LightBulb = { fg = dark_gold },

    -- Symbol kinds
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

    -- blink.cmp
    -- Completion menu window
    BlinkCmpMenu = 'Pmenu',
    BlinkCmpMenuBorder = 'FloatBorder',
    BlinkCmpMenuSelection = 'PmenuSel',
    BlinkCmpScrollBarThumb = 'PmenuThumb',
    -- BlinkCmpScrollBarGutter = {},
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
    BlinkCmpLabelDeprecated = 'DiagnosticDeprecated',
    BlinkCmpLabelMatch = 'PmenuMatch',
    -- BlinkCmpLabelDetail = {},
    -- BlinkCmpLabelDescription = 'BlinkCmpLabelDetail',
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
}

for k, v in pairs(groups) do
    if type(v) == 'string' then
        vim.api.nvim_set_hl(0, k, { link = v })
    else
        vim.api.nvim_set_hl(0, k, v)
    end
end
