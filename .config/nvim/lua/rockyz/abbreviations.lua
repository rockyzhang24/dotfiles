---Create abbreviation
---@param everywhere boolean? The abbreviation applies everywhere or only at the very beginning.
---Defaults to false.
local function abbreviate(from, to, everywhere)
    vim.keymap.set('ca', from, function()
        return everywhere and to or (vim.fn.getcmdtype() == ':' and vim.fn.getcmdline() == from and to or from)
    end, { expr = true })
end

abbreviate('T', 'tabedit')
abbreviate('dot', '!git --git-dir=/Users/rockyzhang/dotfiles/ --work-tree=/Users/rockyzhang')
abbreviate('ts', 'silent !tmux neww tmux-sessionizer')
abbreviate('man', 'Man')
abbreviate('H', 'h')
abbreviate('git', 'Git')
