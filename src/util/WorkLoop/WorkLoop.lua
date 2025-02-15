local class = require("lib.30log")
local LinkedList = require("src.util.LinkedList")

-- TODO FIXME drop outside LinkedList dependency.
-- https://stackoverflow.com/questions/18843610/fast-implementation-of-queues-in-lua

-- TODO better name for this class?
-- TODO interact with a RenderState.DrawObserver object if it exists
-- - empty workloop -> DrawObserver.handle_complete
-- - error (FunctionComponentInstance) -> DrawObserver.handle_error
-- - id = DrawObserver.push({ complete, error }) -> add both to weak list
-- - DrawObserver.pop(id) -> kill listeners (likely to go unused)

---@class LuaX.WorkLoop : Log.BaseFunctions
---@field protected list_dequue fun(self: self): function
---@field protected list LinkedList<function>
---@field protected list_enqueue fun(self: self, cb: function)
---@field protected list_is_empty fun(self: self): boolean
---@field protected run_once fun(self: self)
---
--- Abstract
---@field protected is_running boolean
---@field protected stop fun(self: self)
---@field protected start fun(self: self)
---@field safe_start fun(self: self)
---
--- Abstract optional
---@field add fun(self: self, cb: function)
local WorkLoop = class("WorkLoop")

function WorkLoop:init()
    self.list = LinkedList()
end

function WorkLoop:list_dequue()
    return self.list:dequeue()
end

function WorkLoop:list_enqueue(cb)
    self.list:enqueue(cb)
end

function WorkLoop:list_is_empty()
    return self.list:is_empty()
end

function WorkLoop:add(cb)
    self:list_enqueue(cb)
end

function WorkLoop:stop ()
    self.is_running = false
end

function WorkLoop:run_once()
    if self:list_is_empty() then
        self:stop()
        return
    end

    local cb = self:list_dequue()

    --[[
    self.current = Promise(function (res)

    end)
    ]]

    cb()
end

function WorkLoop:safely_start ()
    if self.is_running then
        return
    end

    self.is_running = true

    self:start()
end

return WorkLoop