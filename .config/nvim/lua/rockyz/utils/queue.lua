-- FIFO queue implementation

local Queue = {}

Queue.__index = Queue

function Queue.new()
    local self = setmetatable({}, Queue)
    self.first = 0
    self.last = -1
    return self
end

function Queue:is_empty()
    return self.first > self.last
end

function Queue:push(value)
    self.last = self.last + 1
    self[self.last] = value
end

function Queue:pop()
    if self:is_empty() then
        return nil
    end
    local value = self[self.first]
    self[self.first] = nil
    self.first = self.first + 1
    return value
end

return Queue
