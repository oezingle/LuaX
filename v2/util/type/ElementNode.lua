local class              = require("lib.30log")
local map_list           = require("v2.util.polyfill.map.list")
local object_entries     = require("v2.util.polyfill.object_entries")
local component_registry = require("v2.util.component_registry")
local shallow_copy       = require("v2.util.shallow_copy")
local FunctionComponentIntsance = require("v2.util.type.FunctionComponentIntsance")

--[[
    -- TODO renderer in here
        - store type -> function | table | string
            - string: check registered string components
            - function -> create ComponentInstance & attach, render.
            - table -> must extend LuaX.Component, so attaching & calling :render() should be enough.
]]

--- Pre-render element class.
---@class LuaX.ElementNode : Log.BaseFunctions
---@field set_children fun(self: self, children: LuaX.ElementNode[]): self
---@field get_children fun(self: self): LuaX.ElementNode[]
---@field set_props fun(self: self, props: LuaX.Props): self
---@field protected props { [string]: any, children: LuaX.ElementNode }
---@field get_props fun(self: self): LuaX.Props
-----@field render fun(self: self): any
---@field get_type fun(self: self): LuaX.Component
---@field type LuaX.Component
---@field set_type fun(self: self, type: LuaX.Component): self
---
---@field attached LuaX.ComponentInstance
---
---@field __tostring fun(self: self): string
---@field _attach fun(self: self, type: LuaX.Component): nil
---
---@operator call:LuaX.ElementNode
local ElementNode = class("ElementNode")

function ElementNode:init(type)
    if type then
        self:set_type(type)
    end

    self.props = {}
end

function ElementNode:set_children(children)
    -- TODO switch to an implementation that checks for old children

    -- special case here as strings have length in the same way as tables
    if type(children) == "string" then
        children = { children }
    end

    -- Children can be passed as a list of children or a single child
    if type(children) == "table" and #children == 0 then
        children = { children }
    end

    self.props.children = children

    return self
end

function ElementNode:get_children()
    return self.props.children
end

function ElementNode:set_props(props)
    -- TODO switch to an implementation that checks for old props

    self.props = props

    return self
end

function ElementNode:get_props()
    return self.props
end

function ElementNode:set_type(type)
    self:_attach(type)

    return self
end

-- function ElementNode:get_type()
--     return self.type
-- end

--[[
function ElementNode:render()
    local renderer = get_renderer(self.type)

    local rendered_children = {}

    for i, child in ipairs(self:get_children()) do
        if type(child) == "string" then
            -- this is a text node
            rendered_children[i] = child
        else
            rendered_children[i] = child:render()
        end
    end

    ---@type LuaX.Props
    local props_copy = shallow_copy(self.props)

    props_copy.children = rendered_children

    return renderer(props_copy)
end
]]

---@param component LuaX.Component
---@return LuaX.ComponentInstance
local function get_component(component)
    local t = type(component)

    if t == "string" then
        --- return from component registry
        local actual_component = component_registry.get_by_name(component)

        if not actual_component then
            error(string.format("No component by name %q. Did you make sure to register it?", component))
        end

        if type(actual_component) == "string" then
            return get_component(actual_component)
        end

        return actual_component
    elseif t == "function" then
        return FunctionComponentIntsance(component)
    else
        error(string.format("Can't handle renderer of type %q", t))
    end
end

function ElementNode:_attach (element)
    local component = get_component(element)

    self.attached = component
end


function ElementNode:__tostring()
    return string.format("%s %s",
        self.attached:get_name(),
        table.concat(map_list(object_entries(self.props), function(entry)
            local key = entry[0]
            local value = entry[1]

            if key == "children" then
                return nil
            end

            return string.format("%s=%s", tostring(key), tostring(value))
        end), " ")
    )
end

---@param depth number?
function ElementNode:_print_heirarchy(depth)
    depth = depth or 0

    print(string.rep("\t", depth) .. tostring(self))

    local children = self:get_children() or {}

    for _, child in ipairs(children) do
        if type(child) == "string" then
            print(string.rep("\t", depth + 1) .. child)
        else
            child:_print_heirarchy(depth + 1)
        end
    end
end

return ElementNode
