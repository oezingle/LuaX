local table_equals = require("src.util.table_equals")
local HookState    = require("src.util.HookState")

---@alias LuaX.UseEffectState { deps: any[]?, on_remove: function? }

---@param callback fun(): function?
---@param deps any[]?
local function use_effect(callback, deps)
    local hookstate = HookState.global.get(true)

    local index = hookstate:get_index()

    local last_value = hookstate:get_value(index) or {} --[[@as LuaX.UseEffectState]]
    local last_deps = last_value.deps

    if not deps or not table_equals(deps, last_deps) then
        local new_value = { deps = deps }
        -- new_value.hook_name = "use_effect"

        -- set deps initially to prevent hook refiring
        hookstate:set_value_silent(index, new_value)

        if last_value.on_remove then
            last_value.on_remove()
        end

        local callback_result = callback()

        -- this feels wrong but is performant
        new_value.on_remove = callback_result
    end

    hookstate:increment()
end

return use_effect
