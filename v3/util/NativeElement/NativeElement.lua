local class                 = require("lib.30log")
local count_children_by_key = require("v3.util.NativeElement.helper.count_children_by_key")
local set_child_by_key      = require("v3.util.NativeElement.helper.set_child_by_key")


-- Helper type
---@alias LuaX.NativeElement.ChildrenByKey LuaX.NativeElement  | LuaX.NativeElement.ChildrenByKey[] | LuaX.NativeElement.ChildrenByKey[][]

---@class LuaX.NativeElement : Log.BaseFunctions
-- ---@field protected _key integer
-- ---@field set_key fun(self: self, key: integer)
-- ---@field get_key fun(self: self): integer
---
---@field protected _children_by_key LuaX.NativeElement.ChildrenByKey
---@field _get_key_insert_index fun(self: self, key: LuaX.Key): integer Helper function to get index
---@field get_children_by_key fun(self: self, key: LuaX.Key)
---@field insert_child_by_key fun(self: self, key: LuaX.Key, child: LuaX.NativeElement)
---@field delete_children_by_key fun(self: self, key: LuaX.Key)
---
---@field set_prop_safe fun (self: self ,prop: string, value: any)
---@field set_prop_virtual fun (self: self, prop: string, value: any)
---@field _virtual_props table<string, any>
---
--- Abstract Methods
---@field set_prop fun(self: self, prop: string, value: any)
---@field insert_child fun(self: self, index: number, element: LuaX.NativeElement)
---@field delete_child fun(self: self, index: number)
---
---@field create_element fun(type: string): LuaX.NativeElement
---@field get_root fun(native: any): LuaX.NativeElement Convert a passed object to a root node
---
--- Optional Methods (recommended)
---@field get_type  nil | fun(self: self): string
---@field create_literal nil | fun(value: string): LuaX.NativeElement TODO special rules here?
---
---@field get_prop fun(self: self, prop: string): any
---
---@operator call : LuaX.NativeElement
local NativeElement = class("NativeElement")

function NativeElement:init()
    error("NativeElement must be extended to use for components")
end

--[[
-- TODO does storing these values actually matter?
function NativeElement:set_key(key)
    self._key = key
end
function NativeElement:get_key()
    return self._key
end
]]

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

    -- magic
    self:set_prop_safe(prop, value)
end

function NativeElement:get_prop(prop)
    self._virtual_props = self._virtual_props or {}

    return self._virtual_props[prop]
end

--- Get the real insert position for a child of a given key.
function NativeElement:_get_key_insert_index(key)
    if not self._children_by_key then
        self._children_by_key = {}
    end

    local count = count_children_by_key(self._children_by_key, key)

    --[[
    io.stdout:write("key =")
    for _, value in ipairs_with_nil(key) do
        io.stdout:write(value, " ")
    end
    print()

    print("count =", count)
    ]]

    return count + 1
end

function NativeElement:insert_child_by_key(key, child)
    -- child:set_key(key)

    local insert_index = self:_get_key_insert_index(key)

    -- Insert this child into the key table
    set_child_by_key(self._children_by_key, key, child)

    self:insert_child(insert_index, child)
end

function NativeElement:delete_children_by_key(key)
    local delete_start = self:_get_key_insert_index(key)

    local key_children = self._children_by_key[key] or {}

    for i = 0, #key_children - 1 do
        self:delete_child(delete_start + i)
    end

    set_child_by_key(self._children_by_key, key, nil)
end

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

--- Set class of this instance
function NativeElement:set_props(props)
    for prop, value in pairs(props) do
        if prop ~= "children" then
            self:set_prop(prop, value)
        end
    end
end

return NativeElement
