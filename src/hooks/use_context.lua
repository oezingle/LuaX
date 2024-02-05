
-- TODO FIXME this file
---@generic T
---@param context LuaX.Context<T>
---@return T
local function use_context (context)
    local hookstate = _G.LuaX._hookstate

    return hookstate:get_context(context)
end

return use_context