---@class CallHierarchyNode
---@field name string
---@field kind string|number
---@field detail string|nil
---@field item table
---@field expanded boolean
---@field loading boolean Whether a children request is currently in progress
--
---Whether the loading indicator should be rendered
---To avoid UI flicker, the loading icon is not shown immediately.
---It becomes visible only if the request remains in progress for more than 1 second
---@field show_loading boolean
---
---Child nodes
---
---State meanings:
---  nil   -> not loaded yet
---  {}    -> loaded, no children
---  {...} -> loaded, has children
---
---This field also acts as the children cache.
---Once loaded, children will be reused and no additional LSP request will be sent for this node.
---@field children CallHierarchyNode[]|nil

---@class CallHierarchyEntry
---@field node CallHierarchyNode
---@field depth integer

---@class CallHierarchyState
---@field win integer|nil window id of the hierarchy window
---@field buf integer|nil buffer id of the hierarchy buffer
---@field source_win integer|nil
---@field source_buf integer|nil
---@field client vim.lsp.Client|nil
---@field mode 'incoming'|'outgoing'
---@field view CallHierarchyEntry[] Flattened visible tree
---
---In-flight request sharing
---inflight[key] = callbacks
---@field inflight table<string, fun(children: CallHierarchyNode[]|nil, err?: table)[]>
---
---Number of currently running async jobs
---@field pending integer
---
---Pending async jobs waiting for executing
---@field queue fun(done: function)[]
---
---Invalidates stale async responses
---@field version integer
---
---@field ns integer
---@field root_params lsp.TextDocumentPositionParams|nil

local icons = require('rockyz.icons')
local notify = require('rockyz.utils.notify')

local M = {}

local config = {
    width = 50,
    max_concurrent = 5,
    max_expand_depth = 5,

    global_keymaps = {
        ['yoh'] = 'toggle',
        ['<Leader>hi'] = 'show_incoming_from_cursor',
        ['<Leader>ho'] = 'show_outgoing_from_cursor',
    },

    hierarchy_buf_keymaps = {
        ['za'] = 'expand',
        ['<Enter>'] = 'jump',
        ['<C-x>'] = 'jump_in_split',
        ['<C-v>'] = 'jump_in_vsplit',
        ['<C-t>'] = 'jump_in_tab',
        ['pp'] = 'peek',
        ['p<C-x>'] = 'peek_in_split',
        ['p<C-v>'] = 'peek_in_vsplit',
        ['zM'] = 'collapse_all',
        ['zR'] = 'expand_all',
        ['r'] = 'refresh',
        ['s'] = 'switch_mode',
    },
}

---Per-tabpage call hierarchy state
---@type table<integer, CallHierarchyState>
local states = {}

---@return CallHierarchyState
local function new_state()
    return {
        win = nil,
        buf = nil,
        source_win = nil,
        source_buf = nil,
        client = nil,
        mode = 'incoming',
        view = {},
        inflight = {},
        pending = 0,
        queue = {},
        version = 0,
        ns = vim.api.nvim_create_namespace('rockyz.call_hierarchy.highlights'),
        root_params = nil,
    }
end

---@return CallHierarchyState
local function get_state()
    local tab = vim.api.nvim_get_current_tabpage()
    if not states[tab] then
        states[tab] = new_state()
    end
    return states[tab]
end

---@param state CallHierarchyState
local function update_winbar(state)
    vim.t.call_hierarchy_mode = state.mode
    if state.win and vim.api.nvim_win_is_valid(state.win) then
        vim.api.nvim__redraw({ win = state.win, winbar = true })
    end
end

---@param state CallHierarchyState
---@param node CallHierarchyNode
---@return string
local function cache_key(state, node)
    local item = node.item
    local range = item.range
    return state.mode .. ':' .. item.uri .. ':' .. range.start.line .. ':' .. range.start.character
end

---@param entry CallHierarchyEntry
---@return string,table
local function render_line(entry)
    local node = entry.node
    local indent = string.rep('  ', entry.depth)
    ---@type table<string, table>
    local highlight = {}

    local disclosure_icon = node.expanded and icons.caret.down or icons.caret.right
    if node.show_loading then
        disclosure_icon = icons.misc.spinner
    end

    local prefix = indent .. disclosure_icon

    local kind = vim.lsp.protocol.SymbolKind[node.kind]
    local kind_icon = icons.symbol_kinds[kind] or icons.symbol_kinds['Unknown'] or ''

    local icon_col = #prefix + 1
    local line = prefix .. ' ' .. kind_icon .. ' ' .. node.name

    highlight.icon = {
        kind = kind,
        col = icon_col,
        end_col = icon_col + #kind_icon,
    }

    if node.detail and node.detail ~= '' then
        local detail_col = #line + 1
        line = line .. ' ' .. node.detail

        highlight.detail = {
            col = detail_col,
            end_col = detail_col + #node.detail,
        }
    end

    return line, highlight
end

---@param state CallHierarchyState
---@param value boolean
local function set_modifiable(state, value)
    if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
        vim.bo[state.buf].modifiable = value
    end
end

---@param state CallHierarchyState
---@param start integer 0-based
---@param highlights table<string, table>
local function apply_highlights(state, start, highlights)
    for i, hl in ipairs(highlights) do
        vim.api.nvim_buf_set_extmark(state.buf, state.ns, start + i - 1, hl.icon.col, {
            end_col = hl.icon.end_col,
            hl_group = 'SymbolKind' .. hl.icon.kind
        })
        if hl.detail then
            vim.api.nvim_buf_set_extmark(state.buf, state.ns, start + i - 1, hl.detail.col, {
                end_col = hl.detail.end_col,
                hl_group = 'Description'
            })
        end
    end
end

---@param state CallHierarchyState
---@param start integer 0-based
---@param finish integer 0-based exclusive
---@param entries CallHierarchyEntry[]
local function set_lines(state, start, finish, entries)
    if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
        return
    end

    local lines = {}
    local highlights = {}

    for _, entry in ipairs(entries) do
        local line, highlight = render_line(entry)
        lines[#lines + 1] = line
        highlights[#highlights + 1] = highlight
    end

    set_modifiable(state, true)
    vim.api.nvim_buf_set_lines(state.buf, start, finish, false, lines)
    set_modifiable(state, false)

    vim.api.nvim_buf_clear_namespace(state.buf, state.ns, start, start + #lines)
    apply_highlights(state, start, highlights)
end

---@param state CallHierarchyState
---@param idx integer 1-based view index
local function update_line(state, idx)
    local entry = state.view[idx]
    if not entry then
        return
    end
    set_lines(state, idx - 1, idx, { entry })
end

---Find the current index of an entry in state.view
---
---IMPORTANT:
---The argument must be the actual entry object stored in state.view. Passing a newly created table
---with identical contents will not work because lookup is based on table identity (reference
---equality).
---
---@param state CallHierarchyState
---@param entry CallHierarchyEntry
---@return integer|nil
local function find_entry_index_by_ref(state, entry)
    for i, e in ipairs(state.view) do
        if e == entry then
            return i
        end
    end
end

---@param state CallHierarchyState
---@param entry CallHierarchyEntry
local function start_loading(state, entry)
    local node = entry.node

    node.loading = true
    node.show_loading = false

    local version = state.version

    vim.defer_fn(function()
        if version ~= state.version then
            return
        end
        if not node.loading then
            return
        end

        node.show_loading = true

        local idx = find_entry_index_by_ref(state, entry)
        if idx then
            update_line(state, idx)
        end
    end, 1000)
end

---@param state CallHierarchyState
local function redraw_all(state)
    set_lines(state, 0, -1, state.view)
end

---@param state CallHierarchyState
---@return integer 1-based
local function cursor_index(state)
    return vim.api.nvim_win_get_cursor(state.win)[1]
end

---Run queued async jobs without exceeding max_concurrent
---@param state CallHierarchyState
local function run_next(state)
    while state.pending < config.max_concurrent and #state.queue > 0 do
        local job = table.remove(state.queue, 1)
        state.pending = state.pending + 1
        job(function()
            state.pending = math.max(0, state.pending - 1)
            run_next(state)
        end)
    end
end

---Add an async job to the bounce queue
---@param state CallHierarchyState
---@param fn fun(done: function)
local function enqueue(state, fn)
    state.queue[#state.queue + 1] = fn
    run_next(state)
end

---Load children for a node
---
---If children have already been loaded, the cached node.children value is returned immediately.
---Otherwise an LSP request is issued
---
---@param state CallHierarchyState
---@param node CallHierarchyNode
---@param cb fun(children: CallHierarchyNode[]|nil, err?: table)
local function load_children(state, node, cb)
    local key = cache_key(state, node)

    if node.children ~= nil then
        cb(node.children)
        return
    end

    -- Share one in-flight LSP request among multiple callers
    if state.inflight[key] then
        state.inflight[key][#state.inflight[key] + 1] = cb
        return
    end

    state.inflight[key] = { cb }

    ---@type vim.lsp.Client
    local client = state.client
    local method = state.mode == 'incoming'
        and 'callHierarchy/incomingCalls'
        or 'callHierarchy/outgoingCalls'

    local mode = state.mode
    local version = state.version
    local source_buf = state.source_buf
    local item = node.item

    enqueue(state, function(done)
        client:request(method, { item = item }, function(err, result)
            done()

            local callbacks = state.inflight[key] or {}
            state.inflight[key] = nil

            -- Drop stale responses after mode switch, close, or refresh
            if version ~= state.version then
                return
            end

            -- Error is not equivalent to empty children
            -- Do not cache errors, so the user can retry
            if err then
                for _, callback in ipairs(callbacks) do
                    callback(nil, err)
                end
                return
            end

            local children = {}

            for _, call in ipairs(result or {}) do
                local target = mode == 'incoming' and call.from or call.to

                if target then
                    children[#children + 1] = {
                        name = target.name,
                        kind = target.kind,
                        detail = target.detail,
                        item = target,
                        expanded = false,
                        loading = false,
                        show_loading = false,
                        children = nil,
                    }
                end
            end

            for _, callback in ipairs(callbacks) do
                callback(children)
            end
        end, source_buf)
    end)
end

---@param state CallHierarchyState
---@param idx integer 1-based
---@return integer 1-based exclusive
local function subtree_end(state, idx)
    local entry = state.view[idx]
    if not entry then
        return idx + 1
    end

    local base_depth = entry.depth
    local i = idx + 1

    while i <= #state.view and state.view[i].depth > base_depth do
        i = i + 1
    end

    return i
end

---@param state CallHierarchyState
---@param idx integer 1-based view index
---@param parent CallHierarchyEntry
---@param children CallHierarchyNode[]
---@return CallHierarchyEntry[]
local function insert_children(state, idx, parent, children)
    local entries = {}

    for _, child in ipairs(children) do
        entries[#entries + 1] = {
            node = child,
            depth = parent.depth + 1,
        }
    end

    for i = #entries, 1, -1 do
        table.insert(state.view, idx + 1, entries[i])
    end

    -- idx is 1-based view index. In buffer API, idx means "after current line"
    set_lines(state, idx, idx, entries)

    return entries
end

---@param state CallHierarchyState
---@param idx integer 1-based view index
local function collapse_at(state, idx)
    local entry = state.view[idx]
    if not entry then
        return
    end

    local finish = subtree_end(state, idx)

    for _ = idx + 1, finish - 1 do
        table.remove(state.view, idx + 1)
    end

    entry.node.expanded = false

    if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
        set_modifiable(state, true)
        vim.api.nvim_buf_set_lines(state.buf, idx, finish - 1, false, {})
        set_modifiable(state, false)
    end

    update_line(state, idx)
end

---@param state CallHierarchyState
---@param idx integer 1-based view index
local function expand_at(state, idx)
    local entry = state.view[idx]
    if not entry then
        return
    end

    local node = entry.node

    if node.expanded then
        collapse_at(state, idx)
        return
    end

    if node.loading then
        return
    end

    if node.children == nil then
        start_loading(state, entry)
    end

    load_children(state, node, function(children, err)
        node.loading = false
        node.show_loading = false

        local current_idx = find_entry_index_by_ref(state, entry)
        if not current_idx then
            return
        end

        if err then
            update_line(state, current_idx)
            notify.warn('[Call Hierarchy] Failed to load children')
            return
        end

        children = children or {}

        -- Idempotency guard: another callback may already have expanded it
        if node.expanded then
            return
        end

        node.children = children
        node.expanded = true

        update_line(state, current_idx)

        if #children > 0 then
            insert_children(state, current_idx, entry, children)
        end
    end)
end

---@param buf integer buffer handle
---@return vim.lsp.Client|nil
local function get_client(buf)
    local method = 'textDocument/prepareCallHierarchy'
    local clients = vim.lsp.get_clients({ method = method, bufnr = buf })
    if #clients == 0 then
        notify.warn('[Call Hierarchy] callhierarchy is not supported by the clients of the current buffer')
        return
    end
    local client
    if #clients == 1 then
        client = clients[1]
    else
        local items = {}
        for i, c in ipairs(clients) do
            table.insert(items, string.format('%d. %s', i, c.name))
        end
        table.insert(items, 'Select client: ')
        vim.ui.input({
            prompt = table.concat(items, '\n'),
        }, function(input)
            input = tonumber(input)
            if input == nil or type(input) ~= 'number' or (input == 0 or input > #clients) then
                notify.warn('[Call Hierarchy] Input to select a client is invalid')
                return
            end
            client = clients[input]
        end)
    end
    return client
end

---@param client vim.lsp.Client
---@param buf integer
local function client_attach_to_buf(client, buf)
    return client
        and not client:is_stopped()
        and client.attached_buffers
        and client.attached_buffers[buf]
end

---@param state CallHierarchyState
---@param buf integer
local function ensure_client(state, buf)
    if client_attach_to_buf(state.client, buf) then
        return state.client
    end
    local client = get_client(buf)
    if not client then
        return nil
    end
    state.client = client
    return client
end

---@param state CallHierarchyState
local function prepare_root(state)
    state.version = state.version + 1

    state.view = {}
    state.inflight = {}
    state.queue = {}

    ---@type vim.lsp.Client
    local client = state.client
    local method = 'textDocument/prepareCallHierarchy'

    if not state.root_params then
        notify.warn('[Call Hierarchy] Missing root params')
        return
    end

    local version = state.version

    client:request(method, state.root_params, function(err, result)
        if err or version ~= state.version then
            return
        end

        for _, item in ipairs(result or {}) do
            state.view[#state.view + 1] = {
                node = {
                    name = item.name,
                    kind = item.kind,
                    detail = item.detail,
                    item = item,
                    expanded = false,
                    loading = false,
                    show_loading = false,
                    children = nil,
                },
                depth = 0,
            }
        end

        redraw_all(state)

        -- Auto expand first level if single root
        if #state.view == 1 then
            vim.schedule(function()
                if version == state.version then
                    expand_at(state, 1)
                end
            end)
        end
    end, state.source_buf)
end

---Return a valid source window
---
---If the original source window was closed while the call hierarchy window is still open, create
---a new source window.
---@param state CallHierarchyState
---@return integer|nil
local function ensure_source_win(state)
    if state.source_win and vim.api.nvim_win_is_valid(state.source_win) then
        return state.source_win
    end

    if not state.win or not vim.api.nvim_win_is_valid(state.win) then
        return nil
    end

    vim.api.nvim_win_call(state.win, function()
        vim.cmd('leftabove vertical new')
        state.source_win = vim.api.nvim_get_current_win()
    end)
    vim.api.nvim_win_set_width(state.win, config.width)

    return state.source_win
end

---@param state CallHierarchyState
---@return lsp.Location|nil
local function get_current_location(state)
    local entry = state.view[cursor_index(state)]
    if not entry then
        return
    end

    local item = entry.node.item
    local range = item.selectionRange or item.range

    if not item.uri or not range then
        return
    end

    return {
        uri = item.uri,
        range = range,
    }
end

---@param state CallHierarchyState
---@param opts table|nil
local function select(state, opts)
    opts = opts or {}

    local location = get_current_location(state)

    if not location then
        return
    end

    local source_win = ensure_source_win(state)
    if not source_win or not vim.api.nvim_win_is_valid(source_win) then
        return
    end

    vim.api.nvim_win_call(source_win, function()
        vim.lsp.util.show_document(
            location,
            state.client.offset_encoding,
            { reuse_win = false, focus = true }
        )
    end)

    if opts.focus then
        vim.api.nvim_set_current_win(source_win)
    end
end

---Resolve a window to be used as the anchor for split/vsplit jumps
---
---If no normal window exists, nil is passed to the callback and the caller is expected to open
---a temporary window next to the hierarchy window.
---
---If exactly one normal window exists, it is used directly.
---
---If multiple normal windows exist, the user is prompted to choose one.
---
---The selected window is only used as a temporary anchor for the jump and does not become the
---hierarchy's source window
---
---@param state CallHierarchyState
---@param cb fun(anchor_win: integer|nil)
local function with_split_anchor_win(state, cb)
    local wins = {}

    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if
            win ~= state.win
            and vim.api.nvim_win_is_valid(win)
            and vim.api.nvim_win_get_config(win).relative == ''
        then
            wins[#wins + 1] = win
        end
    end

    if #wins == 0 then
        cb(nil)
        return
    end

    if #wins == 1 then
        cb(wins[1])
        return
    end

    vim.ui.select(wins, {
        prompt = 'Select window as split anchor: ',
        format_item = function(win)
            local buf = vim.api.nvim_win_get_buf(win)
            local name = vim.api.nvim_buf_get_name(buf)
            if name == '' then
                name = '[No Name]'
            else
                name = vim.fn.fnamemodify(name, ':t')
            end
            return string.format('win %d: %s', vim.api.nvim_win_get_number(win), name)
        end,
    }, function(win)
        cb(win)
    end)
end

---Open the item under the cursor in a split window.
---
---The split is created relatively to an anchor window chosen by with_split_anchor_win().
---
---If opts.focus is true, focus is moved to the newly created window. Otherwise the cursor remains
---in the hierarchy window, providing a peek-like experience.
---
---Unlike normal jumps, split/vsplit jumps do not update state.source_win because they are treated
---as temporary views rather than the hierarchy's primary source window.
---
---@param state CallHierarchyState
---@param cmd 'split'|'vsplit'
---@param opts table|nil
local function open_in_split_like(state, cmd, opts)
    opts = opts or {}
    local location = get_current_location(state)
    if not location then
        return
    end

    with_split_anchor_win(state, function(anchor_win)
        local split_win
        if anchor_win and vim.api.nvim_win_is_valid(anchor_win) then
            vim.api.nvim_win_call(anchor_win, function()
                vim.cmd(cmd)
                split_win = vim.api.nvim_get_current_win()
                vim.lsp.util.show_document(location, state.client.offset_encoding, {
                    reuse_win = false,
                    focus = true,
                })
            end)
        else
            -- No normal window exists. Open a temporary source window on the left of the hierarchy
            -- window. Do not update state.source_win.
            if not state.win or not vim.api.nvim_win_is_valid(state.win) then
                return
            end

            vim.api.nvim_win_call(state.win, function()
                vim.cmd('leftabove vertical new')
                split_win = vim.api.nvim_get_current_win()
                vim.lsp.util.show_document(location, state.client.offset_encoding, {
                    reuse_win = false,
                    focus = true,
                })
            end)

            vim.api.nvim_win_set_width(state.win, config.width)
        end

        if opts.focus then
            vim.api.nvim_set_current_win(split_win)
        end
    end)
end

---@param state CallHierarchyState|nil
function M.expand(state)
    state = state or get_state()
    expand_at(state, cursor_index(state))
end

---@param state CallHierarchyState|nil
function M.jump(state)
    state = state or get_state()
    select(state, { focus = true })
end

---@param state CallHierarchyState|nil
function M.jump_in_split(state)
    state = state or get_state()
    open_in_split_like(state, 'split', { focus = true })
end

---@param state CallHierarchyState|nil
function M.jump_in_vsplit(state)
    state = state or get_state()
    open_in_split_like(state, 'vsplit', { focus = true })
end

---@param state CallHierarchyState|nil
function M.jump_in_tab(state)
    state = state or get_state()

    local location = get_current_location(state)
    if not location then
        return
    end

    vim.cmd('tabnew')
    vim.lsp.util.show_document(location, state.client.offset_encoding, {
        reuse_win = false,
        focus = true,
    })
end

---@param state CallHierarchyState|nil
function M.peek(state)
    state = state or get_state()
    select(state)
end

---@param state CallHierarchyState|nil
function M.peek_in_split(state)
    state = state or get_state()
    open_in_split_like(state, 'split', { focus = false })
end

---@param state CallHierarchyState|nil
function M.peek_in_vsplit(state)
    state = state or get_state()
    open_in_split_like(state, 'vsplit', { focus = false })
end

---Collapse all visible nodes without clearing loaded children
---@param state CallHierarchyState|nil
function M.collapse_all(state)
    state = state or get_state()
    local roots = {}

    for _, entry in ipairs(state.view) do
        entry.node.expanded = false
        entry.node.loading = false
        entry.node.show_loading = false

        if entry.depth == 0 then
            roots[#roots + 1] = entry
        end
    end

    state.view = roots
    redraw_all(state)
end

---Expand all reachable nodes breadth-first
---
---Children are loaded lazily and requests are bounded by config.max_concurrent to avoid
---overwhelming the LSP server.
---
---Already loaded nodes reuse node.children directly and do not issue additional LSP requests.
---@param state CallHierarchyState|nil
function M.expand_all(state)
    state = state or get_state()
    local version = state.version

    ---@type CallHierarchyEntry
    local queue = {}

    for _, entry in ipairs(state.view) do
        queue[#queue + 1] = entry
    end

    local active = 0
    local seen = {}

    local function pump()
        if version ~= state.version then
            return
        end

        while active < config.max_concurrent and #queue > 0 do
            local entry = table.remove(queue, 1)
            local idx = find_entry_index_by_ref(state, entry)
            if not idx then
                goto continue
            end

            local node = entry.node
            local key = cache_key(state, node)

            if entry.depth >= config.max_expand_depth or seen[key] or node.loading then
                goto continue
            end

            seen[key] = true

            active = active + 1

            if node.children == nil then
                start_loading(state, entry)
            end

            load_children(state, node, function(children, err)
                active = math.max(0, active - 1)
                if version ~= state.version then
                    return
                end

                node.loading = false
                node.show_loading = false

                local current_idx = find_entry_index_by_ref(state, entry)
                if not current_idx then
                    vim.schedule(pump)
                    return
                end

                if err then
                    update_line(state, current_idx)
                    vim.schedule(pump)
                    return
                end

                children = children or {}

                -- Idempotency guard:
                -- Another callback may have already expanded this node and inserted its children
                -- while this request was in flight.
                -- Ensure that children are inserted at most once.
                if node.expanded then
                    vim.schedule(pump)
                    return
                end

                node.children = children
                node.expanded = true

                update_line(state, current_idx)

                if #children > 0 then
                    local child_entries = insert_children(state, current_idx, entry, children)
                    for _, child_entry in ipairs(child_entries) do
                        queue[#queue + 1] = child_entry
                    end
                end

                vim.schedule(pump)
            end)

            ::continue::
        end
    end

    pump()
end

-- Refresh the current call hierarchy using the original root position
---@param state CallHierarchyState|nil
function M.refresh(state)
    state = state or get_state()
    if not state.source_buf or not vim.api.nvim_buf_is_valid(state.source_buf) then
        notify.warn('[Call Hierarchy] Cannot refresh: source buffer is no longer valid')
        return
    end
    state.inflight = {}
    state.queue = {}

    prepare_root(state)
end

---@param state CallHierarchyState|nil
function M.switch_mode(state)
    state = state or get_state()
    state.mode = state.mode == 'incoming' and 'outgoing' or 'incoming'
    prepare_root(state)
    update_winbar(state)
end

---@param state CallHierarchyState
local function open(state)
    state.buf = vim.api.nvim_create_buf(false, true)
    vim.bo[state.buf].filetype = 'callhierarchy'
    state.win = vim.api.nvim_open_win(state.buf, true, {
        width = config.width,
        split = 'right',
        win = -1,
        style = 'minimal',
    })
    vim.bo[state.buf].buftype = 'nofile'
    vim.bo[state.buf].modifiable = false
    vim.wo[state.win].cursorline = true
    vim.wo[state.win].wrap = false
    vim.wo[state.win].winfixwidth = true
end

---@param state CallHierarchyState
local function close(state)
    if state.win and vim.api.nvim_win_is_valid(state.win) then
        vim.api.nvim_win_close(state.win, true)
    end
    state.win = nil
    state.buf = nil
end

---@param state CallHierarchyState
local function set_buf_keymaps(state)
    for key, action in pairs(config.hierarchy_buf_keymaps) do
        vim.keymap.set('n', key, function()
            M[action](state)
        end, { buf = state.buf, desc = '[Call Hierarchy] ' .. action })
    end
end

---Build root_params from the currently selected hierarchy item
---
---Unlike source-window reloads, this does not move the cursor or navigate to the item's location
---
---@param state CallHierarchyState
---@return boolean
local function set_root_params_from_hierarchy_cursor(state)
    local entry = state.view[cursor_index(state)]
    if not entry then
        return false
    end

    local item = entry.node.item
    local range = item.selectionRange or item.range

    if not item.uri or not range then
        return false
    end

    state.source_buf = vim.uri_to_bufnr(item.uri)
    state.root_params = {
        textDocument = {
            uri = item.uri,
        },
        position = range.start,
    }

    return true
end

---Show or reload call hierarchy
---
---When invoked from the source window, rebuild the hierarchy from the current cursor position.
---
---When invokded from the hierarchy window, rebuild the hierarchy from the currently selected
---hierarchy item.
---
---If the hierarchy window already exists, reuse it and replace the tree. Otherwise, open a new
---hierarchy window.
---
---@param state CallHierarchyState
local function show_from_cursor(state)
    local current_win = vim.api.nvim_get_current_win()
    if state.win and vim.api.nvim_win_is_valid(state.win) and current_win == state.win then
        if not set_root_params_from_hierarchy_cursor(state) then
            notify.warn('[Call Hierarchy] Cannot reload from selected hierarchy item')
            return
        end
    else
        local current_buf = vim.api.nvim_get_current_buf()

        local client = ensure_client(state, current_buf)
        if not client then
            return
        end

        state.source_win = current_win
        state.source_buf = current_buf
        state.root_params = vim.lsp.util.make_position_params(
            state.source_win,
            state.client.offset_encoding
        )

        if not state.win or not vim.api.nvim_win_is_valid(state.win) then
            open(state)
            set_buf_keymaps(state)
        end
    end

    update_winbar(state)
    prepare_root(state)
end

---@param state CallHierarchyState|nil
function M.show_incoming_from_cursor(state)
    state = state or get_state()
    state.mode = 'incoming'
    show_from_cursor(state)
end

---@param state CallHierarchyState|nil
function M.show_outgoing_from_cursor(state)
    state = state or get_state()
    state.mode = 'outgoing'
    show_from_cursor(state)
end

---@param state CallHierarchyState|nil
function M.toggle(state)
    state = state or get_state()
    if state.win and vim.api.nvim_win_is_valid(state.win) then
        close(state)
        return
    end

    show_from_cursor(state)
end

local function set_global_keymaps()
    for key, action in pairs(config.global_keymaps) do
        vim.keymap.set('n', key, function()
            M[action]()
        end, {
            desc = '[Call Hierarchy] ' .. action,
        })
    end
end

set_global_keymaps()

return M
