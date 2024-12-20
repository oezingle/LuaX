---@generic T
---@alias LuaX.Hooks.UseContext fun(context: LuaX.Context<T>): T
---@type LuaX.Hooks.UseContext
local function use_context(context) local contexts=_G.LuaX._context
return contexts[context] end
return use_context