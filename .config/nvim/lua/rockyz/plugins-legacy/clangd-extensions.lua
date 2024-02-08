require('clangd_extensions').setup({
  memory_usage = {
    border = vim.g.border_style,
  },
  symbol_info = {
    border = vim.g.border_style,
  },
  inlay_hints = {
    highlight = 'InlayHint',
  },
  ast = {
    -- Use codicons
    role_icons = {
      type = '',
      declaration = '',
      expression = '',
      specifier = '',
      statement = '',
      ['template argument'] = '',
    },
    kind_icons = {
      Compound = '',
      Recovery = '',
      TranslationUnit = '',
      PackExpansion = '',
      TemplateTypeParm = '',
      TemplateTemplateParm = '',
      TemplateParamObject = '',
    },
  },
})
