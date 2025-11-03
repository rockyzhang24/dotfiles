local notify = require('rockyz.utils.notify')

vim.api.nvim_create_autocmd({ 'PackChanged' }, {
    group = vim.api.nvim_create_augroup('rockyz.pack', { clear = true }),
    callback = function(event)
        local kind = event.data.kind
        local name = event.data.spec.name
        local active = event.data.active
        if kind == 'install' or kind == 'update' then
            -- saghen/blink.cmp
            if name == 'blink.cmp' then
                if not active then
                    vim.cmd.packadd('blink.cmp')
                end
                notify.info('[Pack] blink.cmp: building ...')
                vim.cmd('BlinkCmp build')
                notify.info('[Pack] blink.cmp: building done')
            end
            -- L3MON4D3/LuaSnip
            if name == 'LuaSnip' then
                notify.info('[Pack] LuaSnip: installing jsregexp')
                local obj = vim.system({ 'make', 'install_jsregexp' }, { cwd = event.data.path }):wait()
                if obj.code == 0 then
                    notify.info('[Pack] LuaSnip: successfully to install jsregexp')
                else
                    notify.error('[Pack] LuaSnip: failed to install jsregexp')
                end
            end
        end
        -- nvim-treesitter/nvim-treesitter
        if kind == 'update' and name == 'nvim-treesitter' then
            if not active then
                vim.cmd.packadd('nvim-treesitter')
            end
            notify.info('[Pack] nvim-treesitter: updating installed parsers')
            vim.cmd('TSUpdate')
        end
    end,
})

vim.pack.add({
    -- Misc
    'https://github.com/kyazdani42/nvim-web-devicons',
    'https://github.com/dstein64/vim-startuptime',
    'https://github.com/tpope/vim-surround',
    'https://github.com/tpope/vim-sleuth',
    'https://github.com/tpope/vim-repeat',
    'https://github.com/godlygeek/tabular',
    'https://github.com/mbbill/undotree',
    'https://github.com/haya14busa/vim-asterisk',

    'https://github.com/tommcdo/vim-exchange',
    -- It provides shortcuts:
    -- cx{motion}, cxx (line), X (visual), cxc (clear), and `.` is supported

    'https://github.com/othree/eregex.vim',
    'https://github.com/wellle/targets.vim',
    'https://github.com/danymat/neogen',
    'https://github.com/stevearc/conform.nvim',
    'https://github.com/Wansmer/treesj',
    'https://github.com/junegunn/vim-after-object',
    'https://github.com/preservim/tagbar',
    'https://github.com/dhananjaylatkar/cscope_maps.nvim',

    'https://github.com/tpope/vim-eunuch',
    -- 1. Provides handy commands:
    -- :Remove, :Delete, :Move, :Rename, :Copy, :Duplicate, :Chmod, :Mkdir, :Cfind, :Lfind,
    -- :Clocate, :Llocate, :Wall, :SudoWrite, :SudoEdit
    -- 2. Shebang line auto detection

    'https://github.com/AndrewRadev/linediff.vim',
    -- Run command :Linediff on two separate selections to diff them

    'https://github.com/inkarkat/vim-ingo-library',
    'https://github.com/inkarkat/vim-mark',

    'https://github.com/justinmk/vim-sneak',
    'https://github.com/uga-rosa/ccc.nvim',
    'https://github.com/stefandtw/quickfix-reflector.vim',

    -- LSP
    'https://github.com/smjonas/inc-rename.nvim',
    'https://github.com/b0o/SchemaStore.nvim',

    -- Autocomplete
    {
        src = 'https://github.com/saghen/blink.cmp',
        version = vim.version.range('1.*')
    },

    -- Snippets
    'https://github.com/L3MON4D3/LuaSnip',

    -- Treesitter
    'https://github.com/nvim-treesitter/nvim-treesitter',
    'https://github.com/nvim-treesitter/nvim-treesitter-context',
    'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
    'https://github.com/mizlan/iswap.nvim',
    'https://github.com/m-demare/hlargs.nvim',

    -- Git
    'https://github.com/lewis6991/gitsigns.nvim',
    'https://github.com/tpope/vim-fugitive',
    'https://github.com/tpope/vim-rhubarb',
    -- It providesa command :GBrowse to open the current file, blob, tree, commit, or tag in the
    -- browser.
    'https://github.com/rbong/vim-flog',
    {
        src = 'https://github.com/rockyzhang24/git-messenger.vim',
        version = 'dev',
    },
})
