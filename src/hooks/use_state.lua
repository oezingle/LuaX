local deep_equals = require("src.util.deep_equals")
local HookState   = require("src.util.HookState")

---@alias LuaX.Hooks.UseState.Dispatch<R> fun(new_value: R | (fun(old: R): R))

---@generic T
---@alias LuaX.Hooks.UseState fun(default?: T): T, LuaX.Hooks.UseState.Dispatch<T>

---@generic T
---@param default T?
---@return T, LuaX.Hooks.UseState.Dispatch<T>
local function use_state(default)
    local hookstate = HookState.global.get(true)

    local index = hookstate:get_index()
    local state = hookstate:get_value(index)

    hookstate:increment()

    if state == nil then
        if type(default) == "function" then
            default = default()
        end

        local setter = function(new_value)
            local state = hookstate:get_value(index)

            local new_value = type(new_value) == "function" and new_value(state[1]) or new_value

            if not deep_equals(state[1], new_value, 2) then
                state[1] = new_value

                hookstate:modified(index, state)
            end
        end

        state = { default, setter }

        hookstate:set_value_silent(index, state)
    end

    return state[1], state[2]
end

return use_state
