local cmp = require('cmp')
local lspkind = require('lspkind')

cmp.setup({

  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },

  mapping = {
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-d>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-e>'] = cmp.mapping(cmp.mapping.abort(), { 'i', 'c' }),
    ['<C-y>'] = cmp.mapping(cmp.mapping.confirm({ select = true }), { 'i', 'c' }),

    -- Then the default <C-n> and <C-p> for selecting the next/previous item
  },

  sources = {
    -- The order of the sources gives them priority, or use priority = xxx to specify it.
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer', keyword_length = 5 },
    { name = 'path' },
    { name = 'nvim_lua' }, -- nvim_lua make it only be enabled for Lua filetype
  },

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
  },

  experimental = {
    ghost_text = true,
  },

})

-- Buffer-specific setting
-- NOTE: This will OVERRIDE the global setup for that buffer
-- vim.cmd [[
--   augroup DadbodSql
--     au!
--     autocmd FileType sql,mysql,plsql lua require('cmp').setup.buffer { sources = { { name = 'vim-dadbod-completion' } } }
--   augroup END
-- ]]

-- Disable nvim-cmp for a buffer
-- vim.cmd [[
--   augroup Disable-cmp
--     au!
--     autocmd Filetype xxx lua require('cmp').setup.buffer { enabled = false }
--   augroup END
-- ]]

-- Helpful resources:
-- 1) How to create your own cmp source?
-- https://github.com/tjdevries/config_manager/blob/master/xdg_config/nvim/after/plugin/cmp_gh_source.lua
-- https://youtu.be/_DnmphIwnjo?t=1411
