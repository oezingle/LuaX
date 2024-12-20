
local use_state = require("src.hooks.use_state")

---@generic T
---@alias LuaX.Hooks.UseRef fun(default: T?): { current: T }

---@generic T
---@param default T?
---@return { current: T }
local function use_ref(default)
    -- use_state inserts to hookstate for us, why reinvent the wheel?
    local ref = use_state({ current = default })

    return ref
end

return use_ref