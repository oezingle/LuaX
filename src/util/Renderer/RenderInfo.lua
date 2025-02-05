---@class LuaX.RenderInfo.Info.Minimal
---@field key LuaX.Key
---@field container LuaX.NativeElement
---@field renderer LuaX.Renderer

---@class LuaX.RenderInfo.Info : LuaX.RenderInfo.Info.Minimal
---@field context table<LuaX.Context<any>, any>
---@field draw_group LuaX.DrawGroup.Group

---@class LuaX.RenderInfo 
---@field current LuaX.RenderInfo.Info
local RenderInfo = {}

---@param new LuaX.RenderInfo.Info.Minimal
---@param old LuaX.RenderInfo.Info?
---@return LuaX.RenderInfo.Info
function RenderInfo.inherit (new, old)
    new = new --[[ @as LuaX.RenderInfo.Info ]]
    
    old = old or RenderInfo.get()

    if not old then
        return new
    end

    -- Inherit contexts
    local old_context = old.context

    new.context = new.context or {}
    local new_context = new.context
    for k, v in pairs(old_context) do
        new_context[k] = v
    end

    -- Inherit draw group
    new.draw_group = old.draw_group

    return new
end

---@return LuaX.RenderInfo.Info
function RenderInfo.get () 
    return RenderInfo.current
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
    -- props are only set here to check for changes in render-dependent
    -- internals. Keying by int is probably faster than by string.
    props.__luax_internal = {
        info.context
    }

    return props
end

---@param info LuaX.RenderInfo.Info
---@return LuaX.RenderInfo.Info
function RenderInfo.clone (info)
    local ret = {}
    for k,v in pairs(info) do
        ret[k] = v
    end
    return ret
end

--[[
--- Retrieve render info from props
---@return LuaX.RenderInfo.Info
function RenderInfo.retrieve(props)
    return props.__luax_internal
end
]]

return RenderInfo