local M = {}

local function handle_fast_event(msg, level)
    if vim.in_fast_event() then
        vim.schedule(function()
            vim.notify(msg, level)
        end)
    else
        vim.notify(msg, level)
    end
end

function M.error(msg)
    handle_fast_event(msg, vim.log.levels.ERROR)
end

function M.warn(msg)
    handle_fast_event(msg, vim.log.levels.WARN)
end

function M.info(msg)
    handle_fast_event(msg, vim.log.levels.INFO)
end

return M
