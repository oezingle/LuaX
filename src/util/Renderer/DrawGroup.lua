local RenderInfo = require "src.util.Renderer.RenderInfo"

---@alias LuaX.DrawGroup.OnComplete fun()
---@alias LuaX.DrawGroup.OnRestart fun()
---@alias LuaX.DrawGroup.OnError fun(err: any)

---@class LuaX.DrawGroup.Group
---@field refs integer
---@field on_error LuaX.DrawGroup.OnError
---@field on_complete LuaX.DrawGroup.OnComplete
---@field on_restart LuaX.DrawGroup.OnRestart

---@class LuaX.DrawGroup
local DrawGroup = {}

---@param on_error LuaX.DrawGroup.OnError
---@param on_complete LuaX.DrawGroup.OnComplete
---@param on_restart LuaX.DrawGroup.OnRestart
---@return LuaX.DrawGroup.Group
function DrawGroup.create(on_error, on_complete, on_restart)
    return {
        refs = 0,
        on_error = on_error,
        on_complete = on_complete,
        on_restart = on_restart,
    }
end

---@param group LuaX.DrawGroup.Group
function DrawGroup.ref(group)
    group.refs = group.refs + 1

    if group.refs <= 1 then
        group.on_restart()
    end
end

---@param group LuaX.DrawGroup.Group
function DrawGroup.unref(group)
    group.refs = group.refs - 1

    if group.refs <= 0 then
        group.on_complete()
    end
end

function DrawGroup.current()
    local info = RenderInfo.get()

    if not info then
        return nil
    end

    return info.draw_group
end

---@param group LuaX.DrawGroup.Group?
function DrawGroup.error(group, ...)
    group = group or DrawGroup.current()

    if group then
        group.on_error(...)
    else
        error(...)
    end
end

return DrawGroup
