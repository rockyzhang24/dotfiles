---Provide error, warning, and informational notification helpers.
---
---Each helper accepts a string or an array of lines.
---Nil and empty messages are ignored, and notifications from fast events are scheduled.

local M = {}

---Normalize and display a notification message
---@param message? string|string[]
---@param log_level integer
local function notify(message, log_level)
    if not message or message == '' or (type(message) == 'table' and #message == 0) then
        return
    end

    if type(message) == 'table' then
        local nonempty_lines = {}
        for _, line in ipairs(message) do
            if line ~= '' then
                table.insert(nonempty_lines, line)
            end
        end

        if #nonempty_lines == 0 then
            return
        end

        message = table.concat(nonempty_lines, '\n')
    end

    if vim.in_fast_event() then
        vim.schedule(function()
            vim.notify(message, log_level)
        end)
    else
        vim.notify(message, log_level)
    end
end

---Notify an error message
---@param message? string|string[]
function M.error(message)
    notify(message, vim.log.levels.ERROR)
end

---Notify a warning message
---@param message? string|string[]
function M.warn(message)
    notify(message, vim.log.levels.WARN)
end

---Notify an informational message
---@param message? string|string[]
function M.info(message)
    notify(message, vim.log.levels.INFO)
end

return M
