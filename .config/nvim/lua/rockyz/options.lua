local icons = require('rockyz.icons')

vim.o.breakindent = true
vim.o.cindent = true
vim.o.cmdheight = 1
vim.o.completeopt = 'menuone,noselect,noinsert,fuzzy,popup'
vim.o.cursorline = true
vim.opt.diffopt = {'algorithm:patience', 'closeoff', 'filler', 'inline:word', 'internal', 'linematch:60', 'vertical'}
vim.o.expandtab = true
vim.opt.fillchars = {
    fold = ' ',
    foldopen = icons.caret.down,
    foldclose = icons.caret.right,
    foldsep = ' ',
    foldinner = ' ',
    eob = ' ',
    msgsep = '‾',
}
vim.o.foldcolumn = '1'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
-- vim.opt.guicursor = "i:block" -- use block cursor in insert mode
vim.o.ignorecase = true
vim.opt.isfname:remove('=')
vim.opt.jumpoptions:append('view')
vim.o.laststatus = 3
vim.o.linebreak = true
vim.o.list = true
vim.opt.listchars = {
    trail = '•',
    nbsp = '.',
    precedes = '‹',
    extends = '›',
}
vim.opt.matchpairs:append('<:>')
vim.o.mouse = 'a'
vim.o.mousemodel = 'extend'
vim.o.nrformats = 'octal,bin,hex,unsigned,alpha'
vim.o.number = true
vim.o.pumheight = 15
vim.o.pumwidth = 20
vim.o.pumborder = vim.g.border_style
vim.o.relativenumber = true
vim.o.scrolloff = 3
vim.opt.sessionoptions:append('globals,localoptions,winpos')
vim.o.shada = "!,'500,<50,s10,h"
vim.o.shiftwidth = 4
vim.o.shiftround = true
vim.o.showbreak = '↳ '
vim.o.showmode = false
vim.opt.shortmess:append('acS')
vim.o.signcolumn = 'yes'
vim.o.smartcase = true
vim.o.softtabstop = -1 -- fall back to shiftwidth
vim.o.spelllang = 'en_us'
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.synmaxcol = 500
vim.o.tabclose = 'uselast'
vim.o.tabstop = 4
vim.o.textwidth = 100
vim.o.timeoutlen = 500
vim.o.title = true
vim.cmd([[let &titlestring = (exists('$SSH_TTY') ? 'SSH ' : '') .. '%{fnamemodify(getcwd(),":t")}']])
-- Presistent undo (use set undodir=... to change the undodir, default is ~/.local/share/nvim/undo)
vim.o.undofile = true
vim.o.updatetime = 250
vim.o.wildmode = 'longest:full,full'

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
-- Use LSP folding if it's available; otherwise, fall back to treesitter folding.
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

-- statuscolumn
function _G.stc()
    local lnum = vim.v.virtnum ~= 0 and '%=' or '%l'
    return lnum .. '%s%C' .. ' '
end
vim.o.statuscolumn = '%!v:lua.stc()'
