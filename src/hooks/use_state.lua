
local table_equals = require("src.util.table_equals")
local HookState    = require("src.util.HookState")

---@alias LuaX.Dispatch<T> T | (fun(old: T): T)

---@generic T
---@param default T?
---@return T, fun(new_value: LuaX.Dispatch<T>)
local function use_state (default)
    local hookstate = HookState.global()

    local index = hookstate:get_index()

    local value = hookstate:get_value(index)
    
    if value == nil then
        if type(default) == "function" then
            default = default()
        end

        value = default

        hookstate:set_value_silent(index, value)
    end

    -- TODO closure here supposedly is bad for performance - can it be generic at all?
    local setter = function (cb_or_new_value)
        local new_value = nil

        if type(cb_or_new_value) == "function" then
            new_value = cb_or_new_value(value)
        else
            new_value = cb_or_new_value
        end

        -- Functions cannot be accurately checked, so assume they've changed.
        -- Note that passing a function requires set_value(function () return function () ... end end)
        if type(new_value) == "function" or not table_equals(value, new_value) then
            -- modify the value we compare against
            value = new_value

            hookstate:set_value(index, new_value)
        end
    end

    hookstate:increment()

    return value, setter
end

return use_state