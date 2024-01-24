
local class = require("lib.30log")
local LinkedList = require("v3.util.LinkedList")

---@class LuaX.WorkLoop : Log.BaseFunctions
---@field protected list_dequue fun(self: self): function
---@field protected list LinkedList<function>
---@field protected list_enqueue fun(self: self, cb: function)
---@field protected list_is_empty fun(self: self): boolean
---
--- Abstract
---@field is_running boolean
---@field add fun(self: self, cb: function)
---@field start fun(self: self) Must not crash if double-started. write yourself a guard.
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

return WorkLoop