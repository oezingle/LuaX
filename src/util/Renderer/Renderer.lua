local class                     = require("lib.30log")
local ipairs_with_nil           = require("src.util.ipairs_with_nil")
local key_add                   = require("src.util.key.key_add")
local get_element_name          = require("src.util.Renderer.helper.get_element_name")
local create_native_element     = require("src.util.Renderer.helper.create_native_element")
local table_equals              = require("src.util.table_equals")
local can_modify_child          = require("src.util.Renderer.helper.can_modify_child")
local ElementNode               = require("src.util.ElementNode")

local FunctionComponentInstance = require("src.util.FunctionComponentInstance")
local DefaultWorkLoop           = require("src.util.WorkLoop.Default")

-- TODO FIXME what the hell does this mean.
-- TODO if Renderer.envhacks = true, don't use LuaX global

local max = math.max

--- TODO FIXME this code CANNOT go to prod
--- Determine if this is a class or an instance
---
---@param t Log.BaseFunctions
---@return boolean
local function is_instance(t)
    if t.class then
        return true
    end

    return false
end


---@class LuaX.Renderer : Log.BaseFunctions
---@field workloop LuaX.WorkLoop instance of a workloop
---@field native_element LuaX.NativeElement class here, not instance
---@field set_workloop fun (self: self, workloop: LuaX.WorkLoop): self set workloop using either a class or an instance
---
---@field protected _render_function_component fun(self: self, element: LuaX.ElementNode, container: LuaX.NativeElement, key: LuaX.Key)
---@field protected render_pure_component fun(self: self, component: LuaX.ElementNode | nil, container: LuaX.NativeElement, key: LuaX.Key, caller?: LuaX.ElementNode)
---
---@operator call: LuaX.Renderer
local Renderer = class("Renderer")

function Renderer:init(workloop)
    self:set_workloop(workloop)
end

--- Takes a class, instance, or nil
---@param workloop LuaX.WorkLoop | nil
function Renderer:set_workloop(workloop)
    --- initialize
    if workloop and not is_instance(workloop) then
        workloop = workloop()
    end

    self.workloop = workloop or DefaultWorkLoop()

    return self
end

--[[
    TODO FIXME Renderer:delete_children_by_key(container, key)
        - for all children, call child._component:unmount()
]]

-- TODO FIXME refuses to keep any old elements around!! wtf!!

---@param component LuaX.ElementNode | nil
---@param container LuaX.NativeElement
---@param key LuaX.Key
---@param caller LuaX.ElementNode?
function Renderer:render_pure_component(component, container, key, caller)
    if component == nil then
        -- container:set_child(index, nil)
        container:delete_children_by_key(key)

        return
    end

    local can_modify, existing_child = can_modify_child(component, container, key)

    -- print(container:get_type(), "can_modify", existing_child, can_modify)

    ---@type LuaX.NativeElement
    local node = nil

    if can_modify then
        node = existing_child
    else
        if existing_child then
            container:delete_children_by_key(key)
        end

        node = create_native_element(component, container)
    end

    -- set props
    for prop, value in pairs(component.props) do
        -- TODO table_equals could check functions for string.dump
        if prop ~= "children" and not table_equals(value, node:get_prop(prop)) then
            node:set_prop_safe(prop, value)
        end
    end

    -- handle children using workloop
    local children = component.props['children']

    -- TODO this kind of optimization would be nice but can't work as of rn.
    -- if not caller or caller.props['children'] ~= children then
    local current_children = node:get_children_by_key({}) or {}
    if children then
        local workloop = self.workloop

        local size = max(#current_children, #children)
        for index, child in ipairs_with_nil(children, size) do
            workloop:add(function()
                self:render_keyed_child(child, node, { index }, caller)
            end)
        end

        workloop:start()
    else
        -- TODO FIXME does there exist a scenario where a pure component's children will change? probably!
    end
    -- end

    -- Append to parent node
    if not existing_child then
        container:insert_child_by_key(key, node)
    end
end

---@param element LuaX.ElementNode
---@param container LuaX.NativeElement
---@param key LuaX.Key
function Renderer:_render_function_component(element, container, key)    
    local rendered = element._component:render(element.props)
    
    -- ignore rendering if the component is destined for a re-render
    if not element._component.requests_rerender then
        -- Check if a pure component is sitting in this key, in which case we have to destroy it.
        -- local existing = container:get_children_by_key(key)

        -- if existing and existing.class then
        --     container:delete_children_by_key(key)
        -- end

        self:render_keyed_child(rendered, container, key, element)
    end
end

---@param element LuaX.ElementNode | nil
---@param container LuaX.NativeElement
---@param key LuaX.Key
---@param caller LuaX.ElementNode?
function Renderer:render_keyed_child(element, container, key, caller)
    if not element or type(element.type) == "string" then
        self:render_pure_component(element, container, key, caller)
    elseif type(element) == "table" and element.element_node ~= ElementNode then
        -- lists of children are valid children

        local current_children = container:get_children_by_key(key) or {}

        if current_children.class and class.isClass(current_children.class) then
            container:delete_children_by_key(key)

            current_children = {}
        end

        local size = max(#current_children, #element)

        for i, child in ipairs_with_nil(element, size) do
            local newkey = key_add(key, i)

            self:render_keyed_child(child, container, newkey, caller)
        end
    elseif type(element.type) == "function" then
        -- local new_key = key_add(key, 1)

        -- TODO FIXME do FunctionComponentInstances even matter? do some thinking on it.
        if not element._component then
            -- print("Creating new FunctionComponentInstance for", get_element_name(element))

            element = ElementNode.inherit_props(element, {
                __luax_internal = {
                    renderer = self,
                    container = container,
                }
            })

            local component = element.type
            local component_instance = FunctionComponentInstance(component)

            -- Attach parent contexts
            if caller and caller._component then
                local inherit = caller._component:get_contexts()

                component_instance:inherit_contexts(inherit)
            end

            component_instance:on_change(function()
                self.workloop:add(function()
                    self:_render_function_component(element, container, key)
                end)

                -- start workloop if it isn't running
                self.workloop:start()
            end)

            element._component = component_instance
        end

        self:_render_function_component(element, container, key)
    else
        local component_type = type(element.type)

        error(string.format(
            "Cannot render component of type '%s' (rendered by %s)",
            component_type,
            get_element_name(container)
        ))
    end

    -- TODO need to return promise that is resolved when all children have rendered :(

    -- start workloop in case there's shit to do and it's stopped
    self.workloop:start()
end

---@param component LuaX.ElementNode
---@param container LuaX.NativeElement
function Renderer:render(component, container)
    self:render_keyed_child(component, container, { 1 })
end

return Renderer
