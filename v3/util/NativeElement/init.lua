local class = require("lib.30log")
-- local ipairs_with_nil = require("v3.util.ipairs_with_nil")
-- local FunctionComponentInstance = require("v3.util.FunctionComponentInstance")

---@class LuaX.NativeElement : Log.BaseFunctions
---@field protected _key integer
---@field set_key fun(self: self, key: integer)
---@field get_key fun(self: self): integer
---
--- Abstract Methods
---@field set_prop fun(self: self, prop: string, value: any)
---@field set_child fun(self: self, index: number, element: LuaX.NativeElement | nil)
---
---@field create_element fun(type: string): LuaX.NativeElement
---@field get_root fun(native: any): LuaX.NativeElement Convert a passed object to a root node
---
--- TODO switch to insert_child(index) and delete_child(indexes) in order to allow element key stuff. 
--- TODO should be a table.insert(list, item, pos) in most cases
---
--- Optional Methods (recommended)
---@field get_type fun(self: self): string
---@field create_literal fun(value: string): LuaX.NativeElement TODO special rules here?
---
---@field get_children fun(self: self): LuaX.NativeElement[]
---
---@operator call : LuaX.NativeElement
local NativeElement = class("NativeElement")

function NativeElement:init(native)
    self.native = native
end

function NativeElement:set_key(key)
    self._key = key
end

function NativeElement:get_key()
    return self._key
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
