local transpile_create_element = require("src.util.parser.transpile.create_element")
local get_component_name = require("src.util.parser.transpile.get_component_name")

--- Statically convert a LuaX language node to a create_element() call
---@param node LuaX.Language.Node
---@param components table<string, true> hash map for speed
---@param components_mode "local" | "global"
---@param create_element string
---@return string
local function transpile_node_to_element(node, components, components_mode, create_element)
    if node.type == "comment" then
        return ""
    end

    if node.type == "element" then
        ---@type table<string, string|table>
        local props = node.props or {}

        local children = node.children
        if children and #children >= 1 then
            local str_children = {}

            for i, kid in ipairs(children) do
                if type(kid) == "string" then
                    str_children[i] = "{" .. kid .. "}"
                else
                    str_children[i] = "{" ..
                    transpile_node_to_element(kid, components, components_mode, create_element) .. "}"
                end
            end

            props.children = str_children
        end

        local name = node.name
        local component = get_component_name(components, components_mode, name)

        return transpile_create_element(create_element, component, props)
    end

    error(string.format("Can't transpile LuaX node of type %s", node.type))
end

return transpile_node_to_element
