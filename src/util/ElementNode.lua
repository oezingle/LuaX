local ipairs_with_nil = require("src.util.ipairs_with_nil")
local get_function_location = require("src.util.debug.get_function_location")
local warn = require("src.util.polyfill.warn")


---@alias LuaX.ElementNode.LiteralNode string

---@alias LuaX.ElementNode.Child false | string | LuaX.ElementNode | nil
---@alias LuaX.ElementNode.Children LuaX.ElementNode.Child | (LuaX.ElementNode.Child)[]

--[[
    returning to a super old comment i left here - see
    spec/special/table_equality_slow.lua

    in terms of why tables are slower than strings, I realized it's becaues of
    Lua's string 'baking' - when transforming to bytecode, strings are converted
    to IDs. Accessing these is faster than loading and checking 2 upvalues, even
    if local (by number) as opposed to global (by name)
]]

---@class LuaX.ElementNode
---
--- Instance properties
---@field type LuaX.Component
---@field props LuaX.Props
---
---@field inherit_props fun(self: self, inherit_props: LuaX.Props): self
---@field create fun(component: LuaX.Component | LuaX.ElementNode.LiteralNode, props: LuaX.Props): self
---@field protected LITERAL_NODE LuaX.ElementNode.LiteralNode unique key
---
local ElementNode = {
    LITERAL_NODE = "LUAX_LITERAL_NODE", -- this table is used for its unique key
}

--- Process any possible value for "children" into a list of ElementNodes
---@param children LuaX.ElementNode.Children
---@protected
function ElementNode.clean_children(children)
    -- Convert children to list
    if not children or type(children) == "string" or ElementNode.is(children) then
        children = { children }
    end

    ---@type (LuaX.ElementNode.Child)[]
    local children = children

    for i, _ in ipairs_with_nil(children) do
        -- Terrible fix for the language server. affects performance very
        -- marginally for sure but i don't wanna change it
        ---@type LuaX.ElementNode.Child
        local child = children[i]

        local child_type = type(child)

        if not child then
            child = nil
        elseif child_type ~= "table" then
            if child_type == "function" then
                warn(string.format(
                    "passed a chld function (defined at %s) as a literal. Are you sure you didn't mean to call create_element()?",
                    get_function_location(child)
                ))
            end

            child = ElementNode.create(ElementNode.LITERAL_NODE, { value = tostring(child) })
        end

        children[i] = child
    end

    return children
end

function ElementNode.create(component, props)
    props.children = ElementNode.clean_children(props.children)

    local node = {
        type = component,
        props = props,
    }

    return node
end

--- Check if a value is an ElementNode
---@param val any
---@return boolean
function ElementNode.is(val)
    if type(val) ~= "table" then
        return false
    end

    local t_type = type(val.type)
    if t_type ~= "string" and t_type ~= "function" then
        return false
    end

    if type(val.props) ~= "table" then
        return false
    end

    return true
end

---@overload fun (component: LuaX.ElementNode): boolean
---@param component LuaX.Component
---@return boolean
function ElementNode.is_literal(component)
    if type(component) == "table" then
        return ElementNode.is_literal(component.type)
    end

    return component == ElementNode.LITERAL_NODE
end

return ElementNode
