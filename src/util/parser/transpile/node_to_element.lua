
local transpile_create_element = require("src.util.parser.transpile.create_element")

--[[
    TODO I don't love this implementation. debug.getlocal could be an option but that's not recommended by Lua maintainers.
        - components return string_create_element
        - string_create_element checks get_local_named (see spec/stupid/get_local.lua)
        - if that local exists (and is a valid component), use it as a component
]]

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

--- Statically convert an XML node to a create_element_call
---@param node LuaX.Language.Node
---@param components table<string, true> hash map for speed
---@param components_mode "local" | "global"
local function transpile_node_to_element(node, components, components_mode)
    if node.type == "literal" then
        -- TODO FIXME not so fast buster! any lua code will be interpreted as a static string!

        return transpile_create_element("\"LITERAL_NODE\"", { value = string.format("%q", node.props.value) })
    end

    --[[
    if node.type == "root" then
        local children = node.children

        if not children then
            return transpile_create_element("nil", {})
        end

        if #children > 1 then
            error("LuaX XML should have only one parent element")
        end

        return transpile_node_to_element(children[1], components, components_mode)
    end
    ]]

    -- Otherwise mode
    if node.type == "element" then
        ---@type table<string, string|table>
        local props = node.props
        --[[
        for name, value in pairs(node.props) do
            if value == "" then
                -- TODO is this line really needed? implicit true is ok with ""
                ---@type any
                value = true
            end

            props[name] = value
        end
        ]]

        local kids = node.children
        if kids and #kids >= 1 then
            local children = {}

            for i, kid in ipairs(kids) do
                children[i] = transpile_node_to_element(kid, components, components_mode)
            end

            props.children = children
        end

        local name = node.name
        local component = component_name(components, components_mode, name)

        return transpile_create_element(component, props)
    end

    error(string.format("Can't transpile XML node of type %s", node.type))
end

return transpile_node_to_element
