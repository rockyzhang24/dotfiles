local M = {}

---Execute an external command asynchronously
---@param command string|table The external command
---@param opts table opts for vim.system
---@param on_success? fun(stdout: string)
---@param on_error? fun(stderr: string, stdout: string)
function M.async(command, opts, on_success, on_error)
    opts = opts or {}
    local cmd
    if type(command) == 'string' then
        cmd = vim.split(command, ' ')
    else
        cmd = command
    end
    vim.system(cmd, opts, function(obj)
        if obj.code == 0 then
            if type(on_success) == 'function' then
                on_success(obj.stdout)
            end
        elseif type(on_error) == 'function' then
            on_error(obj.stderr, obj.stdout)
        end
    end)
end

---Execute an external command synchronously
---@param command string|table
---@param opts? table opts for vim.system
function M.sync(command, opts)
    opts = opts or {}
    local cmd
    if type(command) == 'string' then
        cmd = vim.split(command, ' ')
    else
        cmd = command
    end
    return vim.system(cmd, opts):wait()
end

return M
