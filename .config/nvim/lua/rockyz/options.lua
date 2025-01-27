local icons = require('rockyz.icons')

vim.o.number = true
vim.o.relativenumber = true
vim.o.laststatus = 3
vim.o.cursorline = true
vim.o.showmode = false
vim.o.textwidth = 100
vim.o.wildmode = 'longest:full,full'
vim.o.list = true
vim.opt.listchars = {
    trail = '•',
    nbsp = '.',
    precedes = '‹',
    extends = '›',
}
vim.opt.fillchars = {
    fold = ' ',
    foldopen = icons.caret.down,
    foldclose = icons.caret.right,
    foldsep = ' ',
    eob = ' ',
    msgsep = '‾',
}
vim.o.foldcolumn = '1'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.completeopt = 'menu,menuone,noselect,popup'
vim.o.timeoutlen = 500
vim.o.updatetime = 250
vim.opt.shortmess:append('acS')
vim.opt.matchpairs:append('<:>')
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = -1 -- fall back to shiftwidth
vim.o.shiftround = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.inccommand = 'split'
vim.opt.diffopt:append('vertical,algorithm:patience,linematch:60')
vim.o.signcolumn = 'yes'
vim.o.spelllang = 'en_us'
vim.o.pumheight = 15
vim.o.pumwidth = 20
vim.o.breakindent = true
vim.o.showbreak = '↳ '
-- Presistent undo (use set undodir=... to change the undodir, default is ~/.local/share/nvim/undo)
vim.o.undofile = true
vim.o.nrformats = 'octal,bin,hex,unsigned,alpha'
vim.opt.sessionoptions:append('globals,localoptions,winpos')
vim.opt.isfname:remove('=')
vim.o.shada = "!,'500,<50,s10,h"
vim.o.synmaxcol = 300
vim.o.cindent = true
vim.opt.cinoptions:append('g-1')
vim.o.scrolloff = 3
vim.o.mouse = 'a'
vim.o.mousemodel = 'extend'

-- Avoid highlighting the last search when sourcing vimrc
vim.cmd('nohlsearch')
-- Latex
vim.g.tex_flavor = 'latex'
-- Soft wrap in Man page
vim.g.man_hardwrap = 0
-- Disable health checks for these providers
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
-- Netrw
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
vim.g.netrw_localcopydircmd = 'cp -r'

-- Fold
-- Use LSP folding if available; otherwise, fall back to treesitter folding.
vim.o.foldmethod = 'indent' -- default
vim.o.foldtext = '' -- transparent foldtext (https://github.com/neovim/neovim/pull/20750)
local augroup = vim.api.nvim_create_augroup('rockyz.fold', { clear = true })
vim.api.nvim_create_autocmd('LspAttach', {
    group = augroup,
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client:supports_method('textDocument/foldingRange') then
            vim.wo.foldmethod = 'expr'
            vim.wo.foldexpr = 'v:lua.vim.lsp.foldexpr()'
            vim.w.lsp_folding_enabled = true
        end
    end,
})
vim.api.nvim_create_autocmd('FileType', {
    group = augroup,
    callback = function(args)
        if vim.bo[args.buf].filetype ~= 'bigfile' and not vim.w.lsp_folding_enabled then
            local has_parser, _ = pcall(vim.treesitter.get_parser, args.buf)
            if has_parser then
                vim.wo.foldmethod = 'expr'
                vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
            end
        end
    end,
})
