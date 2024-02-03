local class                     = require("lib.30log")
local ipairs_with_nil           = require("src.util.ipairs_with_nil")
local key_add                   = require("src.util.key.key_add")
local get_element_name          = require("src.util.Renderer.helper.get_element_name")
local create_native_element     = require("src.util.Renderer.helper.create_native_element")
local table_equals              = require("src.util.table_equals")
local can_modify_child          = require("src.util.Renderer.helper.can_modify_child")

local FunctionComponentInstance = require("src.util.FunctionComponentInstance")
local DefaultWorkLoop           = require("src.util.WorkLoop.Default")

-- defines LuaX global ( needed for hooks )
-- TODO if Renderer.envhacks = true, don't use LuaX global
require("src.types.LuaX")

local max = math.max

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
---@field get_render fun (self: self): fun(element: LuaX.ElementNode, container: LuaX.NativeElement)
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
TODO add child by key
    - keys set by create_element
    - keys on function component should propogate to all its children

function components can't just check own children, they need to check all children not passed as props.
]]

-- TODO can function components return strings?

-- TODO CHECK OLD CHILDREN SO YOU DON'T WASTE RENDERS FUCK

-- TODO add index prop - check list of children by same key at that index to see if can be reused.
-- TODO reuse child if it exists
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

    for prop, value in pairs(component.props) do
        -- TODO table_equals could check functions for string.dump
        if prop ~= "children" and not table_equals(value, node:get_prop(prop)) then
            node:set_prop_safe(prop, value)
        end
    end



    -- handle children using workloop
    local children = component.props['children']

    if not caller or not caller.props['children'] or caller.props['children'] ~= children then
        local current_children = node:get_children_by_key({}) or {}

        if children then
            local workloop = self.workloop

            local size = max(#current_children, #children)

            for index, child in ipairs_with_nil(children, size) do
                workloop:add(function()
                    self:render_keyed_child(child, node, { index })
                end)
            end

            workloop:start()
        else
            -- TODO FIXME does there exist a scenario where a pure component's children will change? probably!
        end
    end


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

    if not element._component.requests_rerender then
        -- Function components are allowed to return lists of children
        -- (not really -- this isn't good behaviour but fixes Fragments and is React compatible)
        if type(rendered) == "table" and not rendered.type then
            -- TODO does this work? no - breaks!
            local current_children = container:get_children_by_key(key) or {}

            local size = max(#current_children, #rendered)

            for i, child in ipairs_with_nil(rendered, size) do
                self:render_keyed_child(child, container, key_add(key, i))
            end
        else
            self:render_keyed_child(rendered, container, key)
        end
    end
end

---@param element LuaX.ElementNode | nil
---@param container LuaX.NativeElement
---@param key LuaX.Key
---@param caller LuaX.ElementNode?
function Renderer:render_keyed_child(element, container, key, caller)
    if not element or type(element.type) == "string" then
        self:render_pure_component(element, container, key, caller)
    elseif type(element.type) == "function" then
        if not element._component then
            local component = element.type

            local component_instance = FunctionComponentInstance(component)

            component_instance:on_change(function()
                self.workloop:add(function()
                    self:_render_function_component(element, container, key)
                end)

                -- TODO seems to have some issues
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

    -- start workloop in case there's shit to do and it's stopped
    self.workloop:start()
end

---@param component LuaX.ElementNode
---@param container LuaX.NativeElement
function Renderer:render(component, container)
    -- if not container.get_type then
    --     warn("This container element does not implement the optional (but useful) function get_type")
    -- end

    self:render_keyed_child(component, container, { 1 })
end

return Renderer
