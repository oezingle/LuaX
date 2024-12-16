local class                 = require("lib.30log")
local count_children_by_key = require("src.util.NativeElement.helper.count_children_by_key")
local set_child_by_key      = require("src.util.NativeElement.helper.set_child_by_key")
local list_reduce           = require("src.util.polyfill.list.reduce")
local log                   = require("lib.log")
local VirtualElement       = require("src.util.NativeElement.VirtualElement")

--[[
    - count_children_by_key seems like it could have performance issues.
        - pretty much any key function is probably disaterously slow
]]

-- Helper type
---@alias LuaX.NativeElement.ChildrenByKey LuaX.NativeElement | LuaX.NativeElement.ChildrenByKey[] | LuaX.NativeElement.ChildrenByKey[][]

---@class LuaX.NativeElement : Log.BaseFunctions
---
---@field protected _children_by_key LuaX.NativeElement.ChildrenByKey
---@field get_children_by_key fun(self: self, key: LuaX.Key): LuaX.NativeElement.ChildrenByKey
---@field insert_child_by_key fun(self: self, key: LuaX.Key, child: LuaX.NativeElement)
---@field delete_children_by_key fun(self: self, key: LuaX.Key)
---
---@field set_prop_safe fun (self: self ,prop: string, value: any)
---@field set_prop_virtual fun (self: self, prop: string, value: any)
---@field protected _virtual_props table<string, any>
---
--- Abstract Methods
---@field set_prop fun(self: self, prop: string, value: any)
---@field insert_child fun(self: self, index: number, element: LuaX.NativeElement, is_text: boolean)
---@field delete_child fun(self: self, index: number, is_text: boolean)
---
---@field create_element fun(type: string): LuaX.NativeElement
---@field get_root fun(native: any): LuaX.NativeElement Convert a passed object to a root node
---
--- Optional Methods (recommended)
---@field get_type  nil | fun(self: self): string
---@field create_literal nil | fun(value: string, parent: LuaX.NativeElement): LuaX.NativeElement TODO special rules here?
---
---@field get_prop nil|fun(self: self, prop: string): any
---
---@field cleanup nil|fun(self: self)
---
---@field components string[]? class static property - components implemented by this class.
---@operator call : LuaX.NativeElement
local NativeElement = class("NativeElement")

NativeElement._dependencies = {}

---@type LuaX.NativeTextElement
NativeElement._dependencies.NativeTextElement = nil

function NativeElement:init()
    error("NativeElement must be extended to use for components")
end

function NativeElement:get_type_safe ()
    return self.get_type and self:get_type() or "UNKNOWN"
end 

function NativeElement:get_children_by_key(key)
    local children = self._children_by_key

    return list_reduce(key, function(children, key_slice)
        if not children then
            return nil
        end

        -- TODO could be a nice warning?
        --[[
        if children.class then
            warn("Child NativeElement but expected keyed")
        end
        ]]

        return children[key_slice]
    end, children or {})
end

function NativeElement:set_prop_virtual(prop, value)
    self._virtual_props = self._virtual_props or {}

    self._virtual_props[prop] = value

    self:set_prop(prop, value)
end

--- Set props, using virtual props if get_props isn't implemented, or set_prop if it is
function NativeElement:set_prop_safe(prop, value)
    if self.get_prop ~= NativeElement.get_prop then
        ---@diagnostic disable-next-line:inject-field
        self.class.set_prop_safe = self.set_prop
    else
        ---@diagnostic disable-next-line:inject-field
        self.class.set_prop_safe = self.set_prop_virtual
    end

    -- magicially replaced
    self:set_prop_safe(prop, value)
end

function NativeElement:get_prop(prop)
    self._virtual_props = self._virtual_props or {}

    return self._virtual_props[prop]
end

function NativeElement:count_children_by_key (key)
    return count_children_by_key(self._children_by_key, key)
end

-- TODO this block is probably part of the reason only 1 literal can be rendered
function NativeElement:insert_child_by_key(key, child)
    if not self._children_by_key then
        self._children_by_key = {}
    end

    if child.class ~= VirtualElement then
        local insert_index = self:count_children_by_key(key) + 1

        local NativeTextElement = self._dependencies.NativeTextElement
    
        local is_text = NativeTextElement and NativeTextElement:classOf(child.class) or false
    
        log.trace("insert child", child:get_type(), insert_index)

        self:insert_child(insert_index, child, is_text)
    end

    -- Insert this child into the key table
    set_child_by_key(self._children_by_key, key, child)
end

-- TODO does key_children work here for Fragment(Fragment(..elements..)) ?
function NativeElement:delete_children_by_key(key)
    log.trace(self:get_type(), "delete_children_by_key", table.concat(key, "."))
    
    -- No need to delete anything
    if not self._children_by_key then
        self._children_by_key = {}
    end

    local delete_end = count_children_by_key(self._children_by_key, key)

    local key_children = self:get_children_by_key(key)

    -- already no child here
    if not key_children then
        return
    end

    -- enforce table
    if key_children.class then
        key_children = { key_children }
    end

    local delete_start = delete_end - #key_children

    -- iterate backwards
    for i = #key_children, 1, -1 do
        local child_index = delete_start + i

        local child = key_children[i]

        child:cleanup()

        local NativeTextElement = self._dependencies.NativeTextElement

        local is_text = NativeTextElement and NativeTextElement:classOf(child.class) or false

        if child.class ~= VirtualElement then
            self:delete_child(child_index, is_text)
        end
    end

    set_child_by_key(self._children_by_key, key, nil)
end

-- Default implementation does nothing!
function NativeElement:cleanup() end

function NativeElement.create_element(element_type)
    if type(element_type) ~= "string" then
        error("NativeElement cannot render non-pure component")
    end

    return NativeElement()
end

--- Get class. Don't even think about overriding this.
---@return LuaX.NativeElement
function NativeElement:get_class()
    return self.class
end

--- Set multiple props at once
---@param props table<string, any>
function NativeElement:set_props(props)
    for prop, value in pairs(props) do
        if prop ~= "children" then
            self:set_prop(prop, value)
        end
    end
end

---@param children LuaX.NativeElement.ChildrenByKey
function NativeElement.recursive_children_string (children)
    if type(children) ~= "table" then
        return tostring(children)
    end
    
    if #children ~= 0 then
        local children_strs = {}

        for index, child in ipairs(children) do
            table.insert(children_strs, NativeElement.recursive_children_string(child))
        end

        return string.format("{ %s }", table.concat(children_strs, ", "))
    else
        --[[
        for k, v in pairs(children) do
            print("", k, v)
        end
        ]]

        return "Child " .. tostring(children)
    end
end

-- TODO maybe strip this? Addresses are important!
function NativeElement:__tostring()
    local component = self:get_type_safe()

    local children = NativeElement.recursive_children_string(self._children_by_key)

    return component .. " " .. children
end

return NativeElement
