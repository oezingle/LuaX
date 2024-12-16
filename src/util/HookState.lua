local class = require("lib.30log")
local ipairs_with_nil = require("src.util.ipairs_with_nil")
local stringify_table = require("src.util.parser.transpile.stringify_table")

---@alias LuaX.HookState.Listener fun(index: number, value: any)

---@class LuaX.HookState : Log.BaseFunctions
---@field index number
---@field values any[]
---@field listeners LuaX.HookState.Listener
---@operator call:LuaX.HookState
local HookState = class("HookState")

local no_op = function() end

function HookState:init()
    self.values = {}

    self.listener = no_op

    self.index = 1
end

function HookState:reset()
    self.index = 1
end

function HookState:get_index()
    return self.index
end

---@param index number
function HookState:set_index(index)
    self.index = index
end

function HookState:increment()
    self:set_index(self:get_index() + 1)
end

---@param index number?
function HookState:get_value(index)
    return self.values[index or self.index]
end

---@param index number
---@param value any
function HookState:set_value(index, value)
    self:set_value_silent(index, value)

    self:modified(index, value)
end

---@param index number
---@param value any
function HookState:set_value_silent(index, value)
    self.values[index] = value
end

---@param index number
---@param value any
function HookState:modified(index, value)
    self.listener(index, value)
end

---@param listener LuaX.HookState.Listener
function HookState:set_listener(listener)
    self.listener = listener
end

function HookState:__tostring()
    local hooks = {}

    local size = math.max(self.index, #self.values)

    for _, hook in ipairs_with_nil(self.values, size) do
        local hook_str = nil

        if type(hook) == "table" then
            hook_str = stringify_table(hook)
        else
            hook_str = tostring(hook)
        end

        table.insert(hooks, "\t" .. tostring(hook_str))
    end

    return string.format("HookState {\n%s\n}", table.concat(hooks, "\n"))
end

HookState.global = {}

---@overload fun(): LuaX.HookState | nil
---@param required boolean
---@return LuaX.HookState
function HookState.global.get(required)
    local hookstate = _G.LuaX._hookstate

    if required then
        -- TODO more in depth error message
        assert(hookstate, "No global hookstate!")
    end

    return hookstate
end

---@param hookstate LuaX.HookState?
---@return LuaX.HookState? last_hookstate
function HookState.global.set (hookstate)
    local last_hookstate = _G.LuaX._hookstate

    _G.LuaX._hookstate = hookstate

    return last_hookstate
end

return HookState
