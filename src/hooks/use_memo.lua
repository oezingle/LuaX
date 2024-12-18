local HookState  = require("src.util.HookState")
local table_equals = require("src.util.table_equals")

---@alias LuaX.UseMemoState { deps: any[], cached: any }

---@generic T
---@param callback fun(): T
---@param deps any[]
---@return T
local function use_memo(callback, deps)
    local hookstate = HookState.global()

    local index = hookstate:get_index()

    local last_value = hookstate:get_value(index) or {} --[[ @as LuaX.UseMemoState ]]
    local last_deps = last_value.deps

    local memo_value = last_value.cached

    if not table_equals(deps, last_deps) then  
        local new_value = { deps = deps }
        -- new_value.hook_name = "use_memo"
        
        -- set deps initially to prevent hook refiring
        hookstate:set_value_silent(index, new_value)

        memo_value = callback()

        new_value.cached = memo_value
        hookstate:set_value(index, new_value)
    end

    hookstate:increment()

    return memo_value
end

return use_memo
