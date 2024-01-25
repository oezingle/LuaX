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

--- Create, but do not render, an instance of a component.
---@param component LuaX.Component
---@param props table
--- @return LuaX.ElementNode
local function create_element (component, props)    
    ---@diagnostic disable-next-line:undefined-field
    if props.children then
        ---@type LuaX.ElementNode | string | (LuaX.ElementNode | string)[] | nil
        ---@diagnostic disable-next-line:undefined-field
        local children = props.children

        -- single child to children
        if type(children) ~= "table" or #children == 0 then
            children = { children }
        end

        for i, child in ipairs(children) do
            if type(child) ~= "table" then
                child = create_element("LITERAL_NODE", { value = child })
            end

            -- TODO NO BAD NO
            -- child.key = i

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