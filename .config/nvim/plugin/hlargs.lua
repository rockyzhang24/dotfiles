local enabled_filetypes = {
  'go',
}

require('hlargs').setup({
  color = '#fd9621', -- the same with the hl group @lsp.type.parameter
  disable = function(lang, bufnr)
    return not vim.tbl_contains(enabled_filetypes, lang)
  end,
})
