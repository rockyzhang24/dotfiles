-- Clangd requires compile_commands.json to work and the easiest way to generate it is to use CMake.
-- How to use clangd C/C++ LSP in any project: https://gist.github.com/Strus/042a92a00070a943053006bf46912ae9

local notify = require('rockyz.utils.notify_utils')

local function switch_source_header(bufnr)
    bufnr = bufnr == 0 and vim.api.nvim_get_current_buf() or bufnr
    local method_name = 'textDocument/switchSourceHeader'
    local clients = vim.lsp.get_clients({ bufnr = bufnr, name = 'clangd' })
    local uri = vim.uri_from_bufnr(bufnr)
    if #clients > 0 then
        local client = clients[1]
        client:request(method_name, { uri = uri }, function(err, res)
            if err then
                notify.warn(err.message or tostring(err))
            elseif res then
                vim.cmd.edit(vim.uri_to_fname(res))
            else
                notify.warn('Header file not found')
            end
        end, bufnr)
    else
        notify.warn(('method %s is not supported by any servers active on the current buffer'):format(method_name))
    end
end

return {
    cmd = {
        'clangd',
        '--clang-tidy',
        '--header-insertion=iwyu',
        '--completion-style=detailed',
        '--function-arg-placeholders',
        '--fallback-style=none',
    },
    filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
    root_markers = {
        '.clangd',
        '.clang-tidy',
        '.clang-format',
        'compile_commands.json',
        'compile_flags.txt',
        'configure.ac', -- AutoTools
        '.git',
    },
    capabilities = {
        textDocument = {
            completion = {
                editsNearCursor = true,
            },
        },
        offsetEncoding = { 'utf-8', 'utf-16' },
    },
    on_init = function(client, init_result)
        if init_result.offsetEncoding then
            client.offset_encoding = init_result.offsetEncoding
        end
    end,
    on_attach = function(client, bufnr)
        -- Create a command to switch between source file and header
        -- https://clangd.llvm.org/extensions.html#switch-between-sourceheader
        vim.api.nvim_buf_create_user_command(0, 'ClangdSwitchSourceHeader', function()
            switch_source_header(0)
        end, { desc = 'Switch between the main source file (*.cpp) and header (*.h)' })
    end,
}
