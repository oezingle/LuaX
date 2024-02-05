
local Context = require("src.context.Context")

---@generic T
---@param default T?
---@return LuaX.Context<T>
local function create_context (default)
    return Context(default)
end

return create_context