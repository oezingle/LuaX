local table_equals = require("src.util.table_equals")

---@alias LuaX.UseEffectState { deps: any[]?, on_remove: function? }

---@param callback fun(): function?
---@param deps any[]?
local function use_effect(callback, deps)
    local hookstate = LuaX._hookstate

    local index = hookstate:get_index()

    local old_value = hookstate:get_value(index) or {} --[[@as LuaX.UseEffectState]]
    local old_deps = old_value.deps
    local on_remove = old_value.on_remove

    if not deps or not table_equals(deps, old_deps, false) then
        -- set deps initially to prevent hook refiring
        hookstate:set_value_silent(index, { deps = deps })

        if on_remove then
            on_remove()
        end

        local callback_result = callback()

        -- this feels wrong but is performant
        hookstate:get_value(index).on_remove = callback_result
    end

    hookstate:set_index(index + 1)
end

return use_effect
