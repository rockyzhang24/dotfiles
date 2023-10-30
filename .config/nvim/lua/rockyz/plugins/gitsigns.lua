local gitsigns = require('gitsigns')

gitsigns.setup({
  -- Hidden features (probably not stable)
  _signs_staged_enable = true,
  _extmark_signs = true,

  signs = {
    add = { show_count = false },
    change = { show_count = false },
    delete = { show_count = true },
    topdelete = { show_count = true },
    changedelete = { show_count = true },
    untracked = { show_count = false },
  },
  signcolumn = true,
  numhl = false,
  linehl = false,
  word_diff = false,
  sign_priority = 6,
  preview_config = {
    -- Options passed to nvim_open_win
    border = vim.g.border_style,
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1,
  },
  count_chars = {
    [1] = '₁',
    [2] = '₂',
    [3] = '₃',
    [4] = '₄',
    [5] = '₅',
    [6] = '₆',
    [7] = '₇',
    [8] = '₈',
    [9] = '₉',
    ['+'] = '₊',
  },

  -- Keymaps
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function buf_map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    buf_map('n', ']h', function()
      if vim.wo.diff then
        return ']c'
      end
      vim.schedule(function()
        gs.next_hunk()
      end)
      return '<Ignore>'
    end, { expr = true })
    buf_map('n', '[h', function()
      if vim.wo.diff then
        return '[c'
      end
      vim.schedule(function()
        gs.prev_hunk()
      end)
      return '<Ignore>'
    end, { expr = true })

    -- Stage hunk or buffer
    buf_map('n', '<Leader>hs', gs.stage_hunk)
    buf_map('v', '<Leader>hs', function()
      gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end)
    buf_map('n', '<Leader>hS', gs.stage_buffer)

    -- Reset
    buf_map('n', '<Leader>hr', gs.reset_hunk)
    buf_map('v', '<Leader>hr', function()
      gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end)
    buf_map('n', '<Leader>hR', gs.reset_buffer)

    -- Undo the last gs.stage_hunk call
    buf_map('n', '<Leader>hu', gs.undo_stage_hunk)

    -- Discard changes
    buf_map({ 'n', 'v' }, '<Leader>hr', ':Gitsigns reset_hunk<CR>')
    buf_map('n', '<Leader>hR', gs.reset_buffer)

    -- Others
    buf_map('n', '<Leader>hp', gs.preview_hunk)
    buf_map('n', '<Leader>hb', function()
      gs.blame_line({ full = true })
    end)
    buf_map('n', '<Leader>hd', gs.toggle_deleted) -- toggle showing deleted/changed lines via virtual lines
    buf_map('n', '<Leader>hw', gs.toggle_word_diff) -- toggle the word_diff in the buffer

    -- Text object
    buf_map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')

    -- Put hunks into quickfix list
    buf_map('n', '<leader>hQ', function()
      gitsigns.setqflist('all')
    end) -- all modified files for git dir
    buf_map('n', '<leader>hq', gitsigns.setqflist)
  end,
})
