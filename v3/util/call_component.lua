
local FunctionComponentInstance = require("v3.util.FunctionComponentInstance")

--- Call function or class components in order to ensure that the returned component can be represented with a NativeComponent
---@param element LuaX.ElementNode
local function call_component (element)
    local t = type(element.type)

    if t == "function" then
        -- This fucker needs to be cached so bad
        if not element._attached then
            local renderer = element.type

            -- Hide awesome neat caching implementation in this class
            -- FunctionComponentInstance also gives us epic HookStates 
            element._attached = FunctionComponentInstance(renderer)
        end

        return element._attached:render(element.props)
    end

    if t == "string" then
        return element
    end

    error(string.format("Cannot handle component of type '%s'", t))
end

return call_component