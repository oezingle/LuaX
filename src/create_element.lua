local ComponentInstance = require "src.ComponentInstance"

---@param element Component
---@param props Component.Props
local function create_element(element, props)
    local rendered = ComponentInstance(element):render(props)

    return rendered
end

return create_element