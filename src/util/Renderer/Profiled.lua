--- No tests here as this class does very very very little on top of Renderer
---@nospec

local Renderer = require("src.util.Renderer")
local Profiler = require("src.util.Profiler")
local get_element_name = require("src.util.Renderer.helper.get_element_name")

---@class LuaX.ProfiledRenderer : LuaX.Renderer
-- ---@field calls integer
---@field profiler LuaX.Profiler
---@operator call:LuaX.ProfiledRenderer
local ProfiledRenderer = Renderer:extend("ProfiledRenderer")

function ProfiledRenderer:init(workloop)
    -- self.calls = 0

    self:set_workloop(workloop)

    self.profiler = Profiler()
    self.profiler:start()
end

function ProfiledRenderer:render_keyed_child(element, container, key, caller)
    -- self.calls = self.calls + 1

    -- print(get_element_name(container), "rendering", get_element_name(element), table.concat(key, " "))

    ---@diagnostic disable-next-line:undefined-field
    return self.super.render_keyed_child(self, element, container, key, caller)
end

---@param filename string?
function ProfiledRenderer:dump(filename)
    self.profiler:stop()

    self.profiler:dump(filename or "callgrind.out.luax.txt", "KCacheGrind")
end

return ProfiledRenderer
