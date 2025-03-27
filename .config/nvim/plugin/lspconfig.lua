local lspconfig = require('lspconfig')
local util = require('lspconfig/util')
local capabilities = require('rockyz.lsp').client_capabilities

-- Bash
lspconfig.bashls.setup({
    capabilities = capabilities(),
})

-- C/C++
-- Clangd requires compile_commands.json to work and the easiest way to generate it is to use CMake.
-- How to use clangd C/C++ LSP in any project: https://gist.github.com/Strus/042a92a00070a943053006bf46912ae9
lspconfig.clangd.setup({
    capabilities = capabilities(),
    cmd = {
        'clangd',
        '--clang-tidy',
        '--header-insertion=iwyu',
        '--completion-style=detailed',
        '--function-arg-placeholders',
        '--fallback-style=none',
    },
})

-- CSS
lspconfig.cssls.setup({
    capabilities = capabilities(),
})

-- Golang
lspconfig.gopls.setup({
    capabilities = capabilities(),
    root_dir = util.root_pattern('go.work', 'go.mod', '.git'),
    settings = {
        gopls = {
            analyses = {
                unusedparams = true,
            },
            staticcheck = true,
            -- semanticTokens = true, -- go's semantic token highlight is not accurate so far
        },
    },
})

-- HTML
lspconfig.html.setup({
    capabilities = capabilities(),
})

-- Json/Jsonc
lspconfig.jsonls.setup({
    capabilities = capabilities(),
    settings = {
        -- See setting options
        -- https://github.com/microsoft/vscode/tree/main/extensions/json-language-features/server#settings
        json = {
            -- Use JSON Schema Store (SchemaStore.nvim)
            schemas = require('schemastore').json.schemas(),
            validate = { enable = true },
        }
    },
})

-- JavaScript and TypeScript
local lang_settings = {
    suggest = { completeFunctionCalls = true },
    inlayHints = {
        functionLikeReturnTypes = { enabled = true },
        parameterNames = { enabled = 'literals' },
        variableTypes = { enabled = true },
    },
}
lspconfig.vtsls.setup({
    capabilities = capabilities(),
    settings = {
        -- See the configuration schema
        -- https://github.com/yioneko/vtsls/blob/main/packages/service/configuration.schema.json
        vtsls = {
            javascript = lang_settings,
            typescript = lang_settings,
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
})

-- Lua
lspconfig.lua_ls.setup({
    capabilities = capabilities(),
    on_init = function(client)
        local path = client.workspace_folders
            and client.workspace_folders[1]
            and client.workspace_folders[1].name
        if path and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then
            return
        end
        client.config.settings = vim.tbl_deep_extend('force', client.config.settings, {
            Lua = {
                runtime = {
                    version = 'LuaJIT',
                },
                workspace = {
                    checkThirdParty = false,
                    library = {
                        vim.env.VIMRUNTIME,
                        '${3rd}/luv/library',
                    },
                },
            },
        })
    end,
    settings = {
        Lua = {
            -- Inlay hints
            hint = {
                enable = true,
                setType = true,
                arrayIndex = 'Disable',
            },
            codeLens = {
                enable = true,
            },
            completion = {
                callSnippet = 'Replace',
                postfix = '.',
                displayContext = 50,
            },
            telemetry = {
                enable = false,
            },
            -- Lua LS offers a code formatter
            -- Ref: https://github.com/LuaLS/lua-language-server/wiki/Formatter
            -- format = {
            --   enable = true,
            --   defaultConfig = {
            --     indent_size = "4",
            --     max_line_length = "100",
            --     continuation_indent = "8",
            --   },
            -- },
            -- diagnostics = {
            --     -- Code style checking offered by the Lua LS code formatter
            --     neededFileStatus = {
            --       ["codestyle-check"] = "Any",
            --     },
            -- },
        },
    },
})

-- Python
-- lspconfig.pylsp.setup({
--     capabilities = capabilities(),
--     settings = {
--         --
--         -- Pylsp configuration doc: https://github.com/python-lsp/python-lsp-server.
--         --
--         -- To config the formatter and linter, we can use a specific configuration
--         -- file (e.g., pyproject.toml) in the project dir. To find all the available
--         -- configuration options for the formatter and linter, check the specific
--         -- repo.
--         -- 1) To config black, see https://black.readthedocs.io/en/stable/usage_and_configuration/the_basics.html
--         -- 2) To config ruff, see https://beta.ruff.rs/docs/configuration/
--         pylsp = {
--             plugins = {
--                 -- Formatter
--                 black = { enabled = true },
--                 autopep8 = { enabled = false },
--                 yapf = { enabled = false },
--                 -- Linter
--                 ruff = { enabled = true },
--                 pyflakes = { enabled = false },
--                 pycodestyle = { enabled = false },
--                 mccabe = { enabled = false },
--                 -- type checker
--                 pylsp_mypy = { enabled = true },
--                 -- Autocomplete
--                 jedi_comletion = { fuzzy = true },
--             },
--         },
--     },
-- })

lspconfig.pyright.setup({
    capabilities = capabilities(),
})

-- Rust
lspconfig.rust_analyzer.setup({
    capabilities = capabilities(),
})

-- TOML
lspconfig.taplo.setup({
    capabilities = capabilities(),
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
})

-- Vimscript
lspconfig.vimls.setup({
    capabilities = capabilities(),
})

-- Yaml
lspconfig.yamlls.setup({
    capabilities = capabilities(),
    settings = {
        yaml = {
            schemaStore = {
                -- You must disable built-in schemaStore support if you want to use
                -- this plugin (SchemaStore.nvim) and its advanced options like `ignore`.
                enable = false,
                -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
                url = '',
            },
            schemas = require('schemastore').yaml.schemas(),
        },
    },
})
