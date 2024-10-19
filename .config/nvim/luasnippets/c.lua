local snippets = {
    -- main function template
    s(
        {
            trig = 'main',
            name = 'main',
            dec = 'main() function',
            show_condition = function(line)
                -- HACK: only show the snippet "at the top level" of the file
                return #line <= 4 and ('main'):sub(1, #line) == line
            end,
        },
        fmt(
            [[
            int main({}) {{
                {}
                return 0;
            }}
            ]],
            {
                i(1, 'void'),
                i(0),
            }
        )
    ),
}

return snippets
