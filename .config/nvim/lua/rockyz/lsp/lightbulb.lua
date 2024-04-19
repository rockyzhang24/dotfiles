-- Show a lightbulb when code actions are available at the cursor
--
-- Like VSCode, the lightbulb is displayed at the beginning (the first column) of the same line, or
-- the previous line if the space is not enough.
--
-- This is implemented by using extmarks and it's window-local.

local lsp_utils = require('rockyz.lsp.utils')
local bulb_icon = require('rockyz.icons').lightbulb

local method = 'textDocument/codeAction'

local opts = {
  virt_text = {
    { bulb_icon, 'LightBulb' },
  },
  virt_text_pos = 'overlay',
  scoped = true,
}

-- Get the line number where the bulb should be displayed
local function get_bulb_linenr()
  local linenr = vim.fn.line('.')
  if vim.fn.indent('.') <= 2 then
    if linenr == vim.fn.line('w0') then
      return linenr + 1
    else
      return linenr - 1
    end
  end
  return linenr
end

-- Remove the lightbulb
local function lightbulb_remove(winid, bufnr)
  if vim.w[winid].bulb_ns_id == nil and vim.w[winid].bulb_mark_id == nil then
    return
  end
  vim.api.nvim_buf_del_extmark(bufnr, vim.w[winid].bulb_ns_id, vim.w[winid].bulb_mark_id)
  vim.w[winid].prev_bulb_line = nil
end

-- Create or update the lightbulb
local function lightbulb_update(winid, bufnr)
  local bulb_line = get_bulb_linenr() - 1 -- 0-based

  -- No need to update the bulb if its position does not change
  if bulb_line == vim.w[winid].prev_bulb_line then
    return
  end

  -- Create a window-local namespace for the extmark
  if vim.w[winid].bulb_ns_id == nil then
    local ns_id = vim.api.nvim_create_namespace('bulb_ns_id_' .. winid)
    vim.api.nvim_win_add_ns(winid, ns_id)
    vim.w[winid].bulb_ns_id = ns_id
  end
  -- Create an extmark or update the existing one
  if vim.w[winid].bulb_mark_id == nil then
    vim.w[winid].bulb_mark_id = vim.api.nvim_buf_set_extmark(bufnr, vim.w[winid].bulb_ns_id, bulb_line, 0, opts)
    vim.w[winid].bulb_mark_opts = vim.tbl_extend('keep', opts, {
      id = vim.w[winid].bulb_mark_id,
    })
  else
    vim.api.nvim_buf_set_extmark(bufnr, vim.w[winid].bulb_ns_id, bulb_line, 0, vim.w[winid].bulb_mark_opts)
  end

  vim.w[winid].prev_bulb_line = bulb_line
end

-- Ref: the source code of vim.lsp.buf.code_action()
local function lightbulb()
  local winid = vim.api.nvim_get_current_win()
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
    client.request(method, params, function(_, result, _)
      if has_action then
        return
      end
      for _, action in pairs(result or {}) do
        if action then
          has_action = true
        end
      end
      if has_action then
        lightbulb_update(winid, bufnr)
      else
        lightbulb_remove(winid, bufnr)
      end
    end, bufnr)
  end
end

vim.api.nvim_create_augroup('lightbulb', { clear = true })
vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
  group = 'lightbulb',
  callback = lightbulb,
})
