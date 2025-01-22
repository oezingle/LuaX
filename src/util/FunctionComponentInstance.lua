
local class = require("lib.30log")
local HookState = require("src.util.HookState")
local ipairs_with_nil = require("src.util.ipairs_with_nil")
local log = require("lib.log")
local traceback = require("src.util.debug.traceback")

local get_component_name = require("src.util.debug.get_component_name")

local this_file = (...)

---@alias LuaX.ComponentInstance.ChangeHandler fun(element: LuaX.ElementNode | nil)

---@class LuaX.ComponentInstance : Log.BaseFunctions
---@field protected change_handler LuaX.ComponentInstance.ChangeHandler
---
---@field render fun(self: self, props: LuaX.Props): boolean, (LuaX.ElementNode | nil)
---@field set_on_change fun(self: self, cb: LuaX.ComponentInstance.ChangeHandler)
---
---@operator call:LuaX.ComponentInstance

---@class LuaX.FunctionComponentInstance : LuaX.ComponentInstance
---@field protected hookstate LuaX.HookState
---@field init fun(self: self, renderer: LuaX.FunctionComponent)
---
---@field rerender boolean
---
--- Copied from ComponentInstance because lua type checker sucks
---@field set_on_change fun(self: self, cb: LuaX.ComponentInstance.ChangeHandler)
---@operator call: LuaX.FunctionComponentInstance
local FunctionComponentInstance = class("FunctionComponentInstance")

local ABORT_CURRENT_RENDER = {}

function FunctionComponentInstance:init(component)
    self.friendly_name = get_component_name(component)

    log.debug("new FunctionComponentInstance " .. self.friendly_name)

    self.hookstate = HookState()

    self.hookstate:set_listener(function()
        self.rerender = true

        self.change_handler()

        -- If currently rendering this component
        if HookState.global.get() == self.hookstate then
            -- Throw ABORT_RENDER table to early quit rendering this component, and start again
            error(ABORT_CURRENT_RENDER)
        end
    end)

    self.component = component
end

function FunctionComponentInstance:set_on_change(cb)
    self.change_handler = cb
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

    local ok, res = xpcall(component, traceback, props)

    _G.LuaX._context = last_context
    HookState.global.set(last_hookstate)

    if not ok then
        local err = res --[[ @as string ]]
        -- even though err is types as a string, we can ignore that ABORT_CURRENT_RENDER isn't.
        if err ~= ABORT_CURRENT_RENDER then
            -- match everything up to 2 lines before the function. Inline, xpcall, then component.
            err = err:match("(.*)[\n\r].-[\n\r].-[\n\r].-in function '" .. this_file .. ".-'" )
            err = err:gsub("in upvalue 'chunk'", string.format("in function '%s'", self.friendly_name:match("^%S+")))

            err = "While rendering " .. self.friendly_name ..  ":\n" .. err

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
        -- TODO maybe create a HookState destructor API?

        -- hooks can sometimes be garbage collected before components - how do I protect against this?
        if type(hook) == "table" and hook.on_remove then
            hook.on_remove()
        end
    end
end

return FunctionComponentInstance
