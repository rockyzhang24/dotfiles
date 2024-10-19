-- Usage: <Leader>c + querytype, e.g., <Leader>cg to find the definition. Or use command :Cs f
-- querytype, e.g., :Cs f g
--
-- Querytype is consistent with cscope in vim:
-- s: find this symbols (i.e., references)
-- g: find this definition
-- d: find functions called by this function
-- c: find functions calling this function
-- t: find this text string
-- e: find this egrep pattern
-- f: find this file
-- i: find files #including this file
-- a: find places where this symbol is assigned to a value
--
-- Additionally, <C-]>, the keymap for command :Cstag <cword>, to do tags search if no results are
-- found in cscope.
--
-- Instead of using the word under the cursor for the query, we can assign any name for the query
-- using command, e.g., :Cs f g {name}
--
-- Build cscope database: <Leader>cb, or by command :Cs db build

local icons = require('rockyz.icons')

require('cscope_maps').setup({
    cscope = {
        exec = 'gtags-cscope',
        qf_window_size = 10,
        statusline_indicator = 'cscope db building' .. icons.misc.ellipsis,
        project_rooter = {
            enable = true,
        },
    },
})

-- Rebuild DB
local group = vim.api.nvim_create_augroup("rockyz/cscope_db_build", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    pattern = { "*.c", "*.h" },
    callback = function ()
        vim.cmd("Cscope db build")
    end,
})
