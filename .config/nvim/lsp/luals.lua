local root_markers1 = {
    '.emmyrc.json',
    '.luarc.json',
    '.luarc.jsonc',
}
local root_markers2 = {
    '.luacheckrc',
    '.stylua.toml',
    'stylua.toml',
    'selene.toml',
    'selene.yml',
}

---@type vim.lsp.Config
return {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    root_markers = { root_markers1, root_markers2, { '.git' } },
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
            --     enable = true,
            --     defaultConfig = {
            --         indent_size = "4",
            --         max_line_length = "100",
            --         continuation_indent = "8",
            --     },
            -- },
            -- diagnostics = {
            --     -- Code style checking offered by the Lua LS code formatter
            --     neededFileStatus = {
            --         ["codestyle-check"] = "Any",
            --     },
            -- },
        },
    },
}
