
---@param component LuaX.ElementNode
---@param container LuaX.NativeElement
---@return LuaX.NativeElement
local function create_native_element(component, container)
    local NativeElementImplementation = container:get_class()

    local component_type = component.type

    if type(component_type) ~= "string" then
        error("NativeElement cannot render non-pure component")
    end

    local node = nil
    if component.type == "LITERAL_NODE" and NativeElementImplementation.create_literal then
        print(component.props.value)

        error("I need to handle literals much better.")
        
        --node = NativeElementImplementation.create_literal(component.props.value)
    else
        node = NativeElementImplementation.create_element(component_type)
    end

    return node
end

return create_native_element