return {
    cmd = { 'vscode-json-language-server', '--stdio' },
    filetypes = { 'json', 'jsonc' },
    root_markers = { '.git' },
    init_options = {
        provideFormatter = true,
    },
    settings = {
        -- See setting options
        -- https://github.com/microsoft/vscode/tree/main/extensions/json-language-features/server#settings
        json = {
            -- Use JSON Schema Store (SchemaStore.nvim)
            schemas = require('schemastore').json.schemas(),
            validate = { enable = true },
        }
    },
}
