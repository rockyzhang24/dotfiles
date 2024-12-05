local diagnostic_icons = require('rockyz.icons').diagnostics

local M = {}

-- Config diagnostic globally
vim.diagnostic.config({
    float = {
        source = true,
        border = vim.g.border_style,
        severity_sort = true,
        prefix = function(diagnostic)
            local level = vim.diagnostic.severity[diagnostic.severity]
            local prefix = string.format(' %s ', diagnostic_icons[level])
            return prefix, 'Diagnostic' .. level:gsub('^%l', string.upper)
        end,
    },
    virtual_text = {
        prefix = '',
        spacing = 4,
        format = function(diagnostic)
            local icon = diagnostic_icons[vim.diagnostic.severity[diagnostic.severity]]
            return string.format('%s %s ', icon, diagnostic.message)
        end,
    },
    signs = false,
    severity_sort = true,
    jump = {
        float = {
            scope = 'cursor',
        },
    },
})

M.client_capabilities = function()
    local capabilities = vim.tbl_deep_extend(
        'force',
        vim.lsp.protocol.make_client_capabilities(),
        require('cmp_nvim_lsp').default_capabilities()
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
    -- Feed all diagnostics to quickfix list, or buffer diagnostics to location list
    vim.keymap.set('n', '<Leader>dq', vim.diagnostic.setqflist, opts)
    vim.keymap.set('n', '<Leader>dl', vim.diagnostic.setloclist, opts)
    -- Format
    -- vim.keymap.set({ 'n', 'x' }, '<leader>F', function()
    --     vim.lsp.buf.format({ async = true })
    -- end, opts)
    -- Toggle inlay hints
    if client and client.server_capabilities.inlayHintProvider then
        vim.keymap.set('n', 'yoh', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
        end, opts)
    end

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
