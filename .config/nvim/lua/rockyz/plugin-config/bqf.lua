local cmd = vim.cmd
local api = vim.api
local bqf_pv_timer

-- Better highlighting (highlight the range) for the quickfix stuffed by vim-grepper
cmd(([[
  aug Grepper
    au!
    au User Grepper ++nested %s
  aug END
]]):format([[call setqflist([], 'r', {'context': {'bqf': {'pattern_hl': '\%#' . getreg('/')}}})]]))

require('bqf').setup {
  filter = {
    fzf = {
      extra_opts = { '--delimiter', '│' }
    }
  },
  preview = {
    border = { '', '─', '', '', '', '─', '', '' },
    winblend = 0,

    -- Support previewing vim-fugitive :Gclog entries
    -- Ref: https://github.com/kevinhwang91/nvim-bqf/issues/60#issuecomment-1073507403
    should_preview_cb = function(bufnr, qwinid)
      local bufname = api.nvim_buf_get_name(bufnr)
      if bufname:match '^fugitive://' and not api.nvim_buf_is_loaded(bufnr) then
        if bqf_pv_timer and bqf_pv_timer:get_due_in() > 0 then
          bqf_pv_timer:stop()
          bqf_pv_timer = nil
        end
        bqf_pv_timer = vim.defer_fn(function()
          api.nvim_buf_call(bufnr, function()
            cmd(('do fugitive BufReadCmd %s'):format(bufname))
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
    end
  }
}
