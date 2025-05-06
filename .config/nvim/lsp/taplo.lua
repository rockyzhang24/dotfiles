return {
    cmd = { 'taplo', 'lsp', 'stdio' },
    filetypes = { 'toml' },
    root_markers = { '.taplo.toml', 'taplo.toml', '.git' },
    settings = {
        -- See all the setting options
        -- https://github.com/tamasfe/taplo/blob/master/editors/vscode/package.json
        evenBetterToml = {
            taplo = {
                configFile = {
                    enabled = true,
                },
            },
            schema = {
                enabled = true,
                catalogs = {
                    'https://www.schemastore.org/api/json/catalog.json',
                },
                cache = {
                    memoryExpiration = 60,
                    diskExpiration = 600,
                },
            },
        },
    },
}
