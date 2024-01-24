local class                     = require("lib.30log")
local ipairs_with_nil           = require("v3.util.ipairs_with_nil")
local create_element            = require("v3.create_element")

local FunctionComponentInstance = require("v3.util.FunctionComponentInstance")
local DefaultWorkLoop           = require("v3.util.WorkLoop.Default")

-- defines LuaX global ( needed for hooks )
-- TODO if Renderer.envhacks = true, don't use LuaX global
require("v3.types.LuaX")

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
---
---@operator call: LuaX.Renderer
local Renderer = class("Renderer")

function Renderer:init(workloop)
    -- self:set_native_element(native_element)

    self:set_workloop(workloop)
end

--[[
---@param native_element LuaX.NativeElement
function Renderer:set_native_element(native_element)
    if is_instance(native_element) then
        native_element = native_element.class
    end

    self.native_element = native_element
end
]]

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

---@param component LuaX.ElementNode | nil
---@param container LuaX.NativeElement
---@param index number
function Renderer:render_pure_component(component, container, index)
    if component == nil then
        container:set_child(index, nil)

        return
    end

    local NativeElementImplementation = container:get_class()

    local component_type = component.type

    if type(component_type) ~= "string" then
        error("NativeElement cannot render non-pure component")
    end

    local node = NativeElementImplementation.create_element(component_type)

    for prop, value in pairs(component.props) do
        if prop ~= "children" then
            node:set_prop(prop, value)
        end
    end


    -- handle children using workloop
    local children = component.props['children']

    if children then
        local workloop = self.workloop

        for index, child in ipairs_with_nil(children) do
            workloop:add(function()
                self:render_nth_child(child, node, index)
            end)
        end

        workloop:start()
    end

    container:set_child(index, node)
end

---@param element LuaX.ElementNode | nil
---@param container LuaX.NativeElement
---@param index number
function Renderer:render_nth_child(element, container, index)
    if not element or type(element.type) == "string" then
        self:render_pure_component(element, container, index)
    elseif type(element.type) == "function" then
        -- TODO not sure about this one.
        if not element._component then
            local component = element.type

            local component_instance = FunctionComponentInstance(component)

            component_instance:on_change(function()
                self.workloop:add(function()
                    local rendered = element._component:render(element.props)

                    self:render_nth_child(rendered, container, index)
                end)
            end)

            element._component = component_instance
        end

        local rendered = element._component:render(element.props)
        self:render_nth_child(rendered, container, index)
    else
        local component_type = type(element.type)

        local err_string = string.format("Cannot render component of type '%s'", component_type)

        if container.get_type then
            err_string = err_string .. string.format(" (rendered by %s)", container:get_type())
        end

        error(err_string)
    end

    -- start workloop in case there's shit to do and it's stopped
    self.workloop:start()
end

---@param component LuaX.ElementNode
---@param container LuaX.NativeElement
function Renderer:render(component, container)
    self:render_nth_child(component, container, 1)
end

function Renderer:get_render()
    ---@param component LuaX.ElementNode
    ---@param container LuaX.NativeElement
    return function(component, container)
        return self:render(component, container)
    end
end

Renderer.create_element = create_element

return Renderer
