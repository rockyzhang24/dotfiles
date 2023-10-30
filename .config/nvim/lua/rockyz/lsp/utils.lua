local M = {}

--- Get diagnostics (LSP Diagnostic) at the cursor
---
--- Grab the code from https://github.com/neovim/neovim/issues/21985
---
--- TODO:
--- This PR (https://github.com/neovim/neovim/pull/22883) extends
--- vim.diagnostic.get to return diagnostics at cursor directly and even with
--- LSP Diagnostic structure. If it gets merged, simplify this funciton (the
--- code for filter and build can be removed).
---
---@return table # A table of LSP Diagnostic
function M.get_diagnostic_at_cursor()
  local cur_bufnr = vim.api.nvim_get_current_buf()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0)) -- line is 1-based indexing
  -- Get a table of diagnostics at the current line. The structure of the
  -- diagnostic item is defined by nvim (see :h diagnostic-structure) to
  -- describe the information of a diagnostic.
  local diagnostics = vim.diagnostic.get(cur_bufnr, { lnum = line - 1 }) -- lnum is 0-based indexing
  -- Filter out the diagnostics at the cursor position. And then use each to
  -- build a LSP Diagnostic (see
  -- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#diagnostic)
  local lsp_diagnostics = {}
  for _, diag in pairs(diagnostics) do
    if diag.col <= col and diag.end_col >= col then
      table.insert(lsp_diagnostics, {
        range = {
          ['start'] = {
            line = diag.lnum,
            character = diag.col,
          },
          ['end'] = {
            line = diag.end_lnum,
            character = diag.end_col,
          },
        },
        severity = diag.severity,
        code = diag.code,
        source = diag.source or nil,
        message = diag.message,
      })
    end
  end
  return lsp_diagnostics
end

return M
