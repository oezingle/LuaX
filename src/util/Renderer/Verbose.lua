--- No tests here as this class does very very very little on top of Renderer
---@nospec

local Renderer = require("src.util.Renderer")
local get_element_name = require("src.util.Renderer.helper.get_element_name")

---@class LuaX.VerboseRenderer : LuaX.Renderer
---@operator call:LuaX.VerboseRenderer
local VerboseRenderer = Renderer:extend("VerboseRenderer")

function VerboseRenderer:init(workloop)
    self:set_workloop(workloop)
end

function VerboseRenderer:render_keyed_child(element, container, key, caller)
    print(get_element_name(container), "rendering", get_element_name(element), table.concat(key, " "))

    ---@diagnostic disable-next-line:undefined-field
    return self.super.render_keyed_child(self, element, container, key, caller)
end

return VerboseRenderer
