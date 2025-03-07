local class                 = require("lib.30log")
local ipairs_with_nil       = require("src.util.ipairs_with_nil")
local key_add               = require("src.util.key.key_add")
local get_element_name      = require("src.util.debug.get_element_name")
local create_native_element = require("src.util.Renderer.helper.create_native_element")
local deep_equals           = require("src.util.deep_equals")
local can_modify_child      = require("src.util.Renderer.helper.can_modify_child")
local ElementNode           = require("src.util.ElementNode")
local VirtualElement        = require("src.util.NativeElement.VirtualElement")
local DefaultWorkLoop       = require("src.util.WorkLoop.Default")
local RenderInfo            = require("src.util.Renderer.RenderInfo")
local DrawGroup             = require("src.util.Renderer.DrawGroup")
local NativeElement         = require("src.util.NativeElement.NativeElement")


local max = math.max

---@class LuaX.Renderer : Log.BaseFunctions
---@field workloop LuaX.WorkLoop instance of a workloop
---@field native_element LuaX.NativeElement class here, not instance
---@field set_workloop fun (self: self, workloop: LuaX.WorkLoop): self set workloop using either a class or an instance
---@field render fun(self: self, component: LuaX.ElementNode, container: LuaX.NativeElement)
---
---@operator call: LuaX.Renderer
local Renderer = class("Renderer")

function Renderer:init(workloop)
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
---@param info LuaX.RenderInfo.Info
function Renderer:render_native_component(component, container, key, info)
    -- log.trace(get_element_name(container), "render_native_component", get_element_name(component), key_to_string(key))

    -- NativeElement:set_prop_safe now consumes DrawGroup.current, so we must update.
    local info_old = RenderInfo.set(info)

    if component == nil then
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
        if
            -- children are handled differently than other props
            prop ~= "children" and
            -- LuaX:: signifies a property that LuaX handles innately.
            prop:sub(1, 6) ~= "LuaX::" and
            -- values haven't changed.
            not deep_equals(value, node:get_prop_safe(prop), 2)
        then
            node:set_prop_safe(prop, value)
        end
    end

    -- handle children using workloop
    local children = component.props['children']

    local current_children = node:get_children_by_key({}) or {}
    if children then
        local workloop = self.workloop

        local size = max(#current_children, #children)
        for index, child in ipairs_with_nil(children, size) do
            DrawGroup.ref(info.draw_group)

            workloop:add(self.render_keyed_child, self, child, node, { index }, info)
        end

        workloop:safely_start()
    end

    -- Append to parent node
    if not can_modify then
        container:insert_child_by_key(key, node)
    end

    RenderInfo.set(info_old)
end

---@protected
---@param element LuaX.ElementNode
---@param container LuaX.NativeElement
---@param key LuaX.Key
---@param info LuaX.RenderInfo.Info
function Renderer:render_function_component(element, container, key, info)
    -- check if there's already something in the way
    do
        local existing = container:get_children_by_key(key)

        -- Single existing child or too many children. VirtualElement creates 2.
        if existing and (existing.class or #existing > 2) then
            container:delete_children_by_key(key)
        end
    end

    local virtual_key = key_add(key, 1)
    local render_key = key_add(key, 2)
    local can_modify, existing_child = can_modify_child(element, container,
        virtual_key)

    ---@type LuaX.NativeElement.Virtual
    local node = nil

    local info = RenderInfo.inherit({
        -- we pass render_key to functions so they don't overwrite their own
        -- VirtualElement
        key = render_key,

        container = container,

        renderer = self,
    }, info)

    if can_modify then
        node = existing_child --[[ @as LuaX.NativeElement.Virtual ]]
    else
        if existing_child then
            container:delete_children_by_key(virtual_key)
        end

        node = VirtualElement.create_element(element.type)

        container:insert_child_by_key(virtual_key, node)

        node:set_on_change(function()
            self.workloop:add(function()
                -- log.debug("Component change")
                local old = RenderInfo.set(info)

                -- Force render because a hook changed
                local did_render, render_result = node:render(true)

                if did_render then
                    DrawGroup.ref(info.draw_group)

                    self:render_keyed_child(render_result, container,
                        render_key, info)
                end

                RenderInfo.set(old)
            end)

            -- TODO escape current callback somehow?
            -- start workloop if it isn't running
            self.workloop:safely_start()
        end)
    end

    local old = RenderInfo.set(info)

    RenderInfo.bind(element.props, info)
    node:set_props(element.props)

    -- This feels evil
    local did_render, render_result = node:render()
    if did_render then
        DrawGroup.ref(info.draw_group)

        self.workloop:add(self.render_keyed_child, self, render_result, container, render_key, info)
    end

    RenderInfo.set(old)

    self.workloop:safely_start()
end

---@protected
---@param element LuaX.ElementNode | nil
---@param container LuaX.NativeElement
---@param key LuaX.Key
---@param info LuaX.RenderInfo.Info
function Renderer:render_keyed_child(element, container, key, info)
    -- log.trace(get_element_name(container), "rendering", get_element_name(element), key_to_string(key))

    if not element or type(element.type) == "string" then
        self:render_native_component(element, container, key, info)

        -- TODO element.element_node ~= ElementNode equality check might be slow!
        ---@diagnostic disable-next-line:invisible
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

            DrawGroup.ref(info.draw_group)

            self.workloop:add(self.render_keyed_child, self, child, container, newkey, info)
        end
    elseif type(element.type) == "function" then
        self:render_function_component(element, container, key, info)
    else
        local component_type = type(element.type)

        error(string.format(
            "Cannot render component of type '%s' (rendered by %s)",
            component_type, get_element_name(container)
        ))
    end

    DrawGroup.unref(info.draw_group)

    -- start workloop in case there's rendering to do and it's stopped
    self.workloop:safely_start()
end

-- TODO maybe children should know parents? error in Renderer:render_keyed_child used to print calling Component if available

---@param component LuaX.ElementNode
---@param container LuaX.NativeElement
function Renderer:render(component, container)
    -- Check arguments to assert theyr'e correct.
    local args = { self, component, container }
    for i, info in ipairs({
        { type = Renderer, name = "self", extra =
        "Are you calling renderer.render() instead of renderer:render()?" },

        { type = "table",       name = "component" },

        { type = NativeElement, name = "container" }
    }) do
        local arg = args[i]

        local extra = info.extra and (" " .. info.extra) or ""

        if type(info.type) == "string" then
            assert(type(arg) == info.type and not class.isInstance(arg),
                string.format("Expected argument %q to be of type %s" .. extra, info.name, info.type))
        else
            local classname = tostring(info.type)
            -- Try to get the name from class '<classname>' (table: 0x<addr>)
            classname = classname:match("class '[^']+'") or classname

            assert(class.isInstance(arg),
                string.format("Expected argument %q to be an instance of %s" .. extra, info.name, classname))
        end
    end

    -- Create a default draw group
    local group = DrawGroup.create(function(err)
        error(err)
    end, function() end, function() end)

    local render_info = {
        key = {},
        context = {},
        draw_group = group
    }
    -- We need an error handler.
    RenderInfo.set(render_info)

    self.workloop:add(self.render_keyed_child, self, component, container, { 1 }, render_info)

    self.workloop:safely_start()
end

return Renderer
