---@nospec

---@alias LuaX.Component.Fragment LuaX.Generic.FunctionComponent<LuaX.PropsWithChildren<{}>>

---@type LuaX.Component.Fragment
local function Fragment (props)
    return props.children
end

return Fragment