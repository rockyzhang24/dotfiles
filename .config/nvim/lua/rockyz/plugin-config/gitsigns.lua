local gitsigns = require('gitsigns')

gitsigns.setup {
  -- Hidden features (probably not stable)
  _signs_staged_enable = true,
  _extmark_signs = true,

  signs = {
    add          = { show_count = false },
    change       = { show_count = false },
    delete       = { show_count = true },
    topdelete    = { show_count = true },
    changedelete = { show_count = true },
    untracked    = { show_count = false },
  },
  signcolumn = true,
  numhl = false,
  linehl = false,
  word_diff = false,
  sign_priority = 6,
  preview_config = {
    -- Options passed to nvim_open_win
    border = 'single',
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1
  },
  count_chars = {
    [1]   = '₁',
    [2]   = '₂',
    [3]   = '₃',
    [4]   = '₄',
    [5]   = '₅',
    [6]   = '₆',
    [7]   = '₇',
    [8]   = '₈',
    [9]   = '₉',
    ['+'] = '₊',
  },

  -- Keymaps
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      opts.silent = true
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']h', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, { expr = true })

    map('n', '[h', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, { expr = true })

    -- Stage hunk or buffer
    map({ 'n', 'v' }, '<Leader>hs', ':Gitsigns stage_hunk<CR>')
    map('n', '<Leader>hS', gs.stage_buffer)

    -- Unstage hunk or buffer
    map('n', '<Leader>hu', gs.undo_stage_hunk)
    map('n', '<Leader>hU', gs.reset_buffer_index) -- git reset HEAD

    -- Discard changes
    map({ 'n', 'v' }, '<Leader>hr', ':Gitsigns reset_hunk<CR>')
    map('n', '<Leader>hR', gs.reset_buffer)

    map('n', '<Leader>hp', gs.preview_hunk)
    map('n', '<Leader>hb', function() gs.blame_line { full = true } end)
    map('n', '<BS>c', gs.toggle_deleted) -- toggle showing deleted/changed lines via virtual lines
    map('n', '<BS>w', gs.toggle_word_diff) -- toggle the word_diff in the buffer

    -- Text object
    map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')

    -- Put hunks into quickfix list
    map('n', '<leader>hQ', function() gitsigns.setqflist('all') end) -- all modified files for git dir
    map('n', '<leader>hq', gitsigns.setqflist)
  end
}
