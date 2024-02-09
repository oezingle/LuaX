local create_element = require("src.create_element")

---@param value string
local function create_literal(value)
    return create_element("LITERAL_NODE", { value = tostring(value) })
end

---@param value LuaX.ElementNode | any
local function ensure_component(value)
    if type(value) ~= "table" then
        return create_literal(value)
    end

    -- this is a single element
    if value.type and value.props then
        return value
    end

    local ret = {}
    for i, value in pairs(value) do
        ret[i] = ensure_component(value)
    end

    return ret
end

---@param props { value: LuaX.ElementNode | any }
local function LuaBlock(props)
    local value = props.value

    return ensure_component(value)
end

return LuaBlock
