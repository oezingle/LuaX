local class = require("lib.30log")
local HookState = require("src.util.HookState")
local ipairs_with_nil = require("src.util.ipairs_with_nil")
local log = require("lib.log")

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

local ABORT_RENDER = {}

function FunctionComponentInstance:init(component)
    log.debug("new FunctionComponentInstance")

    self.handlers = {}

    self.requests_rerender = false

    self.props = {}

    self.hookstate = HookState()

    self.hookstate:set_listener(function()
        self.requests_rerender = true

        for _, handler in ipairs(self.handlers) do
            handler()
        end
        
        -- Throw ABORT_RENDER table to quit rendering this component, and start again
        error(ABORT_RENDER)
    end)

    self.component = component
end

function FunctionComponentInstance:on_change(cb)
    table.insert(self.handlers, cb)
end

function FunctionComponentInstance:render(props)
    self.requests_rerender = false

    self.hookstate:reset()

    -- TODO optionally use setfenv hack here to set _G.LuaX._context and _G.LuaX._hookstate for only self.component
    local last_context = _G.LuaX._context
    _G.LuaX._context = props.__luax_internal.context
    local last_hookstate = _G.LuaX._hookstate
    _G.LuaX._hookstate = self.hookstate

    local component = self.component

    local ok, res = pcall(component, props)

    _G.LuaX._context = last_context
    _G.LuaX._hookstate = last_hookstate

    if not ok then
        local err = res
        if err ~= ABORT_RENDER then
            error(err)
        end
    else
        local element = res
        return element
    end
end

function FunctionComponentInstance:cleanup () 
    local hooks = self.hookstate.values
    local length = math.max(#self.hookstate.values, self.hookstate.index)

    for _, hook in ipairs_with_nil(hooks, length) do
        -- TODO this breaks use_effect -> HookState -> FunctionComponentInstance encapsulation.
        -- hooks can sometimes be garbage collected before components - how do I protect against this?
        if type(hook) == "table" and hook.on_remove then
            hook.on_remove()
        end
    end
end

return FunctionComponentInstance
