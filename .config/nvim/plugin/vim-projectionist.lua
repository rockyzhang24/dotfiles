vim.g.projectionist_heuristics = {
    ['/*.c|src/*.c'] = {
        ['*.c'] = {
            alternate = { '../include/{}.h', '{}.h' }
        },
        ['*.h'] = {
            alternate = '{}.c'
        },
    },
    ['Makefile'] = {
        ['Makefile'] = {
            alternate = 'CMakeLists.txt'
        },
        ['CMakeLists.txt'] = {
            alternate = 'Makefile'
        },
    },
}
