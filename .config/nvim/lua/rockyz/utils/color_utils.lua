-- Inspired by https://github.com/folke/tokyonight.nvim

local M = {}

M.fg = '#ffffff'
M.bg = '#000000'

---@param c string color in hex
local function rgb(c)
  c = string.lower(c)
  return { tonumber(c:sub(2, 3), 16), tonumber(c:sub(4, 5), 16), tonumber(c:sub(6, 7), 16) }
end

---Blend colro fg with color bg. E.g., blend(fg, 0.2, bg) will blend 80% fg with 20% bg.
---@param foreground string foreground color in hex
---@param background string background color in hex
---@param alpha number|string number between 0 and 1. 0 results in fg, 1 results in bg.
function M.blend(foreground, alpha, background)
  local bg = rgb(background)
  local fg = rgb(foreground)

  local blendChannel = function(i)
    local ret = ((1 - alpha) * fg[i] + (alpha * bg[i]))
    return math.floor(math.min(math.max(0, ret), 255) + 0.5)
  end

  return string.format("#%02x%02x%02x", blendChannel(1), blendChannel(2), blendChannel(3))
end

function M.lighten(hex, amount, fg)
  return M.blend(hex, amount, fg or M.fg)
end

function M.darken(hex, amount, bg)
  return M.blend(hex, amount, bg or M.bg)
end

return M
