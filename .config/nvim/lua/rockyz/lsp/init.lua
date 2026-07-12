local M = {}

-- Diagnostic config

--
-- Diagnostic is displayed as: diagnostic.source: diagnostic.message [diagnostic.code]
-- Virtual text, virtual lines and float should all follow this format
--

---@param diagnostic vim.Diagnostic
---@return string
local function format_diagnostic(diagnostic)
    return string.format('%s: %s', diagnostic.source or 'Unknown', diagnostic.message)
end

---@param diagnostic vim.Diagnostic
---@return string
local function format_diagnostic_code(diagnostic)
    return string.format(' [%s]', diagnostic.code or 'Unknown')
end

local virtual_text_opts = {
    source = false,
    prefix = '●',
    spacing = 4,
    format = format_diagnostic,
    suffix = format_diagnostic_code,
}

local float_opts = {
    source = false,
    border = vim.g.border_style,
    severity_sort = true,
    format = format_diagnostic,
    suffix = format_diagnostic_code,
}

local virtual_lines_opts = {
    format = function(diagnostic)
        return format_diagnostic(diagnostic) .. format_diagnostic_code(diagnostic)
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
vim.lsp.buf.hover = function(config)
    return hover(vim.tbl_deep_extend('force', {
        border = vim.g.border_style,
        max_height = math.floor(vim.o.lines * 0.5),
        max_width = math.floor(vim.o.columns * 0.4),
    }, config or {}))
end

local signature_help = vim.lsp.buf.signature_help
---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.buf.signature_help = function(config)
    return signature_help(vim.tbl_deep_extend('force', {
        border = vim.g.border_style,
        focusable = false,
        max_height = math.floor(vim.o.lines * 0.5),
        max_width = math.floor(vim.o.columns * 0.4),
    }, config or {}))
end

---Return the worst severity
---@return integer?
local function diagnostic_worst_severity()
    local has_warning = false

    for _, d in ipairs(vim.diagnostic.get(0)) do
        if d.severity == vim.diagnostic.severity.ERROR then
            return vim.diagnostic.severity.ERROR
        elseif d.severity == vim.diagnostic.severity.WARN then
            has_warning = true
        end
    end

    if has_warning then
        return vim.diagnostic.severity.WARN
    end
end

---@param count integer
---@return table
local function worst_severity_jump_opts(count)
    local opts = {
        severity = diagnostic_worst_severity(),
        count = count,
        on_jump = function(_, bufnr)
            vim.diagnostic.open_float({
                bufnr = bufnr,
                scope = 'cursor',
                focus = false,
            })
        end,
    }
    return opts
end

---Convert lsp.Range to a Vim range
---@param bufnr integer
---@param lsp_range lsp.Range
---@param offset_encoding 'utf-8'|'utf-16'|'utf-32'
---@return table Range converted from lsp.Range with byte-indexed characters
local function lsp_range_to_vim_range(bufnr, lsp_range, offset_encoding)
    local buf_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local start = lsp_range.start
    local _end = lsp_range['end']
    local start_line = buf_lines[start.line + 1] or ''
    local end_line = buf_lines[_end.line + 1] or ''
    return {
        start = {
            line = start.line,
            -- When on the first character, we can ignore the difference between byte and character
            character = start.character > 0
                and vim.str_byteindex(start_line, offset_encoding, start.character, false)
                or start.character,
        },
        ['end'] = {
            line = lsp_range['end'].line,
            character = _end.character > 0
                and vim.str_byteindex(end_line, offset_encoding, _end.character, false)
                or _end.character,
        },
    }
end

---@return boolean
local function is_before(x, y)
    if x.start.line < y.start.line then
        return true
    elseif x.start.line == y.start.line then
        return x.start.character < y.start.character
    else
        return false
    end
end

---@param position table Position converted from lsp.Position with byte-indexed characters
---@param range table Range converted from lsp.Range with byte-indexed characters
---@return boolean
local function is_position_in_range(position, range)
    return (position.line > range.start.line or (
        position.line == range.start.line and position.character >= range.start.character
    )) and (
        position.line < range['end'].line
        or (position.line == range['end'].line and position.character < range['end'].character)
    )
end

---@param is_closer fun(table, table): boolean
local function move_to_highlight(is_closer)
    local method = 'textDocument/documentHighlight'
    local current_bufnr = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients({ bufnr = current_bufnr, method = method })
    if not next(clients) then
        return
    end

    local current_winid = vim.api.nvim_get_current_win()
    local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(current_winid))
    cursor_row = cursor_row - 1
    local cursor_range = {
        start = { line = cursor_row, character = cursor_col },
    }

    local remaining = #clients
    local closest = nil

    ---@param result lsp.DocumentHighlight[]|nil
    local function on_result(_, result, ctx)
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        if client then
            local offset_encoding = client.offset_encoding
            for _, hl in ipairs(result or {}) do
                local hl_range = lsp_range_to_vim_range(current_bufnr, hl.range, offset_encoding)
                local cursor_inside_range = is_position_in_range(cursor_range.start, hl_range)
                if
                    not cursor_inside_range
                    and is_closer(cursor_range, hl_range)
                    and (closest == nil or is_closer(hl_range, closest))
                    then
                        closest = hl_range
                    end
                end
        end
        remaining = remaining - 1
    end

    for _, client in ipairs(clients) do
        local params = vim.lsp.util.make_position_params(current_winid, client.offset_encoding)
        local request_sent = client:request(method, params, on_result, current_bufnr)
        if not request_sent then
            remaining = remaining - 1
        end
    end

    vim.wait(1000, function()
        return remaining == 0
    end)

    if
        vim.api.nvim_win_is_valid(current_winid)
        and vim.api.nvim_win_get_buf(current_winid) == current_bufnr
        and closest
    then
        vim.api.nvim_win_set_cursor(
            current_winid,
            { closest.start.line + 1, closest.start.character }
        )
    end
end

function M.next_highlight()
    for _ = 1, vim.v.count1 do
        move_to_highlight(is_before)
    end
end

function M.prev_highlight()
    for _ = 1, vim.v.count1 do
        move_to_highlight(function(x, y) return is_before(y, x) end)
    end
end

---@param client vim.lsp.Client
---@param bufnr integer
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
        vim.keymap.set({ 'n', 'x' }, 'gra', vim.lsp.buf.code_action, opts)
    end

    if client:supports_method('textDocument/documentColor') then
        vim.keymap.set({ 'n', 'x' }, 'grc', function()
            -- Select a color presentation from rgb, hex, hsl, lch, etc
            -- Try it in a css file
            vim.lsp.document_color.color_presentation()
        end, opts)
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
    end, opts)
    vim.keymap.set('n', ']D', function() -- last
        vim.diagnostic.jump({ count = math.huge, wrap = false })
    end, opts)
    vim.keymap.set('n', '[w', function() -- previous worst severity, i.e., skip warnings if there are any errors
        vim.diagnostic.jump(worst_severity_jump_opts(-vim.v.count1))
    end, opts)
    vim.keymap.set('n', ']w', function() -- next worst severity
        vim.diagnostic.jump(worst_severity_jump_opts(vim.v.count1))
    end, opts)
    -- Toggle diagnostics (buffer-local)
    vim.keymap.set('n', 'yoe', function()
        vim.diagnostic.enable(not vim.diagnostic.is_enabled({ bufnr = 0 }), { bufnr = 0 })
    end, opts)
    -- Toggle diagnostics (global)
    vim.keymap.set('n', 'yoE', function()
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
        vim.keymap.set('n', 'yoi', function()
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
        vim.keymap.set('n', 'yoI', function()
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
        vim.keymap.set('n', 'yocl', function()
            vim.lsp.codelens.enable(not vim.lsp.codelens.is_enabled())
        end, opts)
    end

    -- Document highlight
    if client:supports_method('textDocument/documentHighlight') then
        local document_highlight_group = vim.api.nvim_create_augroup(('rockyz.lsp.document_highlight.%d'):format(bufnr), { clear = true })
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

        vim.keymap.set('n', '[v', function()
            require('rockyz.lsp').prev_highlight()
        end, opts)
        vim.keymap.set('n', ']v', function()
            require('rockyz.lsp').next_highlight()
        end, opts)
    end
end

local group = vim.api.nvim_create_augroup('rockyz.lsp', { clear = true })

vim.api.nvim_create_autocmd('LspAttach', {
    group = group,
    callback = function(event)
        local bufnr = event.buf
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if not client then
            return
        end
        on_attach(client, bufnr)
    end,
})

-- Close import folds when an LSP client opens a buffer
vim.api.nvim_create_autocmd({ 'LspNotify' }, {
    group = group,
    callback = function(event)
        if event.data.method ~= 'textDocument/didOpen' then
            return
        end
        local winid = vim.fn.bufwinid(event.buf)
        if winid ~= -1 then
            vim.lsp.foldclose('imports', vim.fn.bufwinid(event.buf))
        end
    end,
})

-- Enable LSP servers
vim.lsp.enable({
    'bashls',
    'clangd',
    'cssls',
    'gopls',
    'html',
    'jsonls',
    'luals',
    'taplo',
    'ts_query_ls',
    'tsgo',
    'vimls',
    'yamlls',
})

return M
