require('gitsigns').setup {

  signcolumn = true,
  numhl = true,
  linehl = false,
  word_diff = false,

  sign_priority = 1,

  preview_config = {
    -- Options passed to nvim_open_win
    border = 'rounded',
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1
  },

  signs = {
    add          = {show_count = false, text = '┃' },
    change       = {show_count = false, text = '┃' },
    delete       = {show_count = true },
    topdelete    = {show_count = true },
    changedelete = {show_count = true},
  },

  -- Keymaps (vim.keymap API requires Neovim 0.7)
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', '[h', "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", {expr=true})
    map('n', ']h', "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", {expr=true})

    -- Stage hunk or buffer
    map({'n', 'v'}, '<Leader>hs', gs.stage_hunk)
    map('n', '<Leader>hS', gs.stage_buffer)

    -- Unstage hunk or buffer
    map('n', '<Leader>hu', gs.undo_stage_hunk)
    map('n', '<Leader>hU', gs.reset_buffer_index) -- git reset HEAD

    -- Discard changes
    map({'n', 'v'}, '<Leader>hr', gs.reset_hunk)
    map('n', '<Leader>hR', gs.reset_buffer)

    map('n', '<Leader>hp', gs.preview_hunk)
    map('n', '<Leader>hb', function() gs.blame_line{full=true} end)
    map('n', '<Leader>\\c', gs.toggle_deleted) -- toggle showing deleted/changed lines via virtual lines

    -- Text object
    map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end
}
