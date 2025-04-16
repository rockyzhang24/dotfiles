return {
    cmd = { 'rust-analyzer' },
    filetypes = { 'rust' },
    root_dir = function(bufnr, cb)
        local cargo_crate_dir = vim.fs.root(bufnr, { 'Cargo.toml' })
        if cargo_crate_dir then
            vim.system({
                'cargo',
                'metadata',
                '--no-depts',
                '--format-version',
                '1',
                '--manifest-path',
                cargo_crate_dir .. '/Cargo.toml',
            }, { cwd = cargo_crate_dir }, function(obj)
                if obj.code ~= 0 then
                    cb(cargo_crate_dir)
                else
                    local success, result = pcall(vim.json.decode, obj.stdout)
                    if success and result['workspace_root'] then
                        cb(vim.fs.normalize(result['workspace_root']))
                    else
                        cb(cargo_crate_dir)
                    end
                end
            end)
        else
            cb(vim.fs.root(bufnr, { 'rust-project.json', '.git' }))
        end
    end,
    capabilities = {
        experimental = {
            serverStatusNotification = true,
        },
    },
    before_init = function(init_params, config)
        -- See https://github.com/rust-lang/rust-analyzer/blob/eb5da56d839ae0a9e9f50774fa3eb78eb0964550/docs/dev/lsp-extensions.md?plain=1#L26
        if config.settings and config.settings['rust-analyzer'] then
            init_params.initializationOptions = config.settings['rust-analyzer']
        end
    end,
}
