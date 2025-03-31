-- Clangd requires compile_commands.json to work and the easiest way to generate it is to use CMake.
-- How to use clangd C/C++ LSP in any project: https://gist.github.com/Strus/042a92a00070a943053006bf46912ae9

return {
    cmd = {
        'clangd',
        '--clang-tidy',
        '--header-insertion=iwyu',
        '--completion-style=detailed',
        '--function-arg-placeholders',
        '--fallback-style=none',
    },
    filetypes = { 'c', 'cpp' },
    root_markers = {
        '.clangd',
        '.clang-format',
        'compile_commands.json',
        'compile_flags.txt',
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
}
