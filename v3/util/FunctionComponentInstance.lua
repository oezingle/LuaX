local class = require("lib.30log")
local HookState = require("v3.util.HookState")

---@alias LuaX.ComponentInstance.ChangeHandler fun(element: LuaX.ElementNode | nil)

---@class LuaX.ComponentInstance : Log.BaseFunctions
---@field handlers LuaX.ComponentInstance.ChangeHandler[]
---
---@field render fun(self: self, props: LuaX.Props): (LuaX.ElementNode | nil)
---@field on_change fun(self: self, cb: LuaX.ComponentInstance.ChangeHandler)
---
---@operator call:LuaX.ComponentInstance

---@class LuaX.FunctionComponentInstance : LuaX.ComponentInstance
---@field hookstate LuaX.HookState
---@field handlers LuaX.ComponentInstance.ChangeHandler[]
---@field init fun(self: self, renderer: LuaX.FunctionComponent)
---
--- Copied from ComponentInstance because lua type checker sucks
---@field on_change fun(self: self, cb: LuaX.ComponentInstance.ChangeHandler)
---@operator call: LuaX.FunctionComponentInstance
local FunctionComponentInstance = class("FunctionComponentInstance")

function FunctionComponentInstance:init(component)
    self.handlers = {}

    self.hookstate = HookState()

    self.hookstate:add_listener(function ()
        for _, handler in ipairs(self.handlers) do
            handler()
        end
    end)

    self.component = component
end

function FunctionComponentInstance:on_change(cb)
    table.insert(self.handlers, cb)
end

-- TODO on_change handlers take rendered instances

-- TODO yeah cache
function FunctionComponentInstance:render(props)
    self.hookstate:reset()

    LuaX._hookstate = self.hookstate

    local component = self.component

    local element =  component(props)

    for _, handler in ipairs(self.handlers) do
        handler(element)
    end

    LuaX._hookstate = nil

    return element
end

return FunctionComponentInstance
