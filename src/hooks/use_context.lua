local RenderInfo = require("src.util.Renderer.RenderInfo")

---@generic T
---@alias LuaX.Hooks.UseContext fun(context: LuaX.Context<T>): T

---@type LuaX.Hooks.UseContext
local function use_context (context)
    local info = assert(RenderInfo.get(), "Not currently rendering a component!")
    
    local contexts = assert(info.context, "Could not get contexts")

    return contexts[context] or context.default
end

return use_context