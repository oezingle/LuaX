local get_function_location = require("src.util.debug.get_function_location")
local get_function_name     = require("src.util.debug.get_function_name")
local ElementNode           = require("src.util.ElementNode")
local Inline

-- create a throwaway inline function just to get the decorator's debug info
---@type table | string
local inline_transpiled_location = {}

---@param component LuaX.Component
---@return string
local function actually_get_component_name(component)
    local t = type(component)

    if t == "function" then
        local location = get_function_location(component)
        local name = get_function_name(location)

        if location == inline_transpiled_location then
            local chunk = Inline:get_original_chunk(component)

            if chunk then                
                return actually_get_component_name(chunk)
            else
                -- unable to get more info
                return "Inline LuaX"
            end
        elseif name ~= location then
            return string.format("%s (%s)", name, location)
        end

        -- fallback to just location
        return "Function defined at " .. location
    elseif ElementNode.is_literal(component) then
        return "Literal"
    elseif t == "string" then
        return component
    else
        return string.format("UNKNOWN (%s %s)", t, tostring(component))
    end
end

--- Good ol diamond dependency
---@param value LuaX.Parser.Inline
local function set_Inline (value)
    Inline = value

    inline_transpiled_location = get_function_location(Inline:transpile_decorator(function(props) end))
end

--- Evil diamond dependency resolution.
---@type fun(component: LuaX.Component): string
local get_component_name = setmetatable({
    set_Inline = set_Inline
}, {
    __call = function (_, ...)
        return actually_get_component_name(...)
    end
}) --[[ @as any]]

return get_component_name