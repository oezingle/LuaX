
local table_equals = require("src.util.table_equals")

---@alias LuaX.Dispatch<T> T | (fun(old: T): T)

---@generic T
---@param default T?
---@return T, fun(new_value: LuaX.Dispatch)
local function use_state (default)
    local hookstate = LuaX._hookstate

    local index = hookstate:get_index()

    local value = hookstate:get_value(index)
    
    if value == nil then
        value = default

        hookstate:set_value_silent(index, value)
    end

    -- TODO closure here supposedly is bad for performance
    -- TODO could basically building a class be faster?
    local setter = function (cb_or_new_value)
        local new_value = nil

        if type(cb_or_new_value) == "function" then
            new_value = cb_or_new_value(value)
        else
            new_value = cb_or_new_value
        end

        -- Functions cannot be accurately checked, so assume they've changed.
        if type(new_value) == "function" or not table_equals(value, new_value) then
            hookstate:set_value(index, new_value)
        end
    end

    hookstate:set_index(index + 1)

    return value, setter
end

return use_state