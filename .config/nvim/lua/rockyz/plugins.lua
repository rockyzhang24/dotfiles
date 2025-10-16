local notify = require('rockyz.utils.notify')

vim.api.nvim_create_autocmd({ 'PackChanged' }, {
    group = vim.api.nvim_create_augroup('rockyz.pack', { clear = true }),
    callback = function(args)
        local kind = args.data.kind
        local name = args.data.spec.name
        if kind == 'install' or kind == 'update' then
            -- saghen/blink.cmp
            if name == 'blink.cmp' then
                local dir = vim.fn.stdpath("data") .. "/site/pack/core/opt/blink.cmp"
                notify.info('[Pack] blink.cmp: building ...')
                local obj = vim.system({ 'cargo', 'build', '--release' }, { cwd = dir }):wait()
                if obj.code == 0 then
                    notify.info('[Pack] blink.cmp: building done')
                else
                    notify.error('[Pack] blink.cmp: building failed')
                end
            end
            -- L3MON4D3/LuaSnip
            if name == 'LuaSnip' then
                local dir = vim.fn.stdpath("data") .. "/site/pack/core/opt/LuaSnip"
                notify.info('[Pack] LuaSnip: installing jsregexp')
                local obj = vim.system({ 'make', 'install_jsregexp' }, { cwd = dir }):wait()
                if obj.code == 0 then
                    notify.info('[Pack] LuaSnip: successfully to install jsregexp')
                else
                    notify.error('[Pack] LuaSnip: failed to install jsregexp')
                end
            end
        end
        -- nvim-treesitter/nvim-treesitter
        if kind == 'update' and name == 'nvim-treesitter' then
            vim.cmd.packadd('nvim-treesitter')
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
    'https://github.com/hedyhli/outline.nvim',

    -- Autocomplete
    'https://github.com/saghen/blink.cmp',

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
    }
})
