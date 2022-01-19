require("plugin_config.luasnip.shorthands").setup_shorthands()

local snippets = {

  -- Section
  -- " section-name {{{
  --
  -- " }}}
  s("sec", {
    t("\" "),
    i(1, "section-name"),
    t({" {{{", "", ""}),
    i(0),
    t({"", "", "\" }}}"}),
  }),

  -- Autocmd
  -- augroup group-name
  --   autocmd!
  --   autocmd
  -- augroup END
  s("au", fmt([[
    augroup {}
      autocmd!
      autocmd {}
    augroup END
    ]], {
      i(1, "group-name"),
      i(0),
    })
  ),
}

return snippets
