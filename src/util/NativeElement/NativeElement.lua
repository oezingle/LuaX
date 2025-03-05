local class                 = require("lib.30log")
local count_children_by_key = require("src.util.NativeElement.helper.count_children_by_key")
local set_child_by_key      = require("src.util.NativeElement.helper.set_child_by_key")
local list_reduce           = require("src.util.polyfill.list.reduce")
local VirtualElement        = require("src.util.NativeElement.VirtualElement")
local flatten_children      = require("src.util.NativeElement.helper.flatten_children")
local DrawGroup             = require("src.util.Renderer.DrawGroup")

local table_pack = require("src.util.polyfill.table.pack")
local table_unpack = require("src.util.polyfill.table.unpack")
local traceback = require("src.util.debug.traceback")

---@alias LuaX.NativeElement.ChildrenByKey LuaX.NativeElement | LuaX.NativeElement.ChildrenByKey[] | LuaX.NativeElement.ChildrenByKey[][]

---@class LuaX.NativeElement : Log.BaseFunctions
---
---@field private _children_by_key LuaX.NativeElement.ChildrenByKey
---@field get_children_by_key fun(self: self, key: LuaX.Key): LuaX.NativeElement.ChildrenByKey
---@field insert_child_by_key fun(self: self, key: LuaX.Key, child: LuaX.NativeElement)
---@field delete_children_by_key fun(self: self, key: LuaX.Key)
---@field private count_children_by_key fun(self: self, key: LuaX.Key, ignore_virtual?: boolean): number
---@field private set_child_by_key fun(self: self, key: LuaX.Key, child: LuaX.NativeElement | nil)
---@field private flatten_children fun(self: self, key: LuaX.Key): { element: LuaX.NativeElement, key: LuaX.Key }[]
---
---@field set_prop_safe fun (self: self ,prop: string, value: any)
---@field private set_prop_virtual fun (self: self, prop: string, value: any)
---@field private _virtual_props table<string, any>
---
---@field set_render_name fun(self: self, name: string)
---@field get_render_name fun(self: self): string name
---
--- Abstract Methods
---@field set_prop fun(self: self, prop: string, value: any)
---@field insert_child fun(self: self, index: number, element: LuaX.NativeElement, is_text: boolean)
---@field delete_child fun(self: self, index: number, is_text: boolean)
---
---@field create_element fun(type: string): LuaX.NativeElement
---@field get_root fun(native: any): LuaX.NativeElement Convert a passed object to a root node
---@field get_native fun(self: self): any Get this element's native (UI library) representation.
---
--- Optional Methods (recommended)
---@field get_name  nil | fun(self: self): string Return a friendly name for this element
---@field create_literal nil | fun(value: string, parent: LuaX.NativeElement): LuaX.NativeElement
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

function NativeElement:get_render_name()
    return self.__render_name
end

function NativeElement:set_render_name(name)
    self.__render_name = name
end

-- Child classes are recommended to overload.
function NativeElement:get_name ()
    return self:get_render_name() or "unknown NativeElement"
end

function NativeElement:get_children_by_key(key)
    local children = self._children_by_key

    return list_reduce(key, function(children, key_slice)
        if not children then
            return nil
        end

        return children[key_slice]
    end, children or {})
end

function NativeElement:set_prop_virtual(prop, value)
    self._virtual_props = self._virtual_props or {}

    self._virtual_props[prop] = value

    self:set_prop(prop, value)
end

local NativeElement_function_cache = setmetatable({}, { __mode = "kv" })

--- Set props, using virtual props if get_props isn't implemented, or set_prop if it is
function NativeElement:set_prop_safe(prop, value)
    local prop_method = self.get_prop ~= NativeElement.get_prop and
        self.set_prop or self.set_prop_virtual

    if type(value) == "function" then
        local cached = NativeElement_function_cache[value]
        if cached then
            prop_method(self, prop, cached)
        else
            local group = DrawGroup.current()

            local fn = function (...)
                local ret = table_pack(xpcall(value, traceback, ...))

                local ok = ret[1]

                if not ok then
                    DrawGroup.error(group, table_unpack(ret, 2))
                    return
                end

                return table_unpack(ret, 2)
            end

            NativeElement_function_cache[value] = fn

            prop_method(self, prop, fn)
        end
    else
        prop_method(self, prop, value)
    end
end

function NativeElement:get_prop(prop)
    self._virtual_props = self._virtual_props or {}

    return self._virtual_props[prop]
end

--- Count children up to and including the given key,
--- returning the flat index of the end of the given key
---@param key LuaX.Key
---@param include_virtual boolean?
function NativeElement:count_children_by_key(key, include_virtual)
    return count_children_by_key(self._children_by_key, key, include_virtual)
end

---@param key LuaX.Key
---@param child LuaX.NativeElement | nil
function NativeElement:set_child_by_key(key, child)
    return set_child_by_key(self._children_by_key, key, child)
end

---@param key LuaX.Key
function NativeElement:flatten_children(key)
    local children = self:get_children_by_key(key)

    return flatten_children(children, key)
end

function NativeElement:insert_child_by_key(key, child)
    -- log.trace(self:get_name(), "insert_child_by_key", key_to_string(key))

    if not self._children_by_key then
        self._children_by_key = {}
    end

    if child.class ~= VirtualElement then
        local insert_index = self:count_children_by_key(key) + 1

        local NativeTextElement = self._dependencies.NativeTextElement

        local is_text = NativeTextElement and NativeTextElement:classOf(child.class) or false

        -- log.trace(" ↳ insert native child", child:get_name(), tostring(insert_index))

        self:insert_child(insert_index, child, is_text)
    end

    -- Insert this child into the key table
    self:set_child_by_key(key, child)
end

function NativeElement:delete_children_by_key(key)
    -- log.trace(self:get_name(), "delete_children_by_key", key_to_string(key))

    -- No need to delete anything
    if not self._children_by_key then
        self._children_by_key = {}

        return
    end

    local flattened = self:flatten_children(key)

    -- child already deleted. This seems like bad practice but is valid in cases
    -- like ErrorBoundary handling, where a fallback is rendered (therefore
    -- deleting the child by this key) before the child can be deleted by the
    -- render_function_component result handler
    if #flattened == 0 then
        return
    end

    -- count_children_by_key gets the last index of this key
    local delete_index = self:count_children_by_key(key)

    -- Load here to save table indexes in loop
    local NativeTextElement = self._dependencies.NativeTextElement

    -- iterate backwards so delete_child works nicely.
    for i = #flattened, 1, -1 do
        local child = flattened[i].element

        if child.class ~= VirtualElement then
            local is_text = NativeTextElement and
                NativeTextElement:classOf(child.class) or
                false

            -- log.trace(" ↳ delete native child", child:get_name(), tostring(delete_index))

            self:delete_child(delete_index, is_text)

            delete_index = delete_index - 1
        end

        -- calling cleanup after delete_child means that any memory management
        -- functionality won't result in unexpected behaviour.
        child:cleanup()
    end

    self:set_child_by_key(key, nil)
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

return NativeElement
