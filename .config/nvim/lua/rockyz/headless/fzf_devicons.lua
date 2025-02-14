local devicons = require('nvim-web-devicons')
local color = require('rockyz.utils.color_utils')

for line in io.lines() do
  local ext = line:match('^.+%.(.+)$')
  local file_icon, file_icon_hl = devicons.get_icon(line, ext, { default = true })
  local ansi = color.hl2ansi(file_icon_hl)
  io.stdout:write(ansi .. file_icon .. '\x1b[m ' .. line .. '\n')
end
