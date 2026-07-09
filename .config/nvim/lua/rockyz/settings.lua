local icons = require('rockyz.icons')

--------------------------------------------------------------------------------
-- Editor options
--------------------------------------------------------------------------------

vim.o.breakindent = true
vim.o.cindent = true
vim.o.cmdheight = 1
vim.o.completeopt = 'menuone,noselect,noinsert,fuzzy,popup'
vim.opt.cpoptions:remove('_')
vim.o.cursorline = true
vim.opt.diffopt = {
    'algorithm:patience',
    'closeoff',
    'filler',
    'inline:word',
    'internal',
    'linematch:60',
    'vertical',
}
vim.o.expandtab = true
vim.o.exrc = true
vim.opt.fillchars = {
    eob = ' ',
    fold = ' ',
    foldopen = icons.caret.down,
    foldclose = icons.caret.right,
    foldsep = ' ',
    foldinner = ' ',
    msgsep = '‾',
}
vim.o.foldcolumn = '1'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
-- vim.opt.guicursor = 'i:block' -- Use block cursor in insert mode
vim.o.ignorecase = true
vim.o.inccommand = 'split'
vim.opt.isfname:remove('=')
vim.opt.jumpoptions:append('view')
vim.o.laststatus = 3
vim.o.linebreak = true
vim.o.list = true
vim.opt.listchars = {
    extends = '›',
    nbsp = '.',
    precedes = '‹',
    -- space = '⋅',
    trail = '•',
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
vim.o.softtabstop = -1 -- Fall back to shiftwidth
vim.o.spelllang = 'en_us'
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.switchbuf = 'usetab,newtab'
vim.o.synmaxcol = 500
vim.o.tabclose = 'uselast'
vim.o.tabstop = 4
vim.o.textwidth = 100
vim.o.timeoutlen = 500
vim.o.title = true
vim.cmd([[let &titlestring = (exists('$SSH_TTY') ? 'SSH ' : '') .. '%{fnamemodify(getcwd(),":t")}']])
-- Persistent undo. Use 'undodir' to change the undo directory; the default is
-- ~/.local/share/nvim/undo.
vim.o.undofile = true
vim.o.updatetime = 250
vim.o.wildmode = 'longest:full,full'

-- Avoid highlighting the last search when sourcing vimrc
vim.cmd('nohlsearch')

-- Plugin globals
vim.g.tex_flavor = 'latex'
vim.g.man_hardwrap = 0 -- Soft wrap man pages

-- Disable unused language providers
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

-- Netrw
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
vim.g.netrw_localcopydircmd = 'cp -r'

--------------------------------------------------------------------------------
-- Folding
--------------------------------------------------------------------------------

-- Prefer LSP folding when available; otherwise, fall back to Treesitter.

-- Default until an LSP or Treesitter foldexpr is available
vim.o.foldmethod = 'indent'
-- Use transparent foldtext
vim.o.foldtext = ''

local fold_augroup = vim.api.nvim_create_augroup('rockyz.fold', { clear = true })

vim.api.nvim_create_autocmd('LspAttach', {
    group = fold_augroup,
    callback = function(ev)
        local bufnr = ev.buf
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client and client:supports_method('textDocument/foldingRange') then
            vim.wo.foldmethod = 'expr'
            vim.wo.foldexpr = 'v:lua.vim.lsp.foldexpr()'
            vim.wo.foldtext = 'v:lua.vim.lsp.foldtext()'
            vim.b[bufnr].lsp_folding_enabled = true
        end
    end,
})

vim.api.nvim_create_autocmd('FileType', {
    group = fold_augroup,
    callback = function(ev)
        local bufnr = ev.buf
        if vim.bo[bufnr].filetype ~= 'bigfile' and not vim.b[bufnr].lsp_folding_enabled then
            local has_parser, _ = pcall(vim.treesitter.get_parser, ev.buf)
            if has_parser then
                vim.wo.foldmethod = 'expr'
                vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
            end
        end
    end,
})

-- Statuscolumn
function _G.rockyz_statuscolumn()
    local lnum = vim.v.virtnum ~= 0 and '%=' or '%l'
    return lnum .. '%s%C' .. ' '
end

vim.o.statuscolumn = '%!v:lua.rockyz_statuscolumn()'

--------------------------------------------------------------------------------
-- Terminal
--------------------------------------------------------------------------------

-- Inspired by @justinmk
-- In terminal, map <C-[> to <C-\><C-n> to go back to NORMAL. <ESC> can send literal ESC.
-- In the terminal-nested nvim, map <C-[> back to <ESC>
local function setup_terminal_escape()
    vim.keymap.set('t', '<C-[>', [[<C-\><C-N>]])

    -- Send literal ESC
    vim.keymap.set('t', '<C-Space><C-[>', '<Esc>')

    -- In terminal-nested Nvim, we should map <C-[> back to <ESC>
    if vim.env.NVIM then
        local function parent_chan()
            local ok, chan = pcall(vim.fn.sockconnect, 'pipe', vim.env.NVIM, { rpc = true })
            if not ok then
                vim.notify(('failed to create channel to $NVIM: %s'):format(chan))
            end
            return ok and chan or nil
        end

        local didset = false
        local chan = parent_chan()
        if not chan then
            return
        end

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
            vim.api.nvim_create_autocmd('VimLeave', {
                group = vim.api.nvim_create_augroup('rockyz.terminal.config_esc', { clear = true }),
                callback = function()
                    local chan2 = parent_chan()
                    if not chan2 then
                        return
                    end

                    vim.rpcrequest(chan2, 'nvim_exec2', [=[
                    tunmap <buffer> <C-[>
                    ]=], {})
                end,
            })
        end
    end
end
setup_terminal_escape()

-- Inspired by @justinmk
-- In terminal, mark the start of each prompt in signcolumn; change the current working directory of
-- the terminal window to match the terminal's pwd.
local function setup_terminal()
    vim.api.nvim_create_autocmd('TermOpen', {
        pattern = {
            '{term,shell}://*',
            ':shell*',
        },
        callback = function()
            vim.cmd([=[
            nnoremap <silent><buffer> <cr> i<cr><c-\><c-n>
            nnoremap <silent><buffer> <c-c> i<c-c><c-\><c-n>
            ]=])
        end,
    })

    local osc_namespace = vim.api.nvim_create_namespace('rockyz.terminal.osc')

    vim.api.nvim_create_autocmd('TermRequest', {
        group = vim.api.nvim_create_augroup('rockyz.terminal.osc', { clear = true }),
        callback = function(ev)
            if string.match(ev.data.sequence, '^\027]133;A') then
                -- OSC 133: shell prompt
                local prompt_marks = vim.b[ev.buf].osc133_extmarks or {}
                local prompt_lnum = ev.data.cursor[1]

                for id, l in pairs(prompt_marks) do
                    if l < prompt_lnum then
                        vim.api.nvim_buf_set_extmark(ev.buf, osc_namespace, l, 0, {
                            id = id,
                            sign_text = icons.misc.circle_filled,
                        })
                    end
                end

                local new_id = vim.api.nvim_buf_set_extmark(ev.buf, osc_namespace, prompt_lnum, 0, {
                    sign_text = icons.misc.circle,
                    -- sign_hl_group = 'SpecialChar',
                })

                prompt_marks[new_id] = prompt_lnum
                vim.b[ev.buf].osc133_extmarks = prompt_marks

                for id, l in pairs(prompt_marks) do
                    if l > prompt_lnum then
                        vim.api.nvim_buf_del_extmark(ev.buf, osc_namespace, id)
                        prompt_marks[id] = nil
                    end
                end
            end

            local dir, count = string.gsub(ev.data.sequence, '^\027]7;file://[^/]*', '')
            if count > 0 then
                -- OSC 7: current directory
                if vim.fn.isdirectory(dir) == 0 then
                    vim.notify('invalid dir: ' .. dir)
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
setup_terminal()
