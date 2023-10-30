local function is_begining(from)
  return vim.fn.getcmdtype() == ':' and vim.fn.getcmdline() == from
end

vim.keymap.set('ca', 'T', function()
  return is_begining('T') and 'tabedit' or 'T'
end, { expr = true })

vim.keymap.set('ca', 'dot', function()
  return is_begining('dot')
      and '!git --git-dir=/Users/rockyzhang/dotfiles/ --work-tree=/Users/rockyzhang'
      or 'dot'
end, { expr = true })

vim.keymap.set('ca', 'tm', function()
  return is_begining('tm') and 'silent !tmux neww tmux-sessionizer' or 'tm'
end, { expr = true })

vim.keymap.set('ca', 'man', function()
  return is_begining('man') and 'Man' or 'man'
end, { expr = true })
