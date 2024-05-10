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
  Unit = '',
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
}

icons.lightbulb = ''

icons.diagnostics = {
  ERROR = ' ',
  WARN = ' ',
  HINT = ' ',
  INFO = ' ',
}

icons.git = {
  branch = ' ',
  added = ' ',
  modified = ' ',
  deleted = ' ',
  diff = ' ',
}

icons.separators = {
  chevron_left = '',
  chevron_right = '',
  triangle_left = '',
  triangle_right = '',
  bar = '│',
}

icons.caret = {
  caret_left = '',
  caret_right = '',
}

icons.misc = {
  book = ' ',
  check = ' ',
  color = ' ',
  delimiter = '',
  disconnect = ' ',
  edit = ' ',
  ellipsis = ' ',
  explorer = ' ',
  file = ' ',
  file_code = ' ',
  folder = ' ',
  graph = ' ',
  help = ' ',
  indent = ' ',
  logo = '󰀘 ',
  maximized = ' ',
  note = ' ',
  outline = ' ',
  quickfix = ' ',
  search = ' ',
  source_control = ' ',
  task = ' ',
  term = ' ',
}

return icons
