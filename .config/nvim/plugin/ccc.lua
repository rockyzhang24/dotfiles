local ccc = require('ccc')

ccc.setup({
    highlighter = {
        auto_enable = true,
        excludes = {
            'minpac',
            'minpacprgs',
        },
    },
    pickers = {
        ccc.picker.hex_long, -- enable only long hex (#RRGGBB, #RRGGBBAA) and disable short hex (#RGB, #RGBA)
        ccc.picker.css_rgb,
        ccc.picker.css_hsl,
        ccc.picker.css_hwb,
        ccc.picker.css_lab,
        ccc.picker.css_lch,
        ccc.picker.css_oklab,
        ccc.picker.css_oklch,
    },
})

-- Use uppercase for hex colors
ccc.output.hex.setup({ uppercase = true })
ccc.output.hex_short.setup({ uppercase = true })
