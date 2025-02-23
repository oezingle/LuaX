
-- TODO provide an implementation using a setfenv hack

---@class LuaX.RenderInfo.Info
---@field context table<LuaX.Context<any>, any>

---@class LuaX.RenderInfo 
---@field current LuaX.RenderInfo.Info
local RenderInfo = {}

---@param new LuaX.RenderInfo.Info
---@param old LuaX.RenderInfo.Info?
---@return LuaX.RenderInfo.Info
function RenderInfo.inherit (new, old)
    old = old or RenderInfo.get()

    if not old then
        return new
    end

    -- Inherit contexts
    local old_context = old.context
    local new_context = new.context
    for k, v in pairs(old_context) do
        new_context[k] = v
    end

    return new
end

---@return LuaX.RenderInfo.Info
function RenderInfo.get () 
    return RenderInfo.current or {
        context = {}
    }
end

---@param info LuaX.RenderInfo.Info
function RenderInfo.set (info)
    local old = RenderInfo.get()

    RenderInfo.current = info

    return old
end

--- Bind Render info to props
---@param props LuaX.Props
---@param info LuaX.RenderInfo.Info
---@return LuaX.Props.WithInternal
function RenderInfo.bind(props, info)
    props.__luax_internal = info

    return props
end

--- Retrieve render info from props
---@return LuaX.RenderInfo.Info
function RenderInfo.retrieve(props)
    return props.__luax_internal
end

return RenderInfo