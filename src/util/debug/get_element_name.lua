local get_component_name = require("src.util.debug.get_component_name")
local ElementNode        = require("src.util.ElementNode")
local NativeElement      = require("src.util.NativeElement.NativeElement")
local class              = require("lib.30log")

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

    if ElementNode.is(element) then
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

        return element:get_name()
    end

    if #element ~= 0 then
        return string.format("list(%d)", #element)
    end

    if next(element) == nil then
        return "list(nil)"
    end

    return "UNKNOWN"
end

return get_element_name
