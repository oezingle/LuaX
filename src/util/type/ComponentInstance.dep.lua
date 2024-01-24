local class = require("lib.30log")
local table_equals = require("src.util.table_equals")
local HookState = require("src.util.type.HookState")
local LinkedList = require("src.util.type.LinkedList")

local NativeComponent = require("src.util.type.NativeComponent")
local Element = require("src.util.type.Element")

---@alias Component.Return any

---@alias FunctionComponent<Props> fun(props: Component.Props<Props>): Component.Return

---@alias Component<Props> FunctionComponent<Props> | NativeComponent<Props>

---@alias Component.Props<Props> table | table<Props, any>

---@alias Component.Node<Props> { type: Component<Props>, props: table<Props, any> }

---@class ComponentInstance : Log.BaseFunctions
---@field hookstate LuaX.HookState
---@field element Element
---@field children ComponentInstance[]
---@field last_render any
---@field task_queue LinkedList<function>
local ComponentInstance = class("RenderedComponentInstance")

function ComponentInstance:init(element)
    self.task_queue = LinkedList()

    self.last_props = "this string is here to be an invalid value that isn't nil or any empty table"

    self.hookstate = HookState()
    self.hookstate:add_listener(function()
        self.task_queue:enqueue(function(self)
            self:forcerender(self.last_props)
        end)
    end)

    self.children = {}

    self.element = element
end

function ComponentInstance:render(props)
    if not table_equals(props, self.last_props, false) then
        if props then
            self.element.props = props
        end

        local rendered = self:_forcerender()

        return rendered
    else
        return self.last_render
    end
end

-- I know that this isn't the approach that React takes - children are passed as ReactElements to Components. How?

---@param children Element[]
function ComponentInstance:_render_children(children)
    -- Create new ComponentInstances for the children.
    -- This could definitely be smarter. Mapping old children
    -- to new children to save hookstates and render cycles
    if #self.children ~= #children then
        -- https://stackoverflow.com/questions/124455/how-do-you-pre-size-an-array-in-lua
        self.children = {}

        for index, child in ipairs(children) do
            self.children[index] = ComponentInstance(Element(child.type, child.props))
        end
    end

    ---@type Component.Return[]
    local render = {}

    for index, child in ipairs(children) do
        local component_instance = self.children[index]

        render[index] = component_instance:render(child.props)
    end

    return render
end

function ComponentInstance:_forcerender()
    self.hookstate:reset()

    LuaX._hookstate = self.hookstate

    local render_return = nil

    local renderer = self.element.type
    local props = self.element.props

    if props.children then
        ---@diagnostic disable-next-line:inject-field
        props.children = self:_render_children(props.children)
    end

    local renderer_type = type(renderer)
    if renderer_type == "function" then
        render_return = renderer(props)
    elseif renderer_type == "table" and class.isInstance(renderer) and renderer:instanceOf(NativeComponent) then
        ---@type NativeComponent
        local component = renderer

        component:set_props(props)

        render_return = component:get_element()
    end

    LuaX._hookstate = nil

    self.last_props = props

    self.last_render = render_return

    -- TODO ignore multiple calls from hooks on same render?
    -- Call render again if a hook has forced this.
    if not self.task_queue:is_empty() then
        local fn = self.task_queue:dequeue()

        fn(self)
    end

    return self.last_render
end

return ComponentInstance
