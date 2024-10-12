
local transpile_create_element = require("src.util.parser.transpile.create_element")

--- Return the component's name as a string, either for a lua local,
--- or quoted as a component for NativeElement to use
---
---@param components table<string, true> hash map for speed
---@param components_mode "local" | "global"
---@param name string
local function component_name(components, components_mode, name)
    local has_component = not not components[name]

    local mode_global = components_mode == "global"

    local is_global = has_component == mode_global

    if is_global then
        return string.format("%q", name)
    else
        return name
    end
end

--- Statically convert a LuaX language node to a create_element() call
---@param node LuaX.Language.Node
---@param components table<string, true> hash map for speed
---@param components_mode "local" | "global"
---@param create_element string
---@return string
local function transpile_node_to_element(node, components, components_mode, create_element)
    if node.type == "literal" then        
        return string.format("%q", node.value)
    end

    -- Otherwise mode
    if node.type == "element" then
        ---@type table<string, string|table>
        local props = node.props or {}

        local kids = node.children
        if kids and #kids >= 1 then
            local children = {}

            for i, kid in ipairs(kids) do                
                if type(kid) == "string" then
                    children[i] = "{" .. kid .. "}"

                else
                    children[i] = "{" .. transpile_node_to_element(kid, components, components_mode, create_element) .. "}"
                end
            end

            props.children = children
        end

        local name = node.name
        local component = component_name(components, components_mode, name)

        return transpile_create_element(create_element, component, props)
    end

    error(string.format("Can't transpile LuaX node of type %s", node.type))
end

return transpile_node_to_element
