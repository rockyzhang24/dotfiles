-- Install with: npm install -g @typescript/native-preview

-- Monorepo support
--
-- `tsgo` supports monorepos by default. It will automatically find the `tsconfig.json` or `jsconfig.json` corresponding to the package you are working on.
-- This works without the need of spawning multiple instances of `tsgo`, saving memory.
--
-- It is recommended to use the same version of TypeScript in all packages, and therefore have it available in your workspace root. The location of the TypeScript binary will be determined automatically, but only once.

---@type vim.lsp.Config
return {
    cmd = function(dispatchers, config)
        local cmd = 'tsgo'
        local local_cmd = (config or {}).root_dir and config.root_dir .. '/node_modules/.bin/tsgo'
        if local_cmd and vim.fn.executable(local_cmd) == 1 then
            cmd = local_cmd
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

        -- exclude deno
        if vim.fs.root(bufnr, { 'deno.json', 'deno.jsonc', 'deno.lock' }) then
            return
        end

        -- We fallback to the current working directory if no project root is found
        local project_root = vim.fs.root(bufnr, root_markers) or vim.fn.getcwd()

        on_dir(project_root)
    end,
}
