local bqf_pv_timer

-- Better highlighting (highlight the range) for the quickfix stuffed by vim-grepper
vim.cmd(([[
  aug Grepper
    au!
    au User Grepper ++nested %s
  aug END
]]):format([[call setqflist([], 'r', {'context': {'bqf': {'pattern_hl': '\%#' . getreg('/')}}})]]))

require('bqf').setup({
  -- Check the other default mappings and descriptions: https://github.com/kevinhwang91/nvim-bqf#function-table
  func_map = {
    drop = 'o',
    openc = 'O',
    tabdrop = '<C-t>',
    sclear = 'c',
    pscrollup = '<M-u>',
    pscrolldown = '<M-d>',
    ptoggleauto = '<C-_>',
  },
  filter = {
    fzf = {
      action_for = {
        ['enter'] = 'drop',
        ['ctrl-t'] = 'tab drop',
      },
      extra_opts = {
        '--delimiter',
        '│',
        '--preview-window',
        'default',
      },
    },
  },
  preview = {
    border = { '', '─', '', '', '', '─', '', '' },
    winblend = 0,
    win_height = 20,

    -- Support previewing vim-fugitive :Gclog entries
    -- Ref: https://github.com/kevinhwang91/nvim-bqf/issues/60#issuecomment-1073507403
    should_preview_cb = function(bufnr, qwinid)
      local bufname = vim.api.nvim_buf_get_name(bufnr)
      if bufname:match('^fugitive://') and not vim.api.nvim_buf_is_loaded(bufnr) then
        if bqf_pv_timer and bqf_pv_timer:get_due_in() > 0 then
          bqf_pv_timer:stop()
          bqf_pv_timer = nil
        end
        bqf_pv_timer = vim.defer_fn(function()
          vim.api.nvim_buf_call(bufnr, function()
            vim.cmd(('do fugitive BufReadCmd %s'):format(bufname))
          end)
          require('bqf.preview.handler').open(qwinid, nil, true)
        end, 60)
      end

      -- File size greater than 10K can't be previewed automatically
      -- local fsize = vim.fn.getfsize(bufname)
      -- if fsize > 10 * 1024 then
      --   return false
      -- end

      return true
    end,
  },
})
