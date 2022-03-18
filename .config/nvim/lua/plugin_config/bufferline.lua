require("bufferline").setup{
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
        filetype = "aerial",
        text = "Symbols",
        highlight = "Directory",
      },
    },
    -- Filter out the buffers that shouldn't be shown
    custom_filter = function(buf, buf_nums)
      return vim.bo[buf].filetype ~= "fugitive"
    end
  },
}

-- Buffer picker
vim.keymap.set('n', 'gb', '<Cmd>BufferLinePick<CR>')

-- Move buffer backwards or forwards (consistent with kitty tab movement)
vim.keymap.set('n', '<Leader>b,', '<Cmd>BufferLineMovePrev<CR>')
vim.keymap.set('n', '<Leader>b.', '<Cmd>BufferLineMoveNext<CR>')
