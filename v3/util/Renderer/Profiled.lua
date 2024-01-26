
local Renderer = require("v3.util.Renderer")

---@class LuaX.ProfiledRenderer : LuaX.Renderer
---@field calls integer
---@operator call:LuaX.ProfiledRenderer
local ProfiledRenderer = Renderer:extend("ProfiledRenderer")

function ProfiledRenderer:init(workloop)
    self.calls = 0
    
    self:set_workloop(workloop)
end

function ProfiledRenderer:render_keyed_child(element, container, index)
    self.calls = self.calls + 1

    ---@diagnostic disable-next-line:undefined-field
    return self.super.render_keyed_child(self, element, container, index)
end

return ProfiledRenderer