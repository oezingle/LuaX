
---@nospec

local ElementNode = require("src.util.ElementNode")

--- Create, but do not render, an instance of a component.
---@param component LuaX.Component | LuaX.ElementNode.LiteralNode
---@param props LuaX.Props
--- @return LuaX.ElementNode
local function create_element(component, props)
    return ElementNode.create(component, props)
end

return create_element
