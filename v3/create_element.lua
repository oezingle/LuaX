local get_function_location = require("v3.util.Renderer.helper.get_function_location")

-- removed: trying to make props immutable breaks everything - why protect literally just { type, props }?
-- local make_immutable = require "v3.util.make_immutable"

--[[
-- removed annotations - seems as though lua-language-server can't handle generics this complex. boo!

---@alias LuaX.Generic.CreateElement<Component, Props> fun(type: Component, props: Props): LuaX.ElementNode<Props>

---@generic Props
-- ---@type LuaX.Generic.CreateElement<Component, Props>
---
--- Create, but do not render, an instance of a component.
---@param type LuaX.Component
---@param props `Props`
--- @return LuaX.ElementNode<Props>
]]

---@alias LuaX.CreateElement.Child LuaX.ElementNode | string | nil
---@alias LuaX.CreateElement.Children LuaX.CreateElement.Child | LuaX.CreateElement.Child[]


--- Create, but do not render, an instance of a component.
---@param component LuaX.Component
---@param props table
--- @return LuaX.ElementNode
local function create_element(component, props)
    ---@diagnostic disable-next-line:undefined-field
    if props.children then
        ---@type LuaX.CreateElement.Children
        ---@diagnostic disable-next-line:undefined-field
        local children = props.children

        -- single child to children
        if type(children) ~= "table" or #children == 0 then
            children = { children }
        end

        for i, child in ipairs(children) do
            if child == false then
                child = nil
            elseif type(child) ~= "table" then
                if type(child) == "function" then
                    warn(string.format(
                        "passed a chld function (defined at %s) as a literal. Are you sure you didn't mean to call create_element()?",
                        get_function_location(child)
                    ))
                end

                child = create_element("LITERAL_NODE", { value = tostring(child) })
            end

            children[i] = child
        end

        props.children = children
    end

    return {
        type = component,
        props = props
    }
end

return create_element
