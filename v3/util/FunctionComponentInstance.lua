local class = require("lib.30log")
local HookState = require("v3.util.HookState")
local ipairs_with_nil = require("v3.util.ipairs_with_nil")

---@alias LuaX.ComponentInstance.ChangeHandler fun(element: LuaX.ElementNode | nil)

---@class LuaX.ComponentInstance : Log.BaseFunctions
---@field handlers LuaX.ComponentInstance.ChangeHandler[]
---
--- flag set for if the renderer is going to be called again, in which case returend children are ignored
---@field requests_rerender boolean
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

    self.requests_rerender = false

    self.hookstate = HookState()

    self.hookstate:add_listener(function()
        self.requests_rerender = true

        for _, handler in ipairs(self.handlers) do
            handler()
        end
    end)

    self.component = component
end

function FunctionComponentInstance:on_change(cb)
    table.insert(self.handlers, cb)
end

-- TODO FIXME use_effect unmount

-- TODO yeah cache
function FunctionComponentInstance:render(props)
    self.requests_rerender = false

    self.hookstate:reset()

    LuaX._hookstate = self.hookstate

    local component = self.component

    local element = component(props)

    LuaX._hookstate = nil

    return element
end

function FunctionComponentInstance:__gc ()
    local hooks = self.hookstate.values
    local length = self.hookstate.index

    for _, hook in ipairs_with_nil(hooks, length) do
        if hook.on_remove then
            hook.on_remove()
        end 
    end
end

return FunctionComponentInstance
