local ElementNode = require "src.util.ElementNode"

---@param component LuaX.ElementNode
---@param container LuaX.NativeElement
---@return LuaX.NativeElement
local function create_native_element(component, container)
    local NativeElementImplementation = container:get_class()

    local component_type = component.type

    if type(component_type) ~= "string" then
        error("NativeElement cannot render non-pure component")
    end

    if component.type == ElementNode.LITERAL_NODE and NativeElementImplementation.create_literal then        
        local value = component.props.value

        return NativeElementImplementation.create_literal(value, container)
    else
        return NativeElementImplementation.create_element(component_type)
    end
end

return create_native_element