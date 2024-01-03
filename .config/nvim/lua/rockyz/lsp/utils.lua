--
-- Get diagnostics (LSP Diagnostic[]) whose range overlap the current cursor position
--
-- As for the structure of LSP Diagnostic, see
-- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#diagnostic
--
-- In Neovim, diagnostics have many sources, and LSP diagnostic is just one of them. Neovim defines
-- its own structure, i.e., a table (called vim Diagnostic to distingiush it from LSP Diagnostic)
-- with some necessary fields, to describe a diagnostic, see :h diagnostic-structure.
--
-- vim.diagnostic.get() returns the diagnostics (vim Diagnostic[]) in the current buffer. We need to
-- filter them to get each diagnostic whose range overlaps the current cursor position and convert
-- them to LSP Diagnostic[]
--
-- Usage: when we want to get the code actions under the cursor position, this returned LSP
-- Diagnostic[] can be used as context.diagnostics when calling vim.lsp.buf.code_action() or sending
-- a textDocument/codeAction request to the server.
--

local M = {}

---@return table # A table of LSP Diagnostic, i.e., LSP Diagnostic[]
function M.get_diagnostics_under_cursor()
  local cur_bufnr = vim.api.nvim_get_current_buf()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  line = line - 1 -- convert to 0-indexed
  local diagnostics = vim.diagnostic.get(cur_bufnr, {})
  -- Filter these diagnostic items and convert them to LSP Diagnostic[]
  local lsp_diagnostics = {}
  for _, d in pairs(diagnostics) do
    if
      -- We only need to check the columns if the starting line or the final line of the diagnostic
      -- is the same line with the cursor line. Note: the end position is exclusive.
      (d.lnum < line or d.lnum == line and d.col <= col)
      and (d.end_lnum > line or d.end_lnum == line and d.end_col > col)
    then
      table.insert(lsp_diagnostics, {
        range = {
          start = {
            line = d.lnum,
            character = d.col,
          },
          ['end'] = {
            line = d.end_lnum,
            character = d.end_col,
          },
        },
        severity = type(d.severity) == 'string' and vim.diagnostic.severity[d.severity]
          or d.severity,
        message = d.message,
        source = d.source,
        code = d.code,
      })
    end
  end
  return lsp_diagnostics
end

return M
