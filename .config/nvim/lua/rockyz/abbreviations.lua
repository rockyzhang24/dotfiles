---@param lhs string
---@param rhs string
---@param anywhere? boolean Whether to expand regardless of command-line position
local function abbreviate(lhs, rhs, anywhere)
    vim.keymap.set('ca', lhs, function()
        if anywhere then
            return rhs
        end

        if vim.fn.getcmdtype() == ':' and vim.fn.getcmdline() == lhs then
            return rhs
        end

        return lhs
    end, { expr = true })
end

abbreviate('T', 'tabedit')
abbreviate('dot', '!git --git-dir=' .. vim.fs.joinpath(vim.env.HOME, 'dotfiles') .. ' --work-tree=' .. vim.env.HOME)
abbreviate('ts', 'silent !tmux neww tmux-sessionizer')
abbreviate('man', 'Man')
abbreviate('H', 'h')
abbreviate('git', 'Git')
