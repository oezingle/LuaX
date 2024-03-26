-- TODO consider removing this file

---@nospec

local Renderer = require("src.util.Renderer")
local Profiler = require("src.util.Profiler")

---@class LuaX.ProfiledRenderer : LuaX.Renderer
---@field profiler LuaX.Profiler
---@operator call:LuaX.ProfiledRenderer
local ProfiledRenderer = Renderer:extend("ProfiledRenderer")

function ProfiledRenderer:init(workloop)
    self:set_workloop(workloop)

    ---@diagnostic disable-next-line:assign-type-mismatch
    self.profiler = Profiler()

    self.profiler:start()
end

function ProfiledRenderer:render_keyed_child(element, container, key, caller)
    -- self.calls = self.calls + 1

    ---@diagnostic disable-next-line:undefined-field
    return self.super.render_keyed_child(self, element, container, key, caller)
end

---@param filename string?
function ProfiledRenderer:dump(filename)
    self.profiler:stop()

    self.profiler:dump(filename or "callgrind.out.luax", "KCacheGrind")
end

return ProfiledRenderer
