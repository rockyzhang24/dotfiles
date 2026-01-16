local icons = require('rockyz.icons')

vim.o.breakindent = true
vim.o.cindent = true
vim.o.cmdheight = 1
vim.o.completeopt = 'menuone,noselect,noinsert,fuzzy,popup'
vim.opt.cpoptions:remove('_')
vim.o.cursorline = true
vim.opt.diffopt = {'algorithm:patience', 'closeoff', 'filler', 'inline:word', 'internal', 'linematch:60', 'vertical'}
vim.o.expandtab = true
vim.o.exrc = true
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
vim.o.inccommand = 'split'
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
vim.opt.sessionoptions:remove('blank')
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
            vim.wo.foldtext = 'v:lua.vim.lsp.foldtext()'
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

-- Terminal config

-- Inspired by @justinmk
-- In terminal, map <C-[> to <C-\><C-n> to go back to NORMAL. <ESC> can send literal ESC.
-- In the terminal-nested nvim, map <C-[> back to <ESC>
local function config_term_esc()
    vim.keymap.set('t', '<C-[>', [[<C-\><C-N>]])

    -- Send literal ESC
    vim.keymap.set('t', '<Space><C-[>', '<Esc>')

    -- In terminal-nested Nvim, we should map <C-[> back to <ESC>
    if vim.env.NVIM then
        local function parent_chan()
            local ok, chan = pcall(vim.fn.sockconnect, 'pipe', vim.env.NVIM, {rpc=true})
            if not ok then
                vim.notify(('failed to create channel to $NVIM: %s'):format(chan))
            end
            return ok and chan or nil
        end

        local didset = false
        local chan = assert(parent_chan())

        local function map_parent(lhs)
            -- Map `lhs` in the parent so it gets sent to the child (this) Nvim.
            local map = vim.rpcrequest(chan, 'nvim_exec_lua', [[return vim.fn.maparg(..., 't', false, true)]], { lhs }) --[[@as table<string,any>]]
            if map.rhs == [[<C-\><C-N>]] then
                vim.rpcrequest(chan, 'nvim_exec_lua', [[vim.keymap.set('t', ..., '<Esc>', {buffer=0})]], { lhs })
                didset = true
            end
        end
        map_parent('<C-[>')
        vim.fn.chanclose(chan)

        -- Restore the mapping(s) on VimLeave.
        if didset then
            vim.api.nvim_create_autocmd({'VimLeave'}, {
                group = vim.api.nvim_create_augroup('rockyz.terminal.config_esc', { clear = true }),
                callback = function()
                    local chan2 = assert(parent_chan())
                    vim.rpcrequest(chan2, 'nvim_exec2', [=[
                    tunmap <buffer> <C-[>
                    ]=], {})
                end,
            })
        end
    end
end
config_term_esc()

-- Inspired by @justinmk
-- In terminal, mark the start of each prompt in signcolumn; change the current working directory of
-- the terminal window to match the terminal's pwd.
local function config_term()
    vim.api.nvim_create_autocmd('TermOpen', {
        callback = function()
            vim.cmd[=[
            nnoremap <silent><buffer> <cr> i<cr><c-\><c-n>
            nnoremap <silent><buffer> <c-c> i<c-c><c-\><c-n>
            ]=]
        end
    })
    local ns = vim.api.nvim_create_namespace('rockyz.terminal.osc133')
    vim.api.nvim_create_autocmd('TermRequest', {
        group = vim.api.nvim_create_augroup('rockyz.terminal.termrequest_osc', { clear = true }),
        callback = function(ev)
            if string.match(ev.data.sequence, '^\027]133;A') then
                -- OSC 133: shell-prompt
                local extmarks = vim.b[ev.buf].osc133_extmarks or {}
                local lnum = ev.data.cursor[1]

                for id, l in pairs(extmarks) do
                    if l < lnum then
                        vim.api.nvim_buf_set_extmark(ev.buf, ns, l, 0, {
                            id = id,
                            sign_text = icons.misc.circle_filled,
                        })
                    end
                end

                local new_id = vim.api.nvim_buf_set_extmark(ev.buf, ns, lnum, 0, {
                    sign_text = icons.misc.circle,
                    -- sign_hl_group = 'SpecialChar',
                })

                extmarks[new_id] = lnum
                vim.b[ev.buf].osc133_extmarks = extmarks

                for id, l in pairs(extmarks) do
                    if l > lnum then
                        vim.api.nvim_buf_del_extmark(ev.buf, ns, id)
                    end
                end
            end

            local val, n = string.gsub(ev.data.sequence, '^\027]7;file://[^/]*', '')
            if n > 0 then
                -- OSC 7: dir-change
                local dir = val
                if vim.fn.isdirectory(dir) == 0 then
                    vim.notify('invalid dir: '..dir)
                    return
                end
                vim.b[ev.buf].osc7_dir = dir
                if vim.api.nvim_get_current_buf() == ev.buf then
                    vim.cmd.lcd(dir)
                end
            end
        end,
    })
end
config_term()
