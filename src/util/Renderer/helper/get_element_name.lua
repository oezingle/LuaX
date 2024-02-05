local get_function_location = require("src.util.Renderer.helper.get_function_location")

---@param component LuaX.Component
local function get_component_name(component)
    local t = type(component)

    if t == "function" then
        return "Function defined at " .. get_function_location(component)
    elseif t == "string" then
        return component
    else
        return string.format("UNKNOWN (%s %s)", t, tostring(component))
    end
end

---@param element LuaX.ElementNode | LuaX.NativeElement | LuaX.Component | nil
---@return string
local function get_element_name(element)
    if element == nil then
        return "nil"
    end

    if type(element) == "function" or type(element) == "string" then
        return get_component_name(element)
    end

    if type(element) ~= "table" then
        return string.format("UNKNOWN (type %s)", type(element))
    end

    if element.type then
        return get_component_name(element.type)
    end

    if element.class then
        if element.get_type then
            return element:get_type()
        end

        -- TODO FIXME NativeElement:issubclass() or whatever it's called

        return "UNKNOWN (NativeElement or some 30log class)"
    end

    return "UNKNOWN"
end

return get_element_name
