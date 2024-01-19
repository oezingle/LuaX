
local class = require("lib.30log")

---@class NativeComponent<Props> : Log.BaseFunctions, { get_prop: fun(self: NativeComponent<Props>, prop: Props): any, set_prop: fun(self: NativeComponent<Props>, prop: Props, value: any), set_props: fun(self: NativeComponent<Props>, values: table<Props, any> ) } A component that can be rendered and modified
---@field set_children fun(self: NativeComponent, children: Component.Return[])
---@field get_children fun(self: NativeComponent): Component.Return[]
---@field get_prop fun(self: NativeComponent, prop: any): any
---@field set_prop fun(self: NativeComponent, prop: any, value: any)
---@field set_props fun(self: NativeComponent, values: table)
---@field get_element fun(self: NativeComponent): any
local NativeComponent = class("NativeComponent")

function NativeComponent:set_props(values)
    for prop, value in pairs(values) do
        if prop ~= "children" then
            self:set_prop(prop, value)
        end
    end

    if values.children then
        self:set_children(values.children)
    end
end

---@param index number
function NativeComponent:get_child(index)
    return self:get_children()[index]
end

--- May need to be re-implemented in certain cases: 
--- relies on get_children and set_children, so if
--- children aren't stored in a table natively you're in trouble.
---@param index number
---@param child Component.Return[]
function NativeComponent:set_child(index, child)
    local children = self:get_children()

    children[index] = child

    self:set_children(children)
end

return NativeComponent