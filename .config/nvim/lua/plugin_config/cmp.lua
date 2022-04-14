local cmp = require('cmp')
local lspkind = require('lspkind')

cmp.setup({

  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },

  -- Border
  -- window = {
  --   completion = cmp.config.window.bordered(),
  --   documentation = cmp.config.window.bordered(),
  -- },

  -- Insert mode mappings
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    -- Then the default <C-n> and <C-p> for selecting the next/previous item
  }),

  sources = cmp.config.sources({
    -- The order of the sources gives them priority, or use priority = xxx to specify it.
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer', keyword_length = 4 },
    { name = 'path' },
    { name = 'nvim_lua' }, -- nvim_lua make it only be enabled for Lua filetype
  }),

  formatting = {
    -- Icons
    format = lspkind.cmp_format({
      mode = "symbol_text",
      menu = ({
        buffer = "[buf]",
        nvim_lsp = "[LSP]",
        luasnip = "[snip]",
        nvim_lua = "[lua]",
        path = "[path]",
      })
    }),
    -- Adjust the order of completion menu fields
    -- fields = {
    --   'abbr',
    --   'kind',
    --   'menu',
    -- },
  },

  experimental = {
    ghost_text = true,
  },

})
