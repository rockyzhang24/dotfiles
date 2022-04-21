local cmp = require('cmp')
local lspkind = require('lspkind')

local get_bufnrs = function()
  local buf = vim.api.nvim_get_current_buf()
  local byte_size = vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
  -- Disable buffer source for large file (1MB)
  if byte_size > 1024 * 1024 then
    return {}
  end
  return { buf }
end

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
    {
      name = 'buffer',
      keyword_length = 4,
      option = {
        get_bufnrs = get_bufnrs,
      },
    },
    { name = 'path' },
    { name = 'nvim_lua' }, -- nvim_lua make it only be enabled for Lua filetype
  }),

  formatting = {
    -- Icons
    format = lspkind.cmp_format({
      mode = "symbol_text",
      menu = ({
        buffer = "[Buf]",
        nvim_lsp = "[LSP]",
        luasnip = "[Snip]",
        nvim_lua = "[Lua]",
        path = "[Path]",
      })
    }),
    -- Adjust the order of completion menu fields
    fields = {
      'abbr',
      'kind',
      'menu',
    },
  },

  experimental = {
    ghost_text = true,
  },

})

-- Use buffer source for `/`
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    {
      name = 'buffer',
      option = {
        get_bufnrs = get_bufnrs,
      },
    },
  },
  view = {
    entries = { name = 'wildmenu', separator = ' · ' }
  },
})
