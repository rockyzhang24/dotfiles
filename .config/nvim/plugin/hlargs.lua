-- The plugin is only enabled for the filetypes whose LSP dosen't have the
-- semantic token @lsp.type.parameter support
local enabled_filetypes = {
  'go',
}

require('hlargs').setup({
  color = '#f9ae28', -- the same with the hl group @lsp.type.parameter
  disable = function(lang, bufnr)
    return not vim.tbl_contains(enabled_filetypes, lang)
  end,
})
