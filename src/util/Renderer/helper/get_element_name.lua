
local get_function_location = require("src.util.Renderer.helper.get_function_location")

---@param element LuaX.ElementNode | LuaX.NativeElement | nil
---@return string
local function get_element_name (element)
    if element == nil then
        return "nil"
    end

    if element.type then
        local element_type = element.type

        local t = type(element_type)

        if t == "function" then
            return "Function defined at " ..get_function_location(element_type)
        elseif t == "string" then
            return element_type
        else
            return string.format("UNKNOWN (%s %s)", t, tostring(element_type))
        end
    end

    if element.class then
        if element.get_type then
            return element:get_type()
        end

        return "UNKNOWN (NativeElement or some 30log class)"
    end

    return "UNKNOWN"
end

return get_element_name