local ComponentInstance = require "src.util.type.ComponentInstance"

---@param element Element
local function render (element)
    local component_instance = ComponentInstance(element)

    return component_instance:render()
end

return render