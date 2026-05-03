return {
    -- Use node_modules local executable if available
    cmd = function(dispatchers, config)
        local cmd = 'vscode-json-language-server'
        if (config or {}).root_dir then
            local local_cmd = vim.fs.joinpath(config.root_dir, 'node_modules/.bin', cmd)
            if vim.fn.executable(local_cmd) == 1 then
                cmd = local_cmd
            end
        end
        return vim.lsp.rpc.start({ cmd, '--stdio' }, dispatchers)
    end,
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
