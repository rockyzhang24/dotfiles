local lsp = vim.lsp
-- For mode, only show the first char (or first two chars to distinguish
-- different VISUALs) plus a fancy icon
local function simplifiedMode(str)
  return " " .. (str == "V-LINE" and "VL" or (str == "V-BLOCK" and "VB" or str:sub(1, 1)))
end

-- For filename, show the filename and the filesize
local function fileNameAndSize(str)
  -- For doc, only show filename
  if (string.find(str, '.*/doc/.*%.txt')) then
    str = vim.fn.expand('%:t')
  end
  local size = require('lualine.components.filesize')()
  return size == '' and str or str .. ' [' .. size .. ']'
end

-- Customized location
local function customLocation()
  return '%3l/%-3L:%-2v [%3p%%]'
end

-- Output LSP progress
local function lsp_progress()
  local messages = lsp.util.get_progress_messages()[1]
  if not messages then
    return ""
  end
  local name = messages.name or ""
  local msg = messages.message or ""
  local percentage = messages.percentage or 0
  local title = messages.title or ""
  local spinners = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
  local ms = vim.loop.hrtime() / 1000000
  local frame = math.floor(ms / 120) % #spinners
  return string.format(" %%<%s %s: %s %s (%s%%%%) ", spinners[frame + 1], name, title, msg, percentage)
end

-- Output the LSP client names attached to the current buffer
local function lsp_client_names()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = lsp.get_active_clients({ bufnr = bufnr })
  local client_names = {}
  local msg = 'None'
  if #clients > 0 then
    for _, client in pairs(clients) do
      client_names[#client_names + 1] = client.name
    end
    msg = table.concat(client_names, '·')
  end
  return " LSP:" .. msg
end

require 'lualine'.setup {
  options = {
    icons_enabled = true,
    theme = 'arctic',
    -- component_separators = { left = '', right = '' },
    -- section_separators = { left = '', right = '' },
    -- component_separators = { left = '', right = '' },
    -- section_separators = { left = '', right = '' },
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = {},
    always_divide_middle = true,
    globalstatus = true,
  },
  sections = {
    -- Left
    lualine_a = {
      {
        'mode',
        fmt = simplifiedMode,
      },
    },
    lualine_b = {
      {
        'branch',
        icon = ''
      },
    },
    lualine_c = {
      {
        'filename',
        path = 1,
        symbols = {
          modified = '[+]',
          readonly = '[]',
          unnamed = '[No Name]',
        },
        fmt = fileNameAndSize,
      },
    },
    -- Right
    lualine_x = {
      {
        lsp_progress,
      },
      {
        'diagnostics',
        sources = { "nvim_diagnostic" },
        symbols = { error = 'E:', warn = 'W:', info = 'I:', hint = 'H:' },
        -- symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
        -- symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
      },
      {
        'diff',
        symbols = { added = '+', modified = '~', removed = '-' },
        -- symbols = { added = ' ', modified = ' ', removed = ' ' },
      },
    },
    lualine_y = {
      'filetype'
    },
    lualine_z = {
      customLocation,
    },
  },

  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = {
    'aerial',
    'fugitive',
    'man',
    'quickfix',
  }
}
