local class = require("lib.30log")
local ipairs_with_nil = require("src.util.ipairs_with_nil")

---@alias LuaX.HookState.Listener fun(index: number, value: any)

---@class LuaX.HookState : Log.BaseFunctions
---@field index number
---@field values any[]
---@field listeners LuaX.HookState.Listener[]
---@operator call:LuaX.HookState
local HookState = class("HookState")

function HookState:init()
    self.values = {}

    self.listeners = {}

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

---@param index number
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
function HookState:modified (index, value)
    for _, listener in pairs(self.listeners) do
        listener(index, value)
    end
end

---@param listener LuaX.HookState.Listener
function HookState:add_listener(listener)
    table.insert(self.listeners, listener)
end

-- TODO serialization library would be neat
function HookState:__tostring()
    local hooks = {}

    for _, hook in ipairs_with_nil(self.values, self.index) do
        local hook_str = nil

        if type(hook) == "table" then
            local hook_values = {}

            for key, hook_value in ipairs(hook) do
                local fmt = string.format("%s=%s", key, tostring(hook_value))

                table.insert(hook_values, fmt)
            end

            hook_str = "{ " .. table.concat(hook_values, ", ") .. " }"
        else
            hook_str = tostring(hook)
        end
        
        table.insert(hooks, "\t" .. tostring(hook_str))
    end

    return string.format("HookState {\n%s\n}", table.concat(hooks, "\n"))
end

return HookState
