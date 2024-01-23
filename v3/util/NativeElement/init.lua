local class = require("lib.30log")
local ipairs_with_nil = require("v3.util.ipairs_with_nil")

--- TODO this class needs to handle rendering, or outsource rendering to render() - watch changes on components

--- TODO fixme improve abstract implementation optimization / caching
---@class LuaX.NativeComponent : Log.BaseFunctions
---@field init fun(self: self, type: string)
---@field set_children fun(self: self, children: LuaX.ElementNode[]): self
---@field set_child fun(self: self, index: number, child: LuaX.ElementNode | nil): self
---@field set_props fun(self: self, props: LuaX.Props): self
---
--- Abstract
---@field get_children fun(self: self): LuaX.NativeComponent[]
---
---@field set_prop fun(self: self, prop: string, value: any)
---@field get_props fun(self: self): LuaX.Props
---@field append_child fun(self: self, child: LuaX.NativeComponent)
---
---@field create_root fun(node: any): LuaX.NativeComponent
---
--- Optional - implement these yourself for speed
---@field count_children fun(self: self): number An optional faster implementation for counting children
---@field get_prop fun(self: self, prop: string): any
---@field get_child fun(self: self, index: number): LuaX.NativeComponent
---@field get_as_element fun(self: self): LuaX.ElementNode
---
---@operator call : LuaX.NativeComponent
local NativeComponent = class("NativeComponent")

---@param element LuaX.ElementNode
function NativeComponent:_append_new_element(element)
    -- Using just NativeComponent here would try to use the abstract class
    ---@type LuaX.NativeComponent
    local ImplementedNativeComponent = self.class

    self:append_child(ImplementedNativeComponent(element.type):set_props(element.props))

    return self
end

function NativeComponent:set_child(index, element)
    -- This seems like a bad idea?
    
    -- element.key = index
    local existing_child = self:get_child(index)

    -- check that they're the same type?!
    if existing_child then
        if not element then
            -- TODO deleete this child
            self:delete_child(index)

            return self
        end

        local props = element.props

        for prop, value in pairs(props) do
            local old_prop = existing_child:get_prop(prop)

            -- TODO i think this needs a deep table
            if old_prop ~= value then
                if prop == "children" then
                    existing_child:set_children(value)
                else
                    existing_child:set_prop(prop, value)
                end
            end
        end
    else
        if not element then
            return self
        end

        return self:_append_new_element(element)
    end

    -- never does anything with this child

    return self
end

function NativeComponent:set_props(props)
    for k, v in pairs(props) do
        if k == "children" then
            self:set_children(v)
        else
            self:set_prop(k, v)
        end
    end

    return self
end

function NativeComponent:count_children()
    return #self:get_children()
end

-- TODO improve optimization here
function NativeComponent:set_children(children)
    local child_count = self:count_children()

    if #children ~= child_count then
        --- clear this fucker out
        for i = 1, child_count do
            self:set_child(i, nil)
        end
    end

    -- this shit whack
    for i, child in ipairs_with_nil(children) do
        self:set_child(i, child)
    end

    return self
end

-- Obviously these can be overridden for speed but they exist by default
function NativeComponent:get_child(index)
    return self:get_children()[index]
end

function NativeComponent:get_prop(prop)
    return self:get_props()[prop]
end

function NativeComponent:get_as_element()
    return {
        type = "NATIVE_COMPONENT",
        props = self:get_props()
    }
end

return NativeComponent
