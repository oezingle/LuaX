local class                 = require("lib.30log")
local ipairs_with_nil       = require("src.util.ipairs_with_nil")
local key_add               = require("src.util.key.key_add")
local get_element_name      = require("src.util.Renderer.helper.get_element_name")
local create_native_element = require("src.util.Renderer.helper.create_native_element")
local table_equals          = require("src.util.table_equals")
local can_modify_child      = require("src.util.Renderer.helper.can_modify_child")
local ElementNode           = require("src.util.ElementNode")
local inherit_contexts      = require("src.context.inherit")
local log                   = require("lib.log")
local VirtualElement       = require("src.util.NativeElement.VirtualElement")
local DefaultWorkLoop       = require("src.util.WorkLoop.Default")


local max      = math.max

---@class LuaX.Renderer : Log.BaseFunctions
---@field workloop LuaX.WorkLoop instance of a workloop
---@field native_element LuaX.NativeElement class here, not instance
---@field set_workloop fun (self: self, workloop: LuaX.WorkLoop): self set workloop using either a class or an instance
---
---@field protected render_function_component fun(self: self, element: LuaX.ElementNode, container: LuaX.NativeElement, key: LuaX.Key, caller?: LuaX.ElementNode)
---@field protected render_native_component fun(self: self, component: LuaX.ElementNode | nil, container: LuaX.NativeElement, key: LuaX.Key, caller?: LuaX.ElementNode)
---
---@operator call: LuaX.Renderer
local Renderer = class("Renderer")

function Renderer:init(workloop)
    if not _G.LuaX then
        ---@diagnostic disable-next-line:missing-fields
        _G.LuaX = {}
    end

    self:set_workloop(workloop)
end

--- Takes a class, instance, or nil
---@param workloop LuaX.WorkLoop | nil
function Renderer:set_workloop(workloop)
    -- create an instance if handed a class
    -- instances always have a .class field that points to their class
    if workloop and not workloop.class then
        workloop = workloop()
    end

    self.workloop = workloop or DefaultWorkLoop()

    return self
end

---@protected
---@param component LuaX.ElementNode | nil
---@param container LuaX.NativeElement
---@param key LuaX.Key
---@param caller LuaX.ElementNode?
function Renderer:render_native_component(component, container, key, caller)
    -- print(get_element_name(container), "render_native_component", get_element_name(component))

    if component == nil then
        -- container:set_child(index, nil)
        container:delete_children_by_key(key)

        return
    end

    local can_modify, existing_child = can_modify_child(component, container, key)

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
    end
    -- end

    -- Append to parent node
    if not existing_child then
        container:insert_child_by_key(key, node)
    end
end

---@protected
---@param element LuaX.ElementNode
---@param container LuaX.NativeElement
---@param key LuaX.Key
---@param caller LuaX.ElementNode?
function Renderer:render_function_component(element, container, key, caller)
    local virtual_key = key_add(key, 1)
    local can_modify, existing_child = can_modify_child(element, container, virtual_key)

    ---@type LuaX.NativeElement.Virtual
    local node = nil

    if can_modify then
        node = existing_child --[[ @as LuaX.NativeElement.Virtual ]]
    else
        if existing_child then
            container:delete_children_by_key(virtual_key)
        end

        node = VirtualElement.create_element(element.type)

        node:on_change(function()
            self.workloop:add(function()
                self:render_function_component(element, container, key, caller)
            end)

            -- start workloop if it isn't running
            self.workloop:start()
        end)

        container:insert_child_by_key(virtual_key, node)
    end

    -- link hidden props
    element = ElementNode.inherit_props(element, {
        __luax_internal = {
            renderer = self,
            container = container,
            context = inherit_contexts(caller)
        }
    })
    node:set_props(element.props)

    local render_key = key_add(key, 2)

    -- This feels evil
    local did_render, render_result = node:render()

    if did_render then
        self:render_keyed_child(render_result, container, render_key, element)
    end
end

---@param element LuaX.ElementNode | nil
---@param container LuaX.NativeElement
---@param key LuaX.Key
---@param caller LuaX.ElementNode?
function Renderer:render_keyed_child(element, container, key, caller)
    log.trace(get_element_name(container), "rendering", get_element_name(element), table.concat(key, " "))

    if not element or type(element.type) == "string" then
        self:render_native_component(element, container, key, caller)
        -- TODO element.element_node ~= ElementNode equality check might be slow!
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
        self:render_function_component(element, container, key, caller)
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
