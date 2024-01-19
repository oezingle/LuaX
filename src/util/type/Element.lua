
local class = require("lib.30log")

---@class Element<Props> : Log.BaseFunctions, { type: Component<Props>, props: Component.Props<Props> }
---@field type Component
---@field props Component.Props
local Element = class("Element")

---@param type Component
---@param props Component.Props
function Element:init(type, props)
    self.type = type
    
    self:set_props(props)
end

---@param props Component.Props
function Element:set_props(props)
    self.props = props
end

function Element:render ()

end

return Element