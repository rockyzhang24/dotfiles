local icons = require('rockyz.icons')
local fzf = require('rockyz.fzf')

local M = {}

---@type integer The tabid of the current tabpage
local tab

---Store the state of the outline in the current tabpage
---@class rockyz.outline.OutlineStatePerTab
---@field bufnr integer|nil The bufnr of the outline buffer
---@field win integer|nil The winid of the outline window
---@field source_bufnr integer|nil The bufnr of the source buffer
---@field kinds table<string, boolean> A set to contain unique kinds
---@field contents string[] Contents that will be displayed in outline
---@field highlights table Information to highlight the icon and detail by extmarks
---@field jumps table Information for jump operations
---@field follow_cursor boolean Whether "follow cursor" is enabled
---@field prev_buf_state table The info of the previous buffer (e.g., its buftype, filetype, etc)
---@field provider string Can be "lsp", "treesitter", "ctags" or "man" (specific for man page)
---@field prev_provider string The provider of the previous normal buffer for later restore

---Store per-tab outline state, indexed by tabid
---@type table<integer, rockyz.outline.OutlineStatePerTab>
local states = {}

local config = {
    default_provider = 'lsp',
    toggle = '\\ss',
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
            ['\\sc'] = 'toggle_follow', -- follow cursor
            ['<Leader>sr'] = 'refresh', -- update outline
            ['<Leader>sg'] = 'switch_to_ctags', -- switch to ctags provider
            ['<Leader>sl'] = 'switch_to_lsp', -- switch to LSP provider
            ['<Leader>st'] = 'switch_to_treesitter',
            ['<Leader>sf'] = 'filter_kinds',
            ['<Leader>sc'] = 'clear_filter',
        },
    }
}

-- Configurations for ctags provider
local ctags_config = {
    -- Delimiter in tag.scope, e.g., scope = "fzf.revision" for golang that means this tag is
    -- a child of tag "revision" that is the child of tag "fzf".
    -- For most languages the delimiter is '.', but for C, C++ it's '::'
    scope_sep = '.',
    -- Maps from ctags kind to LSP symbol kind (maybe not accurate)
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
                type = 'TypeAlies',
            },
        },
        erlang = {
            kinds = {
                macro = 'Function',
                record = 'Struct',
                type = 'TypeAlies',
            },
        },
        go = {
            kinds = {
                anonMember = 'Field',
                methodSpec = 'Method',
                package = 'Namespace',
                packageName = 'Namespace',
                talias = 'TypeAlies',
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

---@type table<string, string> Map from the filetype of a special buffer (i.e., buftype ~= '') to
---its provider name
local special_filetype_providers = {
    man = 'man',
    help = 'treesitter',
}

local function create_outline_buffer()
    local state = states[tab]
    if not state.bufnr or not vim.api.nvim_buf_is_valid(state.bufnr) then
        state.bufnr = vim.api.nvim_create_buf(false, true)
        vim.bo[state.bufnr].filetype = 'outline'
    end
end

---@param symbols lsp.DocumentSymbol[]
---@param ctx? table LSP provider should provide this
local function format_symbols(symbols, ctx)
    if symbols == nil then
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
    local state = states[tab]
    local provider = state.provider
    local filter_kinds = state[provider .. '_filter_kinds']

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
                table.insert(state.jumps, {
                    range = symbol.range,
                    selection_range = symbol.selectionRange,
                    offset_encoding = offset_encoding,
                })
            end

            if symbol.children then
                _format_symbols(symbol.children, prefix .. string.rep(' ', 4))
            end
        end
    end

    _format_symbols(symbols, '')
end

local function apply_highlights()
    local state = states[tab]
    local ns = vim.api.nvim_create_namespace('rockyz.outline.highlights')
    for i, hl in ipairs(state.highlights) do
        vim.api.nvim_buf_set_extmark(state.bufnr, ns, i - 1, hl.icon.col, { end_col = hl.icon.end_col, hl_group = 'SymbolKind' .. hl.icon.kind })
        if hl.detail then
            vim.api.nvim_buf_set_extmark(state.bufnr, ns, i - 1, hl.detail.col, { end_col = hl.detail.end_col, hl_group = 'Description' })
        end
    end
end

-- Set contents in the outline buffer
local function set_contents(contents)
    local state = states[tab]
    vim.bo[state.bufnr].modifiable = true
    vim.api.nvim_buf_set_lines(state.bufnr, 0, -1, false, contents)
    vim.bo[state.bufnr].modifiable = false
end

-- LSP provider

local function lsp_request(bufnr)
    local method = 'textDocument/documentSymbol'
    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':t')
    filename = filename ~= '' and filename or '[No Name]'

    local clients = vim.lsp.get_clients({ method = method, bufnr = bufnr })
    if not next(clients) then
        set_contents({ string.format("No LSP symbols found in document '%s'", filename) })
        return
    else
        set_contents({ string.format("Loading document symbols for '%s'%s", filename, icons.misc.ellipsis) })
    end
    local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }

    local remaining = #clients
    for _, client in ipairs(clients) do
        client:request(method, params, function(_, result, ctx)
            local state = states[tab]
            -- Abort if the source buffer or provider changes
            if
                not state.win
                or not vim.api.nvim_win_is_valid(state.win)
                or state.source_bufnr ~= ctx.bufnr
                or state.provider ~= 'lsp'
            then
                return
            end
            format_symbols(result, ctx)
            remaining = remaining - 1
            if remaining == 0 then
                set_contents(state.contents)
                apply_highlights()
                vim.t[tab].outline_provider = 'LSP' -- used by winbar
            end
        end)
    end
end

-- Treesitter provider
-- Highly inspired by aerial.nvim
-- (https://github.com/stevearc/aerial.nvim/tree/master/lua/aerial/backends/treesitter)

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
    default = function(stack, match, node)
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
    help = function(stack, match, node)
        local function get_level(_node)
            local level_str = _node:type():match("^h(%d+)$")
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
        local level_node = assert(node_from_match(match, "level"))
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
}
get_parent_funcs.vimdoc = get_parent_funcs.help
get_parent_funcs.tsx = get_parent_funcs.typescript

local postprocess_funcs = {
    c = function(bufnr, symbol, match)
        local root = node_from_match(match, "root")
        if root then
            while
                root
                and not vim.tbl_contains({
                    "identifier",
                    "field_identifier",
                    "qualified_identifier",
                    "destructor_name",
                    "operator_name",
                }, root:type())
            do
                -- Search the declarator downwards until you hit the identifier
                local next = root:field("declarator")[1]
                if next ~= nil then
                    root = next
                else
                    break
                end
            end
            symbol.name = vim.treesitter.get_node_text(root, bufnr) or "<parse error>"
            if not symbol.selection_range then
                symbol.selection_range = range_from_nodes(root, root)
            end
        end
    end,
    cpp = function(bufnr, symbol, match)
        if symbol.kind ~= "Function" then
            return
        end
        local parent = node_from_match(match, "symbol")
        local stop_types = { "function_definition", "declaration", "field_declaration" }
        while parent and not vim.tbl_contains(stop_types, parent:type()) do
            parent = parent:parent()
        end
        if parent then
            for k, v in pairs(range_from_nodes(parent, parent)) do
                symbol[k] = v
            end
        end
    end,
    ---@note Additionally processes the following captures:
    ---      `@receiver` - extends the name to "@receiver @name"
    go = function(bufnr, symbol, match)
        local receiver = node_from_match(match, "receiver")
        if receiver then
            local receiver_text = vim.treesitter.get_node_text(receiver, bufnr) or "<parse error>"
            symbol.name = string.format("%s %s", receiver_text, symbol.name)
        end
    end,
    help = function(bufnr, symbol, match)
        -- The name node of headers only captures the final node.
        -- We need to get _all_ word nodes
        local pieces = {}
        local node = match.name.node
        if vim.startswith(node_from_match(match, "symbol"):type(), "h") then
            while node and node:type() == "word" do
                local row, col = node:start()
                table.insert(pieces, 1, vim.treesitter.get_node_text(node, bufnr))
                node = node:prev_sibling()
                symbol.lnum = row + 1
                symbol.col = col
                if symbol.selection_range then
                    symbol.selection_range.lnum = row + 1
                    symbol.selection_range.col = col
                end
            end
            symbol.name = table.concat(pieces, " ")
        end
    end,
    ---@note Additionally processes the following captures:
    ---      `@method`, `@string`, and `@modifier` - replaces name with "@method[.@modifier] @string"
    javascript = function(bufnr, symbol, match)
        local method = node_from_match(match, "method")
        local modifier = node_from_match(match, "modifier")
        local string = node_from_match(match, "string")
        if method and string then
            local fn = vim.treesitter.get_node_text(method, bufnr) or "<parse error>"
            if modifier then
                fn = fn .. "." .. (vim.treesitter.get_node_text(modifier, bufnr) or "<parse error>")
            end
            local str = vim.treesitter.get_node_text(string, bufnr) or "<parse error>"
            symbol.name = fn .. " " .. str
        end
    end,
    lua = function(bufnr, symbol, match)
        local method = node_from_match(match, "method")
        if method then
            local fn = vim.treesitter.get_node_text(method, bufnr) or "<parse error>"
            if fn == "it" or fn == "describe" then
                symbol.name = fn .. " " .. string.sub(symbol.name, 2, string.len(symbol.name) - 1)
            end
        end
    end,
    markdown = function(bufnr, symbol, match)
        -- Strip leading whitespace
        local prefix = symbol.name:match("^%s*")
        if prefix ~= "" then
            symbol.name = symbol.name:sub(prefix:len() + 1)
            if symbol.selection_range then
                symbol.selection_range.col = symbol.selection_range.col + prefix:len()
            end
        end
    end,
    rust = function(bufnr, symbol, match)
        if symbol.kind == "Class" then
            local trait_node = node_from_match(match, "trait")
            local type = assert(node_from_match(match, "rust_type"))
            local name = vim.treesitter.get_node_text(type, bufnr) or "<parse error>"
            if trait_node then
                local trait = vim.treesitter.get_node_text(trait_node, bufnr) or "<parse error>"
                name = string.format("%s > %s", name, trait)
            end
            symbol.name = name
        end
    end,
    ---@note Additionally processes the following captures:
    ---      `@method`, `@string`, and `@modifier` - replaces name with "@method[.@modifier] @string"
    typescript = function(bufnr, symbol, match)
        local value_node = node_from_match(match, "var_type")
        if value_node then
            if value_node:type() == "generator_function" then
                symbol.kind = "Function"
            end
            if value_node:type() == "arrow_function" then
                symbol.kind = "Function"
            end
        end
        local method = node_from_match(match, "method")
        local modifier = node_from_match(match, "modifier")
        local string = node_from_match(match, "string")
        if method and string then
            local fn = vim.treesitter.get_node_text(method, bufnr) or "<parse error>"
            if modifier then
                fn = fn .. "." .. (vim.treesitter.get_node_text(modifier, bufnr) or "<parse error>")
            end
            local str = vim.treesitter.get_node_text(string, bufnr) or "<parse error>"
            symbol.name = fn .. " " .. str
        end
    end,
}
postprocess_funcs.vimdoc = postprocess_funcs.help
postprocess_funcs.tsx = postprocess_funcs.typescript

local function ts_get_symbols(bufnr)
    local ft = vim.bo[bufnr].filetype

    local ok, parser = pcall(vim.treesitter.get_parser, bufnr, ft)
    if not ok or not parser then
        return {}
    end

    local syntax_tree = parser:parse()[1]
    if not syntax_tree then
        return {}
    end

    local query = vim.treesitter.query.get(ft, 'outline')
    if not query then
        return {}
    end

    local lang = parser:lang()
    local get_parent = get_parent_funcs[ft] or get_parent_funcs.default

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

        -- LSP symbol (lsp.DocumentSymbol)
        local symbol = {
            kind = kind,
            name = name,
            range = range,
            selectionRange = selection_range,
            children = {},
            -- Additional field "level" used by markdown and vimdoc (help) to construct tree
            -- hierarchy
            level = level,
        }

        local postprocess = postprocess_funcs[ft]
        if postprocess then
            postprocess(bufnr, symbol, match)
        end

        if parent_symbol then
            table.insert(parent_symbol.children, symbol)
        else
            table.insert(symbols, symbol)
        end

        table.insert(stack, {
            node = symbol_node,
            symbol = symbol,
        })

        ::continue::
    end

    return symbols
end

local function treesitter_request(bufnr)
    local state = states[tab]
    -- Abort if the source buffer or provider changes
    if
        not state.win
        or not vim.api.nvim_win_is_valid(state.win)
        or bufnr ~= state.source_bufnr
        or state.provider ~= 'treesitter'
    then
        return
    end
    local symbols = ts_get_symbols(bufnr)
    if not symbols or not next(symbols) then
        local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':t')
        set_contents({ string.format("No Treesitter symbols found in document '%s'", filename) })
        return
    end
    format_symbols(symbols)
    set_contents(states[tab].contents)
    apply_highlights()
    vim.t[tab].outline_provider = 'Treesitter' -- used by winbar
end

-- Ctags provider

-- Convert the tag (entry in the JSON) to LSP symbol (lsp.DocumentSymbol)
-- symbol = {
--     name,
--     kind,
--     detail,
--     range,
--     selectionRange,
--     children,
-- }
---@param text string The output (JSON array) of command `ctags --output-format=json "--fields=*" {file}`
local function ctags_convert_symbols(text)
    local state = states[tab]
    local ft = vim.bo[state.source_bufnr].filetype
    local ctags_ft_config = ctags_config.filetypes[ft] or {}
    ---@type lsp.DocumentSymbol[]
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
        local lsp_kind = 'Unknown' -- default to LSP symbol kind 'Text'
        if tag.kind then
            local kind = tag.kind
            lsp_kind = ctags_ft_config.kinds and ctags_ft_config.kinds[kind]
                or ctags_config.kinds[kind]
                or (kind:sub(1, 1):upper() .. kind:sub(2))
        end
        symbol.kind = lsp_kind

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
            local type = string.gsub(tag.typeref, 'typename:', '', 1)
            table.insert(details, type)
        end
        if tag.signature then
            table.insert(details, tag.signature)
        end
        symbol.detail = #details > 0 and table.concat(details, ' ') or nil
    end

    return symbols
end

local function ctags_request(bufnr)
    local on_exit = vim.schedule_wrap(function(obj)
        local state = states[tab]
        -- Abort if the source buffer or provider changes
        if
            not state.win
            or not vim.api.nvim_win_is_valid(state.win)
            or bufnr ~= state.source_bufnr
            or state.provider ~= 'ctags'
        then
            return
        end
        if obj.code ~= 0 then
            local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':t')
            set_contents({ string.format("Error: failed to run ctags for '%s'", filename) })
            return
        end
        local symbols = ctags_convert_symbols(obj.stdout)
        format_symbols(symbols)
        set_contents(states[tab].contents)
        apply_highlights()
        vim.t[tab].outline_provider = 'Ctags' -- used by winbar
    end)

    local state = states[tab]
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
    ---@type lsp.DocumentSymbol[]
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

local function handle_man(bufnr)
    local state = states[tab]
    state.contents, state.highlights, state.jumps = {}, {}, {}
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
    local symbols = man_convert_symbols(lines)
    format_symbols(symbols)
    set_contents(states[tab].contents)
    apply_highlights()
    vim.t[tab].outline_provider = 'Man' -- used by winbar
end

local function request(bufnr)
    local state = states[tab]
    states[tab].kinds, states[tab].contents, states[tab].highlights, states[tab].jumps = {}, {}, {}, {}
    if state.provider == 'lsp' then
        lsp_request(bufnr)
    elseif state.provider == 'treesitter' then
        treesitter_request(bufnr)
    elseif state.provider == 'ctags' then
        ctags_request(bufnr)
    elseif state.provider == 'man' then
        handle_man(bufnr)
    end
end

-- The foldexpr set to the outline window
function M.get_fold()
    local function indent_level(lnum)
        return vim.fn.indent(lnum) / vim.bo[states[tab].bufnr].shiftwidth
    end
    local this_indent = indent_level(vim.v.lnum)
    local next_indent = indent_level(vim.v.lnum + 1)
    if next_indent == this_indent then
        return this_indent
    elseif next_indent < this_indent then
        return this_indent
    elseif next_indent > this_indent then
        return '>' .. next_indent
    end
end

local function select(opts)
    local state = states[tab]
    local lnum = vim.fn.line('.')
    local jump = state.jumps[lnum]
    local location = { -- lsp.Location
        uri = vim.uri_from_bufnr(state.source_bufnr),
        range = jump.range,
    }
    vim.lsp.util.show_document(location, jump.offset_encoding, { reuse_win = true, focus = opts.focus })
end

-- In outline reveal the symbol that is under the cursor of the source buffer
local function reveal_symbol()
    local state = states[tab]
    if not state.win or not vim.api.nvim_win_is_valid(state.win) then
        return
    end
    local bufnr = vim.api.nvim_get_current_buf()
    local cursor_pos = vim.pos.cursor(bufnr, vim.api.nvim_win_get_cursor(0))
    local cursor_range = vim.range(cursor_pos, cursor_pos)
    local count = 0
    for i = #state.jumps, 1, -1 do
        local jump = state.jumps[i]
        count = count + 1
        local range = vim.range.lsp(state.source_bufnr, jump.range, jump.offset_encoding)
        if range:has(cursor_range) then
            vim.api.nvim_win_call(state.win, function()
                vim.api.nvim_win_set_cursor(state.win, { #state.jumps - count + 1, 0 })
            end)
            return
        end
    end
end

local function disable_follow_cursor()
    vim.api.nvim_del_augroup_by_name(string.format('rockyz.outline.tab%s_follow_cursor', tab))
end

local function enable_follow_cursor()
    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        group = vim.api.nvim_create_augroup(string.format('rockyz.outline.tab%s_follow_cursor', tab), { clear = true }),
        buffer = states[tab].source_bufnr,
        callback = function()
            reveal_symbol()
        end,
    })
end

local function set_keymaps()
    for key, action in pairs(config.keymaps['local']) do
        vim.keymap.set('n', key, function()
            M[action]()
        end, { buffer = states[tab].bufnr })
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

local timer
local debounce_ms = 100

local function ensure_timer()
    if timer and not timer:is_closing() then
        return
    end
    timer = vim.uv.new_timer()
end

local function debounce_request(bufnr)
    ensure_timer()
    timer:stop()
    timer:start(debounce_ms, 0, vim.schedule_wrap(function()
        request(bufnr)
    end))
end

local function del_autocmd()
    vim.api.nvim_del_augroup_by_name('rockyz.outline')
end

local function set_autocmd()
    local group = vim.api.nvim_create_augroup('rockyz.outline', { clear = true })

    -- Refresh the outline if switching to a normal buffer, or a special buffer that has a specific
    -- provider.
    vim.api.nvim_create_autocmd({ 'LspAttach', 'BufEnter' }, {
        group = group,
        callback = function(event)
            local bufnr = event.buf
            local state = states[tab]
            if not state.win or not vim.api.nvim_win_is_valid(state.win) then
                return
            end
            local cur_filetype = vim.bo[bufnr].filetype
            local cur_buftype = vim.bo[bufnr].buftype
            local special_provider = special_filetype_providers[cur_filetype]
            -- Skip refreshing outline if the source buffer is a special buffer and it does not have
            -- a specific provide
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
            create_outline_buffer()
            debounce_request(bufnr)
            if state.follow_cursor then
                enable_follow_cursor()
            end
        end,
    })

    vim.api.nvim_create_autocmd({ 'BufLeave' }, {
        group = group,
        callback = function(event)
            local bufnr = event.buf
            -- Before switching to another buffer, record the state of the current buffer.
            -- It's used to determine whether to refresh the outline after switching buffer. See
            -- BufEnter autocmd above.
            vim.b[bufnr].last_changedtick = vim.b[bufnr].changedtick
            states[tab].prev_buf_state = {
                filetype = vim.bo[bufnr].filetype,
                buftype = vim.bo[bufnr].buftype,
            }
        end,
    })

    -- Update the outline upon text change in the source buffer
    vim.api.nvim_create_autocmd({ 'TextChanged' }, {
        group = group,
        buffer = states[tab].source_bufnr,
        callback = function(event)
            debounce_request(event.buf)
        end,
    })

    vim.api.nvim_create_autocmd({ 'WinClosed' }, {
        group = group,
        pattern = tostring(states[tab].win),
        callback = function()
            del_autocmd()
            del_keymaps()
        end,
    })

end

local function is_opened()
    return states[tab] and states[tab].win and vim.api.nvim_win_is_valid(states[tab].win)
end

local function open()
    local bufnr = vim.api.nvim_get_current_buf()
    local ft = vim.bo[bufnr].filetype
    states[tab].provider = special_filetype_providers[ft] or config.default_provider
    create_outline_buffer()
    local win = vim.api.nvim_open_win(states[tab].bufnr, true, {
        width = 50,
        split = 'right',
        win = -1,
        style = 'minimal',
    })
    local win_options = {
        list = true,
        wrap = false,
        foldcolumn = '1',
        statuscolumn = '%C ',
        cursorline = true,
        foldmethod = 'expr',
        foldexpr = 'v:lua.require("rockyz.outline").get_fold()',
    }
    for option, value in pairs(win_options) do
        vim.wo[option] = value
    end
    states[tab].win = win
    states[tab].source_bufnr = bufnr
    vim.cmd('wincmd p')
    request(bufnr)
    set_keymaps()
    set_autocmd()
end

local function close()
    if states[tab].win and vim.api.nvim_win_is_valid(states[tab].win) then
        vim.api.nvim_win_close(states[tab].win, true)
        -- autocmds will be deleted by the "WinClosed" autocmd
    end
end

function M.jump()
    select({ focus = true })
end

function M.peek()
    select({ focus = false })
end

function M.peek_prev()
    local cur = vim.api.nvim_win_get_cursor(0)
    cur[1] = cur[1] - 1
    pcall(vim.api.nvim_win_set_cursor, 0, cur)
    select({ focus = false })
end

function M.peek_next()
    local cur = vim.api.nvim_win_get_cursor(0)
    cur[1] = cur[1] + 1
    pcall(vim.api.nvim_win_set_cursor, 0, cur)
    select({ focus = false })
end

function M.reveal()
    local source_win = vim.fn.bufwinid(states[tab].source_bufnr)
    vim.api.nvim_win_call(source_win, function()
        reveal_symbol()
    end)
end

function M.toggle_follow()
    local state = states[tab]
    if state.follow_cursor then
        disable_follow_cursor()
        vim.t[tab].is_outline_follow_cursor_enabled = false
    else
        enable_follow_cursor()
        vim.t[tab].is_outline_follow_cursor_enabled = true
    end
    state.follow_cursor = not state.follow_cursor
    -- Update the statusline and winbar
    vim.api.nvim__redraw({ win = state.win, winbar = true })
end

function M.refresh()
    debounce_request(states[tab].source_bufnr)
end

function M.switch_to_ctags()
    local state = states[tab]
    state.provider = 'ctags'
    debounce_request(state.source_bufnr)
end

function M.switch_to_lsp()
    local state = states[tab]
    state.provider = 'lsp'
    debounce_request(state.source_bufnr)
end

function M.switch_to_treesitter()
    local state = states[tab]
    state.provider = 'treesitter'
    debounce_request(state.source_bufnr)
end

function M.filter_kinds()
    local state = states[tab]

    local function filter(selections)
        local provider = state.provider
        state[provider .. '_filter_kinds'] = selections
        debounce_request(state.source_bufnr)
        vim.t[tab].filter_on = true
    end

    local kinds = {}
    for kind, _ in pairs(state.kinds) do
        local icon = icons.symbol_kinds[kind]
        table.insert(kinds, fzf.ansi(icon, 'SymbolKind' .. kind) .. ' ' .. kind)
    end
    fzf.fzf(kinds, {
        enter = filter,
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
    local state = states[tab]
    local provider = state.provider
    state[provider .. '_filter_kinds'] = nil
    debounce_request(state.source_bufnr)
    vim.t[tab].filter_on = false
end

function M.toggle_outline_window()
    if is_opened() then
        close()
    else
        open()
    end
end

vim.keymap.set('n', config.toggle, function()
    M.toggle_outline_window()
end)

vim.api.nvim_create_autocmd({ 'VimEnter', 'TabEnter' }, {
    callback = function()
        tab = vim.api.nvim_get_current_tabpage()
        if not states[tab] then
            states[tab] = {
                bufnr = nil,
                win = nil,
                source_bufnr = nil,
                kinds = {},
                contents = {},
                highlights = {},
                jumps = {},
                follow_cursor = false,
            }
        end
        -- Reset it upon entering a tab
        states[tab].prev_buf_state = nil
    end,
})

vim.api.nvim_create_autocmd({ 'TabClosed' }, {
    callback = function(event)
        states[event.file] = nil
    end,
})

return M
