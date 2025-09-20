-- Ref:
-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/vtsls.lua
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#vtsls
--
-- To configure a TypeScript project, add a
-- [`tsconfig.json`](https://www.typescriptlang.org/docs/handbook/tsconfig-json.html)
-- or [`jsconfig.json`](https://code.visualstudio.com/docs/languages/jsconfig) to
-- the root of your project.
--
-- Monorepo support
--
-- `vtsls` supports monorepos by default. It will automatically find the `tsconfig.json` or
-- `jsconfig.json` corresponding to the package you are working on. This works without the need of
-- spawning multiple instances of `vtsls`, saving memory.
--
-- It is recommended to use the same version of TypeScript in all packages, and therefore have it
-- available in your workspace root. The location of the TypeScript binary will be determined
-- automatically, but only once.

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
    init_options = {
        hostInfo = 'neovim',
    },
    filetypes = {
        'javascript',
        'javascriptreact',
        'javascript.jsx',
        'typescript',
        'typescriptreact',
        'typescript.tsx',
    },
    root_dir = function(bufnr, on_dir)
        -- The project root is where the LSP can be started from
        -- As stated in the documentation above, this LSP supports monorepos and simple projects.
        -- We select then from the project root, which is identified by the presence of a package
        -- manager lock file.
        local root_markers = { 'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml', 'bun.lockb', 'bun.lock' }
        -- Give the root markers equal priority by wrapping them in a table
        root_markers = { root_markers, { '.git' } }
        -- We fallback to the current working directory if no project root is found
        local project_root = vim.fs.root(bufnr, root_markers) or vim.fn.getcwd()

        on_dir(project_root)
    end,
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
