-- Inspired by tokyonight.nvim.
-- https://github.com/folke/tokyonight.nvim

local M = {}

M.fg = '#ffffff'
M.bg = '#000000'

---Convert a hexadecimal color to RGB
---@param hex_color string Hex color in `#rrggbb` format
---@return integer[] rgb
function M.hex2rgb(hex_color)
    hex_color = string.lower(hex_color)
    return { tonumber(hex_color:sub(2, 3), 16), tonumber(hex_color:sub(4, 5), 16), tonumber(hex_color:sub(6, 7), 16) }
end

---Blend two hexadecimal colors
---@param foreground string Foreground color in `#rrggbb` format
---@param alpha number|string Blend ratio: 0 returns foreground and 1 returns background
---@param background string Background color in `#rrggbb` format
---@return string color
function M.blend(foreground, alpha, background)
    local background_rgb = M.hex2rgb(background)
    local foreground_rgb = M.hex2rgb(foreground)

    local blend_channel = function(channel_index)
        local blended_value = ((1 - alpha) * foreground_rgb[channel_index] + (alpha * background_rgb[channel_index]))
        return math.floor(math.min(math.max(0, blended_value), 255) + 0.5)
    end

    return string.format('#%02x%02x%02x', blend_channel(1), blend_channel(2), blend_channel(3))
end

---Lighten a hexadecimal color by blending it toward a foreground color
---@param hex_color string Hex color in `#rrggbb` format
---@param amount number|string Blend ratio
---@param foreground? string Foreground color in `#rrggbb` format
---@return string color
function M.lighten(hex_color, amount, foreground)
    return M.blend(hex_color, amount, foreground or M.fg)
end

---Darken a hexadecimal color by blending it toward a background color.
---@param hex_color string Hex color in `#rrggbb` format
---@param amount number|string Blend ratio
---@param background? string Background color in `#rrggbb` format
---@return string color
function M.darken(hex_color, amount, background)
    return M.blend(hex_color, amount, background or M.bg)
end

---Convert a hexadecimal color to an ANSI truecolor escape sequence
---@param hex_color string hex color with format '#rrggbb'
---@param ansi_type? 'fg'|'bg'
---@return string ansi_escape_sequence
function M.hex2ansi(hex_color, ansi_type)
    local rgb_channels = M.hex2rgb(hex_color)
    ansi_type = ansi_type or 'fg'
    return string.format('\x1b[%s;2;%s;%s;%sm', ansi_type == 'fg' and '38' or '48', unpack(rgb_channels))
end

---Convert a highlight group's color to an ANSI truecolor escape sequence.
---For example, `hl2ansi('Special', 'fg', 'fg')` converts Special's foreground color.
---@param highlight_group string highlight group name
---@param highlight_color_type? 'fg'|'bg'|'sp'
---@param ansi_type? 'fg'|'bg'
---@return string ansi_escape_sequence
function M.hl2ansi(highlight_group, highlight_color_type, ansi_type)
    highlight_color_type = highlight_color_type or 'fg'
    ansi_type = ansi_type or 'fg'
    local highlight_color = vim.api.nvim_get_hl(0, { name = highlight_group, link = false })[highlight_color_type]
    return highlight_color and M.hex2ansi(string.format('#%06x', highlight_color), ansi_type) or ''
end

return M
