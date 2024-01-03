-- Show a lightbulb when code actions are available at the cursor
--
-- Like VSCode, the lightbulb is displayed at the beginning (the first column) of the same line, or
-- the previous line if the space is not enough.
--
-- I implement the lightbulb using a floating window and for simplicity it's only displayed in the
-- active window.
--
-- TODO: the extmark currently is buffer local. If multiple windows open a same buffer, the
-- lightbulb will be displayed in sync. After this issue
-- (https://github.com/neovim/neovim/issues/19654) is solved, we can display the lightbulb using
-- extmark.

local lsp_utils = require('rockyz.lsp.utils')
local icon = require('rockyz.icons').lightbulb

local bulb_bufnr
local prev_winid
local prev_bulb_linenr
local method = 'textDocument/codeAction'

-- Calculate the row offset relative to the cursor line
local function get_row_offset()
  local offset = 0
  local cur_indent = vim.fn.indent('.')
  if cur_indent <= 2 then
    if vim.fn.line('.') == vim.fn.line('w0') then
      offset = 1
    else
      offset = -1
    end
  end
  return offset
end

-- Calculate the col offset relative to the cursor column
local function get_col_offset()
  -- We want to get how many columns (characters) before the cursor that will be the offset for
  -- placing the bulb. If the indent is TAB, each indent level is counted as a single one character
  -- no matter how many spaces the TAB has. We need to convert it to the number of spaces.
  local cur_indent = vim.fn.indent('.')
  local cursor_col = vim.fn.col('.')
  local col = -cursor_col + 1
  if not vim.api.nvim_get_option_value('expandtab', {}) then
    local tabstop = vim.api.nvim_get_option_value('tabstop', {})
    local tab_cnt = cur_indent / tabstop
    if cursor_col <= tab_cnt then
      col = -(cursor_col - 1) * tabstop
    else
      col = -(cursor_col - tab_cnt + cur_indent) + 1
    end
  end
  return col
end

-- Create a floating window showing a lightbulb
local function lightbulb_create(row, col)
  bulb_bufnr = vim.api.nvim_create_buf(false, true)
  local winid = vim.api.nvim_open_win(bulb_bufnr, false, {
    relative = 'cursor',
    width = 1,
    height = 1,
    row = row,
    col = col,
    style = 'minimal',
    noautocmd = true,
    zindex = 1,
  })
  vim.wo[winid].winhl = 'Normal:LightBulb'
  vim.api.nvim_buf_set_lines(bulb_bufnr, 0, 1, false, { icon })
end

-- Remove the bulb floating window
local function lightbulb_remove()
  if bulb_bufnr ~= nil then
    vim.cmd(('noautocmd bwipeout %d'):format(bulb_bufnr))
    bulb_bufnr = nil
  end
end

-- Update the lightbulb, i.e., removing the old one and create a new one
local function lightbulb_update(scrolled)
  local row_offset = get_row_offset()
  local col_offset = get_col_offset()
  local bulb_linenr = vim.fn.line('.') + row_offset
  -- To avoid bulb flickering: don't refresh the bulb when moving in a line
  if bulb_bufnr ~= nil and bulb_linenr == prev_bulb_linenr and not scrolled then
    return
  end
  lightbulb_remove()
  lightbulb_create(row_offset, col_offset)
  prev_bulb_linenr = bulb_linenr
end

-- Display the lightbulb
-- Ref: the source code of vim.lsp.buf.code_action()
local function lightbulb()
  local winid = vim.api.nvim_get_current_win()
  -- Remove lightbulb first after switching to another window
  if winid ~= prev_winid then
    lightbulb_remove()
    prev_winid = winid
  end
  local bufnr = vim.api.nvim_get_current_buf()
  local context = {
    -- Get the diagnostics under the cursor
    diagnostics = lsp_utils.get_diagnostics_under_cursor(),
  }
  local clients = vim.lsp.get_clients({ bufnr = bufnr, method = method })
  local has_action = false
  for _, client in ipairs(clients) do
    local params = vim.lsp.util.make_range_params(winid, client.offset_encoding)
    params.context = context
    client.request(method, params, function(err, result, ctx)
      if has_action then
        return
      end
      for _, action in pairs(result or {}) do
        if action then
          has_action = true
        end
      end
      if has_action then
        lightbulb_update()
      else
        lightbulb_remove()
      end
    end, bufnr)
  end
end

vim.api.nvim_create_augroup('lightbulb', { clear = true })
vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
  group = 'lightbulb',
  pattern = '*',
  callback = lightbulb,
})
-- The bulb should be updated when scrolling the window
vim.api.nvim_create_autocmd({ 'WinScrolled' }, {
  group = 'lightbulb',
  pattern = '*',
  callback = function()
    local winid = vim.api.nvim_get_current_win()
    local event = vim.v.event[tostring(winid)]
    if bulb_bufnr ~= nil and event ~= nil and event.topline ~= 0 then
      lightbulb_update(true)
    end
  end,
})
