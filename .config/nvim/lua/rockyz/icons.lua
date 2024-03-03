local icons = {}

icons.codicon = {
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

icons.winbar = {
  folder = ' ',
  delimiter = '',
  ellipsis = ' ',
  quickfix = ' ',
  source_control = ' ',
  outline = ' ',
  explorer = ' ',
  term = ' ',
}

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
  removed = ' ',
}

icons.separators = {
  chevron_left = '',
  chevron_right = '',
  triangle_left = '',
  triangle_right = '',
}

icons.misc = {
  logo = '󰀘 ',
  search = ' ',
  disconnect = ' ',
  edit = ' ',
  indent = ' ',
  ellipsis = ' ',
}

return icons
