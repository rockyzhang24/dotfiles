-- Display an indicator of tag generation progress
local function gutenTagsProgress()
  return vim.fn['gutentags#statusline']('[', ']')
end

-- For mode, only show the first char (or first two chars to distinguish
-- different VISUALs) plus a fancy icon
local function simplifiedMode(str)
  return "  " .. (str == "V-LINE" and "VL" or (str == "V-BLOCK" and "VB" or str:sub(1, 1)))
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
  return ' %3l/%-3L:%-2v [%3p%%]'
end

require 'lualine'.setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    -- component_separators = { left = '', right = '' },
    -- section_separators = { left = '', right = '' },
    -- component_separators = { left = '', right = '' },
    -- section_separators = { left = '', right = '' },
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = {},
    always_divide_middle = true,
    globalstatus = true, -- requires neovim 0.7 or highter
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
      {
        'diff',
        symbols = { added = '+', modified = '~', removed = '-' },
        -- symbols = { added = ' ', modified = ' ', removed = ' ' },

      },
      {
        'diagnostics',
        sources = { "nvim_diagnostic" },
        -- symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
        symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
      }
    },
    lualine_c = {
      {
        'filename',
        path = 3,
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
      gutenTagsProgress,
      'encoding',
      'fileformat',
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
    lualine_c = { 'filename' },
    lualine_x = {
      {
        'location',
        fmt = customLocation,
      },
    },
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = {
    'aerial',
    'fugitive',
    'nvim-tree',
    'neo-tree',
    'quickfix',
    'toggleterm'
  }
}
