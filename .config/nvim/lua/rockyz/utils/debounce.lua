-- Usage:
--
--[[
local debounce = require('rockyz.utils.debounce')

local function print_hello()
    print('hello')
end

-- Create a debounced function that waits 500 ms after the last invocation
local debounced = debounce(print_hello, 500, false, true)

-- The debounced function can be used as an event callback
demo.on('event', debounced)
--]]

---@class Debounce
---@field timer? uv.uv_timer_t
---@field callback fun(...)
---@field arguments? any[]
---@field wait number
---@field leading? boolean
---@field trailing? boolean
local Debounce = {}

---@param callback fun(...)
---@param wait number The delay time (in milliseconds)
---@param leading boolean? Whether to schedule the callback without waiting on the first trigger
---@param trailing boolean? Whether to schedule the callback after the delay since the last trigger
function Debounce:new(callback, wait, leading, trailing)
    vim.validate('callback', callback, 'function')
    vim.validate('wait', wait, 'number')
    vim.validate('leading', leading, 'boolean', true)
    vim.validate('trailing', trailing, 'boolean', true)

    local instance = setmetatable({}, self)

    instance.timer = nil
    instance.callback = vim.schedule_wrap(callback)
    instance.arguments = nil
    instance.wait = wait
    instance.leading = leading
    instance.trailing = trailing

    return instance
end

function Debounce:call(...)
    local timer = self.timer
    self.arguments = {...}

    if not timer then
        timer = vim.uv.new_timer()
        self.timer = timer

        local on_timer
        if self.trailing then
            on_timer = function()
                self:flush()
            end
        else
            on_timer = function()
                self:cancel()
            end
        end
        timer:start(self.wait, self.wait, on_timer)

        if self.leading then
            self.callback(...)
        end
    else
        timer:again()
    end
end

function Debounce:cancel()
    local timer = self.timer
    if timer and not timer:is_closing() then
        timer:stop()
        timer:close()
    end
    self.timer = nil
    self.arguments = nil
end

function Debounce:flush()
    if not self.timer then
        return
    end

    local arguments = self.arguments
    self:cancel()
    self.callback(unpack(arguments))
end

Debounce.__index = Debounce
Debounce.__call = Debounce.call

return setmetatable(Debounce, {
    __call = Debounce.new
})
