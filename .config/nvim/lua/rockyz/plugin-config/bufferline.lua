local map = require('rockyz.keymap').map

require("bufferline").setup {
  options = {
    numbers = function(opts)
      return string.format('%s', opts.ordinal)
    end,
    diagnostics = 'nvim_lsp',
    diagnostics_indicator = function(count, level, diagnostics_dict, context)
      return "(" .. count .. ")"
    end,
    show_buffer_close_icons = false,
    show_close_icon = false,
    offsets = {
      {
        filetype = "NvimTree",
        text = "File Explorer",
        highlight = "Directory",
      },
      {
        filetype = "neo-tree",
        text = "File Explorer",
        highlight = "Directory",
      },
      {
        filetype = "aerial",
        text = "Symbols",
        highlight = "Directory",
      },
    },
    -- Filter out the buffers that shouldn't be shown
    custom_filter = function(buf_number, buf_numbers)
      local excluded_ft = { "fugitive", "qf" }
      for _, ft in ipairs(excluded_ft) do
        if vim.bo[buf_number].filetype == ft then
          return false
        end
      end
      return true
    end
  },
}

-- Buffer picker
map('n', '<Leader>bp', '<Cmd>BufferLinePick<CR>')

-- Move buffer backwards or forwards (consistent with kitty tab movement)
map('n', '<Leader>b,', '<Cmd>BufferLineMovePrev<CR>')
map('n', '<Leader>b.', '<Cmd>BufferLineMoveNext<CR>')
