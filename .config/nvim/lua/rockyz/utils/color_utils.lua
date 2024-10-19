-- Inspired by https://github.com/folke/tokyonight.nvim

local M = {}

M.fg = '#ffffff'
M.bg = '#000000'

---Convert hex color to RGB
---@param c string color in hex with format '#rrggbb'
function M.hex2rgb(c)
    c = string.lower(c)
    return { tonumber(c:sub(2, 3), 16), tonumber(c:sub(4, 5), 16), tonumber(c:sub(6, 7), 16) }
end

---Blend colro fg with color bg. E.g., blend(fg, 0.2, bg) will blend 80% fg with 20% bg.
---@param foreground string foreground color in hex
---@param background string background color in hex
---@param alpha number|string number between 0 and 1. 0 results in fg, 1 results in bg.
function M.blend(foreground, alpha, background)
    local bg = M.hex2rgb(background)
    local fg = M.hex2rgb(foreground)

    local blendChannel = function(i)
        local ret = ((1 - alpha) * fg[i] + (alpha * bg[i]))
        return math.floor(math.min(math.max(0, ret), 255) + 0.5)
    end

    return string.format('#%02x%02x%02x', blendChannel(1), blendChannel(2), blendChannel(3))
end

function M.lighten(hex, amount, fg)
    return M.blend(hex, amount, fg or M.fg)
end

function M.darken(hex, amount, bg)
    return M.blend(hex, amount, bg or M.bg)
end

---Convert hex color to ANSI escape color code
---@param c string hex color with format '#rrggbb'
---@param to_type string? which ANSI color type will be output, 'fg' or 'bg'.
function M.hex2ansi(c, to_type)
    local rgb = M.hex2rgb(c)
    to_type = to_type or 'fg'
    return string.format('\x1b[%s;2;%s;%s;%sm', to_type == 'fg' and '38' or '48', unpack(rgb))
end

---Convert the color (fg, bg or sp) from a highlight group to ANSI color code (foreground or
---background). E.g., hl2ansi('Special', 'fg', 'fg') will convert the foreground of Spacial to ANSI
---foreground color.
---@param hl string highlight group name
---@param from_type string? which color type will be used in the highlight group, 'fg', 'bg' or 'sp'
---@param to_type string? which ANSI color type will be output, 'fg' or 'bg'
function M.hl2ansi(hl, from_type, to_type)
    from_type = from_type or 'fg'
    to_type = to_type or 'fg'
    local color = vim.api.nvim_get_hl(0, { name = hl, link = false })[from_type]
    return color and M.hex2ansi(string.format('#%06x', color), to_type) or ''
end

return M
