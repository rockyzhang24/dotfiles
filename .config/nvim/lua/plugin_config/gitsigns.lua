require('gitsigns').setup {
  numhl = true,
  sign_priority = 1,

  keymaps = {
    -- Mapping options
    noremap = true,
    silent = true,

    ['n [h'] = { expr = true, "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'"},
    ['n ]h'] = { expr = true, "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'"},

    ['n <leader>hs'] = '<cmd>Gitsigns stage_hunk<CR>',
    ['v <leader>hs'] = ':Gitsigns stage_hunk<CR>',
    ['n <leader>hS'] = '<cmd>Gitsigns stage_buffer<CR>',

    ['n <leader>hu'] = '<cmd>Gitsigns undo_stage_hunk<CR>',
    ['n <leader>hU'] = '<cmd>Gitsigns reset_buffer_index<CR>',  -- undo all hunks of current buffer

    ['n <leader>hr'] = '<cmd>Gitsigns reset_hunk<CR>',  -- "reset" means discarding changes
    ['v <leader>hr'] = ':Gitsigns reset_hunk<CR>',
    ['n <leader>hR'] = '<cmd>Gitsigns reset_buffer<CR>',

    ['n <leader>hp'] = '<cmd>Gitsigns preview_hunk<CR>',
    ['n <leader>hb'] = '<cmd>lua require"gitsigns".blame_line{full=true}<CR>',

    -- Text objects
    ['o ih'] = ':<C-U>Gitsigns select_hunk<CR>',
    ['x ih'] = ':<C-U>Gitsigns select_hunk<CR>',

  },

   preview_config = {
    -- Options passed to nvim_open_win
    border = 'rounded',
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1
  },
}
