-- 1. Define three functions notify.error, notify.warn and notify.info.
-- 2. Each accepts a string or string[] for multiline strings.
-- 3. Empty string and empty table are handled. So when invoking them somewhere, just directly
--    pass the msg string and the emptiness check is not necessary there.

local M = {}

local function handle_fast_event(msg, level)
    if not msg or msg == '' or (type(msg) == 'table' and #msg == 0) then
        return
    end
    if type(msg) == 'table' then
        local filtered = {}
        for _, m in ipairs(msg) do
            if m ~= '' then
                table.insert(filtered, m)
            end
        end
        msg = table.concat(filtered, '\n')
    end

    if vim.in_fast_event() then
        vim.schedule(function()
            vim.notify(msg, level)
        end)
    else
        vim.notify(msg, level)
    end
end


---@param msg string|string[]
function M.error(msg)
    handle_fast_event(msg, vim.log.levels.ERROR)
end

---@param msg string|string[]
function M.warn(msg)
    handle_fast_event(msg, vim.log.levels.WARN)
end

---@param msg string|string[]
function M.info(msg)
    handle_fast_event(msg, vim.log.levels.INFO)
end

return M
