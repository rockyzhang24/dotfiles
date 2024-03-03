local cmp = require('cmp')
local feedkeys = require('cmp.utils.feedkeys')
local keymap = require('cmp.utils.keymap')
local symbol_kinds = require('rockyz.icons').codicon

-- Disable buffer source for large file
local large_file_disable = function()
  local buf = vim.api.nvim_get_current_buf()
  local byte_size = vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
  if byte_size > 1024 * 1024 then -- 1MB
    return {}
  end
  return { buf }
end

local winhighlight = 'FloatBorder:SuggestWidgetBorder,CursorLine:SuggestWidgetSelect,Search:None'
if vim.g.border_enabled then
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
      border = vim.g.border_style,
    },
    documentation = {
      winhighlight = winhighlight,
      border = vim.g.border_style,
      focusable = true,
      max_height = math.floor(vim.o.lines * 0.5),
      max_width = math.floor(vim.o.columns * 0.4),
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
    {
      name = 'nvim_lsp',
      -- Filter out snippets from LSP
      -- entry_filter = function(entry, ctx)
      --   return types.lsp.CompletionItemKind[entry:get_kind()] ~= 'Snippet'
      -- end,
    },
    { name = 'luasnip' },
  }, {
    {
      name = 'buffer',
      option = {
        get_bufnrs = large_file_disable,
      },
    },
    { name = 'path' },
  }),
  formatting = {
    format = function(_, vim_item)
      local MAX_ABBR_WIDTH, MAX_MENU_WIDTH = 25, 30
      local ellipsis = require('rockyz.icons').misc.ellipsis
      -- Add the icon
      vim_item.kind = string.format('%s %s', symbol_kinds[vim_item.kind] or symbol_kinds.Text, vim_item.kind)
      -- Truncate the label
      if vim.api.nvim_strwidth(vim_item.abbr) > MAX_ABBR_WIDTH then
        vim_item.abbr = vim.fn.strcharpart(vim_item.abbr, 0, MAX_ABBR_WIDTH) .. ellipsis
      end
      -- Truncate the description part
      if vim.api.nvim_strwidth(vim_item.menu or '') > MAX_MENU_WIDTH then
        vim_item.menu = vim.fn.strcharpart(vim_item.menu, 0, MAX_MENU_WIDTH) .. ellipsis
      end
      return vim_item
    end,
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
        get_bufnrs = large_file_disable,
      },
    },
  },
  view = {
    entries = { name = 'wildmenu', separator = ' | ' },
  },
})

-- For search backward
cmp.setup.cmdline('?', {
  sources = {
    {
      name = 'buffer',
      option = {
        get_bufnrs = large_file_disable,
      },
    },
  },
  view = {
    entries = { name = 'wildmenu', separator = ' | ' },
  },
})

-- For cmdline
cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'path' },
  }, {
    { name = 'cmdline' },
  }),
})
