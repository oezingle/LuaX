local class = require("lib.30log")
local table_equals = require("src.util.table_equals")
local HookState = require("src.util.type.HookState")
local LinkedList = require("src.util.type.LinkedList")

---@alias Component.Return any

---@alias Component fun(props: Component.Props): Component.Return

---@alias Component.Props table

---@class ComponentInstance : Log.BaseFunctions
---@field hookstate HookState
---@field renderer Component
---@field last_props Component.Props
---@field last_render any
---@field task_queue LinkedList<function>
local ComponentInstance = class("RenderedComponentInstance")

---@param render Component
function ComponentInstance:init(render)
    self.task_queue = LinkedList()

    self.hookstate = HookState()
    self.hookstate:add_listener(function ()
        self.task_queue:enqueue(function (self)
            self:forcerender(self.last_props)
        end)
    end)

    self.last_props = nil

    self.renderer = render
end

---@param props Component.Props
function ComponentInstance:render(props)
    if not table_equals(props, self.last_props, false) then
        local rendered = self:forcerender(props)

        return rendered
    else
        return self.last_render
    end
end

---@param props Component.Props
function ComponentInstance:forcerender(props)    
    self.hookstate:reset()
    
    LuaX._hookstate = self.hookstate
    
    local render_return = nil

    if type(self.renderer) == "function" then
        render_return = self.renderer(props)
    end

    LuaX._hookstate = nil

    self.last_props = props

    self.last_render = render_return

    if not self.task_queue:is_empty() then
        local fn = self.task_queue:dequeue()

        fn(self)
    end

    -- Here so that hooks calling re-renders won't cause bad values to return
    return self.last_render
end

return ComponentInstance
