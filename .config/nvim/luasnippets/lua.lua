local snippets = {
    -- Smart require
    --
    -- req -> local bar = require('foo.bar')
    --              |                 |__ first type the module path
    --              |
    --              |__ the last part of the module path will be put here automatically
    --
    s(
        'req',
        fmt(
            [[
                local {} = require('{}')
            ]],
            {
                f(function(import_name)
                    local parts = vim.split(import_name[1][1], '.', { plain = true })
                    return parts[#parts] or ''
                end, { 1 }),
                i(1),
            }
        )
    ),
}

return snippets
