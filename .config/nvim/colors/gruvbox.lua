-- Reference:
-- https://github.com/morhetz/gruvbox
-- https://github.com/ellisonleao/gruvbox.nvim

local utils = require('rockyz.utils.color')

vim.o.background = vim.g.is_dark and 'dark' or 'light'

-- Gruvbox palette

local dark0_hard = '#1d2021' -- 234, 29-32-33
local dark0 = '#282828' -- 235, 40-40-40
local dark0_soft = '#32302f' -- 236, 50-48-47
local dark1 = '#3c3836' -- 237, 60-56-54
local dark2 = '#504945' -- 239, 80-73-69
local dark3 = '#665c54' -- 241, 102-92-84
local dark4 = '#7c6f64' -- 243, 124-111-100

local gray = '#928374' -- 245, 146-131-116

local light0_hard = '#f9f5d7' -- 230, 249-245-215
local light0 = '#fbf1c7' -- 229, 253-244-193
local light0_soft = '#f2e5bc' -- 228, 242-229-188
local light1 = '#ebdbb2' -- 223, 235-219-178
local light2 = '#d5c4a1' -- 250, 213-196-161
local light3 = '#bdae93' -- 248, 189-174-147
local light4 = '#a89984' -- 246, 168-153-132

local bright_red = '#fb4934' -- 167, 251-73-52
local bright_green = '#b8bb26' -- 142, 184-187-38
local bright_yellow = '#fabd2f' -- 214, 250-189-47
local bright_blue = '#83a598' -- 109, 131-165-152
local bright_purple = '#d3869b' -- 175, 211-134-155
local bright_aqua = '#8ec07c' -- 108, 142-192-124
local bright_orange = '#fe8019' -- 208, 254-128-25

local neutral_red = '#cc241d' -- 124, 204-36-29
local neutral_green = '#98971a' -- 106, 152-151-26
local neutral_yellow = '#d79921' -- 172, 215-153-33
local neutral_blue = '#458588' -- 66, 69-133-136
local neutral_purple = '#b16286' -- 132, 177-98-134
local neutral_aqua = '#689d6a' -- 72, 104-157-106
local neutral_orange = '#d65d0e' -- 166, 214-93-14

local faded_red = '#9d0006' -- 88, 157-0-6
local faded_green = '#79740e' -- 100, 121-116-14
local faded_yellow = '#b57614' -- 136, 181-118-20
local faded_blue = '#076678' -- 24, 7-102-120
local faded_purple = '#8f3f71' -- 96, 143-63-113
local faded_aqua = '#427b58' -- 66, 66-123-88
local faded_orange = '#af3a03' -- 130, 175-58-3

-- Colors

local bg0, bg1, bg2, bg3, bg4
local fg0, fg1, fg2, fg3, fg4
local red, green, yellow, blue, purple, aqua, orange
if vim.g.is_dark then
    bg0 = dark0
    if vim.g.gruvbox_contrast == 'soft' then
        bg0 = dark0_soft
    elseif vim.g.gruvbox_contrast == 'hard' then
        bg0 = dark0_hard
    end

    bg1 = dark1
    bg2= dark2
    bg3 = dark3
    bg4 = dark4

    fg0 = light0
    fg1 = light1
    fg2 = light2
    fg3 = light3
    fg4 = light4

    red = bright_red
    green = bright_green
    yellow = bright_yellow
    blue = bright_blue
    purple = bright_purple
    aqua = bright_aqua
    orange = bright_orange
else
    bg0 = light0
    if vim.g.gruvbox_contrast == 'soft' then
        bg0 = light0_soft
    elseif vim.g.gruvbox_contrast == 'hard' then
        bg0 = light0_hard
    end

    bg1 = light1
    bg2= light2
    bg3 = light3
    bg4 = light4

    fg0 = dark0
    fg1 = dark1
    fg2 = dark2
    fg3 = dark3
    fg4 = dark4

    red = faded_red
    green = faded_green
    yellow = faded_yellow
    blue = faded_blue
    purple = faded_purple
    aqua = faded_aqua
    orange = faded_orange
end

local norm_fg = fg1
local norm_bg = bg0

local statusline_fg = fg1
local statusline_bg = bg2

local winbar_fg = fg4
local winbar_bg = bg0

local tab_active_fg = green
local tab_active_bg = bg2
local tab_inactive_fg = bg4
local tab_inactive_bg = bg1

local filename = purple
local line_number = yellow
local column_number = blue

-- Some colors vary depending on whether the border is enabled or not
local float_norm_bg = norm_bg -- normal bg of float win
local float_scrollbar_gutter_bg = float_norm_bg -- bg of scrollbar gutter in float win
local selection_bg = bg2
if not vim.g.border_enabled then
    float_norm_bg = bg2
    float_scrollbar_gutter_bg = bg2
    selection_bg = bg3
end

-- Background colors for lines that got added, deleted and changed
local diff_added_line_bg = utils.blend(green, 0.8, norm_bg)
local diff_deleted_line_bg = utils.blend(red, 0.8, norm_bg)
local diff_changed_line_bg = utils.blend(blue, 0.8, norm_bg)
-- Background color for text that got added within the added line
local diff_added_text_bg = utils.blend(green, 0.6, norm_bg)
-- Background color for text that got deleted within the deleted line
local diff_deleted_text_bg = utils.blend(red, 0.6, norm_bg)
-- Background color for text that got changed within the changed line
local diff_changed_text_bg = utils.blend(blue, 0.6, norm_bg)

local groups = {

    Normal = { fg = norm_fg, bg = norm_bg },
    NormalFloat = { bg = float_norm_bg },
    FloatBorder = 'NormalFloat',
    FloatTitle = 'Title',
    FloatFooter = 'FloatTitle',
    -- FloatShadow = {},
    -- FloatShadowThrough = {},
    NormalNC = 'Normal',
    CursorLine = { bg = bg1 },
    CursorColumn = 'CursorLine',
    TabLineSel = { fg = tab_active_fg, bg = tab_active_bg },
    TabLine = { fg = tab_inactive_fg, bg = tab_inactive_bg },
    TabLineFill = 'TabLine',
    MatchParen = { bg = bg3, bold = true },
    ColorColumn = { bg = bg1 },
    Conceal = { fg = blue },
    CursorLineNr = { fg = yellow },
    NonText = { fg = bg2 },
    SpecialKey = { fg = fg4 },
    Visual = { bg = bg3 },
    VisualNOS = 'Visual',
    Search = { fg = bg0, bg = yellow },
    IncSearch = { fg = bg0, bg = orange },
    CurSearch = 'IncSearch',
    -- Substitute = 'Search',
    QuickFixLine = { bg = bg1, bold = true },
    StatusLine = { fg = statusline_fg, bg = statusline_bg },
    StatusLineNC = { fg = fg4, bg = bg1 },
    -- StatusLineTerm = 'StatusLine',
    -- StatusLineTermNC = 'StatusLineNC',
    WinBar = { fg = winbar_fg, bg = winbar_bg },
    WinBarNC = { fg = winbar_fg, bg = winbar_bg },
    WinSeparator = { fg = norm_fg },
    MsgSeparator = 'StatueLine',
    -- MsgArea = 'NONE',
    WildMenu = { fg = blue, bg = bg2, bold = true },
    Directory = { fg = green, bold = true },
    Title = { fg = green, bold = true },
    ErrorMsg = { fg = red },
    WarningMsg = { fg = yellow },
    MoreMsg = { fg = blue },
    ModeMsg = { fg = blue },
    -- StderrMsg = 'ErrorMsg',
    -- StdoutMsg = 'NONE',
    LineNr = { fg = bg4 },
    LineNrAbove = 'LineNr',
    LineNrBelow = 'LineNr',
    SignColumn = 'LineNr',
    CursorLineSign = 'SignColumn',
    Folded = { fg = gray, bg = bg1, italic = true },
    FoldColumn = 'SignColumn',
    CursorLineFold = 'FoldColumn',
    Cursor = { reverse = true },
    -- lCursor = { fg = 'bg', bg = 'fg' },
    -- TermCursor = { reverse = true },
    -- CursorIM = 'Cursor',
    Pmenu = 'NormalFloat',
    PmenuSel = { fg = green, bg = selection_bg },
    PmenuSbar = { bg = float_scrollbar_gutter_bg },
    PmenuThumb = { bg = bg4 },
    PmenuMatch = { fg = neutral_aqua, bold = true },
    PmenuMatchSel = { fg = neutral_aqua, bold = true },
    PmenuExtra = 'Pmenu',
    PmenuExtraSel = 'PmenuSel',
    PmenuKind = 'Pmenu',
    PmenuKindSel = 'PmenuSel',
    PmenuBorder = 'Pmenu',
    PmenuShadow = 'FloatShadow',
    PmenuShadowThrough = 'FloatShadowThrough',
    -- ComplMatchIns = 'NONE',
    -- PreInsert = 'Added',
    -- ComplHint = 'NonText',
    -- ComplHintMore = 'MoreMsg',
    -- SnippetTabstop = 'Visual',
    -- SnippetTabstopActive = 'SnippetTabstop',
    Question = { fg = orange },
    DiffAdd = { bg = diff_added_line_bg }, -- added line
    DiffDelete = { bg = diff_deleted_line_bg }, -- deleted line
    DiffChange = { bg = diff_changed_line_bg }, -- changed line
    DiffText = { bg = diff_changed_text_bg }, -- changed text within changed line
    -- DiffTextAdd = {},
    SpellCap = { undercurl = true, sp = blue },
    SpellBad = { undercurl = true, sp = red },
    SpellLocal = { undercurl = true, sp = aqua },
    SpellRare = { undercurl = true, sp = purple },
    Whitespace = 'NonText',
    EndOfBuffer = 'NonText',
    DiagnosticError = { fg = neutral_red },
    DiagnosticWarn = { fg = neutral_yellow },
    DiagnosticInfo = { fg = neutral_blue },
    DiagnosticHint = { fg = neutral_blue },
    DiagnosticOk = { fg = neutral_green },
    DiagnosticDeprecated = { strikethrough = true },
    DiagnosticSignError = 'DiagnosticError',
    DiagnosticSignWarn = 'DiagnosticWarn',
    DiagnosticSignInfo = 'DiagnosticInfo',
    DiagnosticSignHint = 'DiagnosticHint',
    DiagnosticSignOk = 'DiagnosticOk',
    DiagnosticUnderlineError = { undercurl = true, sp = neutral_red },
    DiagnosticUnderlineWarn = { undercurl = true, sp = neutral_yellow },
    DiagnosticUnderlineInfo = { undercurl = true, sp = neutral_blue },
    DiagnosticUnderlineHint = { undercurl = true, sp = neutral_blue },
    DiagnosticUnderlineOk = { undercurl = true, sp = neutral_green },
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
    -- DiagnosticVirtualLinesError = 'DiagnosticError',
    -- DiagnosticVirtualLinesWarn = 'DiagnosticWarn',
    -- DiagnosticVirtualLinesInfo = 'DiagnosticInfo',
    -- DiagnosticVirtualLinesOk = 'DiagnosticOk',
    -- DiagnosticUnnecessary = 'Comment',
    LspReferenceText = { bg = bg2 },
    LspReferenceRead = 'LspReferenceText',
    LspReferenceWrite = 'LspReferenceText',
    LspReferenceTarget = 'LspReferenceText',
    LspInlayHint = 'NonText',
    LspCodeLens = { fg = gray },
    -- LspCodeLensSeparator = 'LspCodeLens',
    LspSignatureActiveParameter = 'Search',

    -- Syntax

    Comment = { fg = gray, italic = true },

    Constant = { fg = purple },
    String = { fg = green },
    Character = 'Constant',
    Number = 'Constant',
    Boolean = 'Constant',
    Float = 'Number',

    Identifier = { fg = blue },
    Function = { fg = green, bold = true },

    Statement = { fg = red },
    Conditional = 'Statement',
    Repeat = 'Statement',
    Label = 'Statement',
    Operator = { fg = orange },
    Keyword = 'Statement',
    Exception = 'Statement',

    PreProc = { fg = aqua },
    Include = 'PreProc',
    Define = 'PreProc',
    Macro = 'PreProc',
    PreCondit = 'PreProc',

    Type = { fg = yellow },
    StorageClass = { fg = orange },
    Structure = { fg = aqua },
    Typedef = 'Type',

    Special = { fg = orange },
    SpecialChar = 'Special',
    Tag = 'Special',
    Delimiter = { fg = orange },
    SpecialComment = 'Special',
    Debug = 'Special',

    Underlined = { fg = blue, underline = true },
    Ignore = 'Normal',
    Error = { fg = 'bg', bg = red, bold = true },
    Todo = { fg = bg0, bg = yellow, bold = true, italic = true },

    Added = 'DiffAdd', -- added line in a diff
    Changed = 'DiffChange', -- changed line in a diff
    Removed = 'DiffDelete', -- removed line in a diff

    -- Treesitter
    -- To find all the capture names and their descriptions, see
    -- https://github.com/nvim-treesitter/nvim-treesitter/blob/master/CONTRIBUTING.md#highlights)

    ['@variable'] = { fg = norm_fg },
    ['@variable.builtin'] = 'Special',
    ['@variable.parameter'] = 'Identifier',
    ['@variable.parameter.builtin'] = '@variable.parameter',
    ['@variable.member'] = 'Identifier',

    ['@constant'] = 'Constant',
    ['@constant.builtin'] = 'Special',
    ["@constant.macro"] = 'Define',

    ["@module"] = 'Structure',
    ["@module.builtin"] = 'Special',
    ['@label'] = 'Label',

    ['@string'] = 'String',
    -- ['@string.documentation'] = {},
    ['@string.regexp'] = '@string.special',
    ['@string.escape'] = '@string.special',
    ['@string.special'] = 'SpecialChar',
    ['@string.special.symbol'] = 'Identifier',
    ['@string.special.url'] = 'Underlined',
    ['@string.special.path'] = '@string.special',

    ['@character'] = 'Character',
    ['@character.special'] = 'SpecialChar',

    ['@boolean'] = 'Boolean',
    ['@number'] = 'Number',
    ['@number.float'] = 'Float',

    ['@type'] = 'Type',
    ['@type.builtin'] = 'Special',
    ["@type.definition"] = 'Typedef',

    ['@attribute'] = 'PreProc',
    ['@attribute.builtin'] = 'Special',
    ['@property'] = 'Identifier',

    ['@function'] = 'Function',
    ['@function.builtin'] = 'Special',
    ['@function.call'] = '@function',
    ['@function.macro'] = 'Macro',

    ['@function.method'] = '@function',
    ['@function.method.call'] = '@function.call',

    ['@constructor'] = 'Special',
    ['@operator'] = 'Operator',

    ['@keyword'] = 'Keyword',
    ['@keyword.coroutine'] = '@keyword',
    ['@keyword.function'] = '@keyword',
    ['@keyword.operator'] = '@keyword',
    ['@keyword.import'] = 'Include',
    ['@keyword.type'] = 'Type',
    ['@keyword.modifier'] = '@keyword',
    ['@keyword.repeat'] = 'Repeat',
    ['@keyword.return'] = '@keyword',
    ['@keyword.debug'] = 'Debug',
    ['@keyword.exception'] = 'Exception',

    ['@keyword.conditional'] = 'Conditional',
    ['@keyword.conditional.ternary'] = '@operator',

    ['@keyword.directive'] = 'PreProc',
    ['@keyword.directive.define'] = 'Define',

    ['@punctuation.delimiter'] = 'Delimiter',
    -- ['@punctuation.bracket'] = {},
    ['@punctuation.special'] = 'Special',

    ['@comment'] = 'Comment',
    -- ['@comment.documentation'] = {},

    ['@comment.error'] = 'DiagnosticError',
    ["@comment.warning"] = 'DiagnosticWarn',
    ['@comment.todo'] = 'Todo',
    ['@comment.note'] = 'DiagnosticInfo',

    ['@markup.strong'] = { bold = true },
    ['@markup.italic'] = { italic = true },
    ['@markup.strikethrough'] = { strikethrough = true },
    ['@markup.underline'] = { underline = true },

    ['@markup.heading'] = 'Title',
    -- ['@markup.heading.1'] = {},
    -- ['@markup.heading.2'] = {},
    -- ['@markup.heading.3'] = {},
    -- ['@markup.heading.4'] = {},
    -- ['@markup.heading.5'] = {},
    -- ['@markup.heading.6'] = {},

    -- ['@markup.quote'] = {},
    ["@markup.math"] = 'Special',

    ['@markup.link'] = 'Underlined',
    ['@markup.link.label'] = 'SpecialChar',
    -- ['@markup.link.url'] = {},

    ['@markup.raw'] = 'String',
    -- ['@markup.raw.block'] = {},

    ['@markup.list'] = 'Delimiter',
    ['@markup.list.checked'] = { fg = green },
    ['@markup.list.unchecked'] = { fg = gray },

    ['@diff.plus'] = { bg = diff_added_text_bg },
    ['@diff.minus'] = { bg = diff_deleted_text_bg },
    ['@diff.delta'] = { bg = diff_changed_text_bg },

    ['@tag'] = 'Tag',
    -- ['@tag.builtin'] = {},
    ['@tag.attribute'] = 'Identifier',
    ['@tag.delimiter'] = 'Delimiter',

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

    -- Misc
    CursorLineNC = { bg = bg1, underdashed = true, sp = bg3 },
    Description = { fg = gray },
    IndentScopeSymbol = 'Delimiter',
    LightBulb = { fg = neutral_yellow },

    -- Tabline
    TabDefaultIcon = { fg = tab_inactive_fg, bg = tab_inactive_bg }, -- icon for special filetype on inactive tab
    TabDefaultIconActive = { fg = tab_active_fg, bg = tab_active_bg }, -- icon for special filetype on active tab
    TabError = { fg = red, bg = tab_inactive_bg },
    TabErrorActive = { fg = red, bg = tab_active_bg },
    TabWarn = { fg = yellow, bg = tab_inactive_bg },
    TabWarnActive = { fg = yellow, bg = tab_active_bg },
    TabIndicatorActive = { fg = neutral_aqua, bg = tab_active_bg },
    TabIndicatorInactive = { fg = bg2, bg = tab_inactive_bg },

    -- Winbar
    WinbarHeader = 'WinBar',
    WinbarPath = { fg = winbar_fg, bg = winbar_bg, italic = true },
    WinbarFilename = 'WinBar',
    WinbarModified = 'WinBar',
    WinbarError = { fg = red, bg = winbar_bg },
    WinbarWarn = { fg = yellow, bg = winbar_bg },
    WinbarQuickfixTitle = 'WinBar',
    WinbarComponentInactive = { fg = bg3, bg = winbar_bg },
    WinbarComponentOn = { fg = green, bg = winbar_bg },
    WinbarComponentOff = { fg = red, bg = winbar_bg },

    -- Statusline
    StlModeNormal = { fg = bg0, bg = fg4, bold = true },
    StlModeInsert = { fg = bg0, bg = blue, bold = true },
    StlModeVisual = { fg = bg0, bg = orange, bold = true },
    StlModeReplace = { fg = bg0, bg = aqua, bold = true },
    StlModeCommand = { fg = bg0, bg = yellow, bold = true },
    StlModeTerminal = { fg = bg0, bg = green, bold = true },
    StlModePending = { fg = bg0, bg = purple, bold = true },

    StlIcon = 'StatusLine',

    StlComponentInactive = { fg = fg4, bg = statusline_bg },
    StlComponentOn = { fg = green, bg = statusline_bg },
    StlComponentOff = { fg = red, bg = statusline_bg },

    StlGitadded = 'StatusLine',
    StlGitdeleted = 'StatusLine',
    StlGitmodified = 'StatusLine',

    StlDiagnosticERROR = 'StatusLine',
    StlDiagnosticWARN = 'StatusLine',
    StlDiagnosticINFO = 'StatusLine',
    StlDiagnosticHINT = 'StatusLine',

    -- StlMacroRecording = 'StlComponentOff',
    -- StlMacroRecorded = 'StlComponentOn',

    StlFiletype = 'StatusLine',
    StlLocComponent = 'StatusLine',

    -- Signs in the gutter for diff
    GutterDiffAdded = { fg = green },
    GutterDiffDeleted = { fg = red },
    GutterDiffChanged = { fg = blue },

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

    -- Fzf
    FzfFilename = { fg = filename },
    FzfLnum = { fg = line_number },
    FzfCol = { fg = column_number },
    FzfDesc = { fg = gray },
    FzfRgQuery = { fg = red },
    FzfTagsPattern = { fg = gray },
    GitStatusStaged = { fg = green },
    GitStatusUnstaged = { fg = red },

    -- Scrollbar
    ScrollbarSlider = { bg = bg2},
    ScrollbarDiffAdded = { fg = utils.blend(green, 0.6, norm_bg) },
    ScrollbarDiffDeleted = { fg = utils.blend(red, 0.6, norm_bg) },
    ScrollbarDiffChanged = { fg = utils.blend(blue, 0.6, norm_bg) },
    ScrollbarDiagnosticError = { fg = utils.blend(red, 0.6, norm_bg) },
    ScrollbarDiagnosticWarn = { fg = utils.blend(yellow, 0.6, norm_bg) },
    ScrollbarDiagnosticInfo = { fg = utils.blend(blue, 0.6, norm_bg) },
    ScrollbarDiagnosticHint = { fg = utils.blend(blue, 0.6, norm_bg) },
    ScrollbarSearch = { fg = utils.blend(neutral_yellow, 0.6, norm_bg) },

    -- Gitsigns
    GitSignsAdd = 'GutterDiffAdded',
    GitSignsChange = 'GutterDiffChanged',
    GitSignsDelete = 'GutterDiffDeleted',
    GitSignsAddNr = 'GitSignsAdd',
    GitSignsChangeNr = 'GitSignsChange',
    GitSignsDeleteNr = 'GitSignsDelete',
    GitSignsAddLn = 'DiffAdd',
    GitSignsChangeLn = 'DiffChange',
    GitSignsDeleteLn = 'DiffDelete',
    -- GitSignsAddInline = '',
    -- GitSignsChangeInline = '',
    -- GitSignsDeleteInline = '',

    -- LSP Symbol kinds
    SymbolKindText = { fg = norm_fg },
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
    BlinkCmpMenuSelection = { bg = selection_bg },
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
    BlinkCmpLabel = { fg = fg0 },
    BlinkCmpLabelDeprecated = 'DiagnosticDeprecated',
    BlinkCmpLabelMatch = 'PmenuMatch',
    BlinkCmpLabelDetail = { fg = gray },
    BlinkCmpLabelDescription = 'BlinkCmpLabelDetail',
    -- Source
    BlinkCmpSource = 'BlinkCmpLabelDetail',
    BlinkCmpGhostText = { fg = bg4 },
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

    -- git-messenger
    gitmessengerPopupNormal = 'NormalFloat',
    gitmessengerHeader = 'Identifier',
    gitmessengerHash = 'Number',
    gitmessengerHistory = 'Constant',
    gitmessengerEmail = 'String',

    -- nvim-treesitter-context
    TreesitterContext = 'Normal',
    TreesitterContextLineNumber = 'LineNr',
    -- TreesitterContextSeparator = {},
    TreesitterContextBottom = { underline = true, sp = bg2 },
    -- TreesitterContextLineNumberBottom = {},
}

for k, v in pairs(groups) do
    if type(v) == 'string' then
        vim.api.nvim_set_hl(0, k, { link = v })
    else
        vim.api.nvim_set_hl(0, k, v)
    end
end
