
local class = require("lib.30log")
local HookState = require("src.util.HookState")
local ipairs_with_nil = require("src.util.ipairs_with_nil")
local log = require("lib.log")
local traceback = require("src.util.debug.traceback")

local get_component_name = require("src.util.Renderer.helper.get_component_name")

---@alias LuaX.ComponentInstance.ChangeHandler fun(element: LuaX.ElementNode | nil)

---@class LuaX.ComponentInstance : Log.BaseFunctions
---@field protected handlers LuaX.ComponentInstance.ChangeHandler[]
---
---@field render fun(self: self, props: LuaX.Props): boolean, (LuaX.ElementNode | nil)
---@field on_change fun(self: self, cb: LuaX.ComponentInstance.ChangeHandler)
---
---@operator call:LuaX.ComponentInstance

---@class LuaX.FunctionComponentInstance : LuaX.ComponentInstance
---@field protected hookstate LuaX.HookState
---@field protected handlers LuaX.ComponentInstance.ChangeHandler[]
---@field init fun(self: self, renderer: LuaX.FunctionComponent)
---
---@field rerender boolean
---
--- Copied from ComponentInstance because lua type checker sucks
---@field on_change fun(self: self, cb: LuaX.ComponentInstance.ChangeHandler)
---@operator call: LuaX.FunctionComponentInstance
local FunctionComponentInstance = class("FunctionComponentInstance")

local ABORT_CURRENT_RENDER = {}

function FunctionComponentInstance:init(component)
    self.friendly_name = get_component_name(component)

    log.debug("new FunctionComponentInstance " .. self.friendly_name)

    self.handlers = {}

    self.props = {}

    self.hookstate = HookState()

    self.hookstate:set_listener(function()
        self.rerender = true

        for _, handler in ipairs(self.handlers) do
            handler()
        end

        -- If currently rendering this component
        if HookState.global.get() == self.hookstate then
            -- Throw ABORT_RENDER table to quit rendering this component, and start again
            error(ABORT_CURRENT_RENDER)
        end
    end)

    self.component = component
end

function FunctionComponentInstance:on_change(cb)
    table.insert(self.handlers, cb)
end

function FunctionComponentInstance:render(props)
    local component = self.component

    log.debug(string.format("FunctionComponentInstance render %s", self.friendly_name))

    self.rerender = false
    self.hookstate:reset()

    -- TODO optionally use setfenv hack here to set _G.LuaX._context and _G.LuaX._hookstate for only self.component
    local last_context = _G.LuaX._context
    _G.LuaX._context = props.__luax_internal.context
    local last_hookstate = HookState.global.set(self.hookstate)


    -- TODO FIXME safe traceback
    local ok, res = xpcall(component, traceback, props)

    _G.LuaX._context = last_context
    HookState.global.set(last_hookstate)

    if not ok then
        local err = res
        if err ~= ABORT_CURRENT_RENDER then            
            error(err)
        end

        return false, nil
    else
        log.trace(string.format("render %s end. rerender=%s", self.friendly_name, self.rerender and "true" or "false"))
        
        local element = res
        
        return not self.rerender, element
    end
end

function FunctionComponentInstance:cleanup()
    log.debug("FunctionComponentInstance cleanup")

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
