local plugins = {
    {
        'k-takata/minpac',
        { type = 'opt' },
    },

    -- Temp

    -- General
    'kyazdani42/nvim-web-devicons',
    'dstein64/vim-startuptime',
    'tpope/vim-surround',
    'tpope/vim-sleuth',
    'tpope/vim-repeat',
    'godlygeek/tabular',
    'mbbill/undotree',
    'haya14busa/vim-asterisk',
    {
        'tommcdo/vim-exchange',
        -- cx{motion}, cxx (line), X (visual), cxc (clear), and `.` is supported
    },
    'othree/eregex.vim',
    'wellle/targets.vim',
    'danymat/neogen',
    'stevearc/conform.nvim',
    'Wansmer/treesj',
    'junegunn/vim-after-object',
    'preservim/tagbar',
    'dhananjaylatkar/cscope_maps.nvim',
    {
        'tpope/vim-eunuch',
        -- 1. Provides handy commands:
        -- :Remove, :Delete, :Move, :Rename, :Copy, :Duplicate, :Chmod, :Mkdir, :Cfind, :Lfind,
        -- :Clocate, :Llocate, :Wall, :SudoWrite, :SudoEdit
        -- 2. Shebang line auto detection
    },
    {
        'AndrewRadev/linediff.vim',
        -- Run command :Linediff on two separate selections to diff them
    },
    'inkarkat/vim-ingo-library',
    'inkarkat/vim-mark',
    'justinmk/vim-sneak',
    'andrewferrier/debugprint.nvim',

    -- LSP
    'smjonas/inc-rename.nvim',
    'b0o/SchemaStore.nvim',
    'hedyhli/outline.nvim',

    -- Autocomplete
    {
        'saghen/blink.cmp',
        {
            ['do'] = function()
                vim.notify('Building blink.cmp', vim.log.levels.INFO)
                local obj = vim.system({ 'cargo', 'build', '--release' }):wait()
                if obj.code == 0 then
                    vim.notify('Building blink.cmp done', vim.log.levels.INFO)
                else
                    vim.notify('Building blink.cmp failed', vim.log.levels.ERROR)
                end
            end,
            -- rev = '*',
        },
    },

    -- Snippets
    {
        'L3MON4D3/LuaSnip',
        {
            ['do'] = 'make install_jsregexp',
        },
    },

    -- Treesitter
    {
        'nvim-treesitter/nvim-treesitter',
        {
            ['do'] = 'TSUpdate',
        },
    },
    'nvim-treesitter/nvim-treesitter-context',
    'nvim-treesitter/nvim-treesitter-textobjects',
    'mizlan/iswap.nvim',
    'm-demare/hlargs.nvim',

    -- Git
    'lewis6991/gitsigns.nvim',
    'tpope/vim-fugitive',
    'tpope/vim-rhubarb', -- :GBrowse
    'rbong/vim-flog',
    {
        'rockyzhang24/git-messenger.vim',
        {
            branch = 'dev',
        },
    },
}

local function pack_init()
    vim.cmd.packadd('minpac')
    vim.fn['minpac#init']({
        progress_open = 'vertical',
        status_open = 'vertical',
        status_auto = true,
    })
    for _, plugin in ipairs(plugins) do
        if type(plugin) == 'string' then
            vim.fn['minpac#add'](plugin)
        else
            vim.fn['minpac#add'](unpack(plugin))
        end
    end
end

-- Install/update plugins
vim.api.nvim_create_user_command('PluginUpdate', function()
    vim.env.GIT_DIR = nil
    vim.env.GIT_WORK_TREE = nil
    pack_init()
    vim.fn['minpac#update']()
end, { bang = true })

-- Delete plugins
vim.api.nvim_create_user_command('PluginDelete', function()
    vim.env.GIT_DIR = nil
    vim.env.GIT_WORK_TREE = nil
    pack_init()
    vim.fn['minpac#clean']()
end, { bang = true })
