
---@alias LuaX.Generic.CreateElement<Component, Props> fun(type: Component, props: Props): LuaX.ElementNode<Props>

---@generic Component, Props
---@type LuaX.Generic.CreateElement<Component, Props>
--- 
--- Create, but do not render, an instance of a component.
--- @param type Component
--- @param props Props
local function create_element (type, props)
    return {
        type = type,
        props = props   
    }
end

return create_element