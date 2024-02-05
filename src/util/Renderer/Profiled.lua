
--- No tests here as this class does very very very little on top of Renderer
---@nospec

local Renderer = require("src.util.Renderer")
local get_element_name = require("src.util.Renderer.helper.get_element_name")

---@class LuaX.ProfiledRenderer : LuaX.Renderer
---@field calls integer
---@operator call:LuaX.ProfiledRenderer
local ProfiledRenderer = Renderer:extend("ProfiledRenderer")

function ProfiledRenderer:init(workloop)
    self.calls = 0
    
    self:set_workloop(workloop)
end

function ProfiledRenderer:render_keyed_child(element, container, index, caller)
    self.calls = self.calls + 1

    print("Rendering", get_element_name(element))

    ---@diagnostic disable-next-line:undefined-field
    return self.super.render_keyed_child(self, element, container, index, caller)
end

return ProfiledRenderer