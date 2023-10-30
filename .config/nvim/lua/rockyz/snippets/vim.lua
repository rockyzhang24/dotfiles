local snippets = {

  -- Autocmd
  -- augroup group-name
  --   autocmd!
  --   autocmd
  -- augroup END
  s(
    'au',
    fmt(
      [[
      augroup {}
        autocmd!
        autocmd {}
      augroup END
      ]],
      {
        i(1, 'group-name'),
        i(0),
      }
    )
  ),

  -- minpac add a plugin
  s(
    'mp',
    fmt(
      [[
      call minpac#add('{}')
      ]],
      {
        i(1, 'plugin name'),
      }
    )
  ),
}

return snippets
