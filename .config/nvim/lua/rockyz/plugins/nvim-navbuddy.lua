local navbuddy = require('nvim-navbuddy')
local actions = require('nvim-navbuddy.actions')
local symbol_kinds = require('rockyz.icons').symbol_kinds

navbuddy.setup({
  window = {
    size = { height = '60%', width = '100%' },
    position = { row = '100%', col = '0%' },
  },
  node_markers = {
    enabled = true,
    icons = {
      leaf = '',
      leaf_selected = '',
      branch = ' ',
    },
  },
  icons = symbol_kinds,
  use_default_mappings = false,
  mappings = {
    -- Close and cursor to the original location
    ['<esc>'] = actions.close(),
    ['q'] = actions.close(),

    -- Up/down
    ['k'] = actions.previous_sibling(),
    ['j'] = actions.next_sibling(),

    -- Move to the left/right/first panel
    ['h'] = actions.parent(),
    ['l'] = actions.children(),
    ['0'] = actions.root(),

    -- Visual selection of the name/scope
    ['v'] = actions.visual_name(),
    ['V'] = actions.visual_scope(),

    -- Yand the name/scope to system clipboard "+
    ['y'] = actions.yank_name(),
    ['Y'] = actions.yank_scope(),

    -- Insert at the start of name/scope
    ['i'] = actions.insert_name(),
    ['I'] = actions.insert_scope(),

    -- Insert at the end of name/scope
    ['a'] = actions.append_name(),
    ['A'] = actions.append_scope(),

    ['r'] = actions.rename(), -- Rename currently focused symbol

    ['d'] = actions.delete(), -- Delete scope

    -- Create/delete fold of the current scope
    ['f'] = actions.fold_create(),
    ['F'] = actions.fold_delete(),

    ['c'] = actions.comment(), -- Comment out current scope

    ['<enter>'] = actions.select(),

    -- Move focused node up/down
    ['K'] = actions.move_up(),
    ['J'] = actions.move_down(),

    -- Toggle the preview
    ['<C-/>'] = actions.toggle_preview(),
    ['<C-_>'] = actions.toggle_preview(), -- alacritty uses <C-_> as <C-/>

    -- Open selected node in split
    ['<C-v>'] = actions.vsplit(),
    ['<C-x>'] = actions.hsplit(),

    -- Fuzzy finder at current level
    ['<Leader>f'] = actions.telescope({
      prompt_prefix = 'Nodes [curent level]> ',
      preview_title = false,
    }),

    ['g?'] = actions.help(), -- Open mappings help window
  },
})

vim.keymap.set('n', '<Leader>n', navbuddy.open)

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('attach_navbuddy', { clear = true }),
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.server_capabilities.documentSymbolProvider then
      navbuddy.attach(client, bufnr)
    end
  end,
})
