local diagnostic_icons = require('rockyz.icons').diagnostics
local methods = vim.lsp.protocol.Methods

local M = {}

-- Diagnostic config

-- The format for diagnostic display is: diagnostic.code: diagnostic.message [diagnostic.source]
-- Virtual text, virtual lines and float should all follow this format
--
-- TODO: The message in the virtual lines already includes the code. I'm not sure if this is a bug.

local virtual_text_opts = {
    source = false,
    prefix = '●',
    spacing = 4,
    format = function(d)
        return string.format('%s: %s', d.code and d.code or 'Unknown', d.message)
    end,
    suffix = function(d)
        return string.format(' [%s]', d.source and d.source or 'Unknown')
    end,
}
local float_opts = {
    source = false,
    border = vim.g.border_style,
    severity_sort = true,
    format = function(d)
        return string.format('%s: %s', d.code and d.code or 'Unknown', d.message)
    end,
    suffix = function(d)
        return string.format(' [%s]', d.source and d.source or 'Unknown')
    end,
}
local virtual_lines_opts = {
    format = function(d)
        return string.format('%s [%s]', d.message, d.source and d.source or 'Unknown')
    end,
}

vim.diagnostic.config({
    float = float_opts,
    virtual_text = virtual_text_opts,
    virtual_lines = false,
    signs = false,
    severity_sort = true,
})

-- Capabilities

M.client_capabilities = function()
    local capabilities = vim.tbl_deep_extend(
        'force',
        vim.lsp.protocol.make_client_capabilities(),
        require('blink.cmp').get_lsp_capabilities()
    )
    return capabilities
end

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
    vim.keymap.set('n', 'yod', function()
        vim.diagnostic.enable(not vim.diagnostic.is_enabled({ bufnr = 0 }), { bufnr = 0 })
    end, opts)
    -- Toggle diagnostics (global)
    vim.keymap.set('n', 'yoD', function()
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
    -- Toggle (buffer-local)
    vim.keymap.set('n', 'yoh', function()
        local is_enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
        vim.b.inlay_hint_enabled = not is_enabled
        vim.lsp.inlay_hint.enable(vim.b.inlay_hint_enabled, { bufnr = 0 })
        vim.notify(string.format('Inlay hints (buffer-local) is %s', vim.b.inlay_hint_enabled and 'enabled' or 'disabled'), vim.log.levels.INFO)
    end, opts)
    -- Toggle (global)
    vim.keymap.set('n', 'yoH', function()
        vim.g.inlay_hint_enabled = not vim.g.inlay_hint_enabled
        vim.lsp.inlay_hint.enable(vim.g.inlay_hint_enabled)
        vim.notify(string.format('Inlay hints (global) is %s', vim.g.inlay_hint_enabled and 'enabled' or 'disabled'), vim.log.levels.INFO)
    end, opts)

    -- Lsp progress
    require('rockyz.lsp.progress')

    -- Show a lightbulb when code actions are available under the cursor
    require('rockyz.lsp.lightbulb')

    -- Enable code lens
    -- if client and client.server_capabilities.codeLensProvider then
    --     vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'InsertLeave' }, {
    --         buffer = bufnr,
    --         callback = function()
    --             vim.lsp.codelens.refresh({ bufnr = 0 })
    --         end,
    --     })
    -- end

    -- Document highlight
    if client:supports_method('textDocument/documentHighlight') then
        vim.api.nvim_create_autocmd({ 'CursorHold', 'InsertLeave' }, {
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.document_highlight()
            end,
        })
        vim.api.nvim_create_autocmd({ 'CursorMoved', 'InsertEnter', 'BufLeave' }, {
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.clear_references()
            end,
        })
    end
end

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        on_attach(client, bufnr)
    end,
})

return M
