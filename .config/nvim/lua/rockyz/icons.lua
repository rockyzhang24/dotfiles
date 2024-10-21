local icons = {}

icons.symbol_kinds = {
    -- Predefined in CompletionItemKind from runtime/lua/vim/lsp/protocl.lua
    Text = ' ',
    Method = ' ',
    Function = ' ',
    Constructor = ' ',
    Field = ' ',
    Variable = ' ',
    Class = ' ',
    Interface = ' ',
    Module = ' ',
    Property = ' ',
    Unit = ' ',
    Value = ' ',
    Enum = ' ',
    Keyword = ' ',
    Snippet = ' ',
    Color = ' ',
    File = ' ',
    Reference = ' ',
    Folder = ' ',
    EnumMember = ' ',
    Constant = ' ',
    Struct = ' ',
    Event = ' ',
    Operator = ' ',
    TypeParameter = ' ',
    -- cod-symbols-* form Nerd Fonts
    Array = ' ',
    Boolean = ' ',
    Key = ' ',
    Misc = ' ',
    Namespace = ' ',
    Numeric = ' ',
    Parameter = ' ',
    Ruler = ' ',
    String = ' ',
    Structure = ' ',
    -- Others
    Null = ' ',
    Number = ' ',
    Object = ' ',
    Package = ' ',
    -- Specials
    Unknown = ' ',
}

icons.diagnostics = {
    ERROR = ' ',
    WARN = ' ',
    HINT = ' ',
    INFO = ' ',
}

icons.git = {
    added = ' ',
    branch = ' ',
    commit = '',
    deleted = ' ',
    diff = ' ',
    git = '󰊢 ',
    modified = ' ',
}

icons.separators = {
    bar = '│',
    bar_left_bold = '▎',
    chevron_left = '',
    chevron_right = '',
    triangle_left = '',
    triangle_right = '',
}

icons.caret = {
    down = '',
    left = '',
    right = '',
}

icons.misc = {
    book = ' ',
    check = ' ',
    circle_filled = '',
    color = ' ',
    command = ' ',
    disconnect = ' ',
    edit = ' ',
    ellipsis = ' ',
    explorer = ' ',
    file = ' ',
    file_code = ' ',
    folder = '󰉋 ',
    graph = ' ',
    help = ' ',
    lightbulb = '',
    lightning_bolt = '󱐋',
    list = ' ',
    location = '',
    indent = ' ',
    logo = '󰀘 ',
    maximized = ' ',
    neovim = ' ',
    note = ' ',
    outline = ' ',
    page_previous = '󰮳 ',
    quickfix = ' ',
    rocket = ' ',
    search = ' ',
    source_control = ' ',
    squared_plus = '󰜄',
    squared_minus = '󰛲',
    task = ' ',
    term = ' ',
    tree = ' ',
}

return icons
