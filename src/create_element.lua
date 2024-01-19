
local Element = require("src.util.type.Element")

-- TODO FIXME this can't call render
-- updating props on render will come to me in a vision.

---@generic Props
---@param component Component<Props>
---@param props Component.Props
local function create_element(component, props)
    return Element(component, props)
end

return create_element
