-- Usage:
-- 1. toggler
--    toggle line comment: gcc
--    toggle block comment: gbc
-- 2. operatorg
--    line: gc
--    block: gb
-- 3. extra
--    add comment on the line above/below/end: gcO/gco/gcA
-- 4. operator-pending (my customization)
--    gc is the text object for adjacent commented lines. E.g., use gdc to delete adjacent commented
--    lines.

require('Comment').setup({
  -- Ignore blank lines
  ignore = '^%s*$',
  -- Integrate nvim-ts-context-commentstring
  pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
})

-- Text object for adjacent commented lines. Use gcgc to uncomment the current and adjacent
-- commented lines like vim-commentary.
-- Taken from https://github.com/numToStr/Comment.nvim/issues/22#issuecomment-1272569139
local function commented_lines_textobj()
  local utils = require('Comment.utils')
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local comment_str = require('Comment.ft').calculate({
    ctype = utils.ctype.linewise,
    range = {
      srow = row,
      scol = 0,
      erow = row,
      ecol = 0,
    },
  }) or vim.bo.commentstring
  local l_comment_str, r_comment_str = utils.unwrap_cstr(comment_str)
  local is_commented = utils.is_commented(l_comment_str, r_comment_str, true)
  local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)
  if next(line) == nil or not is_commented(line[1]) then
    return
  end
  local comment_start, comment_end = row, row
  repeat
    comment_start = comment_start - 1
    line = vim.api.nvim_buf_get_lines(0, comment_start - 1, comment_start, false)
  until next(line) == nil or not is_commented(line)
  comment_start = comment_start + 1
  repeat
    comment_end = comment_end + 1
    line = vim.api.nvim_buf_get_lines(0, comment_end - 1, comment_end, false)
  until next(line) == nil or not is_commented(line)
  comment_end = comment_end - 1
  vim.cmd(string.format('normal! %dGV%dG', comment_start, comment_end))
end
vim.keymap.set('o', 'gc', commented_lines_textobj, { silent = true })
