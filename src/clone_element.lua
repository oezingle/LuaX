local create_element = require("src.create_element")

--- Clone an element
---@param element LuaX.ElementNode | LuaX.ElementNode[]
---@param props LuaX.Props?
local function clone_element(element, props)
    if element.type then
        local component = element.type

        local newprops = {}

        -- copy old props
        for k, v in pairs(element.props or {}) do
            newprops[k] = v
        end

        -- overwrite new porps
        for k, v in pairs(props or {}) do
            newprops[k] = v
        end

        return create_element(component, newprops)
    else
        -- This is a list of elements!!
        local ret = {}

        for i, child in ipairs(element) do
            ret[i] = clone_element(child, props)
        end

        return ret
    end
end

return clone_element