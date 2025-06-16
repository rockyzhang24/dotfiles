local methods = vim.lsp.protocol.Methods

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
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', 'gI', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, { buffer = bufnr, nowait = true })
    vim.keymap.set({ 'i', 's' }, '<C-s>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<Leader>rn', vim.lsp.buf.rename, opts)
    -- Code actions for the current line.
    -- In order to get the code actions only for the cursor position, the diagnostics overlap the
    -- cursor position could be passed as part of the parameter to vim.lsp.buf.code_action(). However,
    -- currently the code action function doesn't offer a way to extract per client diagnostics, i.e.,
    -- all the diagnostics at the cursor position will be sent to each server.
    --
    -- TODO: modify this keymap to only get the code actions for the current cursor position after the
    -- API is fixed.
    vim.keymap.set({ 'n', 'x' }, '<Leader>la', vim.lsp.buf.code_action, opts)

    -- Diagnostics
    vim.keymap.set('n', 'go', vim.diagnostic.open_float, opts)
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
    vim.keymap.set('n', '<Leader>dq', vim.diagnostic.setqflist, opts)
    vim.keymap.set('n', '<Leader>dl', vim.diagnostic.setloclist, opts)

    -- Format
    -- vim.keymap.set({ 'n', 'x' }, '<leader>F', function()
    --     vim.lsp.buf.format({ async = true })
    -- end, opts)

    -- Inlay hints
    if vim.g.inlay_hint_enabled then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end
    -- Toggle inlay hints
    -- (1). Buffer locally
    vim.keymap.set('n', '\\h', function()
        local is_enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
        vim.b.inlay_hint_enabled = not is_enabled
        vim.lsp.inlay_hint.enable(vim.b.inlay_hint_enabled, { bufnr = 0 })

        vim.notify(string.format('Inlay hints (buffer-local) is %s', vim.b.inlay_hint_enabled and 'enabled' or 'disabled'), vim.log.levels.INFO)
    end, opts)
    -- (2). Globally
    vim.keymap.set('n', '\\H', function()
        vim.g.inlay_hint_enabled = not vim.g.inlay_hint_enabled
        vim.lsp.inlay_hint.enable(vim.g.inlay_hint_enabled)
        vim.notify(string.format('Inlay hints (global) is %s', vim.g.inlay_hint_enabled and 'enabled' or 'disabled'), vim.log.levels.INFO)
    end, opts)

    -- Lsp progress
    require('rockyz.lsp.progress')

    -- Show a lightbulb when code actions are available under the cursor
    require('rockyz.lsp.lightbulb')

    -- Code lens
    -- if client:supports_method(methods.textDocument_codeLens) then
    --     local codelens_group = vim.api.nvim_create_augroup('rockyz.lsp.codelens', { clear = true })
    --     vim.api.nvim_create_autocmd("LspProgress", {
    --         group = codelens_group,
    --         pattern = { 'begin', 'end' },
    --         callback = function(ev)
    --             if ev.buf == bufnr then
    --                 vim.lsp.codelens.refresh({ bufnr = bufnr })
    --             end
    --         end,
    --     })
    --     vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "InsertLeave" }, {
    --         group = codelens_group,
    --         buffer = bufnr,
    --         callback = function()
    --             vim.lsp.codelens.refresh({ bufnr = bufnr })
    --         end,
    --     })
    --     vim.lsp.codelens.refresh({ bufnr = bufnr })
    -- end

    -- Document highlight
    if client:supports_method(methods.textDocument_documentHighlight) then
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

    -- Document colors (no need to check supports_method)
    vim.lsp.document_color.enable(true, bufnr)
end

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        on_attach(client, bufnr)
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
