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
    -- For ctags
    Chapter = '󰂺',
    Subsection = '',
}

icons.lines = {
    vertical = '|',
    vertical_heavy = '┃', -- unicode U+2503
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
    chevron_left = '',
    chevron_right = '',
    triangle_left = '',
    triangle_right = '',
}

icons.caret = {
    down = '',
    left = '',
    right = '',
    right_solid = '',
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

icons.block = {
    left_one_quarter = '▎', -- U+258E Left One Quarter Block
    right_middle_half ='🬇', -- U+1FB07 Block Sextant-4
}

icons.misc = {
    book = '',
    check = '󰓆',
    circle = '',
    circle_filled = '',
    code = '',
    color = '',
    disconnect = '',
    edit = '',
    ellipsis = '',
    explorer = '',
    file = '',
    file_code = '',
    filter = '',
    folder = '󰉋',
    format = '',
    graph = '',
    help = '',
    left_double_chevron = '󰄽',
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
    pointer = '',
    quickfix = '',
    right_double_chevron = '󰄾',
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
