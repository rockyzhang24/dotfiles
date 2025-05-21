local icons = {}
icons.minimal = {}

icons.symbol_kinds = {
    -- Predefined in CompletionItemKind from runtime/lua/vim/lsp/protocl.lua
    Text = '',
    Method = '',
    Function = '',
    Constructor = '',
    Field = '',
    Variable = '',
    Class = '',
    Interface = '',
    Module = '',
    Property = '',
    Unit = '',
    Value = '',
    Enum = '',
    Keyword = '',
    Snippet = '',
    Color = '',
    File = '',
    Reference = '',
    Folder = '',
    EnumMember = '',
    Constant = '',
    Struct = '',
    Event = '',
    Operator = '',
    TypeParameter = '',
    -- cod-symbols-* form Nerd Fonts
    Array = '',
    Boolean = '',
    Key = '',
    Misc = '',
    Namespace = '',
    Numeric = '',
    Parameter = '',
    Ruler = '',
    String = '',
    Structure = '',
    -- Others
    Null = '',
    Number = '',
    Object = '',
    Package = '',
    -- Specials
    Unknown = '',
}

icons.lines = {
    vertical = '|',
    double_dash_vertical = '╎',
    triple_dash_vertical = '┆',
    quadruple_dash_vertical = '┊',
}

icons.diagnostics = {
    ERROR = '',
    WARN = '',
    INFO = '',
    HINT = '',
}

icons.minimal.diagnostics = {
    ERROR = 'E',
    WARN = 'W',
    HINT = 'H',
    INFO = 'I',
}

icons.git = {
    added = '',
    branch = '',
    commit = '',
    deleted = '',
    diff = '',
    git = '󰊢',
    modified = '',
}

icons.minimal.git = {
    added = '+',
    deleted = '-',
    modified = '~',
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

icons.access = {
    public = '○',
    protected = '◉',
    private = '●',
}

icons.tree = {
    vertical = '│ ',
    middle = '├╴',
    last = '└╴',
}

icons.misc = {
    book = '',
    check = '󰓆',
    circle_filled = '',
    code = '',
    color = '',
    disconnect = '',
    edit = '',
    ellipsis = '',
    explorer = '',
    file = '',
    file_code = '',
    folder = '󰉋',
    format = '',
    graph = '',
    help = '',
    lightbulb = '',
    lightning_bolt = '󱐋',
    list = '',
    location = '',
    lock = '',
    indent = '',
    logo = '󰀘',
    maximized = '',
    neovim = '',
    note = '',
    outline = '',
    page_previous = '󰮳',
    quickfix = '',
    rocket = '',
    search = '',
    source_control = '',
    switch_on = '',
    switch_off = '',
    task = '',
    term = '',
    thumbsup = '',
    thumbsdown = '',
    tree = '󰐅',
}

icons.emoji = {
    star = '⭐️',
    link = '🔗',
    lock = '🔒',
    puzzle = '🧩',
    tag = '🏷️',
    thumbsup = '👍',
    thumbsdown = '👎',
}

return icons
