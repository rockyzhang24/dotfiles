-- Usage:
--
--[[

local debounce = require('rockyz.debounce')

local func = function()
    print('hello')
end

-- Create a debounced funciton that delays invoking func until after 500ms have elapsed since the
-- last time the debounced function was invoked.
local debounced = debounce(func, 500, false, true)

-- Debounced function maybe invoked repeatedly as other's callback
demo.on('event', debounced)

--]]

---@class Debounce
---@field timer userdata
---@field fn function
---@field args table
---@field wait number
---@field leading boolean?
---@field trailing boolean?
local Debounce = {}

---@param fn function
---@param wait number The delay time (in milliseconds)
---@param leading boolean? Whether the function is executed immediately on the first trigger
---@param trailing boolean? Whether the function is executed after the wait time passed since the
---last trigger
function Debounce:new(fn, wait, leading, trailing)
    vim.validate('fn', fn, 'function')
    vim.validate('wait', wait, 'number')
    vim.validate('leading', leading, 'boolean', true)
    vim.validate('trailing', trailing, 'boolean', true)
    local o = setmetatable({}, self)
    o.timer = nil
    o.fn = vim.schedule_wrap(fn)
    o.args = nil
    o.wait = wait
    o.leading = leading
    o.trailing = trailing
    return o
end

function Debounce:call(...)
    local timer = self.timer
    self.args = {...}
    if not timer then
        timer = vim.uv.new_timer()
        self.timer = timer
        local wait = self.wait
        timer:start(wait, wait, not self.trailing and function()
            self:cancel()
        end or function()
            self:flush()
        end)
        if self.leading then
            self.fn(...)
        end
    else
        timer:again()
    end
end

function Debounce:cancel()
    local timer = self.timer
    if timer then
        if timer:has_ref() then
            timer:stop()
            if not timer:is_closing() then
                timer:close()
            end
        end
        self.timer = nil
    end
end

function Debounce:flush()
    if self.timer then
        self:cancel()
        self.fn(unpack(self.args))
    end
end

Debounce.__index = Debounce
Debounce.__call = Debounce.call

return setmetatable(Debounce, {
    __call = Debounce.new
})
