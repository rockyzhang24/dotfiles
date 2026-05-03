local M = {}

-- Diagnostic config

--
-- Diagnostic is displayed as: diagnostic.source: diagnostic.message [diagnostic.code]
-- Virtual text, virtual lines and float should all follow this format
--

local function format(d)
    return string.format('%s: %s', d.source and d.source or 'Unknown', d.message)
end

local function suffix(d)
    return string.format(' [%s]', d.code and d.code or 'Unknown')
end

local virtual_text_opts = {
    source = false,
    prefix = '●',
    spacing = 4,
    format = format,
    suffix = suffix,
}

local float_opts = {
    source = false,
    border = vim.g.border_style,
    severity_sort = true,
    format = format,
    suffix = suffix,
}

local virtual_lines_opts = {
    format = function(d)
    return string.format(
        '%s: %s [%s]',
        d.source and d.source or 'Unknown',
        d.message,
        d.code and d.code or 'Unknown'
    )
    end,
}

vim.diagnostic.config({
    float = float_opts,
    virtual_text = virtual_text_opts,
    virtual_lines = false,
    signs = false,
    severity_sort = true,
})

local hover = vim.lsp.buf.hover
---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.buf.hover = function()
    return hover {
        border = vim.g.border_style,
        max_height = math.floor(vim.o.lines * 0.5),
        max_width = math.floor(vim.o.columns * 0.4),
    }
end

local signature_help = vim.lsp.buf.signature_help
---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.buf.signature_help = function()
    return signature_help {
        border = vim.g.border_style,
        focusable = false,
        max_height = math.floor(vim.o.lines * 0.5),
        max_width = math.floor(vim.o.columns * 0.4),
    }
end

local function on_attach(client, bufnr)
    --
    -- Mappings
    --
    -- Nvim creates the following default LSP mappings:
    --  * K in NORMAL maps to vim.lsp.buf.hover()
    --  * grr in NORMAL maps to vim.lsp.buf.references()
    --  * gri in NORMAL maps to vim.lsp.buf.implementation()
    --  * grt in NORMAL maps to vim.lsp.buf.type_definition()
    --  * grx in NORMAL maps to vim.lsp.codelens.run()
    --  * gO in NORMAL maps to vim.lsp.buf.document_symbol()
    --  * grn in NORMAL maps to vim.lsp.buf.rename()
    --  * gra in NORMAL and VISUAL maps to vim.lsp.buf.code_action()
    --  * <C-s> in INSERT and SELECT maps to vim.lsp.buf.signature_help()
    --  * an and in in VISUAL maps to outer and inner incremental selections, respectively, using
    --  vim.lsp.buf.selection_range()
    -- Also, the following default diagnostic mappings are creataed:
    --  * ]d and [d: jump to the next or previous diagnostic
    --  * ]D and [D: jump to the last or first diagnostic
    --  * <C-w>d and <C-w><C-d> map to vim.diagnostic.open_float()
    --

    local opts = { buffer = bufnr }

    if client:supports_method('textDocument/references') then
        vim.keymap.set('n', 'grr', '<Cmd>lua require("rockyz.fzf").lsp_references()<CR>', opts)
    end

    if client:supports_method('textDocument/typeDefinition') then
        vim.keymap.set('n', 'gy', '<Cmd>lua require("rockyz.fzf").lsp_type_definition()<CR>', opts)
    end

    if client:supports_method('textDocument/definition') then
        vim.keymap.set('n', 'gd', '<Cmd>lua require("rockyz.fzf").lsp_definition()<CR>', opts)
    end

    if client:supports_method('textDocument/declaration') then
        vim.keymap.set('n', 'gD', '<Cmd>lua require("rockyz.fzf").lsp_declaration()<CR>', opts)
    end

    if client:supports_method('textDocument/implementation') then
        vim.keymap.set('n', 'gi', '<Cmd>lua require("rockyz.fzf").lsp_implementation()<CR>', opts)
    end

    if client:supports_method('textDocument/signatureHelp') then
        vim.keymap.set('i', '<C-s>', function()
            -- Close the completion menu first (if open) that may overlap the signature window
            if require('blink.cmp.completion.windows.menu').win:is_open() then
                require('blink.cmp').hide()
            end
            vim.lsp.buf.signature_help()
        end, opts)
    end

    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'grn', vim.lsp.buf.rename, opts)

    if client:supports_method('textDocument/codeAction') then
        -- Code actions for the current line.
        -- In order to get the code actions only for the cursor position, the diagnostics overlap the
        -- cursor position could be passed as part of the parameter to vim.lsp.buf.code_action(). However,
        -- currently the code action function doesn't offer a way to extract per client diagnostics, i.e.,
        -- all the diagnostics at the cursor position will be sent to each server.
        --
        -- TODO: modify this keymap to only get the code actions for the current cursor position after the
        -- API is fixed.
        vim.keymap.set({ 'n', 'x' }, 'gra', vim.lsp.buf.code_action, opts)
    end

    if client:supports_method('textDocument/documentColor') then
        vim.keymap.set({ 'n', 'x' }, 'grc', function()
            -- Select a color presentation from rgb, hex, hsl, lch, etc
            -- Try it in a css file
            vim.lsp.document_color.color_presentation()
        end)
    end

    -- <M-ENTER> (insert-mode) manually triggers LSP completion
    vim.keymap.set('i', '<M-Enter>', function()
        vim.lsp.completion.enable(true, client.id, bufnr)
        -- vim.notify('lsp completion: working...')
        vim.lsp.completion.get()
        -- vim.cmd[[redraw | echo '']]
    end, opts)

    -- Diagnostics
    vim.keymap.set('n', 'gl', vim.diagnostic.open_float, opts)
    vim.keymap.set('n', '[d', function() -- previous
        vim.diagnostic.jump({ count = -vim.v.count1 })
    end, opts)
    vim.keymap.set('n', ']d', function() -- next
        vim.diagnostic.jump({ count = vim.v.count1 })
    end, opts)
    vim.keymap.set('n', '[D', function() -- first
        vim.diagnostic.jump({ count = -math.huge, wrap = false })
    end)
    vim.keymap.set('n', ']D', function() -- last
        vim.diagnostic.jump({ count = math.huge, wrap = false })
    end)
    vim.keymap.set('n', '[e', function() -- previous error
        vim.diagnostic.jump({ count = -vim.v.count1, severity = vim.diagnostic.severity.ERROR })
    end, opts)
    vim.keymap.set('n', ']e', function() -- next error
        vim.diagnostic.jump({ count = vim.v.count1, severity = vim.diagnostic.severity.ERROR })
    end, opts)
    -- Toggle diagnostics (buffer-local)
    vim.keymap.set('n', '\\e', function()
        vim.diagnostic.enable(not vim.diagnostic.is_enabled({ bufnr = 0 }), { bufnr = 0 })
    end, opts)
    -- Toggle diagnostics (global)
    vim.keymap.set('n', '\\E', function()
        vim.diagnostic.enable(not vim.diagnostic.is_enabled())
    end, opts)
    -- Switch the way diagnostics are displayed (virtual text or virtual line)
    vim.keymap.set('n', 'gK', function()
        local old_opts = vim.diagnostic.config()
        if not old_opts then
            return
        end
        local new_opts = {}
        new_opts.virtual_text = not old_opts.virtual_text and virtual_text_opts or false
        new_opts.virtual_lines = not old_opts.virtual_lines and virtual_lines_opts or false
        vim.diagnostic.config(new_opts)
    end, opts)

    -- Feed all diagnostics to quickfix list, or buffer diagnostics to location list
    vim.keymap.set('n', 'grq', vim.diagnostic.setqflist, opts)
    vim.keymap.set('n', 'grl', vim.diagnostic.setloclist, opts)

    -- Format
    -- vim.keymap.set({ 'n', 'x' }, '<leader>F', function()
    --     vim.lsp.buf.format({ async = true })
    -- end, opts)

    -- Inlay hints
    if client:supports_method('textDocument/inlayHint') then
        if vim.g.inlay_hint_enabled then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end
        -- Toggle inlay hints
        -- (1). Buffer locally
        vim.keymap.set('n', '\\h', function()
            local is_enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
            vim.b.inlay_hint_enabled = not is_enabled
            vim.lsp.inlay_hint.enable(vim.b.inlay_hint_enabled, { bufnr = 0 })
            vim.notify(
                string.format(
                    'Inlay hints (buffer-local) is %s',
                    vim.b.inlay_hint_enabled and 'enabled' or 'disabled'
                ),
                vim.log.levels.INFO
            )
        end, opts)
        -- (2). Globally
        vim.keymap.set('n', '\\H', function()
            vim.g.inlay_hint_enabled = not vim.g.inlay_hint_enabled
            vim.lsp.inlay_hint.enable(vim.g.inlay_hint_enabled)
            vim.notify(
                string.format(
                    'Inlay hints (global) is %s',
                    vim.g.inlay_hint_enabled and 'enabled' or 'disabled'
                ),
                vim.log.levels.INFO
            )
        end, opts)
    end

    -- Lsp progress
    require('rockyz.lsp.progress')

    -- Lightbulb
    if client:supports_method('textDocument/codeAction') then
        require('rockyz.lsp.lightbulb')
    end

    -- Codelens
    if client:supports_method('textDocument/codeLens') then
        -- Toggle
        vim.keymap.set('n', '\\cl', function()
            vim.lsp.codelens.enable(not vim.lsp.codelens.is_enabled())
        end, opts)
    end

    -- Document highlight
    if client:supports_method('textDocument/documentHighlight') then
        local document_highlight_group = vim.api.nvim_create_augroup('rockyz.lsp.document_highlight', { clear = true })
        vim.api.nvim_create_autocmd({ 'CursorHold', 'InsertLeave' }, {
            group = document_highlight_group,
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.document_highlight()
            end,
        })
        vim.api.nvim_create_autocmd({ 'CursorMoved', 'InsertEnter', 'BufLeave' }, {
            group = document_highlight_group,
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.clear_references()
            end,
        })
    end
end

local group = vim.api.nvim_create_augroup('rockyz.lsp', { clear = true })

vim.api.nvim_create_autocmd('LspAttach', {
    group = group,
    callback = function(ev)
        local bufnr = ev.buf
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        on_attach(client, bufnr)
    end,
})

-- Auto close imports
vim.api.nvim_create_autocmd({ 'LspNotify' }, {
    group = group,
    callback = function(ev)
        if ev.data.method == 'textDocument/didOpen' then
            vim.lsp.foldclose('imports', vim.fn.bufwinid(ev.buf))
        end
    end,
})

-- Enable LSP servers
local lsp_configs = {}
for _, v in ipairs(vim.api.nvim_get_runtime_file('lsp/*', true)) do
    local name = vim.fn.fnamemodify(v, ':t:r')
    lsp_configs[name] = true
end

vim.lsp.enable(vim.tbl_keys(lsp_configs))

return M
