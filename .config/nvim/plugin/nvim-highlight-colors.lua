require('nvim-highlight-colors').setup({
    render = 'virtual',
    virtual_symbol = '●',
    enable_short_hex = false,
    enable_tailwind = true,
    exclude_filetypes = {
        'man',
        'minpac',
    },
})
