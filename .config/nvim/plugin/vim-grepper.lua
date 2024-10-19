vim.g.grepper = {
    dir = 'repo,file',
    repo = { '.git', '.hg', '.svn' },
    tools = { 'rg', 'git' },
    searchreg = 1,
    prompt_mapping_tool = '<Leader>G',
    rg = {
        grepprg = 'rg -H --no-heading --vimgrep --smart-case',
        grepformat = '%f:%l:%c:%m,%f',
        escape = '\\^$.*+?()[]{}|',
    },
}

-- Keymaps
vim.keymap.set('n', '<Leader>G', '<Cmd>Grepper<CR>')
vim.keymap.set({ 'n', 'x' }, 'gs', '<Plug>(GrepperOperator)', { remap = true }) -- operator

-- Usage:
-- 1. :Grepper<CR> will launch the default tool (i.e., the first tool in the defined tools). In my
--    config, it is rg. We can provide the query and the optional dir for the search. Using
--    <Leader>G to cycle through the list of the defined tools.
-- 2. :Grepper command is more general. It accepts options such as -jump, -tool, etc. We can use
--    -<TAB> to autocomplete them. Actually, :Grepper<CR> is an alias of :Grepper -tool rg
