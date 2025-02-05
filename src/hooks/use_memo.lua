local HookState    = require("src.util.HookState")
local deep_equals  = require("src.util.deep_equals")
local table_pack   = require("src.util.polyfill.table.pack")
local table_unpack = require("src.util.polyfill.table.unpack")


---@alias LuaX.Hooks.UseMemo.State { deps: any[], cached: any }

---@generic T
---@alias LuaX.Hooks.UseMemo fun (callback: (fun(): T), deps: any[]): T

---@generic T
---@param callback fun(): T
---@param deps any[]
---@return T
local function use_memo(callback, deps)
    local hookstate = HookState.global.get(true)

    local index = hookstate:get_index()

    local last_value = hookstate:get_value(index) or {} --[[ @as LuaX.Hooks.UseMemo.State ]]
    local last_deps = last_value.deps

    local memo_value = last_value.cached

    if not deep_equals(deps, last_deps, 2) then
        local new_value = { deps = deps }
        -- new_value.hook_name = "use_memo"

        -- set deps initially to prevent hook refiring
        hookstate:set_value_silent(index, new_value)

        memo_value = table_pack(callback())

        new_value.cached = memo_value
        hookstate:set_value(index, new_value)
    end

    hookstate:increment()

    return table_unpack(memo_value)
end

return use_memo
