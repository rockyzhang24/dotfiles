local cmp = require('cmp')
local types = require('cmp.types')
local lspkind = require('lspkind')
local feedkeys = require('cmp.utils.feedkeys')
local keymap = require('cmp.utils.keymap')
local border_enabled = vim.g.border_enabled

local get_bufnrs = function()
  local buf = vim.api.nvim_get_current_buf()
  local byte_size = vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
  -- Disable buffer source for large file (1MB)
  if byte_size > 1024 * 1024 then
    return {}
  end
  return { buf }
end

local winhighlight = 'FloatBorder:SuggestWidgetBorder,CursorLine:SuggestWidgetSelect,Search:None'
if border_enabled then
  winhighlight = 'Normal:Normal,PmenuThumb:ScrollbarSlider,' .. winhighlight
else
  winhighlight = 'Normal:Pmenu,' .. winhighlight
end

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  window = {
    completion = {
      winhighlight = winhighlight,
      border = border_enabled and 'single' or 'none',
    },
    documentation = {
      winhighlight = winhighlight,
      border = border_enabled and 'single' or 'none',
      focusable = true,
    },
  },
  -- Mappings
  -- Default mappings can be found here: https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/config/mapping.lua
  -- Ref: https://github.com/hrsh7th/nvim-cmp/issues/1027
  mapping = {
    ['<C-n>'] = {
      i = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
    },
    ['<C-p>'] = {
      i = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
    },
    ['<C-b>'] = {
      i = cmp.mapping.scroll_docs(-4),
    },
    ['<C-f>'] = {
      i = cmp.mapping.scroll_docs(4),
    },
    ['<C-Enter>'] = {
      i = cmp.mapping.complete(),
    },
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
    }),
    ['<C-y>'] = {
      i = cmp.mapping.confirm({ select = true }),
    },
    ['<Tab>'] = {
      c = function()
        if cmp.visible() then
          cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
        else
          feedkeys.call(keymap.t('<C-z>'), 'n')
        end
      end,
    },
    ['<S-Tab>'] = {
      c = function()
        if cmp.visible() then
          cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
        else
          feedkeys.call(keymap.t('<C-z>'), 'n')
        end
      end,
    },
  },
  sources = cmp.config.sources({
    -- The order of the sources gives them priority, or use priority = xxx to specify it.
    { name = 'nvim_lua' }, -- nvim_lua make it only be enabled for Lua filetype
    {
      name = 'nvim_lsp',
      -- Filter out snippets from LSP
      -- entry_filter = function(entry, ctx)
      --   return types.lsp.CompletionItemKind[entry:get_kind()] ~= 'Snippet'
      -- end,
    },
    { name = 'luasnip' },
    {
      name = 'buffer',
      keyword_length = 4,
      option = {
        get_bufnrs = get_bufnrs,
      },
    },
    { name = 'path' },
  }),
  -- This sorting config is grabbed from TJ
  sorting = {
    comparators = {
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.score,

      function(entry1, entry2)
        local _, entry1_under = entry1.completion_item.label:find "^_+"
        local _, entry2_under = entry2.completion_item.label:find "^_+"
        entry1_under = entry1_under or 0
        entry2_under = entry2_under or 0
        if entry1_under > entry2_under then
          return false
        elseif entry1_under < entry2_under then
          return true
        end
      end,

      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  },
  formatting = {
    -- Icons
    format = lspkind.cmp_format({
      mode = "symbol",
      preset = "codicons",
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
      'kind',
      'abbr',
      'menu',
    },
  },
  experimental = {
    ghost_text = {
      hl_group = 'GhostText',
    },
  },
})

-- For search forward
cmp.setup.cmdline('/', {
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

-- For search backward
cmp.setup.cmdline('?', {
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

-- For cmdline
cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  }),
})
