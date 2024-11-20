---@generic T
---@param context LuaX.Context<T>
---@return T
local function use_context(context) local contexts=_G.LuaX._context
return contexts[context] end
return use_context