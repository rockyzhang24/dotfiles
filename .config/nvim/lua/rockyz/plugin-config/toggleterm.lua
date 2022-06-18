require("toggleterm").setup {
  size = function(term)
    if term.direction == "horizontal" then
      return 20
    elseif term.direction == "vertical" then
      return vim.o.columns * 0.4
    end
  end,
  open_mapping = [[<C-\>]],
  insert_mappings = true,
  terminal_mappings = true,
  shade_terminals = true,
  start_in_insert = true,
  direction = 'horizontal', -- can be 'vertical', 'horizontal', 'window', 'float'
  shell = vim.o.shell,
  float_opts = {
    border = 'curved',
  },
}
