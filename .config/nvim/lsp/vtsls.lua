local lang_settings = {
    suggest = { completeFunctionCalls = true },
    inlayHints = {
        functionLikeReturnTypes = { enabled = true },
        parameterNames = { enabled = 'literals' },
        variableTypes = { enabled = true },
    },
}

return {
    cmd = { 'vtsls', '--stdio' },
    filetypes = {
        'javascript',
        'javascriptreact',
        'javascript.jsx',
        'typescript',
        'typescriptreact',
        'typescript.tsx',
    },
    root_markers = { 'tsconfig.json', 'package.json', 'jsconfig.json', '.git' },
    settings = {
        -- See the configuration schema
        -- https://github.com/yioneko/vtsls/blob/main/packages/service/configuration.schema.json
        javascript = lang_settings,
        typescript = lang_settings,
        vtsls = {
            -- Use workspace version of TypeScript
            autoUseWorkspaceTsdk = true,
            experimental = {
                maxInlayHintLength = 30,
                completion = {
                    enableServerSideFuzzyMatch = true,
                },
            },
        },
    },
}
