local treesitter_indent = require('nvim-treesitter').indentexpr

vim.bo.indentexpr = function()
    local indent = treesitter_indent()

    if indent >= 0 then
        return indent
    end

    return vim.fn.GetTypescriptIndent()
end
