-- Implement a FIFO queue.

---@class Queue
---@field private first_index integer
---@field private last_index integer
local Queue = {}

Queue.__index = Queue

---Create an empty queue.
---@return Queue
function Queue.new()
    return setmetatable({
        first_index = 1,
        last_index = 0,
    }, Queue)
end

---Return whether the queue contains no values.
---@return boolean
function Queue:is_empty()
    return self.first_index > self.last_index
end

---Append a value to the end of the queue.
---@param value any
function Queue:push(value)
    if value == nil then
        error('Queue does not support nil values')
    end

    self.last_index = self.last_index + 1
    self[self.last_index] = value
end

---Remove and return the value at the front of the queue.
---@return any?
function Queue:pop()
    if self:is_empty() then
        return nil
    end
    local value = self[self.first_index]
    self[self.first_index] = nil

    if self.first_index == self.last_index then
        self.first_index = 1
        self.last_index = 0
    else
        self.first_index = self.first_index + 1
    end

    return value
end

return Queue
