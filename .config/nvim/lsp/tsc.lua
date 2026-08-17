---Install with: npm install -g typescript

---Monorepo support
---
---`tsc` supports monorepos by default. It will automatically find the `tsconfig.json` or `jsconfig.json` corresponding to the package you are working on.
---This works without the need of spawning multiple instances of `tsc`, saving memory.
---
---It is recommended to use the same version of TypeScript in all packages, and therefore have it
---available in your workspace root. The location of the TypeScript binary will be determined
---automatically, but only once.

---@type vim.lsp.Config
return {
    settings = {
        ['js/ts'] = {
            inlayHints = {
                parameterNames = {
                    enabled = 'literals',
                    suppressWhenArgumentMatchesName = true,
                },
                parameterTypes = { enabled = true },
                variableTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                enumMemberValues = { enabled = true },
            },
            referencesCodeLens = {
                enabled = true,
                showOnAllFunctions = true,
            },
            implementationsCodeLens = {
                enabled = true,
                showOnInterfaceMethods = true,
                showOnAllClassMethods = true,
            },
        },
    },
    cmd = function(dispatchers, config)
        local cmd = 'tsc'
        local bins = { 'tsc', 'tsgo' }
        for _, bin in ipairs(bins) do
            if (config or {}).root_dir then
                local local_cmd = vim.fs.joinpath(config.root_dir, 'node_modules/.bin', bin)
                if vim.fn.executable(local_cmd) == 1 then
                    cmd = local_cmd
                    break
                end
            end
            if vim.fn.executable(bin) == 1 then
                cmd = bin
                break
            end
        end
        return vim.lsp.rpc.start({ cmd, '--lsp', '--stdio' }, dispatchers)
    end,
    filetypes = {
        'javascript',
        'javascriptreact',
        'typescript',
        'typescriptreact',
    },
    root_dir = function(bufnr, on_dir)
        -- The project root is where the LSP can be started from
        -- As stated in the documentation above, this LSP supports monorepos and simple projects.
        -- We select then from the project root, which is identified by the presence of a package
        -- manager lock file.
        local root_markers = { { 'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml', 'bun.lockb', 'bun.lock' }, { '.git' } }

        local deno_root = vim.fs.root(bufnr, { 'deno.json', 'deno.jsonc' })
        local deno_lock_root = vim.fs.root(bufnr, { 'deno.lock' })
        local project_root = vim.fs.root(bufnr, root_markers)
        if deno_lock_root and (not project_root or #deno_lock_root > #project_root) then
            -- deno lock is closer than package manager lock, abort
            return
        end
        if deno_root and (not project_root or #deno_root >= #project_root) then
            -- deno config is closer than or equal to package manager lock, abort
            return
        end
        -- project is standard TS, not deno
        -- We fallback to the current working directory if no project root is found
        on_dir(project_root or vim.fn.getcwd())
    end,
}
