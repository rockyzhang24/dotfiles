local gps = require("nvim-gps")

-- Display an indicator of tag generation progress
local function gutenTagsProgress()
  return vim.fn['gutentags#statusline']('[', ']')
end

require'lualine'.setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    -- component_separators = { left = '', right = ''},
    -- section_separators = { left = '', right = ''},
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {},
    always_divide_middle = true,
    globalstatus = false,  -- requires neovim 0.7 or highter
  },
  sections = {
    -- Left
    lualine_a = {'mode'},
    lualine_b = {
      'branch',
      {
        'diff',
        symbols = {added= '+', modified = '~', removed = '-'},
      },
      {
        'diagnostics',
        sources = {"nvim_diagnostic"},
        -- Same as the fg color of the highlight group DiagnosticSignXXX
        diagnostics_color = {
          error = { fg = '#fb4934' },
          warn = { fg = '#fabd2f' },
          info = { fg = '#83a598' },
          hint = { fg = '#8ec07c' },
        },
        -- symbols = {error = ' ', warn = ' ', info = ' ', hint = ' '},
        symbols = {error = ' ', warn = ' ', info = ' ', hint = ' '},
      }
    },
    lualine_c = {'filename'},

    -- Right
    lualine_x = {
      { gps.get_location, cond = gps.is_available },
      gutenTagsProgress,
      'encoding',
      'fileformat',
      'filetype'
    },
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = {'quickfix', 'fugitive', 'nvim-tree', 'aerial', 'toggleterm'}
}
