local ElementNode = require("src.util.ElementNode")

---@param element LuaX.ElementNode
---@param container LuaX.NativeElement
---@return LuaX.NativeElement
local function create_native_element(element, container)
    local NativeElementImplementation = container:get_class()

    local element_type = element.type

    if type(element_type) ~= "string" then
        error("NativeElement cannot render non-pure component")
    end

    if ElementNode.is_literal(element) and NativeElementImplementation.create_literal then        
        local value = element.props.value

        return NativeElementImplementation.create_literal(value, container)
    else
        local elem = NativeElementImplementation.create_element(element_type)
        elem:set_render_name(element_type)

        local onload = element.props["LuaX::onload"]
        if onload then
            assert(type(onload) == "function", "LuaX::onload value must be a function")

            onload(elem:get_native(), elem)
        end

        return elem
    end
end

return create_native_element