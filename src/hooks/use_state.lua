
-- TODO would be nice if setter called before actual render somehow. (ie use_memo)

---@generic T
---@param default T?
---@return T, fun(new_value: T)
local function use_state (default)
    local hookstate = LuaX._hookstate

    local index = hookstate:get_index()

    local value = hookstate:get_value(index)
    
    if not value then
        value = default

        hookstate:set_value_silent(index, value)
    end

    -- TODO closure here supposedly is bad for performance
    -- TODO could basically building a class be faster?
    local setter = function (new_value)
        if (value ~= new_value) then
            hookstate:set_value(index, new_value)
        end
    end

    hookstate:set_index(index + 1)

    return value, setter
end

return use_state