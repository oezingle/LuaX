local ElementNode = require("v2.util.type.ElementNode")

---@alias LuaX.Generic.CreateElement<Type, Props> fun(type: Type, props: LuaX.Generic.Props<Props>): LuaX.ElementNode

---@type LuaX.Generic.CreateElement<string, string>
--- 
--- Create, but do not render, an instance of a component.
--- @param type LuaX.Component
--- @param props LuaX.Generic.Props<string>
local function create_element(type, props)
    local node = ElementNode(type)
        -- :set_type(type)
        :set_props(props)

    return node
end

return create_element
