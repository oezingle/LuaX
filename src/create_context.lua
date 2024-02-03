
---@alias LuaX.Context table

---@generic T : LuaX.Context
---@param default T?
---@return T
local function create_context (default)
    return {} or default
end