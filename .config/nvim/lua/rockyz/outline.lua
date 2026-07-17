---@class rockyz.outline.Jump
---@field range lsp.Range
---@field selection_range lsp.Range
---@field offset_encoding string

---@alias rockyz.outline.Provider 'lsp'|'treesitter'|'ctags'|'man'

---@class rockyz.outline.OutlineSymbol
---@field name string
---@field kind string|nil
---@field detail string|nil
---@field range lsp.Range|nil
---@field selectionRange lsp.Range|nil
---@field children rockyz.outline.OutlineSymbol[]|nil

---@class rockyz.outline.TreeSitterSymbol: rockyz.outline.OutlineSymbol
---@field scope string|nil
---@field level integer Tree hierarchy level used by Markdown and help
---@field parent rockyz.outline.TreeSitterSymbol|nil Parent symbol used during postprocessing

---@alias rockyz.outline.Postprocess fun(bufnr: integer, symbol: rockyz.outline.TreeSitterSymbol, match: table): boolean|nil # Return false to exclude the symbol from the outline

---@alias rockyz.outline.FormattableSymbol lsp.DocumentSymbol|lsp.SymbolInformation|rockyz.outline.OutlineSymbol

---@class rockyz.outline.BufferState
---@field filetype string
---@field buftype string

---Store the state of the outline in the current tabpage
---@class rockyz.outline.OutlineStatePerTab
---@field bufnr integer|nil The bufnr of the outline buffer
---@field winid integer|nil The winid of the outline window
---@field source_bufnr integer|nil The bufnr of the source buffer
---@field kinds table<string, boolean> A set to contain unique kinds
---@field contents string[] Contents that will be displayed in outline
---@field highlights table Information to highlight the icon and detail by extmarks
---@field jumps table<integer, rockyz.outline.Jump|false> Jump operations indexed by outline line
---@field follow_cursor boolean Whether "follow cursor" is enabled
---@field prev_buf_state rockyz.outline.BufferState|nil The state of the previous buffer (e.g., its buftype, filetype, etc)
---@field provider rockyz.outline.Provider|nil Current outline provider
---@field prev_provider rockyz.outline.Provider|nil The provider of the previous normal buffer for restoration
---@field timer uv.uv_timer_t|nil
---@field request_id integer Monotonically increasing ID for outline requests

local icons = require('rockyz.icons')
local fzf = require('rockyz.fzf')
local notify = require('rockyz.utils.notify')

local M = {}

---Store per-tab outline state, indexed by tabid
---@type table<integer, rockyz.outline.OutlineStatePerTab>
local states = {}

---@type table<string, { query: vim.treesitter.Query|nil, err: string|nil }>
local query_cache = {}

local highlight_ns = vim.api.nvim_create_namespace('rockyz.outline.highlights')

local config = {
    default_provider = 'lsp',
    toggle = 'yoo',
    width = 50,
    keymaps = {
        -- Local keymaps available only in outline buffer
        ['local'] = {
            ['<Enter>'] = 'jump', -- jump to the symbol in source window
            p = 'peek',
            ['<C-k>'] = 'peek_prev',
            ['<C-j>'] = 'peek_next',
        },
        -- Available in both normal buffer and outline buffer
        global = {
            gs = 'reveal', -- reveal the symbol in outline buffer
            ['yosf'] = 'toggle_follow', -- follow cursor
            ['<Leader>sr'] = 'refresh', -- update outline
            ['<Leader>sg'] = 'switch_to_ctags', -- switch to ctags provider
            ['<Leader>sl'] = 'switch_to_lsp', -- switch to LSP provider
            ['<Leader>st'] = 'switch_to_treesitter',
            ['<Leader>sf'] = 'filter_kinds',
            ['<Leader>sc'] = 'clear_filter',
            ['<Leader>sF'] = 'show_functions_only', -- show functions only
        },
    }
}

-- Configurations for ctags provider
local ctags_config = {
    -- Delimiter in tag.scope, e.g., scope = "fzf.revision" for golang that means this tag is
    -- a child of tag "revision" that is the child of tag "fzf".
    -- For most languages the delimiter is '.', but for C, C++ it's '::'
    scope_sep = '.',

    -- Maps ctags kinds to outline symbol kinds
    kinds = {
        const = 'Constant',
        constructor = 'Constructor',
        enum = 'Enum',
        func = 'Function',
        member = 'Field',
        var = 'Variable',
    },

    filetypes = {
        cpp = {
            scope_sep = '::',
            kinds = {
                enumerator = 'EnumMember',
                header = 'File',
                macro = 'Constant',
                partition = 'Namespace',
                typedef = 'TypeParameter',
                union = 'Struct',
            },
        },
        cmake = {
            kinds = {
                macro = 'Function',
                option = 'Variable',
                project = 'Module',
                target = 'Class',
            },
        },
        css = {
            kinds = {
                id = 'Key',
                selector = 'Object',
            },
        },
        clojure = {
            kinds = {
                unknown = 'Variable',
            },
        },
        diff = {
            kinds = {
                deletedFile = 'File',
                hunk = 'Namespace',
                modifiedFile = 'File',
                newFile = 'File',
            },
        },
        elixir = {
            kinds = {
                callback = 'Function',
                delegate = 'Function',
                exception = 'Class',
                guard = 'Function',
                implementation = 'Interface',
                macro = 'Function',
                protocol = 'Interface',
                record = 'Struct',
                test = 'Function',
                type = 'TypeParameter',
            },
        },
        erlang = {
            kinds = {
                macro = 'Function',
                record = 'Struct',
                type = 'TypeParameter',
            },
        },
        go = {
            kinds = {
                anonMember = 'Field',
                methodSpec = 'Method',
                package = 'Namespace',
                packageName = 'Namespace',
                talias = 'TypeParameter',
                type = 'Class',
                unknown = 'Null',
            },
        },
        html = {
            kinds = {
                anchor = 'Field',
                heading1 = 'Class',
                heading2 = 'Class',
                heading3 = 'Class',
                id = 'Field',
                script = 'File',
                stylesheet = 'File',
                title = 'Module',
            },
        },
        haskell = {
            kinds = {
                type = 'TypeParameter',
            },
        },
        java = {
            kinds = {
                annotation = 'Class',
                enumConstant = 'EnumMember',
                ['local'] = 'Variable',
                package = 'Module',
            },
        },
        javascript = {
            kinds = {
                getter = 'Method',
                setter = 'Method',
                generator = 'Function',
            },
        },
        lisp = {
            kinds = {
                generic = 'Function',
                unknown = 'Variable',
                macro = 'Function',
                parameter = 'Variable',
                type = 'TypeParameter',
            },
        },
        make = {
            kinds = {
                makefile = 'File',
                macro = 'Function',
                target = 'Method',
            },
        },
        man = {
            kinds = {
                subsection = 'Namespace',
                section = 'Module',
                title = 'Module',
            },
        },
        md = {
            kinds = {
                chapter = 'Module',
                footnote = 'Object',
                hashtag = 'Key',
                l4subsection = 'Namespace',
                l5subsection = 'Namespace',
                section = 'Module',
                subsection = 'Namespace',
                subsubsection = 'Namespace',
            },
        },
        ocaml = {
            kinds = {
                Exception = 'Class',
                RecordField = 'Field',
                type = 'TypeParameter',
                val = 'Variable',
            },
        },
        py = {
            kinds = {
                member = 'Field',
                namespace = 'Module',
                unknown = 'Variable',
            },
        },
        rust = {
            kinds = {
                enumerator = 'EnumMember',
                implementation = 'Class',
                macro = 'Function',
                typedef = 'TypeParameter',
            },
        },
        scss = {
            kinds = {
                id = 'Field',
                mixin = 'Function',
                parameter = 'Variable',
                placeholder = 'Class',
            },
        },
        sql = {
            kinds = {
                ccflag = 'Constant',
                cursor = 'Variable',
                database = 'Module',
                domain = 'TypeParameter',
                index = 'Key',
                label = 'Variable',
                mlconn = 'Module',
                mlprop = 'Property',
                mltable = 'Struct',
                package = 'Module',
                procedure = 'Function',
                publication = 'Module',
                service = 'Module',
                schema = 'Module',
                subtype = 'TypeParameter',
                synonym = 'Module',
                table = 'Struct',
                trigger = 'Event',
                view = 'Module',
            },
        },
        sh = {
            kinds = {
                alias = 'Variable',
                heredoc = 'Variable',
                script = 'File',
            },
        },
        typescript = {
            kinds = {
                alias = 'TypeParameter',
                enumerator = 'EnumMember',
                generator = 'Function',
            },
        },
        vim = {
            kinds = {
                augroup = 'Module',
                command = 'Function',
                filename = 'File',
                map = 'Variable',
            },
        },
        zsh = {
            kinds = {
                alias = 'Variable',
                heredoc = 'Variable',
                script = 'File',
            },
        },
    },
}

---@type table<string, rockyz.outline.Provider> Map from the filetype of a special buffer (i.e.,
---buftype ~= '') to its provider name
local special_filetype_providers = {
    man = 'man',
    help = 'treesitter',
}

---@param tabpage integer
---@return rockyz.outline.OutlineStatePerTab
local function ensure_state(tabpage)
    if not states[tabpage] then
        states[tabpage] = {
            bufnr = nil,
            winid = nil,
            source_bufnr = nil,
            kinds = {},
            contents = {},
            highlights = {},
            jumps = {},
            follow_cursor = false,
            timer = nil,
            request_id = 0,
        }
    end
    return states[tabpage]
end

---Ignore results from requests that no longer match the current outline state
---@param tabpage integer
---@param bufnr integer
---@param provider rockyz.outline.Provider
---@param request_id integer
---@param changedtick integer
local function is_stale(tabpage, bufnr, provider, request_id, changedtick)
    local state = states[tabpage]
    return not state
        or not state.winid
        or not vim.api.nvim_win_is_valid(state.winid)
        or bufnr ~= state.source_bufnr
        or state.provider ~= provider
        or state.request_id ~= request_id
        or not vim.api.nvim_buf_is_valid(bufnr)
        or vim.api.nvim_buf_get_changedtick(bufnr) ~= changedtick
end

---@param tabpage integer
local function create_outline_buffer(tabpage)
    local state = states[tabpage]
    if not state.bufnr or not vim.api.nvim_buf_is_valid(state.bufnr) then
        state.bufnr = vim.api.nvim_create_buf(false, true)
        vim.bo[state.bufnr].filetype = 'outline'
    end
end

---@param tabpage integer
---@param symbols rockyz.outline.FormattableSymbol[]|nil
---@param ctx? table LSP provider should provide this
local function format_symbols(tabpage, symbols, ctx)
    if symbols == nil or symbols == vim.NIL then
        return
    end

    local offset_encoding = 'utf-8'

    if ctx then
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        if not client then
            return
        end
        offset_encoding = client.offset_encoding
    end

    local state = states[tabpage]
    local provider = state.provider
    local filter_kinds = state[provider .. '_filter_kinds']

    ---@param _symbols rockyz.outline.FormattableSymbol[]
    ---@param prefix string
    local function _format_symbols(_symbols, prefix)
        for _, symbol in ipairs(_symbols) do
            local kind
            if state.provider == 'lsp' then
                kind = vim.lsp.protocol.SymbolKind[symbol.kind] or 'Unknown'
            else
                kind = symbol.kind or 'Unknown'
            end

            if filter_kinds == nil or vim.list_contains(filter_kinds or {}, kind) then
                local icon = icons.symbol_kinds[kind] or icons.symbol_kinds['Unknown']
                state.kinds[kind] = true

                -- Line that will be displayed in the outline buffer
                local line = {}
                table.insert(line, icon)
                table.insert(line, symbol.name)
                local detail
                if symbol.detail and symbol.detail ~= '' then
                    detail = string.gsub(symbol.detail, '\n', '')
                    table.insert(line, detail)
                end
                table.insert(state.contents, prefix .. table.concat(line, ' '))

                -- Necessary information to highlight the icon and symbol detail by extmarks
                local icon_col = #prefix
                local highlight = {}
                highlight.icon = {
                    kind = kind,
                    col = icon_col,
                    end_col = icon_col + #icon,
                }
                if detail then
                    local detail_col = #prefix + #icon + #symbol.name + 2
                    highlight.detail = {
                        col = detail_col,
                        end_col = detail_col + #detail,
                    }
                end
                table.insert(state.highlights, highlight)

                -- Necessary information for jump operations.
                -- * jump to the symbol in source buffer by vim.lsp.util.show_document(location, offset_encoding)
                -- * follow cursor (i.e., auto jump to the symbol in outline)
                -- * reveal (i.e., jump to the symbol in outline by a keymap)
                local range = symbol.range or (symbol.location and symbol.location.range)
                local selection_range = symbol.selectionRange or range
                if range and selection_range then
                    table.insert(state.jumps, {
                        range = range,
                        selection_range = selection_range,
                        offset_encoding = offset_encoding,
                    })
                else
                    table.insert(state.jumps, false)
                end
            end

            if symbol.children then
                _format_symbols(symbol.children, prefix .. string.rep(' ', 4))
            end
        end
    end

    _format_symbols(symbols, '')
end

---@param tabpage integer
local function apply_highlights(tabpage)
    local state = states[tabpage]
    for i, hl in ipairs(state.highlights) do
        vim.api.nvim_buf_set_extmark(state.bufnr, highlight_ns, i - 1, hl.icon.col, { end_col = hl.icon.end_col, hl_group = 'SymbolKind' .. hl.icon.kind })
        if hl.detail then
            vim.api.nvim_buf_set_extmark(state.bufnr, highlight_ns, i - 1, hl.detail.col, { end_col = hl.detail.end_col, hl_group = 'Description' })
        end
    end
end

---Set contents in the outline buffer
---@param tabpage integer
---@param contents string[]
local function set_contents(tabpage, contents)
    local state = states[tabpage]
    vim.bo[state.bufnr].modifiable = true
    vim.api.nvim_buf_clear_namespace(state.bufnr, highlight_ns, 0, -1)
    vim.api.nvim_buf_set_lines(state.bufnr, 0, -1, false, contents)
    vim.bo[state.bufnr].modifiable = false
end

-- LSP provider

---@param tabpage integer
---@param bufnr integer
---@param request_id integer
---@param changedtick integer
local function lsp_request(tabpage, bufnr, request_id, changedtick)
    local method = 'textDocument/documentSymbol'
    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':t')
    filename = filename ~= '' and filename or '[No Name]'

    local clients = vim.lsp.get_clients({ method = method, bufnr = bufnr })
    if not next(clients) then
        set_contents(tabpage, { string.format("No LSP symbols found in document '%s'", filename) })
        return
    end

    set_contents(tabpage, { string.format("Loading document symbols for '%s'%s", filename, icons.misc.ellipsis) })

    local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }
    local remaining = #clients
    local request_failed = false

    local function finish()
        remaining = remaining - 1
        if remaining ~= 0 then
            return
        end

        local state = states[tabpage]
        if not state then
            return
        end

        if request_failed and #state.contents == 0 then
            set_contents(tabpage, { string.format("Failed to request document symbols for '%s'", filename) })
            return
        end

        set_contents(tabpage, state.contents)
        apply_highlights(tabpage)
        vim.t[tabpage].outline_provider = 'LSP' -- used by winbar
    end

    for _, client in ipairs(clients) do
        local ok = client:request(method, params, function(err, result, ctx)
            if is_stale(tabpage, ctx.bufnr, 'lsp', request_id, changedtick) then
                return
            end

            if err then
                request_failed = true
            else
                format_symbols(tabpage, result, ctx)
            end
            finish()
        end, bufnr)

        if not ok then
            request_failed = true
            finish()
        end
    end
end

-- Treesitter provider
-- Highly inspired by aerial.nvim: https://github.com/stevearc/aerial.nvim/tree/master/lua/aerial/backends/treesitter

---@param start_node TSNode
---@param end_node TSNode
local function range_from_nodes(start_node, end_node)
    local sr, sc = start_node:start()
    local er, ec = end_node:end_()
    return {
        start = { line = sr, character = sc },
        ['end'] = { line = er, character = ec },
    }
end

local function node_from_match(match, path)
    local ret = ((match or {})[path] or {}).node
    if path == 'symbol' and not ret then
        -- Backwards compatibility for old @type capture
        ret = ((match or {}).type or {}).node
    end
    return ret
end

local get_parent_funcs = {
    default = function(stack, _, node)
        for i = #stack, 1, -1 do
            local last_node = stack[i].node
            if last_node == node or vim.treesitter.is_ancestor(last_node, node) then
                return stack[i].symbol, last_node, i
            else
                table.remove(stack, i)
            end
        end
        return nil, nil, 0
    end,

    help = function(stack, _, node)

        local function get_level(_node)
            local level_str = _node:type():match('^h(%d+)$')
            if level_str then
                return tonumber(level_str)
            else
                return 99
            end
        end

        -- Fix the symbol nesting
        local level = get_level(node)
        for i = #stack, 1, -1 do
            local last = stack[i]
            if get_level(last.node) < level then
                return last.symbol, last.node, i
            else
                table.remove(stack, i)
            end
        end
        return nil, nil, 0
    end,
    markdown = function(stack, match, node)
        local level_node = assert(node_from_match(match, 'level'))
        -- Parse the level out of e.g. atx_h1_marker
        local level = tonumber(string.match(level_node:type(), '%d')) - 1
        for i = #stack, 1, -1 do
            if stack[i].symbol.level < level or stack[i].node == node then
                return stack[i].symbol, stack[i].node, level
            else
                table.remove(stack, i)
            end
        end
        return nil, nil, level
    end,
    typst = function(stack, match, node)
        local level = tonumber(match.level)
        assert(level, "Missing 'level' metadata in typst query")
        for i = #stack, 1, -1 do
            if stack[i].symbol.level < level or stack[i].node == node then
                return stack[i].symbol, stack[i].node, level
            else
                table.remove(stack, i)
            end
        end
        return nil, nil, level
    end,
}
get_parent_funcs.vimdoc = get_parent_funcs.help
get_parent_funcs.tsx = get_parent_funcs.typescript

---Adjust language specific Treesitter symbols before adding them to the outline
---@type table<string, rockyz.outline.Postprocess>
local postprocess_funcs = {
    -- Resolves nested C declarators to their actual identifier
    c = function(bufnr, symbol, match)
        local root = node_from_match(match, 'root')
        if root then
            while
                root
                and not vim.tbl_contains({
                    'identifier',
                    'field_identifier',
                    'qualified_identifier',
                    'destructor_name',
                    'operator_name',
                }, root:type())
            do
                -- Search the declarator downwards until you hit the identifier
                local next = root:field('declarator')[1]
                if next ~= nil then
                    root = next
                else
                    break
                end
            end
            symbol.name = vim.treesitter.get_node_text(root, bufnr) or '<parse error>'
            if not symbol.selectionRange then
                symbol.selectionRange = range_from_nodes(root, root)
            end
        end
    end,

    -- Extends C++ function ranges to include their declarations
    cpp = function(_, symbol, match)
        if symbol.kind ~= 'Function' then
            return
        end
        local parent = node_from_match(match, 'symbol')
        local stop_types = { 'function_definition', 'declaration', 'field_declaration' }
        while parent and not vim.tbl_contains(stop_types, parent:type()) do
            parent = parent:parent()
        end
        if parent then
            for k, v in pairs(range_from_nodes(parent, parent)) do
                symbol[k] = v
            end
        end
    end,

    -- Maps Elixir constructs to LSP kinds and skips defstruct entries after making their parent
    elixir = function(bufnr, symbol, match)
        local kind_map = {
            callback = 'Function',
            def = 'Function',
            defguard = 'Function',
            defimpl = 'Class',
            defmacro = 'Function',
            defmacrop = 'Function',
            defmodule = 'Module',
            defp = 'Function',
            defprotocol = 'Interface',
            defstruct = 'Struct',
            module_attribute = 'Field',
            spec = 'TypeParameter',
        }

        local identifier = node_from_match(match, 'identifier')
        if identifier then
            local name = vim.treesitter.get_node_text(identifier, bufnr) or '<parse error>'
            if name == 'defp' then
                symbol.scope = 'private'
            end
            symbol.kind = kind_map[name] or symbol.kind
            if name == 'callback' and symbol.parent then
                symbol.parent.kind = 'Interface'
            elseif name == 'defstruct' and symbol.parent then
                symbol.parent.kind = 'Struct'
                -- Keep the parent Struct but omit the defstruct declaration itself
                return false
            elseif name == 'defimpl' then
                local protocol = assert(node_from_match(match, 'protocol'))
                local protocol_name = vim.treesitter.get_node_text(protocol, bufnr) or '<parse error>'
                symbol.name = string.format('%s > %s', symbol.name, protocol_name)
            elseif name == 'test' then
                symbol.name = string.format('test %s', symbol.name)
            elseif name == 'describe' then
                symbol.name = string.format('describe %s', symbol.name)
            end
        elseif symbol.kind == 'Constant' then
            symbol.name = string.format('@%s', symbol.name)
        end
    end,

    ---Prefixes Go method names with their receiver
    ---@note Additionally processes the following captures:
    ---      `@receiver` - extends the name to "@receiver @name"
    go = function(bufnr, symbol, match)
        local receiver = node_from_match(match, 'receiver')
        if receiver then
            local receiver_text = vim.treesitter.get_node_text(receiver, bufnr) or '<parse error>'
            symbol.name = string.format('%s %s', receiver_text, symbol.name)
        end
    end,

    -- Reconstructs complete Vim help header names and selection ranges
    help = function(bufnr, symbol, match)
        -- The name node of headers only captures the final node.
        -- We need to get _all_ word nodes
        local pieces = {}
        local node = match.name.node
        if vim.startswith(node_from_match(match, 'symbol'):type(), 'h') then
            while node and node:type() == 'word' do
                local row, col = node:start()
                table.insert(pieces, 1, vim.treesitter.get_node_text(node, bufnr))
                node = node:prev_sibling()
                if symbol.selectionRange then
                    symbol.selectionRange.start.line = row
                    symbol.selectionRange.start.character = col
                end
            end
            symbol.name = table.concat(pieces, ' ')
        end
    end,

    ---Prefixes JavaScript test and describe names with their call method
    ---@note Additionally processes the following captures:
    ---      `@method`, `@string`, and `@modifier` - replaces name with "@method[.@modifier] @string"
    javascript = function(bufnr, symbol, match)
        local method = node_from_match(match, 'method')
        local modifier = node_from_match(match, 'modifier')
        local string = node_from_match(match, 'string')
        if method and string then
            local fn = vim.treesitter.get_node_text(method, bufnr) or '<parse error>'
            if modifier then
                fn = fn .. '.' .. (vim.treesitter.get_node_text(modifier, bufnr) or '<parse error>')
            end
            local str = vim.treesitter.get_node_text(string, bufnr) or '<parse error>'
            symbol.name = fn .. ' ' .. str
        end
    end,

    -- Prefixes Lua Busted test and describe names with their call method
    lua = function(bufnr, symbol, match)
        local method = node_from_match(match, 'method')
        if method then
            local fn = vim.treesitter.get_node_text(method, bufnr) or '<parse error>'
            if fn == 'it' or fn == 'describe' then
                symbol.name = fn .. ' ' .. string.sub(symbol.name, 2, string.len(symbol.name) - 1)
            end
        end
    end,

    -- Removes leading whitespace from Markdown headings
    markdown = function(_, symbol, _)
        -- Strip leading whitespace
        local prefix = symbol.name:match('^%s*')
        if prefix ~= '' then
            symbol.name = symbol.name:sub(prefix:len() + 1)
            if symbol.selectionRange then
                symbol.selectionRange.start.character = symbol.selectionRange.start.character + prefix:len()
            end
        end
    end,

    ---Prefixes Ruby method names with their receiver and call method
    ---@note Additionally processes the following captures:
    ---      `@method`, `@receiver`, `@separator` - extends the name to "@method @receiver[@separator]@name", with @separator defaulting to "."
    ruby = function(bufnr, symbol, match)
        -- Receiver modification comes first, as we intend for it to generate a ruby-like `receiver.name`
        local receiver = node_from_match(match, 'receiver')
        local separator = node_from_match(match, 'separator')
        if receiver then
            local receiver_name = vim.treesitter.get_node_text(receiver, bufnr) or '<parse error>'
            local separator_string = separator and vim.treesitter.get_node_text(separator, bufnr) or '.'
            if receiver_name ~= symbol.name then
                symbol.name = receiver_name .. separator_string .. symbol.name
            end
        end

        -- Method modification comes last, as it's supposed to generate a global prefix
        -- akin to RSpec's "describe ClassName"
        local method = node_from_match(match, 'method')
        if method then
            local fn = vim.treesitter.get_node_text(method, bufnr) or '<parse error>'
            if fn ~= symbol.name then
                symbol.name = fn .. ' ' .. symbol.name
            end
        end
    end,

    -- Formats Rust trait implementation names
    rust = function(bufnr, symbol, match)
        if symbol.kind == 'Class' then
            local trait_node = node_from_match(match, 'trait')
            local type = assert(node_from_match(match, 'rust_type'))
            local name = vim.treesitter.get_node_text(type, bufnr) or '<parse error>'
            if trait_node then
                local trait = vim.treesitter.get_node_text(trait_node, bufnr) or '<parse error>'
                name = string.format('%s > %s', name, trait)
            end
            symbol.name = name
        end
    end,

    ---Corrects TypeScript function kinds and prefixes test and describe names
    ---@note Additionally processes the following captures:
    ---      `@method`, `@string`, and `@modifier` - replaces name with "@method[.@modifier] @string"
    typescript = function(bufnr, symbol, match)
        local value_node = node_from_match(match, 'var_type')
        if value_node then
            if value_node:type() == 'generator_function' then
                symbol.kind = 'Function'
            end
            if value_node:type() == 'arrow_function' then
                symbol.kind = 'Function'
            end
        end
        local method = node_from_match(match, 'method')
        local modifier = node_from_match(match, 'modifier')
        local string = node_from_match(match, 'string')
        if method and string then
            local fn = vim.treesitter.get_node_text(method, bufnr) or '<parse error>'
            if modifier then
                fn = fn .. '.' .. (vim.treesitter.get_node_text(modifier, bufnr) or '<parse error>')
            end
            local str = vim.treesitter.get_node_text(string, bufnr) or '<parse error>'
            symbol.name = fn .. ' ' .. str
        end
    end,

    -- Prefixes Zig test declarations with test
    zig = function(_, symbol, match)
        local node = assert(node_from_match(match, 'symbol'))
        if node:type() == 'test_declaration' then
            symbol.name = 'test ' .. symbol.name
        end
    end,
}
postprocess_funcs.cuda = postprocess_funcs.cpp
postprocess_funcs.tsx = postprocess_funcs.typescript
postprocess_funcs.vimdoc = postprocess_funcs.help

---@param lang string
---@return vim.treesitter.Query|nil query
---@return string|nil err
local function get_query(lang)
    local entry = query_cache[lang]
    if entry then
        return entry.query, entry.err
    end

    local ok, query = pcall(vim.treesitter.query.get, lang, 'outline')
    if ok then
        query_cache[lang] = { query = query }
    else
        query_cache[lang] = { err = tostring(query) }
    end

    return query_cache[lang].query, query_cache[lang].err
end

---@param bufnr integer|nil
---@return vim.treesitter.LanguageTree|nil
local function get_parser(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
    return ok and parser or nil
end

---@param bufnr integer
---@param lang string
---@param query vim.treesitter.Query
---@param syntax_tree TSTree
---@return rockyz.outline.TreeSitterSymbol[]
local function ts_build_symbols(bufnr, lang, query, syntax_tree)
    local get_parent = get_parent_funcs[lang] or get_parent_funcs.default

    local stack = {}
    local symbols = {}

    for _, matches, metadata in query:iter_matches(syntax_tree:root(), bufnr, nil, nil) do
        local match = vim.tbl_extend('force', {}, metadata)
        for id, nodes in pairs(matches) do
            local node = nodes[#nodes]
            match = vim.tbl_extend('keep', match, {
                [query.captures[id]] = {
                    metadata = metadata[id],
                    node = node,
                },
            })
        end

        local name_match = match.name or {}
        local selection_match = match.selection or {}
        local symbol_node = (match.symbol or match.type or {}).node
        if not symbol_node then
            goto continue
        end
        local start_node = (match.start or {}).node or symbol_node
        local end_node = (match['end'] or {}).node or start_node
        local parent_symbol, parent_node, level = get_parent(stack, match, symbol_node)
        -- Sometimes our queries will match the same node twice.
        -- Detect that (symbol_node == parent_node), and skip dupes.
        if symbol_node == parent_node then
            goto continue
        end
        local kind = match.kind
        if not kind then
            vim.api.nvim_echo({
                { string.format("[Outline] Missing 'kind' metadata in query file for language %s", lang) },
            }, true, { err = true })
            break
        elseif not vim.lsp.protocol.SymbolKind[kind] then
            vim.api.nvim_echo({
                { string.format("[Outline] Invalid 'kind' metadata '%s' in query file for language %s", kind, lang) },
            }, true, { err = true })
            break
        end
        local range = range_from_nodes(start_node, end_node)
        local selection_range
        if selection_match.node then
            selection_range = range_from_nodes(selection_match.node, selection_match.node)
        end
        local name
        if name_match.node then
            name = vim.treesitter.get_node_text(name_match.node, bufnr, name_match) or '<parse error>'
            if not selection_range then
                selection_range = range_from_nodes(name_match.node, name_match.node)
            end
        else
            name = '<Anonymous>'
        end

        selection_range = selection_range or range

        -- Treesitter symbol with an LSP-like shape
        local symbol = {
            kind = kind,
            name = name,
            range = range,
            selectionRange = selection_range,
            children = {},
            -- Additional field "level" used by markdown and vimdoc (help) to construct tree
            -- hierarchy
            level = level,
            -- Additional field "parent" for easily adjusting (by postprocess_func) the parent
            -- symbol based on its child
            parent = parent_symbol,
        }

        local postprocess = postprocess_funcs[lang]
        local should_include = not postprocess or postprocess(bufnr, symbol, match) ~= false

        if should_include then
            if parent_symbol then
                table.insert(parent_symbol.children, symbol)
            else
                table.insert(symbols, symbol)
            end

            table.insert(stack, {
                node = symbol_node,
                symbol = symbol,
            })
        end

        ::continue::
    end

    return symbols
end

---@param tabpage integer
---@param bufnr integer
---@param cb fun(lang: string, query: vim.treesitter.Query, syntax_tree: TSTree)
---@param request_id integer
---@param changedtick integer
local function ts_parse_tree(tabpage, bufnr, cb, request_id, changedtick)
    local parser = get_parser(bufnr)
    if not parser then
        set_contents(tabpage, { 'No parser for this buffer' })
        return
    end

    local lang = parser:lang()

    local query = get_query(lang)
    if not query then
        set_contents(tabpage, { string.format('No runtime query for %s', lang) })
        return
    end

    parser:parse(nil, function(err, syntax_trees)
        if is_stale(tabpage, bufnr, 'treesitter', request_id, changedtick) then
            return
        end
        if err then
            set_contents(tabpage, { 'Error occurred when parsing the language tree' })
            notify.error('[Outline] ' .. err)
            return
        else
            cb(lang, query, syntax_trees[1])
        end
    end)
end

---@param tabpage integer
---@param bufnr integer
---@param request_id integer
---@param changedtick integer
local function treesitter_request(tabpage, bufnr, request_id, changedtick)
    ts_parse_tree(tabpage, bufnr, function(lang, query, syntax_tree)
        local symbols = ts_build_symbols(bufnr, lang, query, syntax_tree)
        format_symbols(tabpage, symbols)
        set_contents(tabpage, states[tabpage].contents)
        apply_highlights(tabpage)
    end, request_id, changedtick)

    vim.t[tabpage].outline_provider = 'Treesitter' -- used by winbar
end

-- Ctags provider

---Convert ctags JSON entries to outline symbols
---
---symbol = {
---    name,
---    kind,
---    detail,
---    range,
---    selectionRange,
---    children,
---}
---
---@param tabpage integer
---@param text string Line-delimited JSON output of `ctags --output-format=json "--fields=*" {file}`
local function ctags_convert_symbols(tabpage, text)
    local state = states[tabpage]
    local ft = vim.bo[state.source_bufnr].filetype
    local ctags_ft_config = ctags_config.filetypes[ft] or {}

    ---@type rockyz.outline.OutlineSymbol[]
    local symbols = {}
    local tags = {}

    for line in vim.gsplit(text, '\n', { plain = true, trimempty = true }) do
        local tag = vim.json.decode(line)
        table.insert(tags, tag)
    end

    -- Sort tags by position
    table.sort(tags, function(t1, t2)
        return t1.line < t2.line
    end)

    local function ensure_child(children, name)
        for _, child in ipairs(children) do
            if child.name == name then
                return child
            end
        end
        local new = { name = name, children = {} }
        table.insert(children, new)
        return new
    end

    for _, tag in ipairs(tags) do

        -- Use tag.scope to build the hierarchical structure, i.e., the "children" field in each
        -- symbol
        local children = symbols
        if tag.scope and #tag.scope > 0 then
            local scope_parts = vim.split(tag.scope, ctags_ft_config.scope_sep or ctags_config.scope_sep, { plain = true, trimempty = true })
            for i, part in ipairs(scope_parts) do
                local child = ensure_child(children, part)
                children = child.children
                if i == #scope_parts and not child.kind then
                    child.kind = tag.scopeKind
                end
            end
        end

        local symbol = ensure_child(children, tag.name)

        -- Kind
        local symbol_kind = 'Unknown'
        if tag.kind then
            local kind = tag.kind
            symbol_kind = ctags_ft_config.kinds and ctags_ft_config.kinds[kind]
                or ctags_config.kinds[kind]
                or (kind:sub(1, 1):upper() .. kind:sub(2))
        end
        symbol.kind = symbol_kind

        -- Range and selectionRange
        local range = {
            -- Both line and character (i.e., column) are 0-indexed
            start = { line = tag.line - 1, character = 0 },
            ['end'] = { line = tag.line - 1, character = 10000 },
        }
        if tag['end'] then
            range['end'].line = tag['end'] - 1
        end
        symbol.range = range
        symbol.selectionRange = range

        symbol.access = tag.access  -- optional

        -- Detail
        local details = {}
        if tag.typeref then
            local type_name = string.gsub(tag.typeref, 'typename:', '', 1)
            table.insert(details, type_name)
        end
        if tag.signature then
            table.insert(details, tag.signature)
        end
        symbol.detail = #details > 0 and table.concat(details, ' ') or nil
    end

    return symbols
end

---@param tabpage integer
---@param bufnr integer
---@param request_id integer
---@param changedtick integer
local function ctags_request(tabpage, bufnr, request_id, changedtick)
    local on_exit = vim.schedule_wrap(function(obj)
        if is_stale(tabpage, bufnr, 'ctags', request_id, changedtick) then
            return
        end
        if obj.code ~= 0 then
            local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':t')
            set_contents(tabpage, { string.format("Error: failed to run ctags for '%s'", filename) })
            return
        end
        local symbols = ctags_convert_symbols(tabpage, obj.stdout)
        format_symbols(tabpage, symbols)
        set_contents(tabpage, states[tabpage].contents)
        apply_highlights(tabpage)
        vim.t[tabpage].outline_provider = 'Ctags' -- used by winbar
    end)

    local state = states[tabpage]
    state.contents, state.highlights, state.jumps = {}, {}, {}
    vim.system({
        'ctags',
        '--output-format=json',
        '--fields=*',
        vim.api.nvim_buf_get_name(bufnr),
    }, { text = true }, on_exit)
end

-- Man page provider

---@param lines string[] The text lines in the man page
local function man_convert_symbols(lines)
    ---@type rockyz.outline.OutlineSymbol[]
    local symbols = {}

    local last_header
    local prev_lnum = 0
    local prev_line = ''

    local function finalize_header()
        if last_header then
            last_header.range['end'].line = prev_lnum - 1
            last_header.range['end'].character = prev_line:len()
        end
    end

    for lnum, line in ipairs(lines) do
        local header = line:match('^[A-Z].+')
        local padding, arg = line:match('^(%s+)(-.+)')
        if header and lnum > 1 then
            finalize_header()
            local symbol = {
                name = header,
                kind = 'Interface',
                range = {
                    start = { line = lnum - 1, character = 0 },
                    ['end'] = { line = lnum - 1, character = 10000 },
                },
            }
            symbol.selectionRange = symbol.range
            last_header = symbol
            table.insert(symbols, symbol)
        elseif arg then
            local symbol = {
                name = arg,
                kind = 'Interface',
                range = {
                    start = { line = lnum - 1, character = padding:len() },
                    ['end'] = { line = lnum - 1, character = line:len() },
                },
            }
            symbol.selectionRange = symbol.range
            if last_header then
                last_header.children = last_header.children or {}
                table.insert(last_header.children, symbol)
            else
                table.insert(symbols, symbol)
            end
        end
        prev_lnum = lnum
        prev_line = line
    end
    finalize_header()
    return symbols
end

---@param tabpage integer
---@param bufnr integer
local function handle_man(tabpage, bufnr)
    local state = states[tabpage]
    state.contents, state.highlights, state.jumps = {}, {}, {}
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
    local symbols = man_convert_symbols(lines)
    format_symbols(tabpage, symbols)
    set_contents(tabpage, states[tabpage].contents)
    apply_highlights(tabpage)
    vim.t[tabpage].outline_provider = 'Man' -- used by winbar
end

---@param tabpage integer
---@param bufnr integer
local function request(tabpage, bufnr)
    local state = states[tabpage]
    if not state or not state.winid or not vim.api.nvim_win_is_valid(state.winid) then
        return
    end

    if not vim.api.nvim_buf_is_valid(bufnr) then
        return
    end

    state.request_id = state.request_id + 1
    local request_id = state.request_id
    local changedtick = vim.api.nvim_buf_get_changedtick(bufnr)

    state.kinds, state.contents, state.highlights, state.jumps = {}, {}, {}, {}
    if state.provider == 'lsp' then
        lsp_request(tabpage, bufnr, request_id, changedtick)
    elseif state.provider == 'treesitter' then
        treesitter_request(tabpage, bufnr, request_id, changedtick)
    elseif state.provider == 'ctags' then
        ctags_request(tabpage, bufnr, request_id, changedtick)
    elseif state.provider == 'man' then
        handle_man(tabpage, bufnr)
    end
end

-- The foldexpr used by the outline window
function M.get_fold()
    local tabpage = vim.api.nvim_get_current_tabpage()
    local state = states[tabpage]
    local shiftwidth = vim.bo[state.bufnr].shiftwidth
    if shiftwidth == 0 then
        shiftwidth = vim.bo[state.bufnr].tabstop
    end

    local function indent_level(lnum)
        return vim.fn.indent(lnum) / shiftwidth
    end

    local this_indent = indent_level(vim.v.lnum)
    local next_indent = indent_level(vim.v.lnum + 1)

    if next_indent > this_indent then
        return '>' .. next_indent
    end
    return this_indent
end

---@param tabpage integer
---@param opts table
local function select(tabpage, opts)
    local state = states[tabpage]
    if not state then
        return
    end

    local lnum = vim.fn.line('.')
    local jump = state.jumps[lnum]
    if not jump then
        return
    end

    local location = { -- lsp.Location
        uri = vim.uri_from_bufnr(state.source_bufnr),
        range = jump.selection_range,
    }

    vim.lsp.util.show_document(location, jump.offset_encoding, { reuse_win = true, focus = opts.focus })
end

---In outline reveal the symbol that is under the cursor of the source buffer
---@param tabpage integer
local function reveal_symbol(tabpage)
    local state = states[tabpage]
    if not state or not state.winid or not vim.api.nvim_win_is_valid(state.winid) then
        return
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local cursor_pos = vim.pos.cursor(bufnr, vim.api.nvim_win_get_cursor(0))
    local cursor_range = vim.range(cursor_pos, cursor_pos)
    local count = 0
    for i = #state.jumps, 1, -1 do
        local jump = state.jumps[i]
        count = count + 1

        if jump then
            local range = vim.range.lsp(state.source_bufnr, jump.range, jump.offset_encoding)
            if range:has(cursor_range) then
                vim.api.nvim_win_call(state.winid, function()
                    vim.api.nvim_win_set_cursor(state.winid, { #state.jumps - count + 1, 0 })
                end)
                return
            end
        end
    end
end

---@param tabpage integer
local function disable_follow_cursor(tabpage)
    pcall(
        vim.api.nvim_del_augroup_by_name,
        string.format('rockyz.outline.tab%s_follow_cursor', tabpage)
    )
end

---@param tabpage integer
local function enable_follow_cursor(tabpage)
    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        group = vim.api.nvim_create_augroup(
            string.format('rockyz.outline.tab%s_follow_cursor', tabpage),
            { clear = true }
        ),
        buffer = states[tabpage].source_bufnr,
        callback = function()
            if vim.api.nvim_get_current_tabpage() == tabpage then
                reveal_symbol(tabpage)
            end
        end,
    })
end

---@param tabpage integer
local function set_keymaps(tabpage)
    for key, action in pairs(config.keymaps['local']) do
        vim.keymap.set('n', key, function()
            M[action]()
        end, { buffer = states[tabpage].bufnr })
    end
    for key, action in pairs(config.keymaps.global) do
        vim.keymap.set('n', key, function()
            M[action]()
        end)
    end
end

local function del_keymaps()
    for key, _ in pairs(config.keymaps.global) do
        vim.keymap.del('n', key)
    end
end

local debounce_ms = 100

---@param state rockyz.outline.OutlineStatePerTab
local function ensure_timer(state)
    if state.timer and not state.timer:is_closing() then
        return
    end
    state.timer = vim.uv.new_timer()
end

---@param tabpage integer
---@param bufnr integer
local function debounce_request(tabpage, bufnr)
    local state = states[tabpage]
    if not state then
        return
    end

    ensure_timer(state)
    state.timer:stop()
    state.timer:start(debounce_ms, 0, vim.schedule_wrap(function()
        if states[tabpage] then
            request(tabpage, bufnr)
        end
    end))
end

---@param tabpage integer
local function autocmd_group_name(tabpage)
    return string.format('rockyz.outline.tab%s', tabpage)
end

---@param state rockyz.outline.OutlineStatePerTab
local function close_timer(state)
    if state.timer and not state.timer:is_closing() then
        state.timer:stop()
        state.timer:close()
    end
    state.timer = nil
end

---@return boolean
local function has_open_outline()
    for _, state in pairs(states) do
        if state.winid and vim.api.nvim_win_is_valid(state.winid) then
            return true
        end
    end
    return false
end

---@param tabpage integer
local function del_autocmd(tabpage)
    pcall(vim.api.nvim_del_augroup_by_name, autocmd_group_name(tabpage))
end

---@param tabpage integer
local function set_autocmd(tabpage)
    local group = vim.api.nvim_create_augroup(autocmd_group_name(tabpage), { clear = true })

    -- Refresh the outline if switching to a normal buffer, or a special buffer that has a specific
    -- provider.
    vim.api.nvim_create_autocmd({ 'LspAttach', 'BufEnter' }, {
        group = group,
        callback = function(event)
            if vim.api.nvim_get_current_tabpage() ~= tabpage then
                return
            end

            local state = states[tabpage]
            if not state or not state.winid or not vim.api.nvim_win_is_valid(state.winid) then
                return
            end

            local bufnr = event.buf
            local cur_filetype = vim.bo[bufnr].filetype
            local cur_buftype = vim.bo[bufnr].buftype
            local special_provider = special_filetype_providers[cur_filetype]
            -- Skip refreshing outline if the source buffer is a special buffer and it does not have
            -- a specific provider
            if cur_buftype ~= '' and special_provider == nil then
                return
            end

            -- Skip refreshing outline if the source buffer was switched back from a special buffer
            -- that has no specific provider and hasn't been modified. (prev_buf_state will be reset
            -- to nil upon TabEnter)
            local prev_buf_state = state.prev_buf_state or {}
            local prev_filetype, prev_buftype = prev_buf_state.filetype, prev_buf_state.buftype
            if
                next(prev_buf_state) ~= nil
                and prev_buftype ~= ''
                and special_filetype_providers[prev_filetype] == nil
                and vim.b[bufnr].last_changedtick == vim.b[bufnr].changedtick
            then
                return
            end

            -- If switching from a normal buffer to a buffer that has its specific provider, store
            -- the provider of the normal buffer for later restore.
            if prev_buftype == '' and special_provider ~= nil then
                state.prev_provider = state.provider
            end

            state.provider = special_provider or state.prev_provider or config.default_provider
            state.source_bufnr = bufnr
            create_outline_buffer(tabpage)
            debounce_request(tabpage, bufnr)
            if state.follow_cursor then
                enable_follow_cursor(tabpage)
            end
        end,
    })

    vim.api.nvim_create_autocmd({ 'BufLeave' }, {
        group = group,
        callback = function(event)
            if vim.api.nvim_get_current_tabpage() ~= tabpage then
                return
            end

            local state = states[tabpage]
            if not state then
                return
            end

            local bufnr = event.buf
            -- Before switching to another buffer, record the state of the current buffer.
            -- It's used to determine whether to refresh the outline after switching buffer. See
            -- BufEnter autocmd above.
            vim.b[bufnr].last_changedtick = vim.b[bufnr].changedtick
            state.prev_buf_state = {
                filetype = vim.bo[bufnr].filetype,
                buftype = vim.bo[bufnr].buftype,
            }
        end,
    })

    -- Update the outline upon text change in the source buffer
    vim.api.nvim_create_autocmd({ 'TextChanged' }, {
        group = group,
        callback = function(event)
            local state = states[tabpage]
            if not state
                or vim.api.nvim_get_current_tabpage() ~= tabpage
                or event.buf ~= state.source_bufnr
            then
                return
            end

            debounce_request(tabpage, event.buf)
        end,
    })

    vim.api.nvim_create_autocmd({ 'WinClosed' }, {
        group = group,
        pattern = tostring(states[tabpage].winid),
        callback = function()
            local state = states[tabpage]
            if not state then
                return
            end

            state.winid = nil
            close_timer(state)
            disable_follow_cursor(tabpage)
            del_autocmd(tabpage)
            if not has_open_outline() then
                del_keymaps()
            end
        end,
    })

end

---@param tabpage integer
---@return rockyz.outline.OutlineStatePerTab|nil
local function get_open_state(tabpage)
    local state = states[tabpage]
    if not state or not state.winid or not vim.api.nvim_win_is_valid(state.winid) then
        return
    end
    return state
end

---@param tabpage integer
local function is_opened(tabpage)
    return get_open_state(tabpage) ~= nil
end

---@param tabpage integer
local function open(tabpage)
    local state = ensure_state(tabpage)
    local bufnr = vim.api.nvim_get_current_buf()
    local ft = vim.bo[bufnr].filetype
    state.provider = special_filetype_providers[ft] or config.default_provider

    create_outline_buffer(tabpage)

    local winid = vim.api.nvim_open_win(state.bufnr, true, {
        width = config.width,
        split = 'right',
        win = -1,
        style = 'minimal',
    })

    local win_options = {
        cursorline = true,
        foldcolumn = '1',
        foldexpr = 'v:lua.require("rockyz.outline").get_fold()',
        foldmethod = 'expr',
        list = true,
        statuscolumn = '%C ',
        winfixwidth = true,
        wrap = false,
    }

    for option, value in pairs(win_options) do
        vim.wo[option] = value
    end

    state.winid = winid
    state.source_bufnr = bufnr

    vim.cmd('wincmd p')
    request(tabpage, bufnr)
    set_keymaps(tabpage)
    set_autocmd(tabpage)

    if state.follow_cursor then
        enable_follow_cursor(tabpage)
    end
end

---@param tabpage integer
local function close(tabpage)
    if states[tabpage].winid and vim.api.nvim_win_is_valid(states[tabpage].winid) then
        vim.api.nvim_win_close(states[tabpage].winid, true)
        -- autocmds will be deleted by the "WinClosed" autocmd
    end
end

---Filter symbols for the given kinds
---@param tabpage integer
---@param kinds string[] List of kinds
local function show_only(tabpage, kinds)
    local state = get_open_state(tabpage)
    if not state then
        return
    end

    local provider = state.provider
    state[provider .. '_filter_kinds'] = kinds
    debounce_request(tabpage, state.source_bufnr)
    vim.t[tabpage].filter_on = true
    vim.api.nvim__redraw({ win = state.winid, winbar = true })
end

function M.jump()
    local tabpage = vim.api.nvim_get_current_tabpage()
    select(tabpage, { focus = true })
end

function M.peek()
    local tabpage = vim.api.nvim_get_current_tabpage()
    select(tabpage, { focus = false })
end

function M.peek_prev()
    local tabpage = vim.api.nvim_get_current_tabpage()
    local cur = vim.api.nvim_win_get_cursor(0)
    cur[1] = cur[1] - 1
    pcall(vim.api.nvim_win_set_cursor, 0, cur)
    select(tabpage, { focus = false })
end

function M.peek_next()
    local tabpage = vim.api.nvim_get_current_tabpage()
    local cur = vim.api.nvim_win_get_cursor(0)
    cur[1] = cur[1] + 1
    pcall(vim.api.nvim_win_set_cursor, 0, cur)
    select(tabpage, { focus = false })
end

function M.reveal()
    local tabpage = vim.api.nvim_get_current_tabpage()
    local state = get_open_state(tabpage)
    if not state then
        return
    end

    local source_winid = vim.fn.bufwinid(state.source_bufnr)
    if source_winid == -1 then
        return
    end

    vim.api.nvim_win_call(source_winid, function()
        reveal_symbol(tabpage)
    end)
end

function M.toggle_follow()
    local tabpage = vim.api.nvim_get_current_tabpage()
    local state = get_open_state(tabpage)
    if not state then
        return
    end

    if state.follow_cursor then
        disable_follow_cursor(tabpage)
        vim.t[tabpage].is_outline_follow_cursor_enabled = false
    else
        enable_follow_cursor(tabpage)
        vim.t[tabpage].is_outline_follow_cursor_enabled = true
    end
    state.follow_cursor = not state.follow_cursor
    -- Update the statusline and winbar
    vim.api.nvim__redraw({ win = state.winid, winbar = true })
end

function M.show_functions_only()
    local tabpage = vim.api.nvim_get_current_tabpage()
    show_only(tabpage, { 'Constructor', 'Function', 'Method' })
end

function M.refresh()
    local tabpage = vim.api.nvim_get_current_tabpage()
    local state = get_open_state(tabpage)
    if not state then
        return
    end

    debounce_request(tabpage, state.source_bufnr)
end

function M.switch_to_ctags()
    local tabpage = vim.api.nvim_get_current_tabpage()
    local state = get_open_state(tabpage)
    if not state then
        return
    end

    state.provider = 'ctags'
    debounce_request(tabpage, state.source_bufnr)
end

function M.switch_to_lsp()
    local tabpage = vim.api.nvim_get_current_tabpage()
    local state = get_open_state(tabpage)
    if not state then
        return
    end

    state.provider = 'lsp'
    debounce_request(tabpage, state.source_bufnr)
end

function M.switch_to_treesitter()
    local tabpage = vim.api.nvim_get_current_tabpage()
    local state = get_open_state(tabpage)
    if not state then
        return
    end

    state.provider = 'treesitter'
    debounce_request(tabpage, state.source_bufnr)
end

function M.filter_kinds()
    local tabpage = vim.api.nvim_get_current_tabpage()
    local state = get_open_state(tabpage)
    if not state then
        return
    end

    local kinds = {}
    for kind, _ in pairs(state.kinds) do
        local icon = icons.symbol_kinds[kind] or icons.symbol_kinds['Unknown']
        table.insert(kinds, fzf.ansi(icon, 'SymbolKind' .. kind) .. ' ' .. kind)
    end

    fzf.fzf(kinds, {
        enter = function(selected_kinds)
            show_only(tabpage, selected_kinds)
        end,
    }, {
        '--prompt',
        '[Outline] Filter Kinds> ',
        '--preview-window',
        'hidden',
        '--bind',
        'ctrl-/:ignore',
        '--accept-nth',
        '2',
    })
end

function M.clear_filter()
    local tabpage = vim.api.nvim_get_current_tabpage()
    local state = get_open_state(tabpage)
    if not state then
        return
    end

    local provider = state.provider
    state[provider .. '_filter_kinds'] = nil

    debounce_request(tabpage, state.source_bufnr)

    vim.t[tabpage].filter_on = false
    vim.api.nvim__redraw({ win = state.winid, winbar = true })
end

function M.toggle_outline_window()
    local tabpage = vim.api.nvim_get_current_tabpage()
    if is_opened(tabpage) then
        close(tabpage)
    else
        open(tabpage)
    end
end

vim.keymap.set('n', config.toggle, function()
    M.toggle_outline_window()
end)

vim.api.nvim_create_autocmd({ 'VimEnter', 'TabEnter' }, {
    callback = function()
        local tabpage = vim.api.nvim_get_current_tabpage()
        ensure_state(tabpage).prev_buf_state = nil
    end,
})

vim.api.nvim_create_autocmd({ 'TabClosedPre' }, {
    callback = function()
        local tabpage = vim.api.nvim_get_current_tabpage()
        local state = states[tabpage]
        if not state then
            return
        end

        local had_outline = state.winid and vim.api.nvim_win_is_valid(state.winid)
        state.winid = nil
        close_timer(state)
        disable_follow_cursor(tabpage)
        del_autocmd(tabpage)
        states[tabpage] = nil

        if had_outline and not has_open_outline() then
            del_keymaps()
        end
    end,
})

return M
