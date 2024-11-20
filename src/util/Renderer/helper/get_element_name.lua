local get_function_location = require("src.util.Renderer.helper.get_function_location")
local get_function_name     = require("src.util.Renderer.helper.get_function_name")
local ElementNode           = require("src.util.ElementNode")
local NativeElement         = require("src.util.NativeElement.NativeElement")
local class = require("lib.30log")

local inline_transpile_decorator = require("src.util.parser.inline.decorator")
-- TODO how heavy is this functionality, time wise?
local inline_transpiled_location = get_function_location(inline_transpile_decorator(function (props) end))

---@param component LuaX.Component
local function get_component_name(component)
    local t = type(component)

    if t == "function" then
        local location = get_function_location(component)
        local name = get_function_name(location)

        if location == inline_transpiled_location then
            return "Inline LuaX"
        elseif name ~= location then
            return string.format("%s (%s)", name, location)
        else
            -- fallback to just location
            return "Function defined at " .. location
        end
    elseif component == ElementNode.LITERAL_NODE then
        return "Literal node"
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

    if element.element_node == ElementNode then
        return get_component_name(element.type)
    end

    if 
        class.isInstance(element) and 
        (
            element.class == NativeElement or 
            ---@diagnostic disable-next-line:undefined-field
            element.class:subclassOf(NativeElement)
        )
    then
        local element = element --[[ @as LuaX.NativeElement ]]

        if element.get_type then
            return element:get_type()
        end

        return "UNKNOWN (extends NativeElement)"
    end

    return "UNKNOWN"
end

return get_element_name
