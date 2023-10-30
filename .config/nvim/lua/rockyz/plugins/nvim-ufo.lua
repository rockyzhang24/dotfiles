local M = {}
local ufo = require('ufo')

-- Provider for a buffer with git or diff filetype (e.g., press dd in vim-flog).
-- It returns UfoFoldingRange (it is a table of { startLine = lineNum_1, endLine
-- = lineNum_2 } that describes the range of a fold) that contains the ranges of
-- all the folds we define.
-- It creates folds for (1) input source (starts with +++ symbol), (2)
-- diff chunks (starts with @@ symbol).
function M.gitProvider(bufnr)
  local res = {}
  local fileStart, hunkStart
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
  for i, line in ipairs(lines) do
    if line:match('^diff %-%-') then
      if hunkStart then
        table.insert(res, { startLine = hunkStart - 1, endLine = i - 2 })
      end
      if fileStart then
        table.insert(res, { startLine = fileStart - 1, endLine = i - 2 })
      end
      fileStart, hunkStart = nil, nil
    elseif line:match('^@@ %-%d+,%d+ %+%d+,%d+') then
      if hunkStart then
        table.insert(res, { startLine = hunkStart - 1, endLine = i - 2 })
      end
      hunkStart = i
    elseif line:match('^%+%+%+ %S') then
      fileStart = i
    end
  end
  if hunkStart then
    table.insert(res, { startLine = hunkStart - 1, endLine = #lines - 2 })
  end
  if fileStart then
    table.insert(res, { startLine = fileStart - 1, endLine = #lines - 2 })
  end
  return res
end

-- Customize fold text
local handler = function(virtText, lnum, endLnum, width, truncate)
  local newVirtText = {}
  local suffix = ('  %d '):format(endLnum - lnum)
  local sufWidth = vim.fn.strdisplaywidth(suffix)
  local targetWidth = width - sufWidth
  local curWidth = 0
  for _, chunk in ipairs(virtText) do
    local chunkText = chunk[1]
    local chunkWidth = vim.fn.strdisplaywidth(chunkText)
    if targetWidth > curWidth + chunkWidth then
      table.insert(newVirtText, chunk)
    else
      chunkText = truncate(chunkText, targetWidth - curWidth)
      local hlGroup = chunk[2]
      table.insert(newVirtText, { chunkText, hlGroup })
      chunkWidth = vim.fn.strdisplaywidth(chunkText)
      -- str width returned from truncate() may less than 2nd argument, need padding
      if curWidth + chunkWidth < targetWidth then
        suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
      end
      break
    end
    curWidth = curWidth + chunkWidth
  end
  table.insert(newVirtText, { suffix, 'UfoFoldedEllipsis' })
  return newVirtText
end

local ftMap = {
  git = M.gitProvider,
  diff = M.gitProvider,
  fugitive = '',
}

ufo.setup({
  provider_selector = function(bufnr, filetype, buftype)
    return ftMap[filetype]
  end,
  fold_virt_text_handler = handler,
  preview = {
    win_config = {
      border = { '', '─', '', '', '', '─', '', '' },
      winblend = 0,
      winhighlight = 'Normal:UfoPreviewNormal,FloatBorder:UfoPreviewBorder,CursorLine:UfoPreviewCursorLine',
    },
    mappings = {
      scrollU = '<C-u>',
      scrollD = '<C-d>',
      jumpTop = '[',
      jumpBot = ']',
    },
  },
})

-- Remap the builtin keymaps for keeping the foldlevel
vim.keymap.set('n', 'zR', ufo.openAllFolds)
vim.keymap.set('n', 'zM', ufo.closeAllFolds)
vim.keymap.set('n', 'zr', ufo.openFoldsExceptKinds)
vim.keymap.set('n', 'zm', ufo.closeFoldsWith)
-- Preview the fold and create some convenient keymaps for the preview window
-- for inserting text directly, or show the documentation via LSP
vim.keymap.set('n', 'K', function()
  local winid = ufo.peekFoldedLinesUnderCursor()
  if winid then
    local bufnr = vim.api.nvim_win_get_buf(winid)
    local keys = { 'a', 'i', 'o', 'A', 'I', 'O', 'c', 's' }
    for _, k in ipairs(keys) do
      vim.keymap.set('n', k, '<CR>' .. k, { remap = true, buffer = bufnr, nowait = true })
    end
  else
    vim.lsp.buf.hover()
  end
end)

return M
