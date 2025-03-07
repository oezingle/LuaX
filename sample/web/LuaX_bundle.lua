-- Bundled by luabundle {"version":"1.7.0"}
local __bundle_require, __bundle_loaded, __bundle_register, __bundle_modules = (function(superRequire)
	local loadingPlaceholder = {[{}] = true}

	local register
	local modules = {}

	local require
	local loaded = {}

	register = function(name, body)
		if not modules[name] then
			modules[name] = body
		end
	end

	require = function(name)
		local loadedModule = loaded[name]

		if loadedModule then
			if loadedModule == loadingPlaceholder then
				return nil
			end
		else
			if not modules[name] then
				if not superRequire then
					local identifier = type(name) == 'string' and '\"' .. name .. '\"' or tostring(name)
					error('Tried to require ' .. identifier .. ', but no such module has been registered')
				else
					return superRequire(name)
				end
			end

			loaded[name] = loadingPlaceholder
			loadedModule = modules[name](require, loaded, register, modules)
			loaded[name] = loadedModule
		end

		return loadedModule
	end

	return require, loaded, register, modules
end)(require)
__bundle_register("__root", function(require, _LOADED, __bundle_register, __bundle_modules)
local Inline     = require("src.util.parser.Inline")
local LuaXParser = require("src.util.parser.LuaXParser")

local runtime    = require("src.entry.runtime")

local _VERSION   = "0.5.0-dev"

---@class LuaX : LuaX.Runtime
--- Parsing
---@field register fun() Register the LuaX loader
---@field Parser LuaX.Parser.V3
---@field transpile { from_path: (fun(path: string): string), from_string: (fun(content: string, source?: string): string), inline: (fun(tag: string): string)|(fun(fn: function): function) }
---
---@operator call:function

local export     = {
    NativeElement     = require("src.util.NativeElement"),
    NativeTextElement = require("src.util.NativeElement.NativeTextElement"),

    register          = require("src.util.parser.loader.register"),
    Parser            = LuaXParser,
    transpile         = {
        ---@param path string
        from_path = function(path)
            return LuaXParser.from_file_path(path):transpile()
        end,
        ---@param content string
        ---@param source string?
        from_string = function(content, source)
            return LuaXParser.from_file_content(content, source):transpile()
        end,
        inline = function(tag)
            return Inline:transpile(tag)
        end
    },

    _VERSION          = _VERSION
}

-- copy fields directly
for k, v in pairs(runtime) do
    export[k] = v
end

export.create_context = export.Context.create
export.create_portal  = export.Portal.create


local element_implementations = {}

-- Load any enabled targets
-- TODO this code is AWFUL. Find a fix compatible with the bundler.
do
    if not true then
        local ok, err = pcall(function()
            element_implementations.WiboxElement = require("src.util.NativeElement.WiboxElement")
        end)
        if not ok then
            element_implementations.WiboxElement = err
        end
    end
    if not true then
        local ok, err = pcall(function()
            element_implementations.GtkElement = require("src.util.NativeElement.GtkElement")
        end)
        if not ok then
            element_implementations.GtkElement = err
        end
    end
    if not SKIP_TARGET_WebElement then
        local ok, err = pcall(function()
            element_implementations.WebElement = require("src.util.NativeElement.WebElement")
        end)
        if not ok then
            element_implementations.WebElement = err
        end
    end
end


setmetatable(export, {
    __call = function(t, tag)
        return t.transpile.inline(tag)
    end,
    __index = function(_, k)
        local implementation = element_implementations[k]
        if type(implementation) == "string" then
            error(implementation)
        else
            return implementation
        end
    end
})

local ensure_warn = require("src.util.ensure_warn")
ensure_warn()

return export

end)
__bundle_register("src.util.ensure_warn", function(require, _LOADED, __bundle_register, __bundle_modules)
---@nospec

local table_pack   = require("src.util.polyfill.table.pack")

-- Some flavours of lua don't provide warn()

local warn_enabled = false

---@param ... string
---@return boolean
local function test_control_flag(...)
    local arg1 = ({ ... })[1]

    if arg1 == "@on" then
        warn_enabled = true

        -- we don't want to print "@on"
        return false
    elseif arg1 == "@off" then
        warn_enabled = false
    end

    return warn_enabled
end

local function nocolor_warn(...)
    if test_control_flag(...) then
        print("Lua warning:", ...)
    end
end

local colors = {
    --RED = "\27[31m",
    YELLOW = "\27[33m",
    RESET = '\27[0m',
}
local function color_warn(...)
    if test_control_flag(...) then
        io.stdout:write(colors.YELLOW)

        io.stdout:write(table.concat(table_pack(...), "\t"))

        io.stdout:write(colors.RESET, "\n")
    end
end

local os_getenv = (os or {}).getenv

local function ensure_warn()
    -- some lua environments provide warn()
    if warn then
        return
    end

    local term = os_getenv and os_getenv("TERM") or ""

    if term:match("xterm") then
        warn = color_warn
    else
        warn = nocolor_warn
    end
end

return ensure_warn

end)
__bundle_register("src.util.polyfill.table.pack", function(require, _LOADED, __bundle_register, __bundle_modules)

local table_pack = table.pack or function (...)
    local t = {...}

    -- luajit (lua 5.1?) is sometimes bad at ascertaining the length of a packed table.
    local len = select("#", ...)
    t['n'] = len

    return t
end

return table_pack
end)
__bundle_register("src.util.NativeElement.WebElement", function(require, _LOADED, __bundle_register, __bundle_modules)
local NativeElement = require("src.util.NativeElement")
local NativeTextElement = require("src.util.NativeElement.NativeTextElement")

local js = require("js")
local document = js.global.document
local null = js.null

---@class LuaX.WebElement : LuaX.NativeElement
local WebElement = NativeElement:extend("WebElement (fengari)")

function WebElement:init(node)
    self.node = node

    self.events_registered = {}
    self.event_listeners = {}
end

---@protected
function WebElement:get_trailing_children(index)
    local children = self.node.childNodes

    local after = {}
    for i = index, #children do
        local child = children[i]
        table.insert(after, child)

        -- TODO is this the best way to do this??
        child:remove()
    end

    return after
end

function WebElement:reinsert_trailing_children(list)
    for _, child in ipairs(list) do
        self.node:append(child)
    end
end

function WebElement:insert_child(index, element)
    local trailing = self:get_trailing_children(index)

    self.node:append(element.node)

    self:reinsert_trailing_children(trailing)
end

function WebElement:delete_child(index)
    local child = self.node.childNodes[index]

    child:remove()
end

function WebElement:set_prop(prop, value)
    if prop:sub(1, 2) == "on" and type(value) == "function" then
        local event = prop:sub(3)

        if not self.events_registered[event] then
            local listeners = self.event_listeners

            -- removeEventListener doesn't work (because fengari-interop
            -- re-marshalls the handler) so I have to create a throwaway handler
            self.node:addEventListener (event, function (e)
                local listener = listeners[event]
                if listener then
                    listener(e)
                end
            end)

            self.events_registered[event] = true
        end

        self.event_listeners[event] = value
    else
        self.node:setAttribute(prop, value)
    end
end

function WebElement:get_prop(prop)
    -- TODO getAttribute doesn't work??

    return self.node.attributes[prop]
end

function WebElement.get_root(native)
    assert(native ~= null, "WebElement root may not be null")

    return WebElement(native)
end

function WebElement:get_native()
    return self.node
end

function WebElement.create_element(name)
    local node = document:createElement(name)

    return WebElement(node)
end

---@class LuaX.WebText : LuaX.NativeTextElement
local WebText = NativeTextElement:extend("WebText")

function WebText:init(node)
    self.node = node
end

function WebText:set_value(value)
    self.node.data = value
end

function WebText:get_value()
    return self.node.data
end

function WebElement.create_literal(value)
    local node = document:createTextNode(value)

    return WebText(node)
end

return WebElement

end)
__bundle_register("src.util.NativeElement.NativeTextElement", function(require, _LOADED, __bundle_register, __bundle_modules)

local NativeElement = require("src.util.NativeElement")
local ElementNode   = require("src.util.ElementNode")

---@class LuaX.NativeTextElement : LuaX.NativeElement
---@field protected parent LuaX.NativeElement
---@field init fun (self: self, props: string, parent: LuaX.NativeElement)
---
--- Abstract fields
---@field get_value fun (self: self): string
---@field set_value fun(self: self, value: string)
local NativeTextElement = NativeElement:extend("NativeTextElement")

NativeElement._dependencies.NativeTextElement = NativeTextElement

-- Doesn't export anything as this is a helper class for NativeElement subclasses
NativeTextElement.components = {}

function NativeTextElement:init (value, parent)
    self.parent = parent

    self:set_value(value)
end

function NativeTextElement:set_prop(prop, value)
    if prop ~= "value" then
        error("Literal nodes do not support props other than value")
    end

    self:set_value(value)
end

function NativeTextElement:get_prop (prop)
    if prop ~= "value" then
        return nil
    end

    return self:get_value()
end

--[[
function NativeTextElement:set_value(value)
    self.parent:set_prop("value", value)
end
]]

function NativeTextElement:insert_child()
    error("NativeTextElement may not have children")
end
function NativeTextElement:delete_child()
    error("NativeTextElement may not have children")
end

function NativeTextElement:get_render_name()
    ---@diagnostic disable-next-line:invisible
    return ElementNode.LITERAL_NODE
end

return NativeTextElement
end)
__bundle_register("src.util.ElementNode", function(require, _LOADED, __bundle_register, __bundle_modules)
local ipairs_with_nil = require("src.util.ipairs_with_nil")
local get_function_location = require("src.util.debug.get_function_location")

---@alias LuaX.ElementNode.LiteralNode string

---@alias LuaX.ElementNode.Child false | string | LuaX.ElementNode | nil
---@alias LuaX.ElementNode.Children LuaX.ElementNode.Child | (LuaX.ElementNode.Child)[]

--[[
    returning to a super old comment i left here - see
    spec/special/table_equality_slow.lua

    in terms of why tables are slower than strings, I realized it's becaues of
    Lua's string 'baking' - when transforming to bytecode, strings are converted
    to IDs. Accessing these is faster than loading and checking 2 upvalues, even
    if local (by number) as opposed to global (by name)
]]

---TODO FIXME add generics
---@class LuaX.ElementNode
---
--- Instance properties
---@field type LuaX.Component
---@field props LuaX.Props
---
---@field protected element_node self
---
---@field inherit_props fun(self: self, inherit_props: LuaX.Props): self
---@field create fun(component: LuaX.Component | LuaX.ElementNode.LiteralNode, props: LuaX.Props): self
---@field protected LITERAL_NODE LuaX.ElementNode.LiteralNode unique key
---
local ElementNode = {
    LITERAL_NODE = "LUAX_LITERAL_NODE", -- this table is used for its unique key
}

--- Process any possible value for "children" into a list of ElementNodes
---@param children LuaX.ElementNode.Children
---@protected
function ElementNode.clean_children(children)
    -- Convert children to list. This getmetatable usage is apparently
    -- recommended https://github.com/Yonaba/30log/wiki/Instances
    if not children or type(children) == "string" or children.element_node == ElementNode then
        children = { children }
    end

    ---@type (LuaX.ElementNode.Child)[]
    local children = children

    for i, _ in ipairs_with_nil(children) do
        -- Terrible fix for the language server. affects performance very
        -- marginally for sure but i don't wanna change it
        ---@type LuaX.ElementNode.Child
        local child = children[i]

        local child_type = type(child)

        if not child then
            child = nil
        elseif child_type ~= "table" then
            if child_type == "function" then
                warn(string.format(
                    "passed a chld function (defined at %s) as a literal. Are you sure you didn't mean to call create_element()?",
                    get_function_location(child)
                ))
            end

            child = ElementNode.create(ElementNode.LITERAL_NODE, { value = tostring(child) })
        end

        children[i] = child
    end

    return children
end

function ElementNode.create(component, props)
    props.children = ElementNode.clean_children(props.children)

    local node = {
        type = component,
        props = props,
        element_node = ElementNode,
    }

    return node
end

---@overload fun (component: LuaX.ElementNode): boolean
---@param component LuaX.Component
---@return boolean
function ElementNode.is_literal (component)
    if type(component) == "table" then
        return ElementNode.is_literal(component.type)
    end
    
    return component == ElementNode.LITERAL_NODE
end

return ElementNode

end)
__bundle_register("src.util.debug.get_function_location", function(require, _LOADED, __bundle_register, __bundle_modules)

--- This is the best lua gives us for getting function names, as getinfo will only return a name if we give it a stack depth.
---@param fn function
---@return string
local function get_function_location (fn)
    if not debug then
        return "UNKNOWN (no debug library)"
    end

    if not debug.getinfo then
        return "UNKNOWN (no debug.getinfo)"
    end

    local ok, ret = pcall(function ()
        local info = debug.getinfo(fn, "S")

        if info.source == "[C]" then
            return "[C]"
        end

        local location = info.source:sub(2) .. ":" .. info.linedefined

        return location
    end)

    if ok then
        return ret
    end

    return "UNKNOWN (error calling debug.getinfo)"
end

return get_function_location
end)
__bundle_register("src.util.ipairs_with_nil", function(require, _LOADED, __bundle_register, __bundle_modules)

---@generic T
---@param list T[]
---@param length integer?
---@return fun(): (number, T)
local function ipairs_with_nil (list, length)
    local max = length or #list

    local index = 0

    return function ()
        if index == max then
            return nil
        end

        index = index + 1

        local item = list[index]

        return index, item
    end
end 

return ipairs_with_nil
end)
__bundle_register("src.util.NativeElement", function(require, _LOADED, __bundle_register, __bundle_modules)
---@nospec

-- see decisions/no_code_init.md

return require("src.util.NativeElement.NativeElement")
end)
__bundle_register("src.util.NativeElement.NativeElement", function(require, _LOADED, __bundle_register, __bundle_modules)
local class                                   = require("lib.30log")
local count_children_by_key                   = require("src.util.NativeElement.helper.count_children_by_key")
local set_child_by_key                        = require("src.util.NativeElement.helper.set_child_by_key")
local list_reduce                             = require("src.util.polyfill.list.reduce")
local VirtualElement                          = require("src.util.NativeElement.VirtualElement")
local flatten_children                        = require("src.util.NativeElement.helper.flatten_children")
local DrawGroup                               = require("src.util.Renderer.DrawGroup")

local table_pack                              = require("src.util.polyfill.table.pack")
local table_unpack                            = require("src.util.polyfill.table.unpack")
local traceback                               = require("src.util.debug.traceback")

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
---@field set_prop_safe fun (self: self, prop: string, value: any)
---@field private set_prop_virtual fun (self: self, prop: string, value: any)
---@field private _virtual_props table<string, any>
---@field get_prop_safe fun (self: self, prop: string): any
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
local NativeElement                           = class("NativeElement")

NativeElement._dependencies                   = {}

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
function NativeElement:get_name()
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

-- TODO test function cache before using it - it should memoize nicely (i know it doesn't lol)
-- Table of { protected = original } functions for get_prop_safe
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

            NativeElement_function_cache[fn] = value

            prop_method(self, prop, fn)
        end
    else
        prop_method(self, prop, value)
    end
    prop_method(self, prop, value)
end

function NativeElement:get_prop_safe(prop)
    local value = self:get_prop(prop)

    if type(value) == "function" then
        local cached = NativeElement_function_cache[value]
        if cached then
            return cached
        end
    end

    return value
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

end)
__bundle_register("src.util.debug.traceback", function(require, _LOADED, __bundle_register, __bundle_modules)

return (debug or {}).traceback or function (msg) return tostring(msg) .. "\n(trace unavailable)" end
end)
__bundle_register("src.util.polyfill.table.unpack", function(require, _LOADED, __bundle_register, __bundle_modules)

---@diagnostic disable-next-line:deprecated
local table_unpack = table.unpack or unpack

return table_unpack
end)
__bundle_register("src.util.Renderer.DrawGroup", function(require, _LOADED, __bundle_register, __bundle_modules)
local RenderInfo = require("src.util.Renderer.RenderInfo")

---@alias LuaX.DrawGroup.OnComplete fun()
---@alias LuaX.DrawGroup.OnRestart fun()
---@alias LuaX.DrawGroup.OnError fun(err: any)

---@class LuaX.DrawGroup.Group
---@field refs integer
---@field on_error LuaX.DrawGroup.OnError
---@field on_complete LuaX.DrawGroup.OnComplete
---@field on_restart LuaX.DrawGroup.OnRestart

---@class LuaX.DrawGroup
local DrawGroup = {}

---@param on_error LuaX.DrawGroup.OnError
---@param on_complete LuaX.DrawGroup.OnComplete
---@param on_restart LuaX.DrawGroup.OnRestart
---@return LuaX.DrawGroup.Group
function DrawGroup.create(on_error, on_complete, on_restart)
    return {
        refs = 1,
        on_error = on_error,
        on_complete = on_complete,
        on_restart = on_restart,
    }
end

---@param group LuaX.DrawGroup.Group
function DrawGroup.ref(group)
    group.refs = group.refs + 1

    if group.refs <= 1 then
        group.on_restart()
    end
end

---@param group LuaX.DrawGroup.Group
function DrawGroup.unref(group)
    group.refs = group.refs - 1

    if group.refs <= 0 then
        group.on_complete()
    end
end

function DrawGroup.current()
    return RenderInfo.get().draw_group
end

---@param group LuaX.DrawGroup.Group?
function DrawGroup.error(group, ...)
    group = group or DrawGroup.current()

    group.on_error(...)
end

return DrawGroup

end)
__bundle_register("src.util.Renderer.RenderInfo", function(require, _LOADED, __bundle_register, __bundle_modules)
---@class LuaX.RenderInfo.Info.Minimal
---@field key LuaX.Key
---@field container LuaX.NativeElement
---@field renderer LuaX.Renderer

---@class LuaX.RenderInfo.Info : LuaX.RenderInfo.Info.Minimal
---@field context table<LuaX.Context<any>, any>
---@field draw_group LuaX.DrawGroup.Group

---@class LuaX.RenderInfo 
---@field current LuaX.RenderInfo.Info
local RenderInfo = {}

---@param new LuaX.RenderInfo.Info.Minimal
---@param old LuaX.RenderInfo.Info?
---@return LuaX.RenderInfo.Info
function RenderInfo.inherit (new, old)
    new = new --[[ @as LuaX.RenderInfo.Info ]]
    
    old = old or RenderInfo.get()

    if not old then
        return new
    end

    -- Inherit contexts
    local old_context = old.context

    new.context = new.context or {}
    local new_context = new.context
    for k, v in pairs(old_context) do
        new_context[k] = v
    end

    -- Inherit draw group
    new.draw_group = old.draw_group

    return new
end

---@return LuaX.RenderInfo.Info
function RenderInfo.get () 
    return RenderInfo.current
end

---@param info LuaX.RenderInfo.Info
function RenderInfo.set (info)
    local old = RenderInfo.get()

    RenderInfo.current = info

    return old
end

--- Bind Render info to props
---@param props LuaX.Props
---@param info LuaX.RenderInfo.Info
---@return LuaX.Props.WithInternal
function RenderInfo.bind(props, info)
    -- props are only set here to check for changes in render-dependent
    -- internals. Keying by int is probably faster than by string.
    props.__luax_internal = {
        info.context
    }

    return props
end

---@param info LuaX.RenderInfo.Info
---@return LuaX.RenderInfo.Info
function RenderInfo.clone (info)
    local ret = {}
    for k,v in pairs(info) do
        ret[k] = v
    end
    return ret
end

--[[
--- Retrieve render info from props
---@return LuaX.RenderInfo.Info
function RenderInfo.retrieve(props)
    return props.__luax_internal
end
]]

return RenderInfo
end)
__bundle_register("src.util.NativeElement.helper.flatten_children", function(require, _LOADED, __bundle_register, __bundle_modules)

local key_add = require("src.util.key.key_add")
local ipairs_with_nil = require("src.util.ipairs_with_nil")

---@param children_by_key LuaX.NativeElement.ChildrenByKey
---@param key LuaX.Key
---@param elements { element: LuaX.NativeElement, key: LuaX.Key }[]?
local function flatten_children (children_by_key, key, elements)
    elements = elements or {}

    if not children_by_key then
        -- nil is allowed, we just ignore    
    elseif children_by_key.class then
        table.insert(elements, { 
            key = key,
            element = children_by_key --[[ @as LuaX.NativeElement ]]
        })
    else
        for i, entry in ipairs_with_nil(children_by_key) do
            local new_key = key_add(key, i)

            flatten_children(entry, new_key, elements)
        end
    end

    return elements
end

return flatten_children
end)
__bundle_register("src.util.key.key_add", function(require, _LOADED, __bundle_register, __bundle_modules)

local table_unpack = require("src.util.polyfill.table.unpack")

---@param key LuaX.Key
---@param value number
---@return LuaX.Key
local function key_add(key, value)
    local copy = { table_unpack(key) }

    table.insert(copy, value)

    return copy
end

return key_add
end)
__bundle_register("src.util.NativeElement.VirtualElement", function(require, _LOADED, __bundle_register, __bundle_modules)
-- Virtual element - class to hold, eg, FunctionComponentInstance.

local class                     = require("lib.30log")
local FunctionComponentInstance = require("src.util.FunctionComponentInstance")
local deep_equals              = require("src.util.deep_equals")

--- This class doesn't actually extend NativeElement because
---  1. VirtualElement's minimal API is all that is needed for its specific use
---     case
--- 2. This minimal API saves memory
--- 3. There are some diamond dependencies that would be created by importing
---    NativeElement
---
--- I didn't create a LuaX.NativeElement.Minimal class or anything because I am
--- in somewhat of a spat with the language server's types system
---
---@class LuaX.NativeElement.Virtual : LuaX.NativeElement
---
---@field protected type LuaX.Component
---@field protected props LuaX.Props
---@field protected new_props boolean
---
---@field render function()
local VirtualElement            = class("LuaX.VirtualElement")

function VirtualElement:init(component)
    if type(component) == "function" then
        self.instance = FunctionComponentInstance(component)

        self.type = component
    else
        self.instance = component
    end
end

function VirtualElement:get_render_name()
    return self.type
end

function VirtualElement:set_on_change(callback)
    self.instance:set_on_change(callback)
end

function VirtualElement:insert_child()
    error("A VirtualElement should never interact with children")
end

VirtualElement.delete_child = VirtualElement.insert_child

---@return LuaX.NativeElement.Virtual
function VirtualElement.create_element(type)
    return VirtualElement(type)
end

function VirtualElement.get_root()
    error("VirtualElements exist to host non-native components, and therefore cannot be used as root elements")
end

function VirtualElement:set_props(props)
    -- Identical table references would make searching for prop changes impossible.
    -- Lucikly this rarely happens in real-world scenarios
    if deep_equals(props, self.props, 2) and props ~= self.props then
        -- no change to props, no rerender, ignore!
        return
    end

    self.props = props

    self.new_props = true
end

---@param force boolean?
---@return boolean did_render, LuaX.ElementNode | LuaX.ElementNode[] | nil result
function VirtualElement:render(force)
    if self.new_props or force then
        local result

        repeat 
            local did_render
            did_render, result = self.instance:render(self.props)
        until did_render
        
        self.new_props = false

        return true, result
    else
        return false, nil
    end
end

function VirtualElement:cleanup()
    self.instance:cleanup()
end

return VirtualElement

end)
__bundle_register("src.util.deep_equals", function(require, _LOADED, __bundle_register, __bundle_modules)
local pairs = pairs
local next = next
local type = type
local getmetatable = getmetatable

---@type fun(a: table, b: table, traversed: table): boolean, table
local fchk_table_keys

---@type fun(a: function, b: function, level: number, traversed: table): boolean
local fchk_functions

--- Check if a value is a primitive
---@param value any
---@return boolean
local function is_primitive(value)
    local t = type(value)
    return t == "nil" or t == "string" or t == "number" or t == "boolean"
end

---@param a any first object to check
---@param b any second object to check
---@param level number? to what degree objects should be checked for equality:
--- - 0 - don't delve into tables or userdata metatables. ignore functions, threads
--- - 1 - ignore functions, threads
--- - 2 - return false for functions (if missing debug), threads
--- - 3 - error for function / thread / userdata values that cannot be checked
---@param traversed table<any, any[]>? Internally used to track objects that are accounted for
local function deep_equals(a, b, level, traversed)
    level = level or 3

    traversed = traversed or {}

    -- Check if both values have been traversed with respect to each other already
    do
        local traversed_a = traversed[a]
        local traversed_b = traversed[b]
        if traversed_a and traversed_b and traversed_a[b] and traversed_b[a] then
            return true
        end
    end

    if a == b then
        return true
    end
    local t = type(a)
    -- Type mismatch
    if t ~= type(b) then
        return false
    end

    if t == "function" then
        return fchk_functions(a, b, level, traversed)
    end

    if t == "userdata" then
        if level < 1 then
            return true
        end

        if not deep_equals(getmetatable(a), getmetatable(b), nil, traversed) then
            return false
        end

        -- make sure we have pairs
        if getmetatable(a).__pairs then
            if not fchk_table_keys(a, b, traversed) then
                return false
            end

            for k, value_a in pairs(a) do
                local value_b = b[k]

                if not deep_equals(value_a, value_b, nil, traversed) then
                    return false
                end
            end
        elseif getmetatable(a).__ipairs and getmetatable(a).__len then
            if #a ~= #b then
                return false
            end

            for i, value_a in ipairs(a) do
                local value_b = b[i]

                if not deep_equals(value_a, value_b, nil, traversed) then
                    return false
                end
            end
        end

        return true
    end

    if t == "thread" then
        return level < 2 or
            (level == 3 and error("Cannot determine equality of thread data"))
    end

    if t == "table" then
        if level < 1 then return true end

        traversed[a] = traversed[a] or {}
        traversed[a][b] = true
        traversed[b] = traversed[b] or {}
        traversed[b][a] = true

        if #a ~= #b then
            return false
        end

        -- TODO can I use mt ~= mt here? genuinely unsure!
        -- check mt
        if not deep_equals(getmetatable(a), getmetatable(b), level, traversed) then
            return false
        end

        -- check keys
        local keys_ok, exotic_b = fchk_table_keys(a, b, traversed)
        if not keys_ok then
            return false
        end

        -- keys must match so we can walk a
        for k, value_a in pairs(a) do
            if not is_primitive(k) then
                local has_key_match = false

                for _, k_b in pairs(exotic_b) do
                    if deep_equals(k, k_b, level, traversed) then
                        if not deep_equals(value_a, b[k_b], level, traversed) then
                            return false
                        end

                        has_key_match = true
                        break
                    end
                end

                if not has_key_match then
                    return false
                end
            elseif not deep_equals(value_a, b[k], level, traversed) then
                return false
            end
        end

        return true
    end

    return false
end

local table_insert = table.insert
local table_remove = table.remove

--- Fast check table keys: check all keys of two tables, ignoring values
--- O(a + b) for primitive keys, O(ab) for exotic keys
---@param a table
---@param b table
---@param traversed table
---@return boolean key_match
---@return table exotic_keys
fchk_table_keys = function(a, b, traversed)
    local primitive_keys_a = {}
    local exotic_keys_a = {}
    for k in pairs(a) do
        if is_primitive(k) then
            primitive_keys_a[k] = true
        else
            table_insert(exotic_keys_a, k)
        end
    end

    local exotic_keys_b = {}
    for k_b in pairs(b) do
        if is_primitive(k_b) then
            if not primitive_keys_a[k_b] then
                return false, exotic_keys_b
            end
            primitive_keys_a[k_b] = nil
        else
            table_insert(exotic_keys_b, k_b)

            local has_match = false
            for i, k_a in ipairs(exotic_keys_a) do
                if deep_equals(k_a, k_b, nil, traversed) then
                    has_match = true
                    table_remove(exotic_keys_a, i)

                    break
                end
            end
            if not has_match then
                return false, exotic_keys_b
            end
        end
    end
    return next(primitive_keys_a) == nil and # exotic_keys_a == 0, exotic_keys_b
end

local debug_getupvalue = (debug or {}).getupvalue
local debug_getinfo = (debug or {}).getinfo
local string_dump = string.dump

---@param a function
---@param b function
---@param level number
---@param traversed table
---@return boolean
fchk_functions = function(a, b, level, traversed)
    -- do a basic check for location, if debug exists
    if debug_getinfo then
        local i_a = debug_getinfo(a, "S")
        local i_b = debug_getinfo(b, "S")

        if i_a.source ~= i_b.source or i_a.linedefined ~= i_b.linedefined then
            return false
        end
    end

    -- check function content
    local str_a = string_dump(a)
    local str_b = string_dump(b)
    if str_a ~= str_b then
        return false
    end

    -- check if upvalues are out of sync.
    if debug_getupvalue then
        local i = 1

        while true do
            local name_a, val_a = debug_getupvalue(a, i)
            local name_b, val_b = debug_getupvalue(b, i)

            if name_a ~= name_b or not deep_equals(val_a, val_b, level, traversed) then
                return false
            end

            if name_a == nil then
                break
            end

            i = i + 1
        end

        return true
    elseif level <= 2 then
        return false
    else
        error("Unable to determine function equality: missing function debug.getupvalue")
    end
end


return deep_equals

end)
__bundle_register("src.util.FunctionComponentInstance", function(require, _LOADED, __bundle_register, __bundle_modules)
local class = require("lib.30log")
local HookState = require("src.util.HookState")
local ipairs_with_nil = require("src.util.ipairs_with_nil")
local traceback = require("src.util.debug.traceback")
local DrawGroup = require("src.util.Renderer.DrawGroup")
local table_pack = require("src.util.polyfill.table.pack")

local get_component_name = require("src.util.debug.get_component_name")

local this_file = "src.util.FunctionComponentInstance"

---@alias LuaX.ComponentInstance.ChangeHandler fun(element: LuaX.ElementNode | nil)

---@class LuaX.ComponentInstance : Log.BaseFunctions
---@field protected change_handler LuaX.ComponentInstance.ChangeHandler
---
---@field render fun(self: self, props: LuaX.Props): boolean, (LuaX.ElementNode | nil)
---@field set_on_change fun(self: self, cb: LuaX.ComponentInstance.ChangeHandler)
---
---@operator call:LuaX.ComponentInstance

---@class LuaX.FunctionComponentInstance : LuaX.ComponentInstance
---@field protected hookstate LuaX.HookState
---@field init fun(self: self, renderer: LuaX.FunctionComponent)
---
---@field rerender boolean
---
--- Copied from ComponentInstance because lua type checker sucks
---@field set_on_change fun(self: self, cb: LuaX.ComponentInstance.ChangeHandler)
---@operator call: LuaX.FunctionComponentInstance
local FunctionComponentInstance = class("FunctionComponentInstance")

local ABORT_CURRENT_RENDER = {}

function FunctionComponentInstance:init(component)
    self.friendly_name = get_component_name(component)

    -- log.debug("new " .. self.friendly_name)

    self.hookstate = HookState()

    self.hookstate:set_listener(function()
        self.rerender = true

        self.change_handler()

        -- If currently rendering this component
        if HookState.global.get() == self.hookstate then
            -- Throw ABORT_RENDER table to early quit rendering this component, and start again
            error(ABORT_CURRENT_RENDER)
        end
    end)

    self.component = component
end

function FunctionComponentInstance:set_on_change(cb)
    self.change_handler = cb
end

function FunctionComponentInstance:render(props)
    local component = self.component

    -- log.debug(string.format("render %s start", self.friendly_name))

    self.rerender = false
    self.hookstate:reset()

    -- TODO should I roll hookstate in to RenderInfo?
    local last_hookstate = HookState.global.set(self.hookstate)

    local ok, res = xpcall(component, traceback, props)

    HookState.global.set(last_hookstate)

    if not ok then
        local err = res --[[ @as string ]]
        -- even though err is typed as a string, we can ignore that ABORT_CURRENT_RENDER isn't.
        if err == ABORT_CURRENT_RENDER then
            -- errors bubble up nicely.
            return false, nil
        end

        err = tostring(err)

        -- match everything up to 2 lines before the function. Inline, xpcall, then component.
        local err_trunc = err:match("(.*)[\n\r].-[\n\r].-[\n\r].-in function '" .. this_file .. ".-'")
        if err_trunc then
            err_trunc = err_trunc:gsub("in upvalue 'chunk'",
                string.format("in function '%s'", self.friendly_name:match("^%S+")))

            err_trunc = "While rendering " .. self.friendly_name .. ":\n" .. err_trunc
        end

        DrawGroup.error(nil, err_trunc or err)
        -- if DrawGroup.error fails without terminating the program, we have to
        -- leave the render loop
        return true, nil
    else
        -- log.trace(string.format("render %s end", self.friendly_name))

        local element = res

        return not self.rerender, element
    end
end

function FunctionComponentInstance:cleanup()
    -- log.debug("FunctionComponentInstance cleanup")

    local hooks = self.hookstate.values
    local length = math.max(#self.hookstate.values, self.hookstate.index)

    for _, hook in ipairs_with_nil(hooks, length) do
        -- TODO this breaks use_effect -> HookState -> FunctionComponentInstance encapsulation.
        -- TODO maybe create a HookState destructor API?

        -- hooks can sometimes be garbage collected before components - how do I protect against this?
        if type(hook) == "table" and hook.on_remove then
            hook.on_remove()
        end
    end
end

return FunctionComponentInstance

end)
__bundle_register("src.util.debug.get_component_name", function(require, _LOADED, __bundle_register, __bundle_modules)
local get_function_location = require("src.util.debug.get_function_location")
local get_function_name     = require("src.util.debug.get_function_name")
local ElementNode           = require("src.util.ElementNode")
local Inline

-- create a throwaway inline function just to get the decorator's debug info
---@type table | string
local inline_transpiled_location = {}

---@param component LuaX.Component
---@return string
local function actually_get_component_name(component)
    local t = type(component)

    if t == "function" then
        local location = get_function_location(component)
        local name = get_function_name(location)

        if location == inline_transpiled_location then
            local chunk = Inline:get_original_chunk(component)

            if chunk then                
                return actually_get_component_name(chunk)
            else
                -- unable to get more info
                return "Inline LuaX"
            end
        elseif name ~= location then
            return string.format("%s (%s)", name, location)
        end

        -- fallback to just location
        return "Function defined at " .. location
    elseif ElementNode.is_literal(component) then
        return "Literal"
    elseif t == "string" then
        return component
    else
        return string.format("UNKNOWN (%s %s)", t, tostring(component))
    end
end

--- Good ol diamond dependency
---@param value LuaX.Parser.Inline
local function set_Inline (value)
    Inline = value

    inline_transpiled_location = get_function_location(Inline:transpile_decorator(function(props) end))
end

--- Evil diamond dependency resolution.
---@type fun(component: LuaX.Component): string
local get_component_name = setmetatable({
    set_Inline = set_Inline
}, {
    __call = function (_, ...)
        return actually_get_component_name(...)
    end
}) --[[ @as any]]

return get_component_name
end)
__bundle_register("src.util.debug.get_function_name", function(require, _LOADED, __bundle_register, __bundle_modules)
local io_open = (io or {}).open

if not io_open then
    return function (l) return l end
end

--- Try to get the local definition of a function. 
--- fails softly. assumes lua chunk is unminified.
---@param location string
local function get_function_name(location)
    local filename = location:match("^(.-):")
    local linenumber = location:match(":(.-)$")

    if not filename or not linenumber then
        return location
    end

    linenumber = tonumber(linenumber)
    local file = io.open(filename, "r")

    if not linenumber or not file then
        return location
    end

    -- seek to that line
    -- I'd use file:seek() but we don't know char count, just line.
    -- This is probably the cheapest way to achieve this
    for _ = 1, linenumber - 1 do
        file:read("l")
    end

    local line = file:read("l")

    local defined_keyword = line:match("function%s*([^%(%s]+)%s*%(")
    if defined_keyword then
        return defined_keyword
    end

    local defined_equal = line:match("([^%s=]+)%s*=%s*function")
    if defined_equal then
        return defined_equal
    end

    local defined_decorator = line:match("([^%s=]+)%s*=%s*[^(]*%(%s*function")
    if defined_decorator then
        return defined_decorator
    end

    local defined_method = line:match("function%s*([^:]+:[^%s(]+)%s*")
    if defined_method then
        return defined_method
    end

    return location
end

local function_name_cache = {}

---@param location string
local function get_function_name_cached(location)
    local cached = function_name_cache[location]

    if cached then
        return cached
    end

    local function_name = get_function_name(location)

    function_name_cache[location] = function_name

    return function_name
end

return get_function_name_cached
end)
__bundle_register("src.util.HookState", function(require, _LOADED, __bundle_register, __bundle_modules)
local class = require("lib.30log")

---@alias LuaX.HookState.Listener fun(index: number, value: any)

---@class LuaX.HookState : Log.BaseFunctions
---@field index number
---@field values any[]
---@field listeners LuaX.HookState.Listener
---@field current LuaX.HookState
---@operator call:LuaX.HookState
local HookState = class("HookState")

local no_op = function() end

function HookState:init()
    self.values = {}

    self.listener = no_op

    self.index = 1
end

function HookState:reset()
    self.index = 1
end

function HookState:get_index()
    return self.index
end

---@param index number
function HookState:set_index(index)
    self.index = index
end

function HookState:increment()
    self:set_index(self:get_index() + 1)
end

---@param index number?
function HookState:get_value(index)
    return self.values[index or self.index]
end

---@param index number
---@param value any
function HookState:set_value(index, value)
    self:set_value_silent(index, value)

    self:modified(index, value)
end

---@param index number
---@param value any
function HookState:set_value_silent(index, value)
    self.values[index] = value
end

---@param index number
---@param value any
function HookState:modified(index, value)
    self.listener(index, value)
end

---@param listener LuaX.HookState.Listener
function HookState:set_listener(listener)
    self.listener = listener
end

local hs_global = {
    ---@type LuaX.HookState?
    current = nil
}
HookState.global = {}

---@overload fun(): LuaX.HookState | nil
---@param required boolean
---@return LuaX.HookState
function HookState.global.get(required)
    local hookstate = hs_global.current

    if required then
        assert(hookstate, "No global hookstate!")
    end

    return hookstate
end

---@param hookstate LuaX.HookState?
---@return LuaX.HookState? last_hookstate
function HookState.global.set(hookstate)
    local last_hookstate = hs_global.current

    hs_global.current = hookstate

    return last_hookstate
end

return HookState

end)
__bundle_register("lib.30log", function(require, _LOADED, __bundle_register, __bundle_modules)
local class = require("lib.30log.30log")

-- hehe

if false then
    --[[
    --- Create a class
    ---@generic T
    ---@param name string the name of the class
    ---@param properties T properties for the class - not instances!
    ---@return T class the bound class object. use :init(), not :new()
    class = function(name, properties)
        return class(name, properties)
    end

    --- Create a class
    ---@param name string the name of the class
    class = function(name)

    end
    ]]

    ---@generic T
    ---@alias Log.ClassExtender (fun(self: LogClass, name: string, properties: T): LogClass<T>)|(fun(self: LogClass, name: string): LogClass<table>)

    ---@class Log.BaseFunctions
    ---@operator call:(Log.BaseFunctions | { extend: Log.ClassExtender<{}> })
    ---@field public init fun(self: LogClass, ...: any) abstract function to initialize the class. return value ignored
    ---@field public new function interally used by 30log. do not modify
    ---@field instanceOf fun(self: LogClass, class: Log.BaseFunctions): boolean check if an object is an instance of a class
    -- TODO :cast
    ---@field classOf fun(self: LogClass, possibleSubClass: any): boolean check if a given object is a subclass of this class
    ---@field subclassOf fun(self: LogClass, possibleParentClass: any): boolean check if a given object is this class's parent class
    ---@field subclasses fun(self: LogClass): LogClass[]
    ---@field extend Log.ClassExtender
    ---@field super LogClass?
    ---
    ---@field class LogClass
    -- TODO https://github.com/Yonaba/30log/wiki/Mixins

    ---@alias LogClass<T> Log.BaseFunctions | { extend: Log.ClassExtender<T> } | T

    ---@generic T
    ---@type (fun(name: string, properties: T): LogClass<T>)|(fun(name: string): LogClass<table>)
    class = function (name, properties)
        error("if i were in hell i'd be pretty cold right now")
    end
end

return class
end)
__bundle_register("lib.30log.30log", function(require, _LOADED, __bundle_register, __bundle_modules)
local next, assert, pairs, type, tostring, setmetatable, baseMt, _instances, _classes, _class = next, assert, pairs, type, tostring, setmetatable, {}, setmetatable({},{__mode = 'k'}), setmetatable({},{__mode = 'k'})
local function assert_call_from_class(class, method) assert(_classes[class], ('Wrong method call. Expected class:%s.'):format(method)) end; local function assert_call_from_instance(instance, method) assert(_instances[instance], ('Wrong method call. Expected instance:%s.'):format(method)) end
local function bind(f, v) return function(...) return f(v, ...) end end
local default_filter = function() return true end
local function deep_copy(t, dest, aType) t = t or {}; local r = dest or {}; for k,v in pairs(t) do if aType ~= nil and type(v) == aType then r[k] = (type(v) == 'table') and ((_classes[v] or _instances[v]) and v or deep_copy(v)) or v elseif aType == nil then r[k] = (type(v) == 'table') and k~= '__index' and ((_classes[v] or _instances[v]) and v or deep_copy(v)) or v end; end return r end
local function instantiate(call_init,self,...) assert_call_from_class(self, 'new(...) or class(...)'); local instance = {class = self}; _instances[instance] = tostring(instance); deep_copy(self, instance, 'table')
	instance.__index, instance.__subclasses, instance.__instances, instance.mixins = nil, nil, nil, nil; setmetatable(instance,self); if call_init and self.init then if type(self.init) == 'table' then deep_copy(self.init, instance) else self.init(instance, ...) end end; return instance
end
local function extend(self, name, extra_params)
	assert_call_from_class(self, 'extend(...)'); local heir = {}; _classes[heir] = tostring(heir); self.__subclasses[heir] = true; deep_copy(extra_params, deep_copy(self, heir))
	heir.name, heir.__index, heir.super, heir.mixins = extra_params and extra_params.name or name, heir, self, {}; return setmetatable(heir,self)
end
baseMt = { __call = function (self,...) return self:new(...) end, __tostring = function(self,...)
	if _instances[self] then return ("instance of '%s' (%s)"):format(rawget(self.class,'name') or '?', _instances[self]) end; return _classes[self] and ("class '%s' (%s)"):format(rawget(self,'name') or '?', _classes[self]) or self end
}; _classes[baseMt] = tostring(baseMt); setmetatable(baseMt, {__tostring = baseMt.__tostring})
local class = {isClass = function(t) return not not _classes[t] end, isInstance = function(t) return not not _instances[t] end}
_class = function(name, attr) local c = deep_copy(attr); _classes[c] = tostring(c)
	c.name, c.__tostring, c.__call, c.new, c.create, c.extend, c.__index, c.mixins, c.__instances, c.__subclasses = name or c.name, baseMt.__tostring, baseMt.__call, bind(instantiate, true), bind(instantiate, false), extend, c, setmetatable({},{__mode = 'k'}), setmetatable({},{__mode = 'k'}), setmetatable({},{__mode = 'k'})
	c.subclasses = function(self, filter, ...) assert_call_from_class(self, 'subclasses(class)'); filter = filter or default_filter; local subclasses = {}; for class in pairs(_classes) do if class ~= baseMt and class:subclassOf(self) and filter(class,...) then subclasses[#subclasses + 1] = class end end; return subclasses end
	c.instances = function(self, filter, ...) assert_call_from_class(self, 'instances(class)'); filter = filter or default_filter; local instances = {}; for instance in pairs(_instances) do if instance:instanceOf(self) and filter(instance, ...) then instances[#instances + 1] = instance end end; return instances end
	c.subclassOf = function(self, superclass) assert_call_from_class(self, 'subclassOf(superclass)'); assert(class.isClass(superclass), 'Wrong argument given to method "subclassOf()". Expected a class.'); local super = self.super; while super do if super == superclass then return true end; super = super.super end; return false end
	c.classOf = function(self, subclass) assert_call_from_class(self, 'classOf(subclass)'); assert(class.isClass(subclass), 'Wrong argument given to method "classOf()". Expected a class.'); return subclass:subclassOf(self) end
	c.instanceOf = function(self, fromclass) assert_call_from_instance(self, 'instanceOf(class)'); assert(class.isClass(fromclass), 'Wrong argument given to method "instanceOf()". Expected a class.'); return ((self.class == fromclass) or (self.class:subclassOf(fromclass))) end
	c.cast = function(self, toclass) assert_call_from_instance(self, 'instanceOf(class)'); assert(class.isClass(toclass), 'Wrong argument given to method "cast()". Expected a class.'); setmetatable(self, toclass); self.class = toclass; return self end
	c.with = function(self,...) assert_call_from_class(self, 'with(mixin)'); for _, mixin in ipairs({...}) do assert(self.mixins[mixin] ~= true, ('Attempted to include a mixin which was already included in %s'):format(tostring(self))); self.mixins[mixin] = true; deep_copy(mixin, self, 'function') end return self end
	c.includes = function(self, mixin) assert_call_from_class(self,'includes(mixin)'); return not not (self.mixins[mixin] or (self.super and self.super:includes(mixin))) end	
	c.without = function(self, ...) assert_call_from_class(self, 'without(mixin)'); for _, mixin in ipairs({...}) do
		assert(self.mixins[mixin] == true, ('Attempted to remove a mixin which is not included in %s'):format(tostring(self))); local classes = self:subclasses(); classes[#classes + 1] = self
		for _, class in ipairs(classes) do for method_name, method in pairs(mixin) do if type(method) == 'function' then class[method_name] = nil end end end; self.mixins[mixin] = nil end; return self end; return setmetatable(c, baseMt) end
class._DESCRIPTION = '30 lines library for object orientation in Lua'; class._VERSION = '30log v1.2.0'; class._URL = 'http://github.com/Yonaba/30log'; class._LICENSE = 'MIT LICENSE <http://www.opensource.org/licenses/mit-license.php>'
return setmetatable(class,{__call = function(_,...) return _class(...) end })
end)
__bundle_register("src.util.polyfill.list.reduce", function(require, _LOADED, __bundle_register, __bundle_modules)


---@generic T, Initial
---@param list T[]
---@param cb fun(previous: Initial, current_value: T, current_index: number, list: T[]): Initial | any
---@param initial Initial
local function list_reduce (list, cb, initial)
    local reduction = initial or list[1]

    for i, value in ipairs(list) do
        reduction = cb(reduction, value, i, list)
    end

    return reduction
end

return list_reduce
end)
__bundle_register("src.util.NativeElement.helper.set_child_by_key", function(require, _LOADED, __bundle_register, __bundle_modules)
local key_first = require("src.util.key.key_first")

---@param children_by_key LuaX.NativeElement.ChildrenByKey
---@param key LuaX.Key
---@param child LuaX.NativeElement | nil
local function set_child_by_key(children_by_key, key, child)
    local first, restkey = key_first(key)

    if children_by_key.class then
        error("set_child_by_key found a NativeElement when it expected an array!")
    end

    if #restkey == 0 then
        children_by_key[first] = child
    else
        if not children_by_key[first] then
            children_by_key[first] = {}
        end

        set_child_by_key(children_by_key[first], restkey, child)
    end
end

return set_child_by_key
end)
__bundle_register("src.util.key.key_first", function(require, _LOADED, __bundle_register, __bundle_modules)
local table_unpack = require("src.util.polyfill.table.unpack")

--- Pop the first key from the list and return a copy of the keylist with that value removed
---@param key LuaX.Key
local function key_first(key)
    -- hehe
    local copy = { table_unpack(key) }
    
    return table.remove(copy, 1), copy
end

return key_first
end)
__bundle_register("src.util.NativeElement.helper.count_children_by_key", function(require, _LOADED, __bundle_register, __bundle_modules)
local ipairs_with_nil = require("src.util.ipairs_with_nil")
local key_first = require("src.util.key.key_first")
local VirtualElement = require("src.util.NativeElement.VirtualElement")

--[[

children_by_key({
    NativeElement,
    {
        NativeElement,
        NativeElement,
    },
    {
        NativeElement,
        NativeElement,
        {
            NativeElement
        }
    }
}, { 3, 3, 1 })
]]

---@param children_by_key LuaX.NativeElement.ChildrenByKey
---@param key LuaX.Key
---@param include_virtual boolean?
local function count_children_by_key(children_by_key, key, include_virtual)
    local count = 0

    -- first could be nil, despite what the type checker says - if the key is empty
    local first, restkey = key_first(key)

    for index, child in ipairs_with_nil(children_by_key, first) do
        if child then
            if child.class then
                if child.class ~= VirtualElement and not include_virtual then
                    count = count + 1
                end
            else
                -- we must count previous children and their subchildren in their entirety.
                -- to avoid missing these subchildren, we pass in an empty key to previous childs
                local pass_key = index == first

                local passed_key = pass_key and restkey or {}

                count = count + count_children_by_key(child, passed_key, include_virtual)
            end    
        end
    end

    return count
end

return count_children_by_key

end)
__bundle_register("src.util.NativeElement.GtkElement", function(require, _LOADED, __bundle_register, __bundle_modules)
---@class LuaX.GtkElement : LuaX.NativeElement
---@field set_lowercase fun(lowercase: boolean)

local vanilla_require = require
local require = function(path)
    local ok, ret = pcall(vanilla_require, path)

    if ok then
        return ret
    else
        warn(ret)
    end
end

return
    require("src.util.NativeElement.GtkElement.lgi.Gtk3Element") or
    error("No GtkElement implementation loaded successfully. To see the errors created by these implementations, use warn(\"@on\") before loading this file.")
end)
__bundle_register("src.util.NativeElement.GtkElement.lgi.Gtk3Element", function(require, _LOADED, __bundle_register, __bundle_modules)
local has_lgi, lgi = pcall(require, "lgi")
if not has_lgi then
    error("Cannot load lgi, therefore cannot load Gtk 3.0 using lgi")
end

local has_Gtk, Gtk = pcall(lgi.require, "Gtk", "3.0")
if not has_Gtk then
    error("Loaded lgi, but cannot load Gtk 3.0 using lgi")
end

local has_GObject, GObject = pcall(lgi.require, "GObject")
if not has_GObject then
    error("Loaded lgi and Gtk, but cannot load GObject using lgi. Are you sure Gtk is installed properly?")
end

local NativeElement = require("src.util.NativeElement")
local NativeTextElement = require("src.util.NativeElement.NativeTextElement")

---@class LuaX.GtkElement.LGI_V3 : LuaX.GtkElement
local Gtk3Element = NativeElement:extend("LuaX.GtkElement (lgi,3.0)")

--[[
Gtk3Element.components = {
    "Gtk.Box",
    "Gtk.VBox",
    "Gtk.HBox",
    "Gtk.Label"
}
]]

-- TODO spinners should :start on init()?
function Gtk3Element:init(native, widget_name)
    -- show elements by default
    if native then
        native:show()
    end

    self.widget = native

    self.widget_name = widget_name

    self.texts = {}

    self.signal_functions = {}
    self.signal_ids = {}
end

function Gtk3Element:set_prop(prop, value)
    local widget = self.widget

    if prop == "show" then
        if value == false then
            widget:hide()
        else
            widget:show()
        end
    elseif prop:match("^on_") then
        local existing_handler = self.signal_ids[prop]
        if existing_handler then
            -- LGI doesn't implement signal disconnection.
            GObject.signal_handler_disconnect(widget, existing_handler)
        end

        self.signal_functions[prop] = value
        if value then
            self.signal_ids[prop] = widget[prop]:connect(value)
        else
            self.signal_ids[prop] = nil
        end
    else
        widget["set_" .. prop](widget, value)
    end
end

function Gtk3Element:get_prop(prop)
    local widget = self.widget

    if prop == "show" then
        return widget:get_visible()
    end

    if prop:match("^on_") then
        return self.signal_functions[prop]
    end

    return widget["get_" .. prop](widget)
end

---@protected
function Gtk3Element:get_trailing_children(index)
    local children = self.widget:get_children()

    local after = {}
    for i = index, #children do
        local child = children[i]

        table.insert(after, child)
        child:ref()
        self.widget:remove(child)
    end

    return after
end

---@protected
function Gtk3Element:reinsert_trailing_children(list)
    for _, child in ipairs(list) do
        self.widget:add(child)
        child:unref()
    end
end

-- TODO some widgets have set_child - if :add doesn't exist (must check using pcall) then use set_child and throw error if multiple children set
function Gtk3Element:insert_child(index, element, is_text)
    if is_text then
        table.insert(self.texts, index, element)

        self:_reload_text()
    else
        local after = self:get_trailing_children(index)

        self.widget:add(element.widget)

        self:reinsert_trailing_children(after)
    end
end

function Gtk3Element:delete_child(index, is_text)
    if is_text then
        table.remove(self.texts, index)
    else
        local after = self:get_trailing_children(index + 1)

        local children = self.widget:get_children()
        local remove_child = children[index]

        self.widget:remove(remove_child)

        self:reinsert_trailing_children(after)
    end
end

function Gtk3Element:cleanup ()
    self.widget:destroy()
end

function Gtk3Element:get_native()
    return self.widget
end

---@param name string
function Gtk3Element.create_element(name)
    ---@type string|nil
    local elem = name:match("Gtk%.(%S+)")

    assert(elem, string.format("GtkElement must be specified by Gtk.<Name> (Could not resolve %q)", name))

    local native = Gtk[elem]()

    assert(native, string.format("No Gtk.%s", elem))

    return Gtk3Element(native, name)
end

function Gtk3Element.get_root(native)
    return Gtk3Element(native, "root")
end

function Gtk3Element:_reload_text()
    local texts = {}

    for _, text_element in ipairs(self.texts) do
        table.insert(texts, text_element.value)
    end

    local text = table.concat(texts, "")

    self:set_prop("label", text)
end

local GtkText = NativeTextElement:extend("LuaX.GtkElement.Text (lgi,3.0)")

function GtkText:set_value(value)
    self.value = value

    self.parent:_reload_text()
end

function GtkText:get_value()
    return self.value
end

---@param value string
---@param parent LuaX.WiboxElement
function Gtk3Element.create_literal(value, parent)
    return GtkText(value, parent)
end

return Gtk3Element

end)
__bundle_register("src.util.NativeElement.WiboxElement", function(require, _LOADED, __bundle_register, __bundle_modules)
local NativeElement = require("src.util.NativeElement")
local NativeTextElement = require("src.util.NativeElement.NativeTextElement")
local string_split = require("src.util.polyfill.string.split")
local list_reduce = require("src.util.polyfill.list.reduce")
local wibox = require("wibox")

---@class LuaX.WiboxElement : LuaX.NativeElement
---@field texts LuaX.WiboxText[]
local WiboxElement = NativeElement:extend("WiboxElement")

WiboxElement.widgets = {
    wibox = {
        container = wibox.container,
        layout = wibox.layout,
        widget = wibox.widget,
        mod = {}
    }
}

function WiboxElement:init(native)
    self.widget = native

    self.texts = {}

    self.signal_handlers = {}
end

---@param prop string
---@param value any
function WiboxElement:set_prop(prop, value)
    local widget = self.widget

    if prop:match("^signal::") then
        local signal_name = prop:sub(9)

        if value then
            widget:weak_connect_signal(signal_name, value)
        end

        self.signal_handlers[prop] = value
    else
        widget[prop] = value
    end
end

function WiboxElement:get_prop(prop)
    if self.signal_handlers[prop] then
        return self.signal_handlers[prop]
    end

    return self.widget[prop]
end

function WiboxElement:insert_child(index, element, is_text)

    if is_text then
        table.insert(self.texts, index, element)

        -- TODO can I remove this? WiboxText calls for us
        self:_reload_text()
    else
        if self.widget.insert then
            self.widget:insert(index, element.widget)
        elseif self.widget.get_children and self.widget.set_children then
            local children = self.widget:get_children()

            table.insert(children, element.widget)

            self.widget:set_children(children)
        else
            error(string.format("Unable to insert child to wibox %s", self.widget))
        end
    end
end

function WiboxElement:delete_child(index, is_text)
    if is_text then
        table.remove(self.texts, index)
    else
        if self.widget.remove then
            self.widget:remove(index)
        elseif self.widget.get_children and self.widget.set_children then
            local children = self.widget:get_children()

            table.remove(children, index)

            self.widget:set_children(children)
        else
            error(string.format("Unable to insert child with wibox %s", self.widget))
        end
    end
end

function WiboxElement:get_native()
    return self.widget
end

---@param element_name string
function WiboxElement.create_element(element_name)
    local fields = string_split(element_name, "%.")

    local widget_type = list_reduce(fields, function(object, key)
        return object[key]
    end, WiboxElement.widgets)

    assert(widget_type, string.format("No widget known by name %q", element_name))

    local widget = wibox.widget { widget = widget_type }

    return WiboxElement(widget, element_name)
end

function WiboxElement.get_root(native)
    return WiboxElement(native)
end

function WiboxElement:_reload_text()
    local texts = {}

    for _, text_element in ipairs(self.texts) do
        table.insert(texts, text_element.value)
    end

    local text = table.concat(texts, "")

    self:set_prop("text", text)
end

---@class LuaX.WiboxText : LuaX.NativeTextElement
---@field protected parent LuaX.WiboxElement
---@field value string
local WiboxText = NativeTextElement:extend("WiboxText")

function WiboxText:set_value(value)
    self.value = value

    self.parent:_reload_text()
end

function WiboxText:get_value()
    return self.value
end

---@param value string
---@param parent LuaX.WiboxElement
function WiboxElement.create_literal(value, parent)
    return WiboxText(value, parent)
end


-- TODO FIXME there must be a way to do this in fewer lines
function WiboxElement.rebuild_component_list()
    local components = {}

    for provider, widget_types in pairs(WiboxElement.widgets) do
        for widget_type, widgets in pairs(widget_types) do
            for widget_name, widget in pairs(widgets) do
                local widget_full_name = table.concat({ provider, widget_type, widget_name, }, ".")

                -- mod widgets can be functions
                if type(widget) == "function" and widget_type == "mod" then
                    table.insert(components, widget_full_name)
                end

                -- ignore wibox.widget.<function> values, and wibox.widget.base
                if type(widget) == "table" and widget_name ~= "base" then
                    if (getmetatable(widget) or {}).__call then
                        table.insert(components, widget_full_name)
                    elseif widget.horizontal and widget.vertical then
                        table.insert(components, widget_full_name .. ".horizontal")
                        table.insert(components, widget_full_name .. ".vertical")
                    elseif widget.month and widget.year then
                        -- special case for calendar
                        table.insert(components, widget_full_name .. ".month")
                        table.insert(components, widget_full_name .. ".year")
                    else
                        -- mod widgets get errors - this is on the user.
                        (widget_type == "mod" and error or warn)(string.format("Widget %s has no __call or horizontal/vertical", widget_full_name))
                    end
                end
            end
        end
    end

    WiboxElement.components = components
end

WiboxElement.rebuild_component_list()

---@param name string 
---@param widget function | table
function WiboxElement.add_mod(name, widget)
    -- TODO check for legal name
    if name:match("[%s.]") then
        error("wibox mod names may not contain whitespace, or the period character")
    end

    WiboxElement.widgets.wibox.mod[name] = widget

    WiboxElement.rebuild_component_list()
end

return WiboxElement

end)
__bundle_register("src.util.polyfill.string.split", function(require, _LOADED, __bundle_register, __bundle_modules)

-- https://stackoverflow.com/questions/1426954/split-string-in-lua

---@param inputstr string
---@param sep string? the seperator pattern
local function split (inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end


return split
end)
__bundle_register("src.util.parser.loader.register", function(require, _LOADED, __bundle_register, __bundle_modules)
local luax_loader = require("src.util.parser.loader.loader")

local has_registered = false

local function luax_loader_register()
    if not has_registered then
        ---@diagnostic disable-next-line:deprecated
        table.insert(package.searchers or package.loaders, luax_loader)
    end

    has_registered = true
end

return luax_loader_register

end)
__bundle_register("src.util.parser.loader.loader", function(require, _LOADED, __bundle_register, __bundle_modules)
-- https://github.com/luarocks/luarocks/blob/master/src/luarocks/loader.lua

local LuaXParser = require("src.util.parser.LuaXParser")

local sep = require("src.util.polyfill.path.sep")

---@param modulename string
local function luax_loader(modulename)
    local modulepath = string.gsub(modulename, "%.", sep)

    local match_module_files = "." .. sep .. "?.luax;." .. sep .. "?" .. sep .. "init.luax"

    for path in string.gmatch(match_module_files, "([^;]+)") do
        local filename = string.gsub(path, "%?", modulepath)

        local file = io.open(filename, "r")

        if file then
            local content = file:read("a")

            local parser = LuaXParser.from_file_content(content, filename)

            local transpiled = parser:transpile()

            local get_module, err = load(transpiled, filename)

            if not get_module then
                error(err)
            end

            return get_module
        end
    end

    return string.format("No LuaX module found for %s", modulename)
end

return luax_loader

end)
__bundle_register("src.util.polyfill.path.sep", function(require, _LOADED, __bundle_register, __bundle_modules)

-- https://stackoverflow.com/questions/37949298/how-do-i-get-directory-path-given-a-file-name-in-lua-which-is-platform-indepen
local sep = package.config:sub(1, 1)

return sep

end)
__bundle_register("src.util.parser.LuaXParser", function(require, _LOADED, __bundle_register, __bundle_modules)
local class                 = require("lib.30log")
local tokens                = require("src.util.parser.tokens")
local node_to_element       = require("src.util.parser.transpile.node_to_element")
local get_global_components = require("src.util.parser.transpile.get_global_components")
-- collect_locals required below, as collect_locals cyclically requires LuaXParser
local TokenStack            = require("src.util.parser.parse.TokenStack")
local escape                = require("src.util.polyfill.string.escape")
local table_pack            = require("src.util.polyfill.table.pack")
local table_unpack          = require("src.util.polyfill.table.unpack")

-- Get the require path of this module
local require_path = "src.util.parser.LuaXParser"
do
    if require_path == (arg or {})[1] then
        print("LuaXParser must be imported")

        os.exit(1)
    end
end

---@class LuaX.Language.Node.Comment
---@field type "comment"

---@class LuaX.Language.Node.Element
---@field type "element"
---@field name string
---@field props LuaX.Props
---@field children LuaX.Language.Node[]

---@alias LuaX.Language.Node LuaX.Language.Node.Element | LuaX.Language.Node.Comment | string

---@class LuaX.Parser.V3 : Log.BaseFunctions
---@field protected text string
---@field protected char integer
---
---@field protected indent string
---
---@field protected current_block_start integer?
---
---@field components { names: table<string, true>, mode: "global"|"local" } a table of component names
---
---@operator call:LuaX.Parser.V3
local LuaXParser     = class("LuaXParser (V3)")

local collect_locals = require("src.util.parser.transpile.collect_locals")(LuaXParser)

-- TODO FIXME use whatever name LuaX was imported via
---@param export_name string
---@return string
local function luax_export(export_name)
    local luax_root = require_path
        -- this code is location dependent
        :gsub("%.util%.parser%.LuaXParser$", "")

    return string.format("require(%q)[%q]", luax_root, export_name)
end

---@protected
LuaXParser.vars = {
    FRAGMENT = {
        name = "_LuaX_Fragment",
        value = luax_export("Fragment"),
        required = false
    },
    IS_COMPILED = {
        name = "_LuaX_is_compiled",
        value = "true",
        required = false
    },
    CREATE_ELEMENT = {
        name = "_LuaX_create_element",
        value = luax_export("create_element"),
        required = false
    }
}

function LuaXParser:init(text)
    if text then
        self:set_text(text)
    end
    self:set_sourceinfo()

    self:set_cursor(1)

    self:set_components({}, "local")
end

---@param text string
---@return self
function LuaXParser:set_text(text)
    if self == LuaXParser then
        error("LuaXParser must be instanciated")
    end

    self.text = text

    self:get_comment_regions()

    return self
end

---@param source string?
---@return self
function LuaXParser:set_sourceinfo(source)
    self.src = source or "Unknown"

    return self
end

--#region component helpers
do
    ---@param components string[]|table<string, true>
    ---@param mode "global" | "local"
    ---@return self
    function LuaXParser:set_components(components, mode)
        if #components > 0 then
            local components_new = {}
            for _, component in ipairs(components) do
                components_new[component] = true
            end
            components = components_new
        end

        if mode == "local" then
            components[self.vars.FRAGMENT.name] = true
        end

        self.components = {
            names = components,
            mode = mode
        }

        return self
    end

    function LuaXParser:auto_set_components()
        assert(self.text, "Parser input text must be set before components names are queried")

        local globals = get_global_components()

        if globals then
            return self:set_components(globals, "global")
        end

        local locals = collect_locals(self.text)
        locals[self.vars.FRAGMENT.name] = true

        return self:set_components(locals, "local")
    end
end
--#endregion

--- TODO this doesn't map to real locations mid-compilation. what can we do?
--- Get an error message for the current parsing position
---@protected
---@param msg string
---@param ... any
---@return string
function LuaXParser:error(msg, ...)
    if ... then
        msg = string.format(msg, ...)
    end

    local fmt = "LuaX Parser - In %s at %d:%d: %s\n\n%s"

    -- TODO improve this.
    local pos = self:get_cursor()
    local context_line = self.text:sub(pos - 20, pos) .. "(HERE)" .. self.text:sub(pos, pos + 20)

    local chars_away = self:get_cursor()
    local n_line = 0
    local n_col = 0
    for line in self.text:gmatch(".-[\n\r]") do
        local sub = chars_away - #line

        if sub < 0 then
            n_col = chars_away

            break
        end
        n_line = n_line + 1
    end

    --- Cast to string here so technically any value can be thrown.
    return string.format(fmt, self.src, n_line, n_col, tostring(msg), context_line)
end

function LuaXParser:get_comment_regions()
    self.comment_regions = {}

    local old_pos = self:get_cursor()
    self:set_cursor(1)
    while true do
        local _, s_end = self:text_find(".-%-%-")

        if not s_end then
            break
        end
        local s_start = s_end - 1

        self:set_cursor(s_end)

        local multiline_match = self:text_match("%[(=*)%[")
        if multiline_match then
            local _, multi_end = self:text_find("]%1]", multiline_match)

            s_end = multi_end + 1
        else
            local line_match = self:text_match("([^\n\r]-)[\n\r]")

            s_end = s_end + #line_match
        end

        table.insert(self.comment_regions, { s_start, s_end })
    end

    self:set_cursor(old_pos)
end

---@param pos integer
---@return { [1]: integer, [2]: integer }?
function LuaXParser:is_in_comment(pos)
    for _, region in pairs(self.comment_regions) do
        if region[1] <= pos and region[2] >= pos then
            return region
        end
    end

    return nil
end

--- Get the next token. Returns the token string, or nil if no token is found
--- and therefore the file has ended.
---@protected
---@return LuaX.Parser.V2.Token token, string[] captured, integer range_start, integer range_end
---@overload fun(self: self): nil
function LuaXParser:get_next_token()
    local matches = {}

    for _, token in ipairs(tokens) do
        local ret = table_pack(self:text_find(token.pattern))
        local range_start = ret[1]
        local range_end = ret[2]
        local captured = table_pack(table_unpack(ret, 3))

        if range_start and range_end and not self:is_in_comment(range_start) then
            table.insert(matches, {
                token = token,
                captured = captured,
                range_start = range_start,
                range_end = range_end
            })
        end
    end

    -- find closest match
    table.sort(matches, function(match_a, match_b)
        return match_a.range_end < match_b.range_end
    end)

    local match = matches[1]

    if match then
        return match.token, match.captured, match.range_start, match.range_end
    end

    return nil
end

function LuaXParser:get_indent()
    -- get 'default' indent, which is the indent of the current block
    local default_slice = self.text:sub(1, self:get_cursor())
    local default_indent = default_slice:match("[\n\r](%s*).-$") or ""

    local indent = ""

    -- match the indent at where the LuaX tag starts
    local pre_tag_indent = self:text_match("^[%S\n\r]-([^%S\n\r]*)")
    if #pre_tag_indent ~= 0 and #default_indent ~= 0 then
        local one_indent = pre_tag_indent:gsub("^" .. default_indent, "")

        indent = pre_tag_indent .. one_indent
    else
        indent = self:text_match(">[\n\r](%s-)[%S\n\r]") or ""
    end

    return indent
end

--#region cursor
do
    ---@protected
    function LuaXParser:move_to_next_token()
        local _, _, token_pos = self:get_next_token()

        if not token_pos then
            error(self:error("Unable to determine next token"))
        end

        self:set_cursor(token_pos)
    end

    ---@param pattern string
    ---@return string|boolean
    function LuaXParser:move_to_pattern_end(pattern)
        --local _, pattern_end = self:text_find(pattern)
        local find = table_pack(self:text_find(pattern))
        table.remove(find, 1) -- ignore start
        local pattern_end = table.remove(find, 1)

        if not pattern_end then
            return false
        end

        self:set_cursor(pattern_end + 1)

        local first_capture = table.remove(find, 1)
        -- return all capture groups or true
        return first_capture or true, table_unpack(find)
    end

    ---@param char number
    ---@return self
    function LuaXParser:set_cursor(char)
        self.char = char

        return self
    end

    ---@return number
    function LuaXParser:get_cursor()
        return self.char
    end

    --- Add chars to the cursor index
    ---@param chars number
    function LuaXParser:move_cursor(chars)
        self:set_cursor(self:get_cursor() + chars)
    end

    function LuaXParser:is_at_end()
        return self:get_cursor() == #self.text
    end

    -- Get the text, regardless of if it is transpiled yet or not.
    function LuaXParser:get_text()
        return self.text
    end

    -- Check if this parser has performed transpilation to any text
    function LuaXParser:has_transpiled()
        return self.vars.IS_COMPILED.required
    end
end
--#endregion



--#region string helpers
do
    --- provides self.text:find from current cursor pos
    ---@protected
    ---@param pattern string
    ---@param ... string
    function LuaXParser:text_find(pattern, ...)
        local args = table_pack(...)

        for i, arg in ipairs(args) do
            pattern = pattern:gsub("%%" .. tostring(i), arg)
        end

        return self.text:find(pattern, self:get_cursor())
    end

    --- provides self.text:match from current cursor pos
    ---@protected
    ---@param pattern string
    ---@param ... string
    function LuaXParser:text_match(pattern, ...)
        local args = table_pack(...)

        for i, arg in ipairs(args) do
            pattern = pattern:gsub("%%" .. tostring(i), arg)
        end

        return self.text:match(pattern, self:get_cursor())
    end

    --- Replace a range of characters with a new string
    --- Think of this function as the antithesis to string.sub
    ---@protected
    ---@param range_start integer
    ---@param range_end integer
    ---@param replacer string
    ---@param ... string
    function LuaXParser:text_replace_range(range_start, range_end, replacer, ...)
        local args = table_pack(...)

        for i, arg in ipairs(args) do
            replacer = replacer:gsub("%%" .. tostring(i), arg)
        end

        self.text = self.text:sub(1, range_start - 1) .. replacer .. self.text:sub(range_end + 1)
    end

    --- Replace a range of characters with a new string, starting at cursor
    ---@protected
    ---@param range_end integer
    ---@param replacer string
    ---@param ... string
    function LuaXParser:text_replace_range_c(range_end, replacer, ...)
        self:text_replace_range(self:get_cursor(), range_end, replacer, ...)
    end

    --- Replace a range of characters with a new string, moving to the end
    ---@protected
    ---@param range_start integer
    ---@param range_end integer
    ---@param replacer string
    ---@param ... string
    function LuaXParser:text_replace_range_move(range_start, range_end, replacer, ...)
        self:text_replace_range(range_start, range_end, replacer, ...)

        self:set_cursor(range_start + #replacer)
    end

    --- Replace a range of characters with a new string, moving to the end, starting at cursor
    ---@protected
    ---@param range_end integer
    ---@param replacer string
    ---@param ... string
    function LuaXParser:text_replace_range_move_c(range_end, replacer, ...)
        self:text_replace_range_move(self:get_cursor(), range_end, replacer, ...)
    end
end
--#endregion



--#region variable handling
do
    --- Set the way the parser handles variables. value must be valid lua
    ---@param on_set_variable fun(name: string, value: string, parser: LuaX.Parser.V3)
    ---@return self
    function LuaXParser:set_handle_variables(on_set_variable)
        self.on_set_variable = on_set_variable

        self:set_required_variables()

        return self
    end

    --- Set all variables that are marked as required (ie, in use in given module)
    ---@protected
    function LuaXParser:set_required_variables()
        for _, var in pairs(self.vars) do
            if var.required then
                self:set_variable(var.name, var.value)
            end
        end
    end

    ---@protected
    ---@param name string
    ---@param value string
    function LuaXParser:set_variable(name, value)
        if self.on_set_variable then
            self.on_set_variable(name, value, self)
        else
            local src
            if debug and debug.getinfo then
                local i = 0
                repeat
                    i = i + 1
                    local info = debug.getinfo(i, "Sl")
                    src = string.format("%s:%d", info.short_src, info.currentline)
                until not src:match("LuaXParser%.lua")
            end

            warn((src and string.format("In %s: ", src) or "") ..
                string.format("LuaXParser: Variable %s not set: no on_set_variable", name))
        end
    end

    function LuaXParser:handle_variables_prepend_text()
        local already_set = {}

        return self:set_handle_variables(function(name, value, parser)
            local fmt = "local %s = %s\n"
            local insert = string.format(fmt, name, value)

            if already_set[name] then
                if already_set[name] == value then
                    return
                else
                    error("Attempt to modify variable that is already set")
                end
            end

            already_set[name] = value

            ---@diagnostic disable-next-line:invisible
            parser.text = insert .. parser.text

            if self.current_block_start then
                self.current_block_start = self.current_block_start + #insert
            end

            parser:move_cursor(#insert)
        end)
    end

    ---@param variables table
    function LuaXParser:handle_variables_as_table(variables)
        return self:set_handle_variables(function(name, value)
            local parse_value, err = load("return " .. value, "LuaX variable value")

            if not parse_value then
                error(err)
            end

            variables[name] = parse_value()
        end)
    end
end
--#endregion


--#region parsing
do
    --- Evaluate a literal string, to ensure that LuaX within a literal is transpiled
    ---@param value string
    function LuaXParser:evaluate_literal(value)
        local on_set_variable = self.on_set_variable and function(name, value)
            -- hardwire parser argument to self, to prepend in the correct text location.
            return self.on_set_variable(name, value, self)
        end

        -- parse internal LuaX expressions if they are found
        local parser = LuaXParser()
            :set_text(value)
            :set_sourceinfo(self.src .. " subparser")
            :set_handle_variables(on_set_variable)
            :set_components(self.components.names, self.components.mode)

        -- TODO should transpile() check for immediate tags instead of checking here?
        if value:sub(1, 1) == "<" and value:sub(-1) == ">" then
            -- TODO ideally finding a tag results in another node
            -- being added instead of a transpiled literal, just to
            -- keep with the 'ast-ness' of it all.
            value = parser:transpile_tag()
        else
            value = parser:transpile()
        end

        return value
    end

    -- TODO this code is terrible.
    --- Parse a child that is not a tag - either a lua block (in {}), a comment, or just text
    ---@protected
    ---@return LuaX.Language.Node[]
    function LuaXParser:parse_non_tag()
        local tokenstack = TokenStack(self.text)
            :set_pos(self:get_cursor())
            :set_requires_literal(true)

        ---@type { is_luablock: boolean, chars: string[], start: integer }[]
        local slices = {}

        -- Loop until LuaX tag found
        while true do
            local pos = tokenstack:get_pos()

            tokenstack:run_once()
            tokenstack:run_until_empty()

            -- This is a luablock
            if tokenstack:get_pos() > pos + 1 then
                table.insert(slices, {
                    is_luablock = true,
                    chars = { self.text:sub(pos + 1, tokenstack:get_pos() - 2) },
                    start = pos + 1
                })
            else
                local current = self.text:sub(pos, pos)

                if current == "<" then
                    -- found tag start
                    break
                elseif current == "-" and self.text:sub(pos):match("^%-%-+>") then
                    -- This pattern is somewhat slow but that's ok, slowness at compile time is ok.
                    -- found HTML-esque comment end
                    break
                elseif current == "{" then
                    -- no-op
                else
                    local last_slice = slices[#slices]

                    -- ensure last_slice is the correct kind
                    if not last_slice or last_slice.is_luablock == true then
                        table.insert(slices, {
                            is_luablock = false,
                            chars = {},
                            start = pos
                        })

                        last_slice = slices[#slices]
                    end

                    table.insert(last_slice.chars, current)
                end
            end
        end

        self:set_cursor(tokenstack:get_pos() - 1)

        ---@type LuaX.Language.Node[]
        local nodes = {}

        for i, slice in ipairs(slices) do
            -- Trim whitespace with indent
            local value = table.concat(slice.chars, "")
                :gsub("\n" .. self.indent, "\n")
                :gsub("^" .. self.indent, "")

            -- trim leading newline
            if i == 1 then
                value = value:gsub("^%s-[\n\r]", "")
            end
            -- trim trailing newline
            if i == #slices then
                value = value:gsub("[\n\r]%s-$", "")
            end

            -- check if this literal isn't just whitespace
            if not value:match("^%s*$") then
                local _, non_ws_start = self.text:find("%S", slice.start)

                if slice.is_luablock then
                    value = self:evaluate_literal(value)
                elseif non_ws_start and self:is_in_comment(non_ws_start) then
                    -- this is a comment

                    ---@diagnostic disable-next-line:cast-local-type
                    value = {
                        type = "comment",
                        value = value
                    }
                else
                    value = value.format("%q", value)
                end

                table.insert(nodes, value)
            end
        end


        -- go back a char for the <
        -- self:move_cursor(-1)

        return nodes
    end

    --- Parse text, returning a list of nodes
    ---@protected
    ---@return LuaX.Language.Node[]
    function LuaXParser:parse_text()
        local nodes = {}

        -- stop iterating at </ - which we will only encounter at the end of the
        -- parent tag. This is because of the recursion we use.
        while not (self:text_match("^%s*</") or self:text_match("^%s*%-%-+>") or self:is_at_end()) do
            if self:text_match("^%s*<") then
                local node = self:parse_tag()

                table.insert(nodes, node)
            else
                local new_nodes = self:parse_non_tag()

                for _, node in ipairs(new_nodes) do
                    table.insert(nodes, node)
                end
            end
        end

        return nodes
    end

    --- Parse text that we know starts with LuaX tag props
    ---@protected
    function LuaXParser:parse_props()
        local props = {}

        while not self:text_match("^%s*>") and not self:text_match("^%s*/%s*>") do
            -- skip whitespace
            self:move_to_pattern_end("^%s*")

            -- skip comments
            local comment = self:is_in_comment(self:get_cursor())
            if comment then
                self:set_cursor(comment[2])
            end

            -- Capture entire prop value, unless it contains spaces
            -- Spaces are resolved by using a TokenStack
            local prop = self:text_match("^[^/>%s]+")

            -- prop might be nil if we skipped a comment and there are no remaining props
            if prop then
                if prop:match("^.-=") then
                    local prop_name = self:move_to_pattern_end("^(.-)%s*=%s*")

                    assert(prop_name, self:error("Prop pattern unable to match"))

                    local tokenstack = TokenStack(self.text)
                        :set_pos(self:get_cursor())
                        -- capture opening quote or bracket
                        :run_once()
                        :run_until_empty()

                    local prop_value = self.text
                        :sub(self:get_cursor(), tokenstack:get_pos() - 1)
                        -- remove block quotes
                        :gsub("^[\"'](.*)[\"']$", "%1")

                    -- this is a literal, check for internal LuaX statements
                    if prop_value:sub(1, 1) == "{" and prop_value:sub(-1) == "}" and
                        -- no match means no tags, so we can skip
                        prop_value:match("<.*>") then
                        prop_value = "{" .. self:evaluate_literal(prop_value:sub(2, -2)) .. "}"
                    end


                    self:set_cursor(tokenstack:get_pos())

                    props[prop_name] = prop_value
                else
                    -- implicit property
                    props[prop] = true

                    self:move_cursor(#prop)
                end
            end
        end

        return props
    end

    --- Parse text that we know is a LuaX tag
    ---@protected
    ---@return LuaX.Language.Node
    function LuaXParser:parse_tag()
        self.indent = self:get_indent()

        self:move_to_pattern_end("^%s*")

        local tag_name

        local is_fragment = self:move_to_pattern_end("^<%s*>")
        if is_fragment then
            tag_name = self.vars.FRAGMENT.name

            self.vars.FRAGMENT.required = true
        else
            tag_name = self:move_to_pattern_end("^<%s*([^%s/>]+)")

            assert(tag_name, self:error("Cannot find tag name"))
            assert(type(tag_name) == "string", "Tag pattern does not capture")
        end

        local is_comment = tag_name:match("^!%-%-+")

        local is_propsless = is_fragment or is_comment
        local props = is_propsless and {} or self:parse_props()

        local no_children = self:move_to_pattern_end("^%s*/%s*>")

        if not (is_propsless or no_children) then
            assert(self:move_to_pattern_end("^%s*>"), self:error("Cannot find end of props"))
        end

        local children = no_children and {} or self:parse_text()

        if is_fragment then
            assert(self:move_to_pattern_end("^%s*<%s*/%s*>"), self:error("Cannot find fragment end"))
        elseif is_comment then
            assert(self:move_to_pattern_end("^%s*%-%-+>"), self:error("Cannot find comment end"))
        else
            local patt = "^%s*<%s*/%s*" .. escape(tag_name) .. "%s*>"

            assert(no_children or self:move_to_pattern_end(patt), self:error("Cannot find ending tag for %q", tag_name))
        end

        if is_comment then
            -- TODO fetch comment value. self.text:sub() works in my mind.
            return {
                type = "comment",
            }
        end

        return {
            type = "element",
            name = tag_name,
            props = props,
            children = children
        }
    end
end
--#endregion parsing


--#region transpilation
do
    --- Transpile text that we know is a LuaX tag
    function LuaXParser:transpile_tag()
        -- we need the minimal set of variables for any tag
        self.vars.CREATE_ELEMENT.required = true
        self.vars.IS_COMPILED.required = true

        -- save cursor position
        self.current_block_start = self:get_cursor()

        local node = self:parse_tag()

        local transpiled = node_to_element(
            node,
            self.components.names,
            self.components.mode,
            self.vars.CREATE_ELEMENT.name
        )

        -- replace from old cursor to new with transpiled node
        self:text_replace_range_move(self.current_block_start, self:get_cursor(), transpiled)

        self.current_block_start = nil

        self:set_required_variables()

        return self.text
    end

    --- Transpile the closest token
    ---@protected
    ---@return boolean continue
    function LuaXParser:transpile_once()
        local token, captured, _, luax_start = self:get_next_token()

        if not token or not luax_start then
            return false
        end

        -- move to token start
        self:move_to_next_token()

        -- TODO why is this -2??? By my logic it should be -1?
        -- replace any start text, move cursor
        self:text_replace_range_move_c(luax_start - 2, token.replacer, table_unpack(captured))

        self:transpile_tag()

        local _, luax_end = self:text_find(token.end_pattern, table_unpack(captured))

        if not luax_end then
            error(self:error("Unable to locate end of block"))
        end
        self:text_replace_range_move_c(luax_end, token.end_replacer, table_unpack(captured))

        return true
    end

    --- Transpile until no more tag tokens can be found
    function LuaXParser:transpile()
        if not self.components then
            warn("Automatically setting parser components")

            self:auto_set_components()
        end

        while self:transpile_once() do
        end

        return self.text
    end
end
--#endregion

--- Assuming a file has been transpiled, write its result to a file path
---@param path string
function LuaXParser:write_to_file(path)
    local f = io.open(path, "w")

    assert(f, string.format("Unable to open %q", path))

    f:write(self.text)
    f:flush()

    f:close()
end

--#region constructors
do
    ---@param str string
    ---@param src string?
    ---@param variables table?
    function LuaXParser.from_inline_string(str, src, variables)
        local parser = LuaXParser()
            :set_text(str)
            :set_sourceinfo(src or "Unknown inline string")

        if variables then
            parser:handle_variables_as_table(variables)
                :auto_set_components()
        end

        return parser
    end

    ---@param str string
    ---@param src string?
    function LuaXParser.from_file_content(str, src)
        return LuaXParser()
            :set_text(str)
            :set_sourceinfo(src or "Unknown file string")
            :handle_variables_prepend_text()
            :auto_set_components()
    end

    --- Autoset a parser from a file path
    ---@param path string
    function LuaXParser.from_file_path(path)
        local f = io.open(path)

        if not f then
            error(string.format("Unable to open file %q", path))
        end

        local content = f:read("a")

        return LuaXParser.from_file_content(content, path)
    end
end
--#endregion


return LuaXParser

end)
__bundle_register("src.util.parser.transpile.collect_locals", function(require, _LOADED, __bundle_register, __bundle_modules)
local Parser = require("lib.lua-parser")

---@type LuaX.Parser.V3
local LuaXParser

---@generic T
---@param list T[]
---@return table<T, true>
local function list_to_map(list)
    local map = {}

    for _, item in pairs(list) do
        map[tostring(item)] = true
    end

    return map
end

--- Recursively collect locals given a lua-parser tree
---@param vars string[]
---@param node Lua-Parser.Node
local function collect_vars(vars, node)
    for _, expression in ipairs(node) do
        --[[
        print(expression)
        for k, v in pairs(expression) do
            if k ~= "parent" then
                print("", k, v)
            end
        end
        ]]

        if expression.name then
            -- lua-parser now seems to nest expression names??
            table.insert(vars, expression.name.name)
        end

        if expression.vars then
            for _, var in ipairs(expression.vars) do
                table.insert(vars, var.name)
            end
        end

        if expression.exprs then
            collect_vars(vars, expression.exprs)
        end
    end
end

---@param text string
---@return table<string, true>
local function collect_locals (text)
    -- this is the most resource intensive way to do this, BUT
    -- 1. users get a warning when auto_set_components can't resolve globals
    -- 2. cpus are free these days. completeness trumps efficiency in this case
    local text = LuaXParser()
        :set_text(text)
        :set_sourceinfo("collect_locals internal parser")
        :set_components({}, "local")
        :transpile()

    local node, err = Parser.parse(text)

    if not node then
        error("Unable to collect locals - are you sure your code is syntactically correct?\n" .. tostring(err))
    end

    ---@type string[]
    local vars = {}

    collect_vars(vars, node)

    return list_to_map(vars)
end

return function (parser)
    LuaXParser = parser

    return collect_locals
end
end)
__bundle_register("lib.lua-parser", function(require, _LOADED, __bundle_register, __bundle_modules)
-- Lua 5.1/LuaJIT provide getfenv & setfenv instead of _ENV, so we can just simulate _ENV
local _ENV = _ENV or _G

local searchpath = package.searchpath
local vanilla_require = require
--- env_aware_require acts the same as require(), except it reads/writes
--- _ENV.package.loaded instead of _G.package.loaded, and loads modules with
--- _ENV instead of _G (where _G is the original globals table, which Lua's
--- standard library uses instead of _ENV)
---@param modpath string
---@return any, string?
local function env_aware_require(modpath)
    local loaded = _ENV.package.loaded[modpath]
    if loaded then
        return loaded
    end

    local c_path = searchpath(modpath, package.cpath)
    -- for C modules, just allow vanilla require behaviour
    if c_path then
        return vanilla_require(modpath)
    end

    local path, err = searchpath(modpath, package.path)

    if not path then
        error(err)
    end

    local chunk, err = loadfile(path, nil, _ENV)
    if not chunk then
        error(err)
    end

    if _VERSION:match("%d.%d") == "5.1" then
        ---@diagnostic disable-next-line:deprecated
        setfenv(chunk, _ENV)
    end

    local mod = chunk(modpath, path)

    package.loaded[modpath] = mod

    return mod, path
end

local function parser_shim()
    local package, require = package, require

    if not true then
        -- push new env so the real package.loaded isn't polluted.
        _ENV          = setmetatable({
            package = setmetatable({
                loaded = {
                    -- This list is minimal for my use case.
                    table = table,
                    string = string
                }
            }, { __index = package }),
            require = env_aware_require
        }, { __index = _G })

        package = _ENV.package
        require = _ENV.require
    end


    package.loaded["ext.op"]                 = require("lib.lua-ext.op")
    package.loaded["ext.table"]              = require("lib.lua-ext.table")
    package.loaded["ext.class"]              = require("lib.lua-ext.class")
    package.loaded["ext.string"]             = require("lib.lua-ext.string")
    package.loaded["ext.tolua"]              = require("lib.lua-ext.tolua")
    package.loaded["ext.assert"]             = require("lib.lua-ext.assert")

    package.loaded["parser.base.ast"]        = require("lib.lua-parser.base.ast")
    package.loaded["parser.lua.ast"]         = require("lib.lua-parser.lua.ast")

    package.loaded["parser.base.datareader"] = require("lib.lua-parser.base.datareader")

    package.loaded["parser.base.tokenizer"]  = require("lib.lua-parser.base.tokenizer")
    package.loaded["parser.lua.tokenizer"]   = require("lib.lua-parser.lua.tokenizer")

    package.loaded["parser.base.parser"]     = require("lib.lua-parser.base.parser")
    package.loaded["parser.lua.parser"]      = require("lib.lua-parser.lua.parser")

    ---@alias Lua-Parser.Location { col: integer, line: integer }
    ---@alias Lua-Parser.Span { from: Lua-Parser.Location, to: Lua-Parser.Location }


    ---@class Lua-Parser.CNode
    ---@field span Lua-Parser.Span
    ---@field copy fun(self: self): self
    ---@field flatten fun(self:self, func: function, varmap: any) TODO Not sure how this works whatsoever
    ---@field toLua fun(self: self): string
    ---@field serialize fun(self: self, apply: function) TODO not sure how this works

    ---@class Lua-Parser.Node.Function : Lua-Parser.CNode
    ---@field type "function"
    ---@field func Lua-Parser.Node
    ---@field args Lua-Parser.Node[]

    ---@class Lua-Parser.Node.String
    ---@field type "string"
    ---@field value string

    ---@class Lua-Parser.Node.If
    ---@field type "if"
    ---@field cond Lua-Parser.Node
    ---@field elseifs Lua-Parser.Node[]
    ---@field elsestmt Lua-Parser.Node

    ---@alias Lua-Parser.Node Lua-Parser.CNode | Lua-Parser.Node.Function | Lua-Parser.Node.String | Lua-Parser.Node.If

    ---@type { parse: fun(lua: string): Lua-Parser.Node }
    return require("lib.lua-parser.parser")
end

return parser_shim()

end)
__bundle_register("lib.lua-parser.parser", function(require, _LOADED, __bundle_register, __bundle_modules)
-- me moving classes around
-- TODO get rid of this file and rename all `require 'parser'` to `require 'parser.lua.parser'` ... or maybe ...
-- ... maybe that's a bad idea, because it is more verbose ...
-- maybe instead of forwarding LuaParser, I should just write some wrapper function shere, like parser.parse(...) to auto-construct a LuaParser and return its tree ...
return require("parser.lua.parser")

end)
__bundle_register("lib.lua-parser.lua.parser", function(require, _LOADED, __bundle_register, __bundle_modules)
local table = require("ext.table")
local assert = require("ext.assert")
local Parser = require("parser.base.parser")

local ast = require("parser.lua.ast")

local LuaTokenizer = require("parser.lua.tokenizer")

local LuaParser = Parser:subclass()

-- save the namespace here, for Parser:setData()
LuaParser.ast = ast

-- static function
function LuaParser.parse(data, source, ...)
	local parser = LuaParser(nil, nil, ...)
	local result = table.pack(parser:setData(data, source))
	if not result[1] then return result:unpack() end
	return parser.tree
end

-- TODO instead of version and useluajit, how about parseFlags, and enable/disable them depending on the version
function LuaParser:init(data, version, source, useluajit)
	self.version = version or _VERSION:match'^Lua (.*)$'
	if useluajit == nil then
		-- I could test for _G.jit's presence, but what if luajit is compiled with jit off but still has LL language feature on ...
		-- TODO unified load shim layer , esp for lua 5.1 ...
		-- TODO TODO if langfix's load has been replaced then this will segfault...
		-- we are detecting LL / ULL suffix, but using load to do so causes some recursion problems (since in some cases I've already overridden load() via ext.load and parser.load_xform ...)
		--local _load = loadstring or load
		--useluajit = _load'return 1LL'
		-- ... so instead, for now just assume jit's presence implies luajit implies LL / ULL for parsing
		useluajit = not not _G.jit
	end
	self.useluajit = not not useluajit

	-- TODO between this and parser.grammar, make a table-based way to specify the rules
	-- TODO TODO a token DAG from the grammar would be nice ...
	-- [[ what to name this ...
	self.parseExprPrecedenceRulesAndClassNames = table{
		{
			name = 'or',
			rules = {
				{token='or', className='_or'},
			},
		},
		{
			name = 'and',
			rules = {
				{token='and', className='_and'},
			},
		},
		{
			name = 'cmp',
			rules = {
				{token='<', className='_lt'},
				{token='>', className='_gt'},
				{token='<=', className='_le'},
				{token='>=', className='_ge'},
				{token='~=', className='_ne'},
				{token='==', className='_eq'},
			},
		},
	}:append(
		self.version < '5.3' and nil or table{
		{
			name = 'bor',
			rules = {
				{token='|', className='_bor'},
			},
		},
		{
			name = 'bxor',
			rules = {
				{token='~', className='_bxor'},
			},
		},
		{
			name = 'band',
			rules = {
				{token='&', className='_band'},
			},
		},
		{
			name = 'shift',
			rules = {
				{token='<<', className='_shl'},
				{token='>>', className='_shr'},
			},
		},
	}):append{
		{
			name = 'concat',
			rules = {
				{token='..', className='_concat'},
			},
		},
		{
			name = 'addsub',	-- arithmetic
			rules = {
				{token='+', className='_add'},
				{token='-', className='_sub'},
			},
		},
		{
			name = 'muldivmod',	-- geometric
			rules = {
				{token='*', className='_mul'},
				{token='/', className='_div'},
				{token='%', className='_mod'},
				-- if version < 5.3 then the // symbol won't be added to the tokenizer anyways...
				{token='//', className='_idiv'},
			},
		},
		{
			name = 'unary',
			unaryLHS = true,
			rules = {
				{token='not', className='_not'},
				{token='#', className='_len'},
				{token='-', className='_unm'},
				{token='~', className='_bnot'},	-- only a 5.3 token
			},
		},
		{
			name = 'pow',
			rules = {
				{token='^', className='_pow', nextLevel='unary'},
			},
		},
	}
	--]]

	if data then
		-- can't return from init so gotta error ...
		assert(self:setData(data, source))
	end
end

function LuaParser:setData(data, source)
	self.gotos = {}		-- keep track of all gotos
	self.labels = {}	-- keep track of all labels
	self.blockStack = table()
	self.functionStack = table{'function-vararg'}

	local result = table.pack(LuaParser.super.setData(self, data))
	if not result[1] then
		return result:unpack()
	end

	-- last verify that all gotos went to all labels
	for _,g in pairs(self.gotos) do
		if not self.labels[g.name] then
			return false, "line "..g.span.to.line..": no visible label '"..g.name.."' for <goto>"
		end
	end
	return true
end

function LuaParser:buildTokenizer(data)
	return LuaTokenizer(data, self.version, self.useluajit)
end

-- default entry point for parsing data sources
function LuaParser:parseTree()
	return self:parse_chunk()
end

function LuaParser:parse_chunk()
	local from = self:getloc()
	local stmts = table()
	repeat
		local stmt = self:parse_stat()
		if not stmt then break end
		stmts:insert(stmt)
		if self.version == '5.1' then
			self:canbe(';', 'symbol')
		end
	until false
	local laststat = self:parse_retstat()
	if laststat then
		stmts:insert(laststat)
		if self.version == '5.1' then
			self:canbe(';', 'symbol')
		end
	end
	return self:node('_block', table.unpack(stmts))
		:setspan{from = from, to = self:getloc()}
end

function LuaParser:parse_block(blockName)
	if blockName then self.blockStack:insert(blockName) end
	local chunk = self:parse_chunk()
	if blockName then assert.eq(self.blockStack:remove(), blockName) end
	return chunk
end

function LuaParser:parse_stat()
	if self.version >= '5.2' then
		repeat until not self:canbe(';', 'symbol')
	end
	local from = self:getloc()
	if self:canbe('local', 'keyword') then
		local ffrom = self:getloc()
		if self:canbe('function', 'keyword') then
			local namevar = self:parse_var()
			if not namevar then error{msg="expected name"} end
			return self:node('_local', {
				self:makeFunction(
					namevar,
					table.unpack((assert(self:parse_funcbody(), {msg="expected function body"})))
				):setspan{from = ffrom , to = self:getloc()}
			}):setspan{from = from , to = self:getloc()}
		else
			local afrom = self:getloc()
			local namelist = assert(self:parse_attnamelist(), {msg="expected attr name list"})
			if self:canbe('=', 'symbol') then
				local explist = assert(self:parse_explist(), {msg="expected expr list"})
				local assign = self:node('_assign', namelist, explist)
					:setspan{from = ffrom, to = self:getloc()}
				return self:node('_local', {assign})
					:setspan{from = from, to = self:getloc()}
			else
				return self:node('_local', namelist)
					:setspan{from = from, to = self:getloc()}
			end
		end
	elseif self:canbe('function', 'keyword') then
		local funcname = self:parse_funcname()
		return self:makeFunction(funcname, table.unpack((assert(self:parse_funcbody(), {msg="expected function body"}))))
			:setspan{from = from , to = self:getloc()}
	elseif self:canbe('for', 'keyword') then
		local namelist = assert(self:parse_namelist(), {msg="expected name list"})
		if self:canbe('=', 'symbol') then
			assert.eq(#namelist, 1, {msg="expected only one name in for loop"})
			local explist = assert(self:parse_explist(), {msg="expected exp list"})
			assert.ge(#explist, 2, {msg="bad for loop"})
			assert.le(#explist, 3, {msg="bad for loop"})
			self:mustbe('do', 'keyword')
			local block = assert(self:parse_block'for =', {msg="for loop expected block"})
			self:mustbe('end', 'keyword')
			return self:node('_foreq', namelist[1], explist[1], explist[2], explist[3], table.unpack(block))
				:setspan{from = from, to = self:getloc()}
		elseif self:canbe('in', 'keyword') then
			local explist = assert(self:parse_explist(), {msg="expected expr list"})
			self:mustbe('do', 'keyword')
			local block = assert(self:parse_block'for in', {msg="expected block"})
			self:mustbe('end', 'keyword')
			return self:node('_forin', namelist, explist, table.unpack(block))
				:setspan{from = from, to = self:getloc()}
		else
			error{msg="'=' or 'in' expected"}
		end
	elseif self:canbe('if', 'keyword') then
		local cond = assert(self:parse_exp(), {msg="unexpected symbol"})
		self:mustbe('then', 'keyword')
		local block = self:parse_block()
		local stmts = table(block)
		-- ...and add elseifs and else to this
		local efrom = self:getloc()
		while self:canbe('elseif', 'keyword') do
			local cond = assert(self:parse_exp(), {msg='unexpected symbol'})
			self:mustbe('then', 'keyword')
			stmts:insert(
				self:node('_elseif', cond, table.unpack((assert(self:parse_block(), {msg='expected block'}))))
					:setspan{from = efrom, to = self:getloc()}
			)
			efrom = self:getloc()
		end
		if self:canbe('else', 'keyword') then
			stmts:insert(
				self:node('_else', table.unpack((assert(self:parse_block(), {msg='expected block'}))))
					:setspan{from = efrom, to = self:getloc()}
			)
		end
		self:mustbe('end', 'keyword')
		return self:node('_if', cond, table.unpack(stmts))
			:setspan{from = from, to = self:getloc()}
	elseif self:canbe('repeat', 'keyword') then
		local block = assert(self:parse_block'repeat', {msg='expected block'})
		self:mustbe('until', 'keyword')
		return self:node(
			'_repeat',
			(assert(self:parse_exp(), {msg='unexpected symbol'})),
			table.unpack(block)
		):setspan{from = from, to = self:getloc()}
	elseif self:canbe('while', 'keyword') then
		local cond = assert(self:parse_exp(), {msg='unexpected symbol'})
		self:mustbe('do', 'keyword')
		local block = assert(self:parse_block'while', {msg='expected block'})
		self:mustbe('end', 'keyword')
		return self:node('_while', cond, table.unpack(block))
			:setspan{from = from, to = self:getloc()}
	elseif self:canbe('do', 'keyword') then
		local block = assert(self:parse_block(), {msg='expected block'})
		self:mustbe('end', 'keyword')
		return self:node('_do', table.unpack(block))
			:setspan{from = from, to = self:getloc()}
	elseif self.version >= '5.2' then
		if self:canbe('goto', 'keyword') then
			local name = self:mustbe(nil, 'name')
			local g = self:node('_goto', name)
				:setspan{from = from, to = self:getloc()}
			self.gotos[name] = g
			return g
		-- lua5.2+ break is a statement, so you can have multiple breaks in a row with no syntax error
		elseif self:canbe('break', 'keyword') then
			return self:parse_break()
				:setspan{from = from, to = self:getloc()}
		elseif self:canbe('::', 'symbol') then
			local name = self:mustbe(nil, 'name')
			local l = self:node('_label', name)
			self.labels[name] = true
			self:mustbe('::', 'symbol')
			return l:setspan{from = from, to = self:getloc()}
		end
	end

	-- now we handle functioncall and varlist = explist rules

	--[[
	stat ::= varlist `=` explist | functioncall
	varlist ::= var {`,` var}
	var ::= Name | prefixexp `[` exp `]` | prefixexp `.` Name
	prefixexp ::= var | functioncall | `(` exp `)`
	functioncall ::= prefixexp args | prefixexp `:` Name args
		right now prefixexp is designed to process trailing args ...
		... so just use it and complain if the wrapping ast is not a _call
	likewise with var, complain if it is a call
	--]]

	local prefixexp = self:parse_prefixexp()
	if prefixexp then
		if self.ast._call:isa(prefixexp) then 	-- function call
			return prefixexp
		else	-- varlist assignment
			local vars = table{prefixexp}
			while self:canbe(',', 'symbol') do
				local var = assert(self:parse_prefixexp(), {msg='expected expr'})
				assert.ne(var.type, 'call', {msg="syntax error"})
				vars:insert(var)
			end
			return self:parse_assign(vars, from)
		end
	end
end

function LuaParser:parse_assign(vars, from)
	self:mustbe('=', 'symbol')
	return self:node('_assign', vars, (assert(self:parse_explist(), {msg='expected expr'})))
		:setspan{from = from, to = self:getloc()}
end

-- 'laststat' in 5.1, 'retstat' in 5.2+
function LuaParser:parse_retstat()
	local from = self:getloc()
	-- lua5.2+ break is a statement, so you can have multiple breaks in a row with no syntax error
	-- that means only handle 'break' here in 5.1
	if self.version == '5.1' and self:canbe('break', 'keyword') then
		return self:parse_break()
			:setspan{from = from, to = self:getloc()}
	end
	if self:canbe('return', 'keyword') then
		local explist = self:parse_explist() or {}
		if self.version >= '5.2' then
			self:canbe(';', 'symbol')
		end
		return self:node('_return', table.unpack(explist))
			:setspan{from = from, to = self:getloc()}
	end
end

-- verify we're in a loop, then return the break

function LuaParser:parse_break()
	local from = self:getloc()
	if not ({['while']=1, ['repeat']=1, ['for =']=1, ['for in']=1})[self.blockStack:last()] then
		error{msg="break not inside loop"}
	end
	return self:node('_break')
		:setspan{from = from, to = self:getloc()}
end


function LuaParser:parse_funcname()
	local from = self:getloc()
	local name = self:parse_var()
	if not name then return end
	while self:canbe('.', 'symbol') do
		local sfrom = self.t:getloc()
		name = self:node('_index',
			name,
			self:node('_string', self:mustbe(nil, 'name'))
				:setspan{from = sfrom, to = self:getloc()}
		):setspan{from = from, to = self:getloc()}
	end
	if self:canbe(':', 'symbol') then
		name = self:node('_indexself', name, self:mustbe(nil, 'name'))
			:setspan{from = from, to = self:getloc()}
	end
	return name
end

-- parses a varialbe name, without attribs, and returns it in a '_var' node
function LuaParser:parse_var()
	local from = self:getloc()
	local name = self:canbe(nil, 'name')
	if not name then return end
	return self:node('_var', name)
		:setspan{from=from, to=self:getloc()}
end

function LuaParser:parse_namelist()
	local var = self:parse_var()
	if not var then return end
	local names = table{var}
	while self:canbe(',', 'symbol') do
		names:insert((assert(self:parse_var(), {msg="expected name"})))
	end
	return names
end

-- same as above but with optional attributes

function LuaParser:parse_attnamelist()
	local from = self:getloc()
	local name = self:canbe(nil, 'name')
	if not name then return end
	local attrib = self:parse_attrib()
	local names = table{
		self:node('_var', name, attrib)
			:setspan{from = from, to = self:getloc()}
	}
	while self:canbe(',', 'symbol') do
		from = self:getloc()
		local name = self:mustbe(nil, 'name')
		local attrib = self:parse_attrib()
		names:insert(
			self:node('_var', name, attrib)
				:setspan{from = from, to = self:getloc()}
		)
	end
	return names
end

function LuaParser:parse_attrib()
	if self.version < '5.4' then return end
	local attrib
	if self:canbe('<', 'symbol') then
		attrib = self:mustbe(nil, 'name')
		self:mustbe('>', 'symbol')
	end
	return attrib
end

function LuaParser:parse_explist()
	local exp = self:parse_exp()
	if not exp then return end
	local exps = table{exp}
	while self:canbe(',', 'symbol') do
		exps:insert((assert(self:parse_exp(), {msg='unexpected symbol'})))
	end
	return exps
end

--[[
exp ::= nil | false | true | Numeral | LiteralString | `...` | function | prefixexp | tableconstructor | exp binop exp | unop exp
... splitting this into two ...
exp ::= [unop] subexp {binop [unop] subexp}
subexp ::= nil | false | true | Numeral | LiteralString | `...` | function | prefixexp | tableconstructor
--]]

function LuaParser:parse_exp()
	return self:parse_expr_precedenceTable(1)
end

function LuaParser:getNextRule(rules)
	for _, rule in pairs(rules) do
		-- TODO why even bother separate it in canbe() ?
		local keywordOrSymbol = rule.token:match'^[_a-zA-Z][_a-zA-Z0-9]*$' and 'keyword' or 'symbol'
		if self:canbe(rule.token, keywordOrSymbol) then
			return rule
		end
	end
end

function LuaParser:getClassNameForRule(rules)
	local rule = self:getNextRule(rules)
	if rule then
		return rule.className
	end
end

function LuaParser:parse_expr_precedenceTable(i)
	local precedenceLevel = self.parseExprPrecedenceRulesAndClassNames[i]
	if precedenceLevel.unaryLHS then
		local from = self:getloc()
		local rule = self:getNextRule(precedenceLevel.rules)
		if rule then
			local nextLevel = i
			if rule.nextLevel then
				nextLevel = self.parseExprPrecedenceRulesAndClassNames:find(nil, function(level)
					return level.name == rule.nextLevel
				end) or error{msg="couldn't find precedence level named "..tostring(rule.nextLevel)}
			end
			return self:node(rule.className, (assert(self:parse_expr_precedenceTable(nextLevel), {msg='unexpected symbol'})))
				:setspan{from = from, to = self:getloc()}
		end
		return self:parse_expr_precedenceTable(i+1)
	else
		-- binary operation by default
		local a
		if i < #self.parseExprPrecedenceRulesAndClassNames then
			a = self:parse_expr_precedenceTable(i+1)
		else
			a = self:parse_subexp()
		end
		if not a then return end
		local rule = self:getNextRule(precedenceLevel.rules)
		if rule then
			local nextLevel = i
			if rule.nextLevel then
				nextLevel = self.parseExprPrecedenceRulesAndClassNames:find(nil, function(level)
					return level.name == rule.nextLevel
				end) or error{msg="couldn't find precedence level named "..tostring(rule.nextLevel)}
			end
			a = self:node(rule.className, a, (assert(self:parse_expr_precedenceTable(nextLevel), {msg='unexpected symbol'})))
				:setspan{from = a.span.from, to = self:getloc()}
		end
		return a
	end
end

function LuaParser:parse_subexp()
	local tableconstructor = self:parse_tableconstructor()
	if tableconstructor then return tableconstructor end

	local prefixexp = self:parse_prefixexp()
	if prefixexp then return prefixexp end

	local functiondef = self:parse_functiondef()
	if functiondef then return functiondef end

	local from = self:getloc()
	if self:canbe('...', 'symbol') then
		assert.eq(self.functionStack:last(), 'function-vararg', {msg='unexpected symbol'})
		return self:node('_vararg')
			:setspan{from = from, to = self:getloc()}
	end
	if self:canbe(nil, 'string') then
		return self:node('_string', self.lasttoken)
			:setspan{from = from, to = self:getloc()}
	end
	if self:canbe(nil, 'number') then
		return self:node('_number', self.lasttoken)
			:setspan{from = from, to = self:getloc()}
	end
	if self:canbe('true', 'keyword') then
		return self:node('_true')
			:setspan{from = from, to = self:getloc()}
	end
	if self:canbe('false', 'keyword') then
		return self:node('_false')
			:setspan{from = from, to = self:getloc()}
	end
	if self:canbe('nil', 'keyword') then
		return self:node('_nil')
			:setspan{from = from, to = self:getloc()}
	end
end

--[[
prefixexp ::= var | functioncall | `(` exp `)`

functioncall ::= prefixexp args | prefixexp `:` Name args
combine...
prefixexp ::= var | prefixexp args | prefixexp `:` Name args | `(` exp `)`
var ::= Name | prefixexp `[` exp `]` | prefixexp `.` Name
combine ...
prefixexp ::= Name | prefixexp `[` exp `]` | prefixexp `.` Name | prefixexp args | prefixexp `:` Name args | `(` exp `)`
simplify ...
prefixexp ::= (Name {'[' exp ']' | `.` Name | [`:` Name] args} | `(` exp `)`) {args}
--]]

function LuaParser:parse_prefixexp()
	local prefixexp
	local from = self:getloc()

	if self:canbe('(', 'symbol') then
		local exp = assert(self:parse_exp(), {msg='unexpected symbol'})
		self:mustbe(')', 'symbol')
		prefixexp = self:node('_par', exp)
			:setspan{from = from, to = self:getloc()}
	else
		prefixexp = self:parse_var()
		if not prefixexp then return end
	end

	while true do
		if self:canbe('[', 'symbol') then
			prefixexp = self:node('_index', prefixexp, (assert(self:parse_exp(), {msg='unexpected symbol'})))
			self:mustbe(']', 'symbol')
			prefixexp:setspan{from = from, to = self:getloc()}
		elseif self:canbe('.', 'symbol') then
			local sfrom = self:getloc()
			prefixexp = self:node('_index',
				prefixexp,
				self:node('_string', self:mustbe(nil, 'name'))
					:setspan{from = sfrom, to = self:getloc()}
			)
			:setspan{from = from, to = self:getloc()}
		elseif self:canbe(':', 'symbol') then
			prefixexp = self:node('_indexself',
				prefixexp,
				self:mustbe(nil, 'name')
			):setspan{from = from, to = self:getloc()}
			local args = self:parse_args()
			if not args then error{msg="function arguments expected"} end
			prefixexp = self:node('_call', prefixexp, table.unpack(args))
				:setspan{from = from, to = self:getloc()}
		else
			local args = self:parse_args()
			if not args then break end

			prefixexp = self:node('_call', prefixexp, table.unpack(args))
				:setspan{from = from, to = self:getloc()}
		end
	end

	return prefixexp
end

-- returns nil on fail to match, like all functions
-- produces error on syntax error
-- returns a table of the args -- particularly an empty table if no args were found

function LuaParser:parse_args()
	local from = self:getloc()
	if self:canbe(nil, 'string') then
		return {
			self:node('_string', self.lasttoken)
				:setspan{from = from, to = self:getloc()}
		}
	end

	local tableconstructor = self:parse_tableconstructor()
	if tableconstructor then return {tableconstructor} end

	if self:canbe('(', 'symbol') then
		local explist = self:parse_explist()
		self:mustbe(')', 'symbol')
		return explist or {}
	end
end
-- helper which also includes the line and col in the function object

function LuaParser:makeFunction(...)
	return self:node('_function', ...) -- no :setspan(), this is done by the caller
end
-- 'function' in the 5.1 syntax

function LuaParser:parse_functiondef()
	local from = self:getloc()
	if not self:canbe('function', 'keyword') then return end
	return self:makeFunction(nil, table.unpack((assert(self:parse_funcbody(), {msg='expected function body'}))))
		:setspan{from = from, to = self:getloc()}
end
-- returns a table of ... first element is a table of args, rest of elements are the body statements

function LuaParser:parse_funcbody()
	if not self:canbe('(', 'symbol') then return end
	local args = self:parse_parlist() or table()
	local lastArg = args:last()
	local functionType = self.ast._vararg:isa(lastArg) and 'function-vararg' or 'function'
	self:mustbe(')', 'symbol')
	self.functionStack:insert(functionType)
	local block = self:parse_block(functionType)
	assert.eq(self.functionStack:remove(), functionType)
	self:mustbe('end', 'keyword')
	return table{args, table.unpack(block)}
end

function LuaParser:parse_parlist()	-- matches namelist() with ... as a terminator
	local from = self:getloc()
	if self:canbe('...', 'symbol') then
		return table{
			self:node('_vararg')
				:setspan{from = from, to = self:getloc()}
		}
	end

	local namevar = self:parse_var()
	if not namevar then return end
	local names = table{namevar}
	while self:canbe(',', 'symbol') do
		from = self:getloc()
		if self:canbe('...', 'symbol') then
			names:insert(
				self:node('_vararg')
					:setspan{from = from, to = self:getloc()}
			)
			return names
		end
		local namevar = self:parse_var()
		if not namevar then error{msg="expected name"} end
		names:insert(namevar)
	end
	return names
end

function LuaParser:parse_tableconstructor()
	local from = self:getloc()
	if not self:canbe('{', 'symbol') then return end
	local fields = self:parse_fieldlist()
	self:mustbe('}', 'symbol')
	return self:node('_table', table.unpack(fields or {}))
		:setspan{from = from, to = self:getloc()}
end

function LuaParser:parse_fieldlist()
	local field = self:parse_field()
	if not field then return end
	local fields = table{field}
	while self:parse_fieldsep() do
		local field = self:parse_field()
		if not field then break end
		fields:insert(field)
	end
	self:parse_fieldsep()
	return fields
end

function LuaParser:parse_field()
	local from = self:getloc()
	if self:canbe('[', 'symbol') then
		local keyexp = assert(self:parse_exp(), {msg='unexpected symbol'})
		self:mustbe(']', 'symbol')
		self:mustbe('=', 'symbol')
		local valexp = self:parse_exp()
		if not valexp then error{msg="expected expression but found "..tostring(self.t.token)} end
		return self:node('_assign', {keyexp}, {valexp})
			:setspan{from = from, to = self:getloc()}
	end

	-- this will be Name or exp
	-- in the case that it is a Name then check for = exp
	local exp = self:parse_exp()
	if not exp then return end

	if self.ast._var:isa(exp) and self:canbe('=', 'symbol') then
		return self:node('_assign',
			{
				self:node('_string', exp.name):setspan(exp.span)
			}, {
				(assert(self:parse_exp(), {msg='unexpected symbol'}))
			}
		):setspan{from = from, to = self:getloc()}
	else
		return exp
	end
end

function LuaParser:parse_fieldsep()
	return self:canbe(',', 'symbol') or self:canbe(';', 'symbol')
end

return LuaParser

end)
__bundle_register("lib.lua-parser.base.parser", function(require, _LOADED, __bundle_register, __bundle_modules)
local class = require("ext.class")
local table = require("ext.table")
local tolua = require("ext.tolua")

local Parser = class()

-- seems redundant. does anyone need to construct a Parser without data? maybe to modify the syntax or something?  just build a subclass in that case?
function Parser:init(data, ...)
	if data then
		assert(self:setData(data, ...))
	end
end

--[[
returns
	true upon success
	nil, msg, loc upon failure
--]]
function Parser:setData(data, source)
	assert(data, "expected data")
	data = tostring(data)
	self.source = source
	local t = self:buildTokenizer(data)
	t:start()
	self.t = t

	-- default entry point for parsing data sources
	local parseError
	local result = table.pack(xpcall(function()
		self.tree = self:parseTree()
	end, function(err)
		-- throw an object if it's an error parsing the code
		if type(err) == 'table' then
			parseError = err
			return
		else
			return err..'\n'
				..self.t:getpos()..'\n'
				..debug.traceback()
		end
	end))
	if not result[1] then
		if not parseError then error(result[2]) end	-- internal error
		return false, self.t:getpos()..': '..parseError.msg 	-- parsed code error
	end

	--
	-- now that we have the tree, build parents
	-- ... since I don't do that during construction ...
	self.ast.refreshparents(self.tree)

	if self.t.token then
		return false, self.t:getpos()..": expected eof, found "..self.t.token
	end
	return true
end

-- TODO I don't need all these, just :getloc()
function Parser:getloc()
	local loc = self.t:getloc()
	loc.source = self.source
	return loc
end

function Parser:canbe(token, tokentype)	-- token is optional
	assert(tokentype)
	if (not token or token == self.t.token)
	and tokentype == self.t.tokentype
	then
		self.lasttoken, self.lasttokentype = self.t.token, self.t.tokentype
		self.t:consume()
		return self.lasttoken, self.lasttokentype
	end
end

function Parser:mustbe(token, tokentype)
	local lasttoken, lasttokentype = self.t.token, self.t.tokentype
	self.lasttoken, self.lasttokentype = self:canbe(token, tokentype)
	if not self.lasttoken then
		error{msg="expected token="..tolua(token).." tokentype="..tolua(tokentype).." but found token="..tolua(lasttoken).." type="..tolua(lasttokentype)}
	end
	return self.lasttoken, self.lasttokentype
end

-- make new ast node, assign it back to the parser (so it can tell what version / keywords / etc are being used)
function Parser:node(index, ...)
	local node = self.ast[index](...)
	node.parser = self
	return node
end

return Parser

end)
__bundle_register("lib.lua-parser.lua.tokenizer", function(require, _LOADED, __bundle_register, __bundle_modules)
local table = require("ext.table")
local assert = require("ext.assert")
local Tokenizer = require("parser.base.tokenizer")

local LuaTokenizer = Tokenizer:subclass()

--[[
NOTICE this only needs to be initialized once per tokenizer, not per-data-source
however at the moment it does need to be initialized once-per-version (as the extra arg to Tokenizer)
maybe I should move it to static initialization and move version-based stuff to subclasses' static-init?

So why 'symbols' vs 'keywords' ?
'Keywords' consist of valid names (names like variables functions etc use)
while 'symbols' consist of everything else. (can symbols contain letters that names can use? at the moment they do not.)
For this reason, when parsing, keywords need separated spaces, while symbols do not (except for distinguishing between various-sized symbols, i.e. < < vs <<).
--]]
function LuaTokenizer:initSymbolsAndKeywords(version, useluajit)
	-- store later for parseHexNumber
	self.version = assert(version)
	self.useluajit = useluajit
	
	for w in ([[... .. == ~= <= >= + - * / % ^ # < > = ( ) { } [ ] ; : , .]]):gmatch('%S+') do
		self.symbols:insert(w)
	end

	for w in ([[and break do else elseif end false for function if in local nil not or repeat return then true until while]]):gmatch('%S+') do
		self.keywords[w] = true
	end

	-- TODO this will break because luajit doesn't care about versions
	-- if I use a load-test, the ext.load shim layer will break
	-- if I use a load('goto=true') test without ext.load then load() doens't accept strings for 5.1 when the goto isn't a keyword, so I might as well just test if load can load any string ...
	-- TODO separate language features from versions and put all the language options in a ctor table somewhere
	do--if version >= '5.2' then
		self.symbols:insert'::'	-- for labels .. make sure you insert it before ::
		self.keywords['goto'] = true
	end
	
	if version >= '5.3' then
		self.symbols:insert'//'
		self.symbols:insert'~'
		self.symbols:insert'&'
		self.symbols:insert'|'
		self.symbols:insert'<<'
		self.symbols:insert'>>'
	end
end

function LuaTokenizer:parseHexNumber(...)
	local r = self.r
	-- if version is 5.2 then allow decimals in hex #'s, and use 'p's instead of 'e's for exponents
	if self.version >= '5.2' then
		-- TODO this looks like the float-parse code below (but with e+- <-> p+-) but meh I'm lazy so I just copied it.
		local token = r:canbe'[%.%da-fA-F]+'
		local numdots = #token:gsub('[^%.]','')
		assert.le(numdots, 1, {msg='malformed number'})
		local n = table{'0x', token}
		if r:canbe'p' then
			n:insert(r.lasttoken)
			-- fun fact, while the hex float can include hex digits, its 'p+-' exponent must be in decimal.
			n:insert(r:mustbe('[%+%-]%d+', 'malformed number'))
		elseif numdots == 0 and self.useluajit then
			if r:canbe'LL' then
				n:insert'LL'
			elseif r:canbe'ULL' then
				n:insert'ULL'
			end
		end
		coroutine.yield(n:concat(), 'number')
	else
		--return LuaTokenizer.super.parseHexNumber(self, ...)
		local token = r:mustbe('[%da-fA-F]+', 'malformed number')
		local n = table{'0x', token}
		if self.useluajit then
			if r:canbe'LL' then
				n:insert'LL'
			elseif r:canbe'ULL' then
				n:insert'ULL'
			end
		end
		coroutine.yield(n:concat(), 'number')
	end
end

function LuaTokenizer:parseDecNumber()
	local r = self.r
	local token = r:canbe'[%.%d]+'
	local numdots = #token:gsub('[^%.]','')
	assert.le(numdots, 1, {msg='malformed number'})
	local n = table{token}
	if r:canbe'e' then
		n:insert(r.lasttoken)
		n:insert(r:mustbe('[%+%-]%d+', 'malformed number'))
	elseif numdots == 0 and self.useluajit then
		if r:canbe'LL' then
			n:insert'LL'
		elseif r:canbe'ULL' then
			n:insert'ULL'
		end
	end
	coroutine.yield(n:concat(), 'number')
end

return LuaTokenizer

end)
__bundle_register("lib.lua-parser.base.tokenizer", function(require, _LOADED, __bundle_register, __bundle_modules)
local table = require("ext.table")
local string = require("ext.string")
local class = require("ext.class")
local assert = require("ext.assert")
local DataReader = require("parser.base.datareader")

local Tokenizer = class()

function Tokenizer:initSymbolsAndKeywords(...)
end

function Tokenizer:init(data, ...)
	-- TODO move what this does to just the subclass initialization
	self.symbols = table(self.symbols)
	self.keywords = table(self.keywords):setmetatable(nil)
	self:initSymbolsAndKeywords(...)

	self.r = DataReader(data)
	self.gettokenthread = coroutine.create(function()
		local r = self.r

		while not r:done() do
			self:skipWhiteSpaces()
			if r:done() then break end

			if self:parseComment() then
			elseif self:parseString() then
			elseif self:parseName() then
			elseif self:parseNumber() then
			elseif self:parseSymbol() then
			else
				error{msg="unknown token "..r.data:sub(r.index)}
			end
		end
	end)
end

function Tokenizer:skipWhiteSpaces()
	local r = self.r
	r:canbe'%s+'
---DEBUG(parser.base.tokenizer): if r.lasttoken then print('read space ['..(r.index-#r.lasttoken)..','..r.index..']: '..r.lasttoken) end
end

-- Lua-specific comments (tho changing the comment symbol is easy ...)
Tokenizer.singleLineComment = string.patescape'--'
function Tokenizer:parseComment()
	local r = self.r
	if r:canbe(self.singleLineComment) then
local start = r.index - #r.lasttoken
		-- read block comment if it exists
		if not r:readblock() then
			-- read line otherwise
			if not r:seekpast'\n' then
				r:seekpast'$'
			end
		end
		--local commentstr = r.data:sub(start, r.index-1)
		-- TODO how to insert comments into the AST?  should they be their own nodes?
		-- should all whitespace be its own node, so the original code text can be reconstructed exactly?
		--coroutine.yield(commentstr, 'comment')
---DEBUG(parser.base.tokenizer): print('read comment ['..start..','..(r.index-1)..']:'..commentstr)
		return true
	end
end

function Tokenizer:parseString()
	if self:parseBlockString() then return true end
	if self:parseQuoteString() then return true end
end

-- Lua-specific block strings
function Tokenizer:parseBlockString()
	local r = self.r
	if r:readblock() then
---DEBUG(parser.base.tokenizer): print('read multi-line string ['..(r.index-#r.lasttoken)..','..r.index..']: '..r.lasttoken)
		coroutine.yield(r.lasttoken, 'string')
		return true
	end
end

-- TODO this is a very lua function though it's in parser/base/ and not parser/lua/ ...
-- '' or "" single-line quote-strings with escape-codes
function Tokenizer:parseQuoteString()
	local r = self.r
	if r:canbe'["\']' then
---DEBUG(parser.base.tokenizer): print('read quote string ['..(r.index-#r.lasttoken)..','..r.index..']: '..r.lasttoken)
---DEBUG(parser.base.tokenizer): local start = r.index-#r.lasttoken
		local quote = r.lasttoken
		local s = table()
		while true do
			r:seekpast'.'
			if r.lasttoken == quote then break end
			if r:done() then error{msg="unfinished string"} end
			if r.lasttoken == '\\' then
				local esc = r:canbe'.'
				local escapeCodes = {a='\a', b='\b', f='\f', n='\n', r='\r', t='\t', v='\v', ['\\']='\\', ['"']='"', ["'"]="'", ['0']='\0', ['\r']='\n', ['\n']='\n'}
				local escapeCode = escapeCodes[esc]
				if escapeCode then
					s:insert(escapeCode)
				elseif esc == 'x' and self.version >= '5.2' then
					esc = r:mustbe'%x' .. r:mustbe'%x'
					s:insert(string.char(tonumber(esc, 16)))
				elseif esc == 'u' and self.version >= '5.3' then
					r:mustbe'{'
					local code = 0
					while true do
						local ch = r:canbe'%x'
						if not ch then break end
						code = code * 16 + tonumber(ch, 16)
					end
					r:mustbe'}'

					-- hmm, needs bit library or bit operations, which should only be present in version >= 5.3 anyways so ...
					local bit = bit32 or require("bit")
					if code < 0x80 then
						s:insert(string.char(code))	-- 0xxxxxxx
					elseif code < 0x800 then
						s:insert(
							string.char(bit.bor(0xc0, bit.band(0x1f, bit.rshift(code, 6))))
							.. string.char(bit.bor(0x80, bit.band(0x3f, code)))
						)
					elseif code < 0x10000 then
						s:insert(
							string.char(bit.bor(0xe0, bit.band(0x0f, bit.rshift(code, 12))))
							.. string.char(bit.bor(0x80, bit.band(0x3f, bit.rshift(code, 6))))
							.. string.char(bit.bor(0x80, bit.band(0x3f, code)))
						)
					else
						s:insert(
							string.char(bit.bor(0xf0, bit.band(0x07, bit.rshift(code, 18))))
							.. string.char(bit.bor(0x80, bit.band(0x3f, bit.rshift(code, 12))))
							.. string.char(bit.bor(0x80, bit.band(0x3f, bit.rshift(code, 6))))
							.. string.char(bit.bor(0x80, bit.band(0x3f, code)))
						)
					end
				elseif esc:match('%d') then
					-- can read up to three
					if r:canbe'%d' then esc = esc .. r.lasttoken end
					if r:canbe'%d' then esc = esc .. r.lasttoken end
					s:insert(string.char(tonumber(esc)))
				else
					if self.version >= '5.2' then
						-- lua5.1 doesn't care about bad escape codes
						error{msg="invalid escape sequence "..esc}
					end
				end
			else
				s:insert(r.lasttoken)
			end
		end
---DEBUG(parser.base.tokenizer): print('read quote string ['..start..','..(r.index-#r.lasttoken)..']: '..r.data:sub(start, r.index-#r.lasttoken))
		coroutine.yield(s:concat(), 'string')
		return true
	end
end

-- C names
function Tokenizer:parseName()
	local r = self.r
	if r:canbe'[%a_][%w_]*' then	-- name
---DEBUG(parser.base.tokenizer): print('read name ['..(r.index-#r.lasttoken)..', '..r.index..']: '..r.lasttoken)
		coroutine.yield(r.lasttoken, self.keywords[r.lasttoken] and 'keyword' or 'name')
		return true
	end
end

function Tokenizer:parseNumber()
	local r = self.r
	if r.data:match('^[%.%d]', r.index) -- if it's a decimal or a number...
	and (r.data:match('^%d', r.index)	-- then, if it's a number it's good
	or r.data:match('^%.%d', r.index))	-- or if it's a decimal then if it has a number following it then it's good ...
	then 								-- otherwise I want it to continue to the next 'else'
		-- lua doesn't consider the - to be a part of the number literal
		-- instead, it parses it as a unary - and then possibly optimizes it into the literal during ast optimization
---DEBUG(parser.base.tokenizer): local start = r.index
		if r:canbe'0[xX]' then
			self:parseHexNumber()
		else
			self:parseDecNumber()
		end
---DEBUG(parser.base.tokenizer): print('read number ['..start..', '..r.index..']: '..r.data:sub(start, r.index-1))
		return true
	end
end

function Tokenizer:parseHexNumber()
	local r = self.r
	local token = r:mustbe('[%da-fA-F]+', 'malformed number')
	coroutine.yield('0x'..token, 'number')
end

function Tokenizer:parseDecNumber()
	local r = self.r
	local token = r:canbe'[%.%d]+'
	assert.le(#token:gsub('[^%.]',''), 1, 'malformed number')
	local n = table{token}
	if r:canbe'e' then
		n:insert(r.lasttoken)
		n:insert(r:mustbe('[%+%-]%d+', 'malformed number'))
	end
	coroutine.yield(n:concat(), 'number')
end

function Tokenizer:parseSymbol()
	local r = self.r
	-- see if it matches any symbols
	for _,symbol in ipairs(self.symbols) do
		if r:canbe(string.patescape(symbol)) then
---DEBUG(parser.base.tokenizer): print('read symbol ['..(r.index-#r.lasttoken)..','..r.index..']: '..r.lasttoken)
			coroutine.yield(r.lasttoken, 'symbol')
			return true
		end
	end
end

-- separate this in case someone has to modify the tokenizer symbols and keywords before starting
function Tokenizer:start()
	-- TODO provide tokenizer the AST namespace and have it build the tokens (and keywords?) here automatically
	self.symbols = self.symbols:mapi(function(v,k) return true, v end):keys()
	-- arrange symbols from largest to smallest
	self.symbols:sort(function(a,b) return #a > #b end)
	self:consume()
	self:consume()
end

function Tokenizer:consume()
	-- [[ TODO store these in an array somewhere, make the history adjustable
	-- then in all the get[prev][2]loc's just pass an index for how far back to search
	self.prev2index = self.previndex
	self.prev2tokenIndex = self.prevtokenIndex

	self.previndex = self.r.index
	self.prevtokenIndex = #self.r.tokenhistory+1
	--]]

	self.token = self.nexttoken
	self.tokentype = self.nexttokentype
	if coroutine.status(self.gettokenthread) == 'dead' then
		self.nexttoken = nil
		self.nexttokentype = nil
		-- done = true
		return
	end
	local status, nexttoken, nexttokentype = coroutine.resume(self.gettokenthread)
	-- detect errors
	if not status then
		local err = nexttoken
		error{
			msg = err,
			token = self.token,
			tokentype = self.tokentype,
			pos = self:getpos(),
			traceback = debug.traceback(self.gettokenthread),
		}
	end
	self.nexttoken = nexttoken
	self.nexttokentype = nexttokentype
end

function Tokenizer:getpos()
	return 'line '..self.r.line
		..' col '..self.r.col
		..' code "'..self.r.data:sub(self.r.index):match'^[^\n]*'..'"'
end

-- return the span across
function Tokenizer:getloc()
	local r = self.r
	local line = self.r.line
	local col = self.r.col

	return {
		line = line,
		col = col,
		index = self.prev2index,
		tokenIndex = self.prev2tokenIndex,
	}
end

return Tokenizer

end)
__bundle_register("lib.lua-parser.base.datareader", function(require, _LOADED, __bundle_register, __bundle_modules)
--[[
TODO
store all tokens(term?) as we go in tokenhistory
then have Tokenizer keep track of the range in this array / forward it to be used as the span in AST
then the AST can look into this array, (maybe also keep track of which tokens are whitespace/comments)
... and reproduce the original file exactly as-is (if so desired).

TODO make sure *all* tokens are correctly stored in tokenhistory.  right now it doesn't reproduce source in 100% of cases. maybe just 99%.

TODO terminology ...
DataReader gets chars as input, turns them into ... collections-of-chars?
Tokenizer gets collections-of-chars as input, turns them into tokens
Parser gets tokens as input, turns them into AST nodes
--]]
local table = require("ext.table")
local class = require("ext.class")
local assert = require("ext.assert")

local DataReader = class()

-- At the moment this is 100% cosmetic.
-- In case someone doesn't want tracking all tokens done for whatever reason (slowdown, memory, etc)
-- enable/disable this to make token-tracking optional
DataReader.tracktokens = true

function DataReader:init(data)
	self.data = data
	self.index = 1

	-- keep track of all tokens as we parse them.
	self.tokenhistory = table()

	-- TODO this isn't robust against different OS file formats.  maybe switching back to determining line number offline / upon error encounter is better than trying to track it while we parse.
	self.line = 1
	self.col = 1

	-- skip past initial #'s
	if self.data:sub(1,1) == '#' then
		if not self:seekpast'\n' then
			self:seekpast'$'
		end
	end
end

function DataReader:done()
	return self.index > #self.data
end

local slashNByte = ('\n'):byte()
function DataReader:updatelinecol()
	if not self.lastUpdateLineColIndex then
		self.lastUpdateLineColIndex = 1
	else
		assert(self.index >= self.lastUpdateLineColIndex)
	end
	for i=self.lastUpdateLineColIndex,self.index do
		if self.data:byte(i,i) == slashNByte then
			self.col = 1
			self.line = self.line + 1
		else
			self.col = self.col + 1
		end
	end
	self.lastUpdateLineColIndex = self.index+1
end

function DataReader:setlasttoken(lasttoken, skipped)
	self.lasttoken = lasttoken
	if self.tracktokens then
		if skipped and #skipped > 0 then
--DEBUG(parser.base.datareader): print('SKIPPED', require 'ext.tolua'(skipped))
			self.tokenhistory:insert(skipped)
		end
--DEBUG(parser.base.datareader): print('TOKEN', require 'ext.tolua'(self.lasttoken))
		self.tokenhistory:insert(self.lasttoken)
--DEBUG(parser.base.datareader paranoid): local sofar = self.tokenhistory:concat()
--DEBUG(parser.base.datareader paranoid): assert.eq(self.data:sub(1,#sofar), sofar, "source vs tokenhistory")
	end
	return self.lasttoken
end

function DataReader:seekpast(pattern)
--DEBUG(parser.base.datareader): print('DataReader:seekpast', require 'ext.tolua'(pattern))
	local from, to = self.data:find(pattern, self.index)
	if not from then return end
	local skipped = self.data:sub(self.index, from - 1)
	self.index = to + 1
	self:updatelinecol()
	return self:setlasttoken(self.data:sub(from, to), skipped)
end

function DataReader:canbe(pattern)
--DEBUG(parser.base.datareader): print('DataReader:canbe', require 'ext.tolua'(pattern))
	return self:seekpast('^'..pattern)
end

function DataReader:mustbe(pattern, msg)
--DEBUG(parser.base.datareader): print('DataReader:mustbe', require 'ext.tolua'(pattern))
	if not self:canbe(pattern) then error{msg=msg or "expected "..pattern} end
	return self.lasttoken
end

-- TODO this one is specific to Lua languages ... I could move it into tokenizer ...
function DataReader:readblock()
	if not self:canbe('%[=*%[') then return end
	local eq = assert(self.lasttoken:match('^%[(=*)%[$'))
	self:canbe'\n'	-- if the first character is a newline then skip it
	local start = self.index
	if not self:seekpast('%]'..eq..'%]') then
		error{msg="expected closing block"}
	end
	-- since we used seekpast, the string isn't being captured as a lasttoken ...
	--return self:setlasttoken(self.data:sub(start, self.index - #self.lasttoken - 1))
	-- ... so don't push it into the history here, just assign it.
	self.lasttoken = self.data:sub(start, self.index - #self.lasttoken - 1)
	return self.lasttoken
end

return DataReader

end)
__bundle_register("lib.lua-parser.lua.ast", function(require, _LOADED, __bundle_register, __bundle_modules)
--[[
parser.base.ast returns the BaseAST root of all AST nodes

TODO ...
... but parser.lua.ast (and maybe soon parser.grammar.ast) return a collection-of-nodes, which are key'd to the token ... hmm ...
maybe for consistency I should have parser.lua.ast return the LuaAST, which is an BaseAST child, and parent of all Lua AST nodes ...
... and give that node a member htat holds a key/value map to all nodes per token ...
But using a namespace is definitely convenient, especially with all the member subclasses and methods that go in it (traverse, nodeclass, etc)
... though these can easily turn into member fields and member methods

tempting to replace the 'ast' namespace with just LuaAST itself, and keep the convention that keys beginning with `_` are subclasses...
--]]
local table = require("ext.table")
local assert = require("ext.assert")
local tolua = require("ext.tolua")

local BaseAST = require("parser.base.ast")


-- namespace table of all Lua AST nodes
-- TODO get rid of parser's dependency on this?  or somehow make the relation between parser rules and ast's closer, like generate the AST from the parser-rules?
-- another TODO how about just storing subclasses as `._type` , then the 'ast' usage outside this file can be just echanged with LuaASTNode itself, and the file can return a class, and lots of things can be simplified
local ast = {}

-- Lua-specific parent class.  root of all other ast node classes in this file.
local LuaAST = BaseAST:subclass()

-- assign to 'ast.node' to define it as the Lua ast's parent-most node class
ast.node = LuaAST

--[[
args:
	maintainSpan = set to true to have the output maintain the input's span
--]]
local slashNByte = ('\n'):byte()
function LuaAST:serializeRecursiveMember(field, args)
	local maintainSpan
	if args then
		maintainSpan = args.maintainSpan
	end
	local s = ''
	-- :serialize() impl provided by child classes
	-- :serialize() should call traversal in-order of parsing (why I want to make it auto and assoc wth the parser and grammar and rule-generated ast node classes)
	-- that means serialize() itself should never call serialize() but only call the consume() function passed into it (for modularity's sake)
	-- it might mean i should capture all nodes too, even those that are fixed, like keywords and symbols, for the sake of reassmbling the syntax
	local line = 1
	local col = 1
	local index = 1
	local consume
	local lastspan
	consume = function(x)
		if type(x) == 'number' then
			x = tostring(x)
		end
		if type(x) == 'string' then
			-- here's our only string join
			local function append(u)
				for i=1,#u do
					if u:byte(i) == slashNByte then
						col = 1
						line = line + 1
					else
						col = col + 1
					end
				end
				index = index + #u
				s = s .. u
			end

			-- TODO here if you want ... pad lines and cols until we match the original location (or exceed it)
			-- to do that, track appended strings to have a running line/col counter just like we do in parser
			-- to do that, separate teh updatelinecol() in the parser to work outside datareader
			if maintainSpan and lastspan then
				while line < lastspan.from.line do
					append'\n'
				end
			end

			-- if we have a name coming in, only insert a space if we were already at a name
			local namelhs = s:sub(-1):match'[_%w]'
			local namerhs = x:sub(1,1):match'[_%w]'
			if namelhs and namerhs then
				append' '
			elseif not namelhs and not namerhs then
				-- TODO here for minification if you want
				-- if we have a symbol coming in, only insert a space if we were already at a symbol and the two together would make a different valid symbol
				-- you'll need to search back the # of the max length of any symbol ...
				append' '
			end
			append(x)
		elseif type(x) == 'table' then
			lastspan = x.span
			assert.is(x, BaseAST)
			assert.index(x, field)
			x[field](x, consume)
		else
			error('here with unknown type '..type(x))
		end
	end
	self[field](self, consume)
	return s
end

function LuaAST:toLua(args)
	return self:serializeRecursiveMember('toLua_recursive', args)
end

-- why distinguish toLua() and serialize(consume)?
-- The need for this design pops up more in subclasses.
-- serialize(consume) is used by all language-serializations
-- toLua_recursive(consume) is for Lua-specific serialization (to-be-subclassed)
-- I'm not sure if this is better than just using a fully separate table of serialization functions per node ...
-- toLua() is the external API
function LuaAST:toLua_recursive(consume)
	return self:serialize(consume)
end

-- ok maybe it's not such a good idea to use tostring and serialization for the same purpose ...
LuaAST.__tostring = string.nametostring

function LuaAST:exec(...)
	local code = self:toLua()
	local f, msg = load(code, ...)
	if not f then
		return nil, msg, code
	end
	return f
end


-- TODO what's a more flexible way of iterating through all child fields?
-- and what's a more flexible way of constructing AST node subclass, and of specifying their fields,
--  especially with grammar rule construction?
-- ... how about instead make all fields indexed, and then for certain classes give them aliases into the fields?
-- ... same with htmlparser?
-- then in line with this, fields will either point to nodes, or point to tables to nodes?
--  or maybe the tables-of-nodes should themselves be AST nodes?
local fields = {
	{'name', 'field'},
	{'index', 'field'},
	{'value', 'field'},
	{'cond', 'one'},
	{'var', 'one'},
	{'min', 'one'},
	{'max', 'one'},
	{'step', 'one'},
	{'func', 'one'},		-- should this be a _function, or a string depicting a function?
	{'arg', 'one'},
	{'key', 'one'},
	{'expr', 'one'},
	{'stmt', 'one'},
	{'args', 'many'},
	{'exprs', 'many'},
	{'elseifs', 'many'},
	{'elsestmt', 'many'},
	{'vars', 'many'},
}

ast.exec = LuaAST.exec

--[[
I need to fix this up better to handle short-circuiting, replacing, removing, etc...
parentFirstCallback is the parent-first traversal method
childFirstCallback is the child-first traversal
return what value of the callbacks you want
returning a new node at the parent callback will not traverse its subsequent new children added to the tree
--]]
local function traverseRecurse(
	node,
	parentFirstCallback,
	childFirstCallback,
	parentNode
)
	if not LuaAST:isa(node) then return node end
	if parentFirstCallback then
		local ret = parentFirstCallback(node, parentNode)
		if ret ~= node then
			return ret
		end
	end
	if type(node) == 'table' then
		-- treat the object itself like an array of many
		for i=1,#node do
			node[i] = traverseRecurse(node[i], parentFirstCallback, childFirstCallback, node)
		end
		for _,field in ipairs(fields) do
			local name = field[1]
			local howmuch = field[2]
			if node[name] then
				if howmuch == 'one' then
					node[name] = traverseRecurse(node[name], parentFirstCallback, childFirstCallback, node)
				elseif howmuch == 'many' then
					local value = node[name]
					for i=#value,1,-1 do
						value[i] = traverseRecurse(value[i], parentFirstCallback, childFirstCallback, node)
					end
				elseif howmuch == 'field' then
				else
					error("unknown howmuch "..howmuch)
				end
			end
		end
	end
	if childFirstCallback then
		node = childFirstCallback(node, parentNode)
	end
	return node
end

function ast.refreshparents(node)
	traverseRecurse(node, function(node, parent)
		node.parent = parent
		return node
	end)
end

local function traverse(node, ...)
	local newnode = traverseRecurse(node, ...)
	ast.refreshparents(newnode)
	return newnode
end

LuaAST.traverse = traverse
ast.traverse = traverse

function LuaAST.copy(n)
	local newn = {}
	setmetatable(newn, getmetatable(n))
	for i=1,#n do
		newn[i] = LuaAST.copy(n[i])
	end
	for _,field in ipairs(fields) do
		local name = field[1]
		local howmuch = field[2]
		local value = n[name]
		if value then
			if howmuch == 'one' then
				if type(value) == 'table' then
					newn[name] = LuaAST.copy(value)
				else
					newn[name] = value
				end
			elseif howmuch == 'many' then
				local newmany = {}
				for k,v in ipairs(value) do
					if type(v) == 'table' then
						newmany[k] = LuaAST.copy(v)
					else
						newmany[k] = v
					end
				end
				newn[name] = newmany
			elseif howmuch == 'field' then
				newn[name] = value
			else
				error("unknown howmuch "..howmuch)
			end
		end
	end
	return newn
end
ast.copy = LuaAST.copy

--[[
flatten a function:
for all its calls, insert them as statements inside the function
this is only possible if the called functions are of a specific form...
varmap is the mapping from function names to _function objects to inline in the _call's place


if the nested function ends with a return ...
... then insert its declarations (for var remapping) into a statement just before the one with this call
... and wrap our return contents in parenthesis ... or make general use of ()'s everywhere (for resolution order)

f stmt
f stmt
f stmt
return something(g(...), h(...))

becomes

f stmt
f stmt
f stmt
local g ret
g stmt
g stmt
g stmt
g ret = previous return value of h
local h ret
h stmt
h stmt
h stmt
h ret = previous return value of h
return something(g ret, h ret)

--]]
function LuaAST.flatten(f, varmap)
	f = LuaAST.copy(f)
	traverseRecurse(f, function(n)
		if type(n) == 'table'
		and ast._call:isa(n)
		then
			local funcname = n.func:toLua()	-- in case it's a var ... ?
			assert(funcname, "can't flatten a function with anonymous calls")
			local f = varmap[funcname]
			if f
			and #f == 1
			and ast._return:isa(f[1])
			then
				local retexprs = {}
				for i,e in ipairs(f[1].exprs) do
					retexprs[i] = LuaAST.copy(e)
					traverseRecurse(retexprs[i], function(v)
						-- _arg is not used by parser - externally used only - I should move flatten somewhere else ...
						if ast._arg:isa(v) then
							return LuaAST.copy(n.args[i])
						end
					end)
					retexprs[i] = ast._par(retexprs[i])
				end
				return ast._block(table.unpack(retexprs))	-- TODO exprlist, and redo assign to be based on vars and exprs
			end
		end
		return n
	end)
	return f
end
ast.flatten = LuaAST.flatten

local function consumeconcat(consume, t, sep)
	for i,x in ipairs(t) do
		consume(x)
		if sep and i < #t then
			consume(sep)
		end
	end
end

local function spacesep(stmts, consume)
	consumeconcat(consume, stmts)
end

local function commasep(exprs, consume)
	consumeconcat(consume, exprs, ',')
end

local function nodeclass(type, parent, args)
	parent = parent or LuaAST
	local cl = parent:subclass(args)
	cl.type = type
	cl.__name = type
	ast['_'..type] = cl
	return cl
end
ast.nodeclass = nodeclass

-- helper function
local function isLuaName(s)
	return s:match'^[_%a][_%w]*$'
end
function ast.keyIsName(key, parser)
	return ast._string:isa(key)
	-- if key is a string and has no funny chars
	and isLuaName(key.value)
	and (
		-- ... and if we don't have a .parser assigned (as is the case of some dynamic ast manipulation ... *cough* vec-lua *cough* ...)
		not parser
		-- ... or if we do have a parser and this name isn't a keyword in the parser's tokenizer
		or not parser.t.keywords[key.value]
	)
end

-- generic global stmt collection
local _block = nodeclass'block'
function _block:init(...)
	for i=1,select('#', ...) do
		self[i] = select(i, ...)
	end
end
function _block:serialize(consume)
	spacesep(self, consume)
end

--statements

local _stmt = nodeclass'stmt'

-- TODO 'vars' and 'exprs' should be nodes themselves ...
local _assign = nodeclass('assign', _stmt)
function _assign:init(vars, exprs)
	self.vars = table(vars)
	self.exprs = table(exprs)
end
function _assign:serialize(consume)
	commasep(self.vars, consume)
	consume'='
	commasep(self.exprs, consume)
end

-- should we impose construction constraints _do(_block(...))
-- or should we infer?  _do(...) = {type = 'do', block = {type = 'block, ...}}
-- or should we do neither?  _do(...) = {type = 'do', ...}
-- neither for now
-- but that means _do and _block are identical ...
local _do = nodeclass('do', _stmt)
function _do:init(...)
	for i=1,select('#', ...) do
		self[i] = select(i, ...)
	end
end
function _do:serialize(consume)
	consume'do'
	spacesep(self, consume)
	consume'end'
end

local _while = nodeclass('while', _stmt)
-- TODO just make self[1] into the cond ...
function _while:init(cond, ...)
	self.cond = cond
	for i=1,select('#', ...) do
		self[i] = select(i, ...)
	end
end
function _while:serialize(consume)
	consume'while'
	consume(self.cond)
	consume'do'
	spacesep(self, consume)
	consume'end'
end

local _repeat = nodeclass('repeat', _stmt)
-- TODO just make self[1] into the cond ...
function _repeat:init(cond, ...)
	self.cond = cond
	for i=1,select('#', ...) do
		self[i] = select(i, ...)
	end
end
function _repeat:serialize(consume)
	consume'repeat'
	spacesep(self, consume)
	consume'until'
	consume(self.cond)
end

--[[
_if(_eq(a,b),
	_assign({a},{2}),
	_elseif(...),
	_elseif(...),
	_else(...))
--]]
-- weird one, idk how to reformat
local _if = nodeclass('if', _stmt)
-- TODO maybe just assert the node types and store them as-is in self[i]
function _if:init(cond,...)
	local elseifs = table()
	local elsestmt, laststmt
	for i=1,select('#', ...) do
		local stmt = select(i, ...)
		if ast._elseif:isa(stmt) then
			elseifs:insert(stmt)
		elseif ast._else:isa(stmt) then
			assert(not elsestmt)
			elsestmt = stmt -- and remove
		else
			if laststmt then
				assert(laststmt.type ~= 'elseif' and laststmt.type ~= 'else', "got a bad stmt in an if after an else: "..laststmt.type)
			end
			table.insert(self, stmt)
		end
		laststmt = stmt
	end
	self.cond = cond
	self.elseifs = elseifs
	self.elsestmt = elsestmt
end
function _if:serialize(consume)
	consume'if'
	consume(self.cond)
	consume'then'
	spacesep(self, consume)
	for _,ei in ipairs(self.elseifs) do
		consume(ei)
	end
	if self.elsestmt then
		consume(self.elsestmt)
	end
	consume'end'
end

-- aux for _if
local _elseif = nodeclass('elseif', _stmt)
-- TODO just make self[1] into the cond ...
function _elseif:init(cond,...)
	self.cond = cond
	for i=1,select('#', ...) do
		self[i] = select(i, ...)
	end
end
function _elseif:serialize(consume)
	consume'elseif'
	consume(self.cond)
	consume'then'
	spacesep(self, consume)
end

-- aux for _if
local _else = nodeclass('else', _stmt)
function _else:init(...)
	for i=1,select('#', ...) do
		self[i] = select(i, ...)
	end
end
function _else:serialize(consume)
	consume'else'
	spacesep(self, consume)
end

local _foreq = nodeclass('foreq', _stmt)
-- step is optional
-- TODO just make self[1..4] into the var, min, max, step ...
-- ... this means we can possibly have a nil child mid-sequence ...
-- .. hmm ...
-- ... which is better:
-- *) requiring table.max for integer iteration instead of ipairs
-- *) or using fields instead of integer indexes?
function _foreq:init(var,min,max,step,...)
	self.var = var
	self.min = min
	self.max = max
	self.step = step
	for i=1,select('#', ...) do
		self[i] = select(i, ...)
	end
end
function _foreq:serialize(consume)
	consume'for'
	consume(self.var)
	consume'='
	consume(self.min)
	consume','
	consume(self.max)
	if self.step then
		consume','
		consume(self.step)
	end
	consume'do'
	spacesep(self, consume)
	consume'end'
end

-- TODO 'vars' should be a node itself
local _forin = nodeclass('forin', _stmt)
function _forin:init(vars, iterexprs, ...)
	self.vars = vars
	self.iterexprs = iterexprs
	for i=1,select('#', ...) do
		self[i] = select(i, ...)
	end
end
function _forin:serialize(consume)
	consume'for'
	commasep(self.vars, consume)
	consume'in'
	commasep(self.iterexprs, consume)
	consume'do'
	spacesep(self, consume)
	consume'end'
end

local _function = nodeclass('function', _stmt)
-- name is optional
-- TODO make 'args' a node
function _function:init(name, args, ...)
	-- prep args...
	for i=1,#args do
		args[i].index = i
		args[i].param = true
	end
	self.name = name
	self.args = args
	for i=1,select('#', ...) do
		self[i] = select(i, ...)
	end
end
function _function:serialize(consume)
	consume'function'
	if self.name then
		consume(self.name)
	end
	consume'('
	commasep(self.args, consume)
	consume')'
	spacesep(self, consume)
	consume'end'
end

-- aux for _function
-- not used by parser - externally used only - I should get rid of it
local _arg = nodeclass'arg'
-- TODO just self[1] ?
function _arg:init(index)
	self.index = index
end
-- params need to know what function they're in
-- so they can reference the function's arg names
function _arg:serialize(consume)
	consume('arg'..self.index)
end

-- _local can be an assignment of multi vars to muli exprs
--  or can optionally be a declaration of multi vars with no statements
-- so it will take the form of assignments
-- but it can also be a single function declaration with no equals symbol ...
-- the parser has to accept functions and variables as separate conditions
--  I'm tempted to make them separate symbols here too ...
-- exprs is a table containing: 1) a single function 2) a single assign statement 3) a list of variables
local _local = nodeclass('local', _stmt)
-- TODO just self[1] instead of self.exprs[i]
function _local:init(exprs)
	if ast._function:isa(exprs[1]) or ast._assign:isa(exprs[1]) then
		assert(#exprs == 1, "local functions or local assignments must be the only child")
	end
	self.exprs = table(assert(exprs))
end
function _local:serialize(consume)
	if ast._function:isa(self.exprs[1]) or ast._assign:isa(self.exprs[1]) then
		consume'local'
		consume(self.exprs[1])
	else
		consume'local'
		commasep(self.exprs, consume)
	end
end

-- control

local _return = nodeclass('return', _stmt)
-- TODO either 'exprs' a node of its own, or flatten it into 'return'
function _return:init(...)
	self.exprs = {...}
end
function _return:serialize(consume)
	consume'return'
	commasep(self.exprs, consume)
end

local _break = nodeclass('break', _stmt)
function _break:serialize(consume) consume'break' end

local _call = nodeclass'call'
-- TODO 'args' a node of its own ?  or store it in self[i] ?
function _call:init(func, ...)
	self.func = func
	self.args = {...}
end
function _call:serialize(consume)
	if #self.args == 1
	and (ast._table:isa(self.args[1])
		or ast._string:isa(self.args[1])
	) then
		consume(self.func)
		consume(self.args[1])
	else
		consume(self.func)
		consume'('
		commasep(self.args, consume)
		consume')'
	end
end

local _nil = nodeclass'nil'
_nil.const = true
function _nil:serialize(consume) consume'nil' end

local _boolean = nodeclass'boolean'

local _true = nodeclass('true', _boolean)
_true.const = true
_true.value = true
function _true:serialize(consume) consume'true' end

local _false = nodeclass('false', _boolean)
_false.const = true
_false.value = false
function _false:serialize(consume) consume'false' end

local _number = nodeclass'number'
-- TODO just self[1] instead of self.value ?
-- but this breaks convention with _boolean having .value as its static member value.
-- I could circumvent this with _boolean subclass [1] holding the value ...
function _number:init(value) self.value = value end
function _number:serialize(consume) consume(tostring(self.value)) end

local _string = nodeclass'string'
-- TODO just self[1] instead of self.value
function _string:init(value) self.value = value end
function _string:serialize(consume)
	-- use ext.tolua's string serializer
	consume(tolua(self.value))
end

local _vararg = nodeclass'vararg'
function _vararg:serialize(consume) consume'...' end

-- TODO 'args' a node, or flatten into self[i] ?
local _table = nodeclass'table'	-- single-element assigns
function _table:init(...)
	for i=1,select('#', ...) do
		self[i] = select(i, ...)
	end
end
function _table:serialize(consume)
	consume'{'
	for i,arg in ipairs(self) do
		-- if it's an assign then wrap the vars[1] with []'s
		if ast._assign:isa(arg) then
			assert.len(arg.vars, 1)
			assert.len(arg.exprs, 1)
			-- TODO if it's a string and name and not a keyword then use our shorthand
			-- but for this , I should put the Lua keywords in somewhere that both the AST and Tokenizer can see them
			-- and the Tokenizer builds separate lists depending on the version (so I guess a table per version?)
			if ast.keyIsName(arg.vars[1], self.parser) then
				consume(arg.vars[1].value)
			else
				consume'['
				consume(arg.vars[1])
				consume']'
			end
			consume'='
			consume(arg.exprs[1])
		else
			consume(arg)
		end
		if i < #self then
			consume','
		end
	end
	consume'}'
end

-- OK here is the classic example of the benefits of fields over integers:
-- extensibility.
-- attrib was added later
-- as we add/remove fields, that means reordering indexes, and that means a break in compat
-- one workaround to merging the two is just named functions and integer-indexed children
-- another is a per-child traversal routine (like :serialize())
local _var = nodeclass'var'	-- variable, lhs of ast._assign's
function _var:init(name, attrib)
	self.name = name
	self.attrib = attrib
end
function _var:serialize(consume)
	consume(self.name)
	if self.attrib then
		-- the extra space is needed for assignments, otherwise lua5.4 `local x<const>=1` chokes while `local x<const> =1` works
		consume'<'
		consume(self.attrib)
		consume'>'
	end
end

local _par = nodeclass'par'
ast._par = _par
ast._parenthesis = nil
function _par:init(expr)
	self.expr = expr
end
function _par:serialize(consume)
	consume'('
	consume(self.expr)
	consume')'
end

local _index = nodeclass'index'
function _index:init(expr,key)
	self.expr = expr
	-- helper add wrappers to some types:
	-- TODO or not?
	if type(key) == 'string' then
		key = ast._string(key)
	elseif type(key) == 'number' then
		key = ast._number(key)
	end
	self.key = key
end
function _index:serialize(consume)
	if ast.keyIsName(self.key, self.parser) then
		-- the use a .$key instead of [$key]
		consume(self.expr)
		consume'.'
		consume(self.key.value)
	else
		consume(self.expr)
		consume'['
		consume(self.key)
		consume']'
	end
end

-- this isn't the () call itself, this is just the : dereference
-- a:b(c) is _call(_indexself(_var'a', _var'b'), _var'c')
-- technically this is a string lookup, however it is only valid as a lua name, so I'm just passing the Lua string itself
local _indexself = nodeclass'indexself'
function _indexself:init(expr,key)
	self.expr = assert(expr)
	assert(isLuaName(key))
	-- TODO compat with _index?  always wrap?  do this before passing in key?
	--key = ast._string(key)
	self.key = assert(key)
end
function _indexself:serialize(consume)
	consume(self.expr)
	consume':'
	consume(self.key)
end

local _op = nodeclass'op'
-- TODO 'args' a node ... or just flatten it into this node ...
function _op:init(...)
	for i=1,select('#', ...) do
		self[i] = select(i, ...)
	end
end
function _op:serialize(consume)
	for i,x in ipairs(self) do
		consume(x)
		if i < #self then consume(self.op) end
	end
end

for _,info in ipairs{
	{'add','+'},
	{'sub','-'},
	{'mul','*'},
	{'div','/'},
	{'pow','^'},
	{'mod','%'},
	{'concat','..'},
	{'lt','<'},
	{'le','<='},
	{'gt','>'},
	{'ge','>='},
	{'eq','=='},
	{'ne','~='},
	{'and','and'},
	{'or','or'},
	{'idiv', '//'},	-- 5.3+
	{'band', '&'},	-- 5.3+
	{'bxor', '~'},	-- 5.3+
	{'bor', '|'},	-- 5.3+
	{'shl', '<<'},	-- 5.3+
	{'shr', '>>'},	-- 5.3+
} do
	local op = info[2]
	local cl = nodeclass(info[1], _op)
	cl.op = op
end

for _,info in ipairs{
	{'unm','-'},
	{'not','not'},
	{'len','#'},
	{'bnot','~'},		-- 5.3+
} do
	local op = info[2]
	local cl = nodeclass(info[1], _op)
	cl.op = op
	function cl:init(...)
		for i=1,select('#', ...) do
			self[i] = select(i, ...)
		end
	end
	function cl:serialize(consume)
		consume(self.op)
		consume(self[1])	-- spaces required for 'not'
	end
end

local _goto = nodeclass('goto', _stmt)
function _goto:init(name)
	self.name = name
end
function _goto:serialize(consume)
	consume'goto'
	consume(self.name)
end

local _label = nodeclass('label', _stmt)
function _label:init(name)
	self.name = name
end
function _label:serialize(consume)
	consume'::'
	consume(self.name)
	consume'::'
end

return ast

end)
__bundle_register("lib.lua-parser.base.ast", function(require, _LOADED, __bundle_register, __bundle_modules)
local table = require("ext.table")
local string = require("ext.string")
local class = require("ext.class")

local BaseAST = class()

-- this is too relaxed, since concat maps to tostring maps to toLua, and I want toLua only called from external, and toLua_recursive from internal
--BaseAST.__concat = string.concat

function BaseAST:setspan(span)
	self.span = span
	return self
end

-- returns ancestors as a table, including self
function BaseAST:ancestors()
	local n = self
	local t = table()
	repeat
		t:insert(n)
		n = n.parent
	until not n
	return t
end

-- TODO move traverse flatten etc here once the fields problem is sorted out

return BaseAST

end)
__bundle_register("lib.lua-ext.assert", function(require, _LOADED, __bundle_register, __bundle_modules)
--[[
the original assert() asserts that the first arg is true, and returns all args, therefore we can assert that the first returned value will also always coerce to true
1) should asserts always return a true value?
2) or should asserts always return the forwarded value?
I'm voting for #2 so assert can be used for wrapping args and not changing behvaior.  when would you need to assert the first arg is true afer the assert has already bene carried out anyways? 
... except for certain specified operations that cannot return their first argument, like assertindex()
--]]

-- cheap 'tolua'
local function tostr(x)
	if type(x) == 'string' then return ('%q'):format(x) end
	return tostring(x)
end

local function prependmsg(msg, str)
	return (msg and (tostring(msg)..': ') or '')..str
end

local function asserttype(x, t, msg, ...)
	local xt = type(x)
	if xt ~= t then
		error(prependmsg(msg, "expected "..tostring(t).." found "..tostring(xt)))
	end
	return x, t, msg, ...
end

local function assertis(obj, cl, msg, ...)
	if not cl.isa then
		error(prependmsg(msg, "assertis expected 2nd arg to be a class"))
	end
	if not cl:isa(obj) then
		error(prependmsg(msg, "object "..tostring(obj).." is not of class "..tostring(class)))
	end
	return obj, cl, msg, ...
end

-- how to specify varargs...
-- for now: (msg, N, type1, ..., typeN, arg1, ..., argN)
local function asserttypes(msg, n, ...)
	asserttype(n, 'number', prependmsg(msg, "asserttypes number of args"))
	for i=1,n do
		asserttype(select(n+i, ...), select(i, ...), prependmsg(msg, "asserttypes arg "..i))
	end
	return select(n+1, ...)
end

local function asserteq(a, b, msg, ...)
	if not (a == b) then
		error(prependmsg(msg, "got "..tostr(a).." == "..tostr(b)))
	end
	return a, b, msg, ...
end

local function asserteqeps(a, b, eps, msg, ...)
	eps = eps or 1e-7
	if math.abs(a - b) > eps then
		error((msg and msg..': ' or '').."expected |"..a.." - "..b.."| < "..eps)
	end
	return a, b, eps, msg, ...
end

local function assertne(a, b, msg, ...)
	if not (a ~= b) then
		error(prependmsg(msg, "got "..tostr(a).." ~= "..tostr(b)))
	end
	return a, b, msg, ...
end

local function assertlt(a, b, msg, ...)
	if not (a < b) then
		error(prependmsg(msg, "got "..tostr(a).." < "..tostr(b)))
	end
	return a, b, msg, ...
end

local function assertle(a, b, msg, ...)
	if not (a <= b) then
		error(prependmsg(msg, "got "..tostr(a).." <= "..tostr(b)))
	end
	return a, b, msg, ...
end

local function assertgt(a, b, msg, ...)
	if not (a > b) then
		error(prependmsg(msg, "got "..tostr(a).." > "..tostr(b)))
	end
	return a, b, msg, ...
end

local function assertge(a, b, msg, ...)
	if not (a >= b) then
		error(prependmsg(msg, "got "..tostr(a).." >= "..tostr(b)))
	end
	return a, b, msg, ...
end

-- this is a t[k] operation + assert
local function assertindex(t, k, msg, ...)
	if not t then
		error(prependmsg(msg, "object is nil"))
	end
	local v = t[k]
	assert(v, prependmsg(msg, "expected "..tostr(t).."["..tostr(k).." ]"))
	return v, msg, ...
end

-- assert integer indexes 1 to len, and len of tables matches
-- maybe I'll use ipairs... maybe
local function asserttableieq(t1, t2, msg, ...)
	asserteq(#t1, #t2, msg)
	for i=1,#t1 do
		asserteq(t1[i], t2[i], msg)
	end
	return t1, t2, msg, ...
end

-- for when you want to assert a table's length but still want to return the table
-- TODO should this be like assertindex() where it performs the operation and returns the operator value, i.e. returns the length instead of the table?
-- or would that be less usable than asserting the length and returning the table?
local function assertlen(t, n, msg, ...)
	asserteq(#t, n, msg)
	return t, n, msg, ...
end

local function asserterror(f, msg, ...)
	asserteq(pcall(f, ...), false, msg)
	return f, msg, ...
end

local origassert = _G.assert
return setmetatable({
	type = asserttype,
	types = asserttypes,
	is = assertis,
	eq = asserteq,
	ne = assertne,
	lt = assertlt,
	le = assertle,
	gt = assertgt,
	ge = assertge,
	index = assertindex,
	eqeps = asserteqeps,
	tableieq = asserttableieq,
	len = assertlen,
	error = asserterror,
}, {
	-- default `assert = require 'ext.assert'` works, as well as `assertle = assert.le`
	__call = function(t, ...)
		return origassert(...)
	end,
})

end)
__bundle_register("lib.lua-ext.tolua", function(require, _LOADED, __bundle_register, __bundle_modules)
--[[
how to handle recursion ...
a={}
b={}
a.b=b
b.a=a

tolua(a) would give ...
{b={a=error('recursive reference')}}

but how about, if something is found that is marked in touched tables ...
1) wrap everything in a function block
2) give root a local
3) add assignments of self-references after-the-fact

(function()
	local _tmp={b={}}
	_tmp.b.a= _tmp
	return _tmp
end)()
--]]

local table = require("ext.table")

local function builtinPairs(t)
	return next,t,nil
end

local _0byte = ('0'):byte()
local _9byte = ('9'):byte()
local function escapeString(s)
	--[[ multiline strings
	-- it seems certain chars can't be encoded in Lua multiline strings
	-- TODO find out exactly which ones
	-- TODO if 's' begins with [ or ends with ] then you're gonna have a bad time ...
	-- in fact ... does Lua support multiline strings that begin with [ or end with ] ?  especially the latter ...
	local foundNewline
	local foundBadChar
	for i=1,#s do
		local b = s:byte(i)
		if b == 10
		-- TODO still lua loading will convert \r \n's into \n's ... so this is still not guaranteed to reproduce the original ...
		-- I could disable multi line strs when encoding \r's ...
		-- but this gets to be a bit os-specific ...
		-- a better solution would be changing fromlua() to properly handle newline formatting within multiline strings ...
		--or b == 13
		then
			foundNewline = true
		elseif b < 32 or b > 126 then
			foundBadChar = true
			break	-- don't need to keep looking
		end
	end
	if foundNewline and not foundBadChar then
		for neq=0,math.huge do
			local eq = ('='):rep(neq)
			local open = '['..eq..'['
			local close = ']'..eq..']'
			if not s:find(open, 1, true)
			and not s:find(close, 1, true)
			and s:sub(-neq-1) ~= close:sub(1,neq+1) -- if the very end of the string is close without the last ] then it could still do a false match ...
			then
				-- open and close aren't in the string, we can use this to escape the string
				-- ... ig all I have to search for is close, but meh
				local ret = open .. '\n' 	-- \n cuz lua ignores trailing spaces/newline after the opening
					.. s .. close
--DEBUG: require 'ext.assert'.eq(load('return '..ret)(), s)
				return ret
			end
		end
	end
	--]]

	-- [[
	-- this will only escape escape codes
	-- will respect unicode
	-- but it skips \r \t and encodes them as \13 \9
	local o = ('%q'):format(s)
	o = o:gsub('\\\n','\\n')
	return o
	--]]
	--[==[ this gets those that builtin misses
	-- but does it in lua so it'll be slow
	-- and requires implementations of iscntrl and isdigit
	--
	-- it's slow and has bugs.
	--
	-- TODO
	-- for size-minimal strings:
	-- if min(# single-quotes, # double-quotes) within the string > 2 then use [[ ]] (so long as that isn't used either)
	-- otherwise use as quotes whatever the min is
	-- or ... use " to wrap if less than 1 " is embedded
	-- then use ' to wrap if less than 1 ' is embedded
	-- then use [[ ]] to wrap if no [[ ]] is embedded
	-- ... etc for [=...=[ all string escape options
	local o = '"'
	for i=1,#s do
		local c = s:sub(i,i)
		if c == '"' then
			o = o .. '\\"'
		elseif c == '\\' then
			o = o .. '\\\\'
		elseif c == '\n' then
			o = o .. '\\n'
		elseif c == '\r' then
			o = o .. '\\r'
		elseif c == '\t' then
			o = o .. '\\t'
		elseif c == '\a' then
			o = o .. '\\a'
		elseif c == '\b' then
			o = o .. '\\b'
		elseif c == '\f' then
			o = o .. '\\f'
		elseif c == '\v' then
			o = o .. '\\v'
		else
			local b = c:byte()
			assert(b < 256)
			if b < 0x20 or b == 0x7f then	-- if iscntrl(c)
-- make sure the next character isn't a digit because that will mess up the encoded escape code
				local b2 = c:byte(i+1)
				if not (b2 and b2 >= _0byte and b2 <= _9byte) then	-- if not isdigit(c2) then
					o = o .. ('\\%d'):format(b)
				else
					o = o .. ('\\%03d'):format(b)
				end
			else
				-- TODO for extended ascii, why am I seeing different things here vs encoding one character at a time?
				o = o .. c
			end
		end
	end
	o = o .. '"'
	o:gsub('\\(%d%d%d)', function(d)
		if tonumber(d) > 255 then
			print('#s', #s)
			print'o'
			print(o)
			print's'
			print(s)
			error("got an oob escape code: "..d)
		end
	end)
	local f = require 'ext.fromlua'(o)
	if f ~= s then
		print('#s', #s)
		print('#f', #f)
		print'o'
		print(o)
		print's'
		print(s)
		print'f'
		print(f)
		print("failed to reencode as the same string")
		for i=1,math.min(#s,#f) do
			if f:sub(i,i) ~= s:sub(i,i) then
				print('char '..i..' differs')
				break
			end
		end
		error("here")

	end
	return o
	--]==]
end

-- as of 5.4.  I could modify this based on the Lua version (like removing 'goto') but misfiring just means wrapping in quotes, so meh.
local reserved = {
	["and"] = true,
	["break"] = true,
	["do"] = true,
	["else"] = true,
	["elseif"] = true,
	["end"] = true,
	["false"] = true,
	["for"] = true,
	["function"] = true,
	["goto"] = true,
	["if"] = true,
	["in"] = true,
	["local"] = true,
	["nil"] = true,
	["not"] = true,
	["or"] = true,
	["repeat"] = true,
	["return"] = true,
	["then"] = true,
	["true"] = true,
	["until"] = true,
	["while"] = true,
}

-- returns 'true' if k is a valid variable name, but not a reserved keyword
local function isVarName(k)
	return type(k) == 'string' and k:match('^[_a-zA-Z][_a-zA-Z0-9]*$') and not reserved[k]
end

local toLuaRecurse

local function toLuaKey(state, k, path)
	if isVarName(k) then
		return k, true
	else
		local result = toLuaRecurse(state, k, nil, path, true)
		if result then
			return '['..result..']', false
		else
			return false, false
		end
	end
end


-- another copy of maxn, with custom pairs
local function maxn(t, state)
	local max = 0
	local count = 0
	for k,v in state.pairs(t) do
		count = count + 1
		if type(k) == 'number' then
			max = math.max(max, k)
		end
	end
	return max, count
end


local defaultSerializeForType = {
	number = function(state,x)
		if x == math.huge then return 'math.huge' end
		if x == -math.huge then return '-math.huge' end
		if x ~= x then return '0/0' end
		return tostring(x)
	end,
	boolean = function(state,x) return tostring(x) end,
	['nil'] = function(state,x) return tostring(x) end,
	string = function(state,x) return escapeString(x) end,
	['function'] = function(state, x)
		local result, s = pcall(string.dump, x)

		if result then
			s = 'load('..escapeString(s)..')'
		else
			-- if string.dump failed then check the builtins
			-- check the global object and one table deep
			-- todo maybe, check against a predefined set of functions?
			if s == "unable to dump given function" then
				local found
				for k,v in state.pairs(_G) do
					if v == x then
						found = true
						s = k
						break
					elseif type(v) == 'table' then
						-- only one level deep ...
						for k2,v2 in state.pairs(v) do
							if v2 == x then
								s = k..'.'..k2
								found = true
								break
							end
						end
						if found then break end
					end
				end
				if not found then
					s = "error('"..s.."')"
				end
			else
				return "error('got a function I could neither dump nor lookup in the global namespace nor one level deep')"
			end
		end

		return s
	end,
	table = function(state, x, tab, path, keyRef)
		local result

		local newtab = tab .. state.indentChar
		-- TODO override for specific metatables?  as I'm doing for types?

		if state.touchedTables[x] then
			if state.skipRecursiveReferences then
				result = 'error("recursive reference")'
			else
				result = false	-- false is used internally and means recursive reference
				state.wrapWithFunction = true

				-- we're serializing *something*
				-- is it a value?  if so, use the 'path' to dereference the key
				-- is it a key?  if so the what's the value ..
				-- do we have to add an entry for both?
				-- maybe the caller should be responsible for populating this table ...
				if keyRef then
					state.recursiveReferences:insert('root'..path..'['..state.touchedTables[x]..'] = error("can\'t handle recursive references in keys")')
				else
					state.recursiveReferences:insert('root'..path..' = '..state.touchedTables[x])
				end
			end
		else
			state.touchedTables[x] = 'root'..path

			-- prelim see if we can write it as an indexed table
			local numx, count = maxn(x, state)
			local intNilKeys, intNonNilKeys
			-- only count if our max isn't too high
			if numx < 2 * count then
				intNilKeys, intNonNilKeys = 0, 0
				for i=1,numx do
					if x[i] == nil then
						intNilKeys = intNilKeys + 1
					else
						intNonNilKeys = intNonNilKeys + 1
					end
				end
			end

			local hasSubTable

			local s = table()

			-- add integer keys without keys explicitly. nil-padded so long as there are 2x values than nils
			local addedIntKeys = {}
			if intNonNilKeys
			and intNilKeys
			and intNonNilKeys >= intNilKeys * 2
			then	-- some metric for when to create in-order tables
				for k=1,numx do
					if type(x[k]) == 'table' then hasSubTable = true end
					local nextResult = toLuaRecurse(state, x[k], newtab, path and path..'['..k..']')
					if nextResult then
						s:insert(nextResult)
					-- else x[k] is a recursive reference
					end
					addedIntKeys[k] = true
				end
			end

			-- sort key/value pairs added here by key
			local mixed = table()
			for k,v in state.pairs(x) do
				if not addedIntKeys[k] then
					if type(v) == 'table' then hasSubTable = true end
					local keyStr, usesDot = toLuaKey(state, k, path)
					if keyStr then
						local newpath
						if path then
							newpath = path
							if usesDot then newpath = newpath .. '.' end
							newpath = newpath .. keyStr
						end
						local nextResult = toLuaRecurse(state, v, newtab, newpath)
						if nextResult then
							mixed:insert{keyStr, nextResult}
						-- else x[k] is a recursive reference
						end
					end
				end
			end
			mixed:sort(function(a,b) return a[1] < b[1] end)	-- sort by keys
			mixed = mixed:map(function(kv) return table.concat(kv, '=') end)
			s:append(mixed)

			local thisNewLineChar, thisNewLineSepChar, thisTab, thisNewTab
			if not hasSubTable and not state.alwaysIndent then
				thisNewLineChar = ''
				thisNewLineSepChar = ' '
				thisTab = ''
				thisNewTab = ''
			else
				thisNewLineChar = state.newlineChar
				thisNewLineSepChar = state.newlineChar
				thisTab = tab
				thisNewTab = newtab
			end

			local rs = '{'..thisNewLineChar
			if #s > 0 then
				rs = rs .. thisNewTab .. s:concat(','..thisNewLineSepChar..thisNewTab) .. thisNewLineChar
			end
			rs = rs .. thisTab .. '}'

			result = rs
		end
		return result
	end,
}

local function defaultSerializeMetatableFunc(state, m, x, tab, path, keyRef)
	-- only serialize the metatables of tables
	-- otherwise, assume the current metatable is the default one (which is usually nil)
	if type(x) ~= 'table' then return 'nil' end
	return toLuaRecurse(state, m, tab..state.indentChar, path, keyRef)
end

toLuaRecurse = function(state, x, tab, path, keyRef)
	if not tab then tab = '' end

	local xtype = type(x)
	local serializeFunction
	if state.serializeForType then
		serializeFunction = state.serializeForType[xtype]
	end
	if not serializeFunction then
		serializeFunction = defaultSerializeForType[xtype]
	end

	local result
	if serializeFunction then
		result = serializeFunction(state, x, tab, path, keyRef)
	else
		result = '['..type(x)..':'..tostring(x)..']'
	end
	assert(result ~= nil)

	if state.serializeMetatables then
		local m = getmetatable(x)
		if m ~= nil then
			local serializeMetatableFunc = state.serializeMetatableFunc or defaultSerializeMetatableFunc
			local mstr = serializeMetatableFunc(state, m, x, tab, path, keyRef)
			-- make sure you get something
			assert(mstr ~= nil)
			-- but if that something is nil, i.e. setmetatable(something newly created with a nil metatable, nil), then don't bother modifing the code
			if mstr ~= 'nil' and mstr ~= false then
				-- if this is false then the result was deferred and we need to add this line to wherever else...
				assert(result ~= false)
				result = 'setmetatable('..result..', '..mstr..')'
			end
		end
	end

	return result
end

--[[
args:
	indent = default to 'true', set to 'false' to make results concise, true will skip inner-most tables. set to 'always' for always indenting.
	pairs = default to a form of pairs() which iterates over all fields using next().  Set this to your own custom pairs function, or 'pairs' if you would like serialization to respect the __pairs metatable (which it does not by default).
	serializeForType = a table with keys of lua types and values of callbacks for serializing those types
	serializeMetatables = set to 'true' to include serialization of metatables
	serializeMetatableFunc = function to override the default serialization of metatables
	skipRecursiveReferences = default to 'false', set this to 'true' to not include serialization of recursive references
--]]
local function tolua(x, args)
	local state = {
		indentChar = '',
		newlineChar = '',
		wrapWithFunction = false,
		recursiveReferences = table(),
		touchedTables = {},
	}
	local indent = true
	if args then
		-- indent == ... false => none, true => some, "always" => always
		if args.indent == false then indent = false end
		if args.indent == 'always' then state.alwaysIndent = true end
		state.serializeForType = args.serializeForType
		state.serializeMetatables = args.serializeMetatables
		state.serializeMetatableFunc = args.serializeMetatableFunc
		state.skipRecursiveReferences = args.skipRecursiveReferences
	end
	if indent then
		state.indentChar = '\t'
		state.newlineChar = '\n'
	end
	state.pairs = builtinPairs

	local str = toLuaRecurse(state, x, nil, '')

	if state.wrapWithFunction then
		str = '(function()' .. state.newlineChar
			.. state.indentChar .. 'local root = '..str .. ' ' .. state.newlineChar
			-- TODO defer self-references to here
			.. state.recursiveReferences:concat(' '..state.newlineChar..state.indentChar) .. ' ' .. state.newlineChar
			.. state.indentChar .. 'return root ' .. state.newlineChar
			.. 'end)()'
	end

	return str
end

return setmetatable({}, {
	__call = function(self, x, args)
		return tolua(x, args)
	end,
	__index = {
		-- escaping a Lua string for load() to use
		escapeString = escapeString,
		-- returns 'true' if the key passed is a valid Lua variable string, 'false' otherwise
		isVarName = isVarName,
		-- table of default serialization functions indexed by each time
		defaultSerializeForType = defaultSerializeForType,
		-- default metatable serialization function
		defaultSerializeMetatableFunc = defaultSerializeMetatableFunc,
	}
})

end)
__bundle_register("lib.lua-ext.string", function(require, _LOADED, __bundle_register, __bundle_modules)
--[[
notice that,
while this does override the 'string' and add some extra stuff,
it does not explicitly replace the default string metatable __index
to do that, require 'ext.meta' (or do it yourself)
--]]
local string = {}
for k,v in pairs(require("string")) do string[k] = v end

local table = require("ext.table")

-- table.concat(string.split(a,b),b) == a
function string.split(s, exp)
	exp = exp or ''
	s = tostring(s)
	local t = table()
	-- handle the exp='' case
	if exp == '' then
		for i=1,#s do
			t:insert(s:sub(i,i))
		end
	else
		local searchpos = 1
		local start, fin = s:find(exp, searchpos)
		while start do
			t:insert(s:sub(searchpos, start-1))
			searchpos = fin+1
			start, fin = s:find(exp, searchpos)
		end
		t:insert(s:sub(searchpos))
	end
	return t
end

function string.trim(s)
	return s:match('^%s*(.-)%s*$')
end

-- should this wrap in a table?
function string.bytes(s)
	return table{s:byte(1,#s)}
end

string.load = load or loadstring

--[[
-- drifting further from standards...
-- this string-converts everything concat'd (no more errors, no more print(a,b,c)'s)
getmetatable('').__concat = function(a,b)
	return tostring(a)..tostring(b)
end
--]]

-- a C++-ized accessor to subsets
-- indexes are zero-based inclusive
-- sizes are zero-based-exclusive (or one-based-inclusive depending on how you think about it)
-- parameters are (index, size) rather than (start index, end index)
function string.csub(d, start, size)
	if not size then return string.sub(d, start + 1) end	-- til-the-end
	return string.sub(d, start + 1, start + size)
end

--d = string data
--l = length of a column.  default 32
--w = hex word size.  default 1
--c = extra column space.  default 8
function string.hexdump(d, l, w, c)
	d = tostring(d)
	l = tonumber(l)
	w = tonumber(w)
	c = tonumber(c)
	if not l or l < 1 then l = 32 end
	if not w or w < 1 then w = 1 end
	if not c or c < 1 then c = 8 end
	local s = table()
	local rhs = table()
	local col = 0
	for i=1,#d,w do
		if i % l == 1 then
			s:insert(string.format('%.8x ', (i-1)))
			rhs = table()
			col = 1
		end
		s:insert' '
		for j=w,1,-1 do
			local e = i+j-1
			local sub = d:sub(e,e)
			if #sub > 0 then
				local b = string.byte(sub)
				s:insert(string.format('%.2x', b))
				rhs:insert(b >= 32 and sub or '.')
			end
		end
		if col % c == 0 then
			s:insert' '
		end
		if (i + w - 1) % l == 0 or i+w>#d then
			s:insert' '
			s:insert(rhs:concat())
		end
		if (i + w - 1) % l == 0 then
			s:insert'\n'
		end
		col = col + 1
	end
	return s:concat()
end

-- escape for pattern matching
local escapeFind = '[' .. ([[^$()%.[]*+-?]]):gsub('.', '%%%1') .. ']'
function string.patescape(s)
	return (s:gsub(escapeFind, '%%%1'))
end

-- this is a common function, especially as a __concat metamethod
-- it is nearly table.concat, except table.concat errors upon non-string/number instead of calling tostring() automatically
-- (should I change table.concat's default behavior and use that instead?  nah, because why require a table creation.)
-- tempted to make this ext.op.concat ... but that's specifically a binary op ... and that shouldn't call tostring() while this should ...
-- maybe I should move this to ext.op as 'tostringconcat' or something?
function string.concat(...)
	local n = select('#', ...)
	if n == 0 then return end	-- base-case nil or "" ?
	local s = tostring((...))
	if n == 1 then return s end
	return s .. string.concat(select(2, ...))
end

-- another common __tostring metamethod
-- since luajit doesn't support __name metafield
function string:nametostring()
	-- NOTICE this will break for anything that overrides its __metatable metafield
	local mt = getmetatable(self)

	-- invoke a 'rawtostring' call / get the builtin 'tostring' result
	setmetatable(self, nil)
	local s = tostring(self)
	setmetatable(self, mt)

	local name = mt.__name
	return name and tostring(name)..s:sub(6) or s
end

return string

end)
__bundle_register("lib.lua-ext.class", function(require, _LOADED, __bundle_register, __bundle_modules)
local table = require("ext.table")

-- classes

local function newmember(class, ...)
	local obj = setmetatable({}, class)
	if obj.init then return obj, obj:init(...) end
	return obj
end

local classmeta = {
	__call = function(self, ...)
-- [[ normally:
		return self:new(...)
--]]
--[[ if you want to keep track of all instances
		local results = table.pack(self:new(...))
		local obj = results[1]
		self.instances[obj] = true
		return results:unpack()
--]]
	end,
}

-- usage: class:isa(obj)
--  so it's not really a member method, since the object doesn't come first, but this way we can use it as Class:isa(obj) and not worry about nils or local closures
local function isa(cl, obj)
	assert(cl, "isa: argument 1 is nil, should be the class object")	-- isa(nil, anything) errors, because it should always have a class in the 1st arg
	if type(obj) ~= 'table' then return false end	-- class:isa(not a table) will return false
	if not obj.isaSet then return false end	-- not an object generated by class(), so it doesn't have a set of all classes that it "is-a"
	return obj.isaSet[cl] or false	-- returns true if the 'isaSet' of the object's metatable (its class) holds the calling class
end

local function class(...)
	local cl = table(...)
	cl.class = cl

	cl.super = ...	-- .super only stores the first.  the rest can be accessed by iterating .isaSet's keys

	-- I was thinking of calling this '.superSet', but it is used for 'isa' which is true for its own class, so this is 'isaSet'
	cl.isaSet = {[cl] = true}
	for i=1,select('#', ...) do
		local parent = select(i, ...)
		if parent ~= nil then
			cl.isaSet[parent] = true
			if parent.isaSet then
				for grandparent,_ in pairs(parent.isaSet) do
					cl.isaSet[grandparent] = true
				end
			end
		end
	end

	-- store 'descendantSet' as well that gets appended when we call class() on this obj?
	for ancestor,_ in pairs(cl.isaSet) do
		ancestor.descendantSet = ancestor.descendantSet or {}
		ancestor.descendantSet[cl] = true
	end

	cl.__index = cl
	cl.new = newmember
	cl.isa = isa	-- usage: Class:isa(obj)
	cl.subclass = class     -- such that cl:subclass() or cl:subclass{...} will return a subclass of 'cl'

--[[ if you want to keep track of all instances
	cl.instances = setmetatable({}, {__mode = 'k'})
--]]

	setmetatable(cl, classmeta)
	return cl
end

return class

end)
__bundle_register("lib.lua-ext.table", function(require, _LOADED, __bundle_register, __bundle_modules)
local table = {}
for k,v in pairs(require("table")) do table[k] = v end

table.__index = table

function table.new(...)
	return setmetatable({}, table):union(...)
end

setmetatable(table, {
	__call = function(t, ...)
		return table.new(...)
	end
})

-- 5.2 or 5.3 compatible
table.unpack = table.unpack or unpack

-- [[ how about table.unpack(t) defaults to table.unpack(t, 1, t.n) if t.n is present?
-- for cohesion with table.pack?
-- already table.unpack's default is #t, but this doesn't account for nils
-- this might break compatability somewhere ...
local origTableUnpack = table.unpack
function table.unpack(...)
	local nargs = select('#', ...)
	local t, i, j = ...
	if nargs < 3 and t.n ~= nil then
		return origTableUnpack(t, i or 1, t.n)
	end
	return origTableUnpack(...)
end
--]]

-- 5.1 compatible
if not table.pack then
	function table.pack(...)
		local t = {...}
		t.n = select('#', ...)
		return setmetatable(t, table)
	end
else
	local oldpack = table.pack
	function table.pack(...)
		return setmetatable(oldpack(...), table)
	end
end

-- non-5.1 compat:
if not table.maxn then
	function table.maxn(t)
		local max = 0
		for k,v in pairs(t) do
			if type(k) == 'number' then
				max = math.max(max, k)
			end
		end
		return max
	end
end

-- applies to the 'self' table
-- same behavior as new
function table:union(...)
	for i=1,select('#', ...) do
		local o = select(i, ...)
		if o then
			for k,v in pairs(o) do
				self[k] = v
			end
		end
	end
	return self
end

-- something to consider:
-- mapvalue() returns a new table
-- but append() modifies the current table
-- for consistency shouldn't append() create a new one as well?
function table:append(...)
	for i=1,select('#', ...) do
		local u = select(i, ...)
		if u then
			for _,v in ipairs(u) do
				table.insert(self, v)
			end
		end
	end
	return self
end

function table:removeKeys(...)
	for i=1,select('#', ...) do
		local v = select(i, ...)
		self[v] = nil
	end
end

-- cb(value, key, newtable) returns newvalue[, newkey]
-- nil newkey means use the old key
function table:map(cb)
	local t = table()
	for k,v in pairs(self) do
		local nv, nk = cb(v,k,t)
		if nk == nil then nk = k end
		t[nk] = nv
	end
	return t
end

-- cb(value, key, newtable) returns newvalue[, newkey]
-- nil newkey means use the old key
function table:mapi(cb)
	local t = table()
	for k=1,#self do
		local v = self[k]
		local nv, nk = cb(v,k,t)
		if nk == nil then nk = k end
		t[nk] = nv
	end
	return t
end

-- this excludes keys that don't pass the callback function
-- if the key is an ineteger then it is table.remove'd
-- currently the handling of integer keys is the only difference between this
-- and calling table.map and returning nil kills on filtered items
function table:filter(f)
	local t = table()
	if type(f) == 'function' then
		for k,v in pairs(self) do
			if f(v,k) then
				-- TODO instead of this at runtime, how about filter vs filteri like map vs mapi
				-- but most the times filter is used it is for integers already
				-- how about filterk?  or probably filteri and change everything
				if type(k) == 'string' then
					t[k] = v
				else
					t:insert(v)
				end
			end
		end
	else
		-- I kind of want to do arrays ... but should we be indexing the keys or values?
		-- or separate functions for each?
		error('table.filter second arg must be a function')
	end
	return t
end

function table:keys()
	local t = table()
	for k,_ in pairs(self) do
		t:insert(k)
	end
	return t
end

function table:values()
	local t = table()
	for _,v in pairs(self) do
		t:insert(v)
	end
	return t
end

-- should we have separate finds for pairs and ipairs?
-- should we also return value, key to match map, sup, and inf?
--   that seems redundant if it's find-by-value ...
function table:find(value, eq)
	if eq then
		for k,v in pairs(self) do
			if eq(v, value) then return k, v end
		end
	else
		for k,v in pairs(self) do
			if v == value then return k, v end
		end
	end
end

-- should insertUnique only operate on the pairs() ?
-- 	especially when insert() itself is an ipairs() operation
function table:insertUnique(value, eq)
	if not table.find(self, value, eq) then table.insert(self, value) end
end

function table:removeObject(...)
	local removedKeys = table()
	local len = #self
	local k = table.find(self, ...)
	while k ~= nil do
		if type(k) == 'number' and tonumber(k) <= len then
			table.remove(self, k)
		else
			self[k] = nil
		end
		removedKeys:insert(k)
		k = table.find(self, ...)
	end
	return table.unpack(removedKeys)
end

function table:kvpairs()
	local t = table()
	for k,v in pairs(self) do
		table.insert(t, {[k]=v})
	end
	return t
end

-- TODO - math instead of table?
-- TODO - have cmp default to operator> just like inf and sort?
function table:sup(cmp)
	local bestk, bestv
	if cmp then
		for k,v in pairs(self) do
			if bestv == nil or cmp(v, bestv) then bestk, bestv = k, v end
		end
	else
		for k,v in pairs(self) do
			if bestv == nil or v > bestv then bestk, bestv = k, v end
		end
	end
	return bestv, bestk
end

-- TODO - math instead of table?
function table:inf(cmp)
	local bestk, bestv
	if cmp then
		for k,v in pairs(self) do
			if bestv == nil or cmp(v, bestv) then bestk, bestv = k, v end
		end
	else
		for k,v in pairs(self) do
			if bestv == nil or v < bestv then bestk, bestv = k, v end
		end
	end
	return bestv, bestk
end

-- combine elements of
function table:combine(callback)
	local s
	for _,v in pairs(self) do
		if s == nil then
			s = v
		else
			s = callback(s, v)
		end
	end
	return s
end

local op = require("ext.op")

function table:sum()
	return table.combine(self, op.add)
end

function table:product()
	return table.combine(self, op.mul)
end

function table:last()
	return self[#self]
end

-- just like string subset
function table.sub(t,i,j)
	if i < 0 then i = math.max(1, #t + i + 1) end
	--if i < 0 then i = math.max(1, #t + i + 1) else i = math.max(1, i) end		-- TODO this is affecting symmath edge cases somewhere ...
	j = j or #t
	j = math.min(j, #t)
	if j < 0 then j = math.min(#t, #t + j + 1) end
	--if j < 0 then j = math.min(#t, #t + j + 1) else j = math.max(1, j) end	-- TODO this is affecting symmath edge cases somewhere ...
	local res = {}
	for k=i,j do
		res[k-i+1] = t[k]
	end
	setmetatable(res, table)
	return res
end

function table.reverse(t)
	local r = table()
	for i=#t,1,-1 do
		r:insert(t[i])
	end
	return r
end

function table.rep(t,n)
	local c = table()
	for i=1,n do
		c:append(t)
	end
	return c
end

-- in-place sort is fine, but it returns nothing.  for kicks I'd like to chain methods
local oldsort = require("table").sort
function table:sort(...)
	oldsort(self, ...)
	return self
end

-- returns a shuffled duplicate of the ipairs in table 't'
function table.shuffle(t)
	t = table(t)
	-- https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
	for i=#t,2,-1 do
		local j = math.random(i-1)
		t[i], t[j] = t[j], t[i]
	end
	return t
end

function table.pickRandom(t)
	return t[math.random(#t)]
end

-- where to put this ...
-- I want to convert iterators into tables
-- it looks like a coroutine but it is made for functions returned from coroutine.wrap
-- also, what to do with multiple-value iterators (like ipairs)
-- do I only wrap the first value?
-- do I wrap both values in a double table?
-- do I do it optionally based on the # args returned?
-- how about I ask for a function to convert the iterator to the table?
-- this is looking very similar to table.map
-- I'll just wrap it with table.wrap and then let the caller use :mapi to transform the results
-- usage: table.wrapfor(ipairs(t))
-- if you want to wrap a 'for=' loop then just use range(a,b[,c])
-- ok at this point I should just start using lua-fun ...
function table.wrapfor(f, s, var)
	local t = table()
	while true do
		local vars = table.pack(f(s, var))
		local var_1 = vars[1]
		if var_1 == nil then break end
		var = var_1
		t:insert(vars)
	end
	return t
end

-- https://www.lua.org/pil/9.3.html
local function permgen(t, n)
	if n < 1 then
		coroutine.yield(t)
	else
		for i=n,1,-1 do
			-- put i-th element as the last one
			t[n], t[i] = t[i], t[n]
			-- generate all permutations of the other elements
			permgen(t, n - 1)
			-- restore i-th element
			t[n], t[i] = t[i], t[n]
		end
	end
end

-- return iterator of permutations of the table
function table.permutations(t)
	return coroutine.wrap(function()
		permgen(t, table.maxn(t))
	end)
end

-- I won't add table.getmetatable because, as a member method, that will always return 'table'

-- if you use this as a member method then know that you can't use it a second time (unless the metatable you set it to has a __index that has 'setmetatable' defined)
table.setmetatable = setmetatable

return table

end)
__bundle_register("lib.lua-ext.op", function(require, _LOADED, __bundle_register, __bundle_modules)
--[[
make lua functions for each operator.
it looks like i'm mapping 1-1 between metamethods and fields in this table.
useful for using Lua as a functional language.

TODO rename to 'ops'?
--]]

--local load = require 'string'.load	-- string.load = loadstring or load
local load = loadstring or load

-- test if we hae lua 5.3 bitwise operators
-- orrr I could just try each op and bail out on error
-- and honestly I should be defaulting to the 'bit' library anyways, esp in the case of luajit where it is translated to an asm opcode
local lua53 = _VERSION >= 'Lua 5.3'

local symbolscode = [[

	-- which fields are unary operators
	local unary = {
		unm = true,
		bnot = true,
		len = true,
		lnot = true,
	}

	local symbols = {
		add = '+',
		sub = '-',
		mul = '*',
		div = '/',
		mod = '%',
		pow = '^',
		unm = '-',			-- unary
		concat = '..',
		eq = '==',
		ne = '~=',
		lt = '<',
		le = '<=',
		gt = '>',
		ge = '>=',
		land = 'and',		-- non-overloadable
		lor = 'or',			-- non-overloadable
		len = '#',			-- unary
		lnot = 'not',		-- non-overloadable, unary
]]
if lua53 then
	symbolscode = symbolscode .. [[
		idiv = '//',		-- 5.3
		band = '&',			-- 5.3
		bor = '|',			-- 5.3
		bxor = '~',			-- 5.3
		shl = '<<',			-- 5.3
		shr = '>>',			-- 5.3
		bnot = '~',			-- 5.3, unary
]]
--[[ alternatively, luajit 'bit' library:
I should probably include all of these instead
would there be a perf hit from directly assigning these functions to my own table,
 as there is a perf hit for assigning from ffi.C func ptrs to other variables?  probably.
 how about as a tail call / vararg forwarding?
I wonder if luajit adds extra metamethods

luajit 2.0		lua 5.2		lua 5.3
band			band		&
bnot			bnot		~
bor				bor			|
bxor			bxor		~
lshift			lshift		<<
rshift			rshift		>>
arshift			arshift
rol				lrotate
ror				rrotate
bswap (reverses 32-bit integer endian-ness of bytes)
tobit (converts from lua number to its signed 32-bit value)
tohex (string conversion)
				btest (does some bitflag stuff)
				extract (same)
				replace (same)
--]]
end
symbolscode = symbolscode .. [[
	}
]]

local symbols, unary = assert(load(symbolscode..' return symbols, unary'))()

local code = symbolscode .. [[
	-- functions for operators
	local ops
	ops = {
]]
for name,symbol in pairs(symbols) do
	if unary[name] then
		code = code .. [[
		]]..name..[[ = function(a) return ]]..symbol..[[ a end,
]]
	else
		code = code .. [[
		]]..name..[[ = function(a,b) return a ]]..symbol..[[ b end,
]]
	end
end
code = code .. [[
		index = function(t, k) return t[k] end,
		newindex = function(t, k, v)
			t[k] = v
			return t, k, v	-- ? should it return anything ?
		end,
		call = function(f, ...) return f(...) end,

		symbols = symbols,

		-- special pcall wrapping index, thanks luajit.  thanks.
		-- while i'm here, multiple indexing, so it bails out nil early, so it's a chained .? operator
		safeindex = function(t, ...)
			if select('#', ...) == 0 then return t end
			local res, v = pcall(ops.index, t, ...)
			if not res then return nil, v end
			return ops.safeindex(v, select(2, ...))
		end,
	}
	return ops
]]
return assert(load(code))()

end)
__bundle_register("src.util.polyfill.string.escape", function(require, _LOADED, __bundle_register, __bundle_modules)

--- https://stackoverflow.com/questions/9790688/escaping-strings-for-gsub
---@param text string
local function escape_pattern(text)
    return text:gsub("([^%w])", "%%%1")
end

return escape_pattern
end)
__bundle_register("src.util.parser.parse.TokenStack", function(require, _LOADED, __bundle_register, __bundle_modules)
local class = require("lib.30log")
local is_cancelled = require("src.util.parser.parse.is_cancelled")

---@return table<string, true>
local function get_tokens()
    local tokens = {
        "{",
        "}",
        "[",
        "]",
        "(",
        ")",
        "'",
        "\"",
    }

    local out = {}
    for _, token in ipairs(tokens) do
        out[token] = true
    end

    return out
end

---@class LuaX.TokenStack : Log.BaseFunctions
---@field pos integer
---@field text string
---@field tokens table<string, true>
---@field requires_literal boolean
---@operator call:LuaX.TokenStack
local TokenStack = class("TokenStack")

---@param text string
function TokenStack:init(text)
    self:set_pos(1)

    self.stack = ""

    self.text = text

    self.tokens = get_tokens()

    self:set_requires_literal(false)
end

---@param requires_literal boolean
---@return self
function TokenStack:set_requires_literal(requires_literal)
    self.requires_literal = requires_literal

    return self
end

---@param pos integer
---@return self
function TokenStack:set_pos(pos)
    self.pos = pos

    return self
end

function TokenStack:get_pos()
    return self.pos
end

---- Check if the current character is cancelled by backslashes
function TokenStack:is_cancelled()
    return is_cancelled(self.text, self.pos)
end

--- Check if the current character is a token
---@return boolean
function TokenStack:is_token()
    if self:is_cancelled() then
        return false
    end

    local char = self.text:sub(self.pos, self.pos)

    return self.tokens[char] or false
end

---@param char "<" | ">" | "{" | "}" | "[" | "]" | "(" | ")" | "\"" | "'"
function TokenStack.get_opposite(char)
    return ({
        ["<"] = ">",
        [">"] = "<",

        ["{"] = "}",
        ["}"] = "{",

        ["["] = "]",
        ["]"] = "[",

        ["("] = ")",
        [")"] = "(",

        ["\""] = "\"",
        ["'"] = "'",
    })[char]
end

function TokenStack:is_empty()
    return #self.stack == 0
end

--[[
function TokenStack:is_in_literal()
    return self.text:match("{")
end

function TokenStack:is_in_string()
    return self.text:match("['\"]") or self.text:match("%[%[")
end
]]

-- collect char if:
--      first char(s) is string (LuaXParser props collection)
--      first char(s) is literal (LuaXParser props collection / literal parsing)

--- Advance one character
---@return self
function TokenStack:run_once()
    local char = self.text:sub(self.pos, self.pos)

    if self:is_token() then
        local last_token = self.stack:sub(-1)

        if self.get_opposite(char) == last_token then
            self.stack = self.stack:sub(1, -2)
        else
            if not self.stack:match("[\"']$") and not self.stack:match("%[%[$") then
                if not self.requires_literal or self.stack:match("^{") or char == "{" then
                    self.stack = self.stack .. char
                end
            end
        end
    end

    self:safety_check()

    self.pos = self.pos + 1

    return self
end

function TokenStack:get_current()
    return self.text:sub(self.pos, self.pos)
end

function TokenStack:safety_check()
    if self.pos > #self.text + 1 then
        error("TokenStack out of text bounds")
    end
end

---@return self
function TokenStack:run_until_empty()
    while not self:is_empty() do
        self:run_once()

        self:safety_check()
    end

    return self
end

return TokenStack

end)
__bundle_register("src.util.parser.parse.is_cancelled", function(require, _LOADED, __bundle_register, __bundle_modules)

--- Check if the character at pos of text is cancelled
---@param text string
---@param pos integer
---@return boolean
local function is_cancelled(text, pos)
    local pos = pos - 1

    local char = text:sub(pos, pos)

    local cancelled = false

    while char == "\\" do
        cancelled = not cancelled       
        
        pos = pos - 1

        char = text:sub(pos, pos)
    end

    return cancelled
end

return is_cancelled
end)
__bundle_register("src.util.parser.transpile.get_global_components", function(require, _LOADED, __bundle_register, __bundle_modules)
local NativeElement      = require("src.util.NativeElement")
local warn_once          = require("src.util.warn_once")

local function get_global_components()
    -- Check if we can safely use global mode for component names
    local globals = {}

    ---@type LuaX.NativeElement[]
    local subclasses_of_native_element = NativeElement:subclasses()

    if #subclasses_of_native_element == 0 then
        warn_once(
            "LuaX Parser: NativeElement has not been extended yet - defaulting to local variable lookup" .. '\n' ..
            "to use global mode, import your NativeElement implementation before any LuaX files"
        )

        return nil
    end

    for i, NativeElementImplementation in ipairs(subclasses_of_native_element) do
        -- saves some memory to do this here, as every string from this class in globals will be the same
        local implementation_name = tostring(NativeElementImplementation)

        -- try to strip 30log's info - we only need class name
        implementation_name = implementation_name:match("class '([^']+)'") or implementation_name

        if not NativeElementImplementation.components then
            warn_once(string.format(
                "LuaX Parser: NativeElement subclass %s does not have a component registry list - defaulting to local variable lookup",
                implementation_name
            ))

            return nil
        end

        for _, component_name in ipairs(NativeElementImplementation.components) do
            if globals[component_name] then
                warn_once(string.format(
                    "LuaX Parser: Multiple NativeElement implementations implement an element called %q.",
                    component_name
                ))
            end

            -- so that we can look up which implementation uses this
            globals[component_name] = i
        end
    end

    return globals
end

local last_globals = nil
local last_subclass_count = nil
local function get_global_components_cached ()
    local subclass_count = #NativeElement:subclasses()
    
    if subclass_count ~= last_subclass_count or not last_globals then
        last_globals = get_global_components()
    end

    return last_globals
end

return get_global_components_cached
end)
__bundle_register("src.util.warn_once", function(require, _LOADED, __bundle_register, __bundle_modules)
--- Can't be tested because of warn() usage
---@nospec

local table_pack = require("src.util.polyfill.table.pack")

local warn_history = {}

--- Like warn(), but will cache previous warnings.
---@param ... any
local function warn_once (...)
    local strs = {}
    for i, sub in ipairs(table_pack(...)) do
        strs[i] = tostring(sub)
    end
    
    local hash = table.concat(strs)

    if not warn_history[hash] then
        warn(...)

        warn_history[hash] = true
    end
end

return warn_once
end)
__bundle_register("src.util.parser.transpile.node_to_element", function(require, _LOADED, __bundle_register, __bundle_modules)
local transpile_create_element = require("src.util.parser.transpile.create_element")
local get_component_name = require("src.util.parser.transpile.get_component_name")

--- Statically convert a LuaX language node to a create_element() call
---@param node LuaX.Language.Node
---@param components table<string, true> hash map for speed
---@param components_mode "local" | "global"
---@param create_element string
---@return string
local function transpile_node_to_element(node, components, components_mode, create_element)
    if node.type == "comment" then
        return ""
    end

    if node.type == "element" then
        ---@type table<string, string|table>
        local props = node.props or {}

        local children = node.children
        if children and #children >= 1 then
            local str_children = {}

            for i, child in ipairs(children) do
                if type(child) == "string" then
                    str_children[i] = "{" .. child .. "}"
                else
                    str_children[i] = "{" ..
                    transpile_node_to_element(child, components, components_mode, create_element) .. "}"
                end
            end

            props.children = str_children
        end

        local name = node.name
        local component = get_component_name(components, components_mode, name)

        return transpile_create_element(create_element, component, props)
    end

    error(string.format("Can't transpile LuaX node of type %s", node.type))
end

return transpile_node_to_element

end)
__bundle_register("src.util.parser.transpile.get_component_name", function(require, _LOADED, __bundle_register, __bundle_modules)

--- Return the component's name as a string, either for a lua local,
--- or quoted as a component for NativeElement to use
---
---@param components table<string, true> hash map for speed
---@param components_mode "local" | "global"
---@param name string
local function get_component_name(components, components_mode, name)
    -- LuaX.<name> is always treated as a global
    if name:sub(1, 5) == "LuaX." then
        return string.format("%q", name:sub(6))
    end

    local search_name =
        -- Turn MyContext.Provider or MyContext["Provider"] into just MyContext
        name:match("^(.-)[%.%[]") or
        -- Default to just the name if we can't match table key calls
        name

    -- try both shortened name and full-length name
    local has_component = not not (components[search_name] or components[name])

    local mode_global = components_mode == "global"

    local is_global = has_component == mode_global

    if is_global then
        return string.format("%q", name)
    else
        return name
    end
end

return get_component_name
end)
__bundle_register("src.util.parser.transpile.create_element", function(require, _LOADED, __bundle_register, __bundle_modules)

local stringify_table = require("src.util.parser.transpile.stringify_table")

--- Return a string of a call to create_element for transpiling LuaX
--- Strings here for everything, as they're interpreted as Lua literals
--- 
---@param create_element string? the local name for create_element
---@param type string 
---@param props table
local function transpile_create_element (create_element, type, props)
    create_element = create_element or "create_element"

    local prop_str = stringify_table(props)

    return string.format("%s(%s, %s)", create_element, type, prop_str)
end

return transpile_create_element
end)
__bundle_register("src.util.parser.transpile.stringify_table", function(require, _LOADED, __bundle_register, __bundle_modules)
local ipairs_with_nil = require("src.util.ipairs_with_nil")

---@param input any
---@return string
local stringify = function(input)
    error("should have been replaced!")
end

--- Try really really hard to stringify a table safely.
--- Obviously this table has to be serializable
---
--- Don't take this stringifier for a good implementation,
--- it's only really bothered with LuaX
---
---@param input table
---@return string
local function stringify_table(input)
    local elements = {}

    -- number keys need to be handled differently to others, because of the way LuaX works.
    for k, v in pairs(input) do
        if type(k) ~= "number" then
            local key = stringify(k)
            local value = stringify(v)

            local format = string.format("[%s]=%s", key, value)

            table.insert(elements, format)
        end
    end

    for _, v in ipairs_with_nil(input) do
        local value = stringify(v)

        if #value ~= 0 then
            table.insert(elements, value)
        end
    end

    return string.format("{ %s }", table.concat(elements, ", "))
end

stringify = function(input)
    local t = type(input)

    if t == "nil" or t == "number" or t == "boolean" then
        return tostring(input)
    end

    if t == "string" then
        if input:match("^{.*}$") then
            -- parse a literal
            return input:sub(2, -2)
        else
            return string.format("%q", input)
        end
    end

    if t == "table" then
        return stringify_table(input)
    end

    if t == "function" then
        local dump = string.dump(input)

        return string.format("load(%q)", dump)
    end

    error(string.format("Cannot stringify %s", t))
end

return stringify_table
end)
__bundle_register("src.util.parser.tokens", function(require, _LOADED, __bundle_register, __bundle_modules)
---@nospec too simple to need a test. just a list

local keywords = require("src.util.parser.keywords")
local escape   = require("src.util.polyfill.string.escape")

---@class LuaX.Parser.V2.Token
---@field pattern string
---@field replacer string
---@field end_pattern string
---@field end_replacer string

---@param token any
---@return LuaX.Parser.V2.Token
local function ensure_token(token)
    token.replacer = token.replacer or ""
    token.end_pattern = token.end_pattern or ""
    token.end_replacer = token.end_replacer or ""

    return token
end

-- Generate a list of valid tokens that precede LuaX tags
local function bake_tokens()
    ---@type any[]
    local tokens = {
        {
            -- Capture here to keep whitespace & allow indent features to work nicely.
            pattern = "return%s*%[(=*)%[(%s*)<",
            replacer = "return %2",
            end_pattern = "%s*%]%1%]",
            end_replacer = ""
        },
        {
            pattern = "LuaX%s*%(%[(=*)%[(%s*)<",
            replacer = "%2",
            end_pattern = "%s*%]%1%]%s*%)",
            end_replacer = ""
        }
    }

    for _, keyword in ipairs(keywords) do
        table.insert(tokens, {
            pattern = keyword .. "%s*<",
            replacer = keyword .. " "
        })
    end

    -- https://hackage.haskell.org/package/language-lua-0.11.0.1/docs/Language-Lua-Token.html
    for token, match in pairs({
        ["{"] = "}",
        ["["] = "]",
        ["("] = ")",
        [","] = "",
        ["="] = "",
    }) do
        table.insert(tokens, {
            pattern = escape(token) .. "%s*<",
            replacer = token,
            -- Add end_pattern match for matching ending brackets
            end_pattern = match and ("%s*" .. escape(match)),
            end_replacer = match
        })
    end

    ---@type LuaX.Parser.V2.Token[]
    local ret = {}

    for _, token in ipairs(tokens) do
        table.insert(ret, ensure_token(token))
    end

    return ret
end

return bake_tokens()

end)
__bundle_register("src.util.parser.keywords", function(require, _LOADED, __bundle_register, __bundle_modules)

---@nospec too simple to need a test. just a list

-- https://www.lua.org/manual/5.1/manual.html section 2.1

local keywords = {
    "and",
    "break",
    "do",
    "else",
    "elseif",
    "end",
    "false",
    "for",
    "function",
    "if",
    "in",
    "local",
    "nil",
    "not",
    "or",
    "repeat",
    "return",
    "then",
    "true",
    "until",
    "while"
}

return keywords

end)
__bundle_register("src.entry.runtime", function(require, _LOADED, __bundle_register, __bundle_modules)
---@class LuaX.Runtime
--- APIs
---@field Renderer LuaX.Renderer
---@field Children LuaX.Children
---
---@field NativeElement LuaX.NativeElement
---
---@field create_element fun(type: LuaX.Component, props: LuaX.Props): LuaX.ElementNode
---@field clone_element (fun(element: LuaX.ElementNode, props: LuaX.Props): LuaX.ElementNode) | (fun(element: LuaX.ElementNode[], props: LuaX.Props): LuaX.ElementNode[])
--- Components
---@field Fragment LuaX.Component.Fragment
---@field Suspense LuaX.Component.Suspense
---@field ErrorBoundary LuaX.Component.ErrorBoundary
---@field Portal LuaX.Portal
---@field Context LuaX.Context
--- Hooks
---@field use_context LuaX.Hooks.UseContext
---@field use_effect LuaX.Hooks.UseEffect
---@field use_memo LuaX.Hooks.UseMemo
---@field use_portal LuaX.Hooks.UsePortal
---@field use_ref LuaX.Hooks.UseRef
---@field use_state LuaX.Hooks.UseState
---@field use_suspense LuaX.Hooks.UseSuspense
local runtime = {
    Renderer          = require("src.util.Renderer"),
    Children          = require("src.Children"),

    create_element    = require("src.create_element"),
    clone_element     = require("src.clone_element"),

    Fragment          = require("src.components.Fragment"),
    Suspense          = require("src.components.Suspense"),
    ErrorBoundary     = require("src.components.ErrorBoundary"),
    Context           = require("src.Context"),
    Portal            = require("src.Portal"),

    use_callback      = require("src.hooks.use_callback"),
    use_context       = require("src.hooks.use_context"),
    use_effect        = require("src.hooks.use_effect"),
    use_memo          = require("src.hooks.use_memo"),
    use_portal        = require("src.hooks.use_portal"),
    use_ref           = require("src.hooks.use_ref"),
    use_state         = require("src.hooks.use_state"),
    use_suspense      = require("src.hooks.use_suspense"),
}

return runtime

end)
__bundle_register("src.hooks.use_suspense", function(require, _LOADED, __bundle_register, __bundle_modules)
local DrawGroup = require("src.util.Renderer.DrawGroup")
local use_memo  = require("src.hooks.use_memo")

---@alias LuaX.Hooks.UseSuspense fun(): (suspend: fun(), resolve: fun())

---@type LuaX.Hooks.UseSuspense
local function use_suspense()
    local group = use_memo(function()
        return DrawGroup.current()
    end, {})

    return function ()
        DrawGroup.ref(group)
    end, function ()
        DrawGroup.unref(group)
    end
end

return use_suspense

end)
__bundle_register("src.hooks.use_memo", function(require, _LOADED, __bundle_register, __bundle_modules)
local HookState    = require("src.util.HookState")
local deep_equals  = require("src.util.deep_equals")
local table_pack   = require("src.util.polyfill.table.pack")
local table_unpack = require("src.util.polyfill.table.unpack")

---@alias LuaX.Hooks.UseMemo.State { deps: any[], cached: any }

---@generic T
---@alias LuaX.Hooks.UseMemo fun (callback: (fun(): T), deps: any[]): T

---@generic T
---@param callback fun(): T
---@param deps any[]
---@return T
local function use_memo(callback, deps)
    local hookstate = HookState.global.get(true)

    local index = hookstate:get_index()

    local last_value = hookstate:get_value(index) or {} --[[ @as LuaX.Hooks.UseMemo.State ]]
    local last_deps = last_value.deps

    local memo_value = last_value.cached

    if not deep_equals(deps, last_deps, 2) then
        local new_value = { deps = deps }
        -- new_value.hook_name = "use_memo"

        -- set deps initially to prevent hook refiring
        hookstate:set_value_silent(index, new_value)

        memo_value = table_pack(callback())

        new_value.cached = memo_value
        hookstate:set_value(index, new_value)
    end

    hookstate:increment()

    return table_unpack(memo_value)
end

return use_memo

end)
__bundle_register("src.hooks.use_state", function(require, _LOADED, __bundle_register, __bundle_modules)
local deep_equals = require("src.util.deep_equals")
local HookState   = require("src.util.HookState")

---@alias LuaX.Hooks.UseState.Dispatch<R> fun(new_value: R | (fun(old: R): R))

---@generic T
---@alias LuaX.Hooks.UseState fun(default?: T): T, LuaX.Hooks.UseState.Dispatch<T>

---@generic T
---@param default T?
---@return T, LuaX.Hooks.UseState.Dispatch<T>
local function use_state(default)
    local hookstate = HookState.global.get(true)

    local index = hookstate:get_index()
    local state = hookstate:get_value(index)

    hookstate:increment()

    if state == nil then
        if type(default) == "function" then
            default = default()
        end

        local setter = function(new_value)
            local state = hookstate:get_value(index)
            
            if type(new_value) == "function" then
                new_value = new_value(state[1])
            end

            if not deep_equals(state[1], new_value, 2) then
                state[1] = new_value

                hookstate:modified(index, state)
            end
        end

        state = { default, setter }

        hookstate:set_value_silent(index, state)
    end

    return state[1], state[2]
end

return use_state

end)
__bundle_register("src.hooks.use_ref", function(require, _LOADED, __bundle_register, __bundle_modules)

local use_state = require("src.hooks.use_state")

---@generic T
---@alias LuaX.Hooks.UseRef fun(default: T?): { current: T }

---@generic T
---@param default T?
---@return { current: T }
local function use_ref(default)
    -- use_state inserts to hookstate for us, why reinvent the wheel?
    local ref = use_state({ current = default })

    return ref
end

return use_ref
end)
__bundle_register("src.hooks.use_portal", function(require, _LOADED, __bundle_register, __bundle_modules)
local use_context = require("src.hooks.use_context")
local Portal      = require("src.Portal")

---@alias LuaX.Hooks.UsePortal fun (name?: string): LuaX.Portal

local function use_portal(name)
    local portals = assert(use_context(Portal.Context),
        "No portals supplied! Are you sure a parent of this component is rendering its Provider?")

    local portal = portals[name or "LuaX.Portal"]

    return assert(portal, name and string.format("No portal by name %q", name) or "No default portal")
end

return use_portal

end)
__bundle_register("src.Portal", function(require, _LOADED, __bundle_register, __bundle_modules)
local class          = require("lib.30log")
local use_effect     = require("src.hooks.use_effect")
local use_memo       = require("src.hooks.use_memo")
local use_state      = require("src.hooks.use_state")
local Context        = require("src.Context")
local use_context    = require("src.hooks.use_context")
local create_element = require("src.create_element")

local map            = require("src.util.polyfill.list.map")

if warn then
    -- I'm ignoring major.minor.patch for Portals for now.
    warn("Portals are an experimental feature and are subject to change until the next minor release")
end

---@class LuaX.Portal : Log.BaseFunctions
---
---@field Inlet LuaX.Component<LuaX.PropsWithChildren>
---@field Outlet LuaX.Component
---
---@field Context LuaX.Context<LuaX.Portal>
---
---@field name string | "LuaX.Portal"
---@field protected children { uid: number, child: LuaX.ElementNode[] }[]
---
---@field protected GenericProvider LuaX.Component<LuaX.PropsWithChildren>
---@field protected GenericInlet LuaX.Component<LuaX.PropsWithChildren>
---@field protected GenericOutlet LuaX.Component
local Portal = class("LuaX.Portal")

---@alias LuaX.Portal.UID number

-- Probably fine for our usages
-- TODO run the stats on this.
---@return LuaX.Portal.UID
function Portal:unique()
    return math.random(0xFFFF)
end

-- TODO backwards compatible react-like Portal.create overload? Portal.create(ElementNode, NativeElement, key?)

-- TODO test exotic configurations:
-- - portal to non-root NativeElement, same renderer
-- - portal to non-root NativeElement on different renderer

local rtfm = [[
Portal is a class that must be instanciated before use:
    local MyPortal = Portal()

    return (
        <>
            <MyPortal.Outlet />

            <MyPortal.Inlet>
                Hello World!
            </MyPortal.Inlet>
        </>
    )

consider reading doc/Portals.md
]]
Portal.Inlet = function() error(rtfm) end
Portal.Outlet = Portal.Inlet

function Portal:init(name)
    self.name = name

    self.children = {}

    self.observers = setmetatable({}, { __mode = "k" })

    self.Outlet = function()
        return self:GenericOutlet()
    end
    self.Inlet = function(props)
        return self:GenericInlet(props)
    end
    self.Provider = function(props)
        return self:GenericProvider(props)
    end
end

---@param cb function
function Portal:observe(cb)
    self.observers[cb] = true
end

---@param cb function
function Portal:unobserve(cb)
    self.observers[cb] = nil
end

function Portal:update()
    local cbs = {}
    for cb in pairs(self.observers) do
        cbs[cb] = true
    end

    for cb in pairs(cbs) do
        cb()
    end
end

---@param uid LuaX.Portal.UID
---@param child LuaX.ElementNode | LuaX.ElementNode[]
function Portal:add_child(uid, child)
    for _, existing in ipairs(self.children) do
        -- check if this existing child entry has the given UID
        if existing.uid == uid then
            existing.child = child
            self:update()

            return
        end
    end

    -- if we haven't returned yet, insert a new child
    table.insert(self.children, { uid = uid, child = child })
    self:update()
end

---@param uid LuaX.Portal.UID
---@return boolean
function Portal:remove_child(uid)
    for i, existing in ipairs(self.children) do
        if existing.uid == uid then
            table.remove(self.children, i)
            self:update()

            return true
        end
    end

    return false
end

---@param props LuaX.PropsWithChildren<{}>
function Portal:GenericInlet(props)
    local children = props.children

    local uid = use_memo(function()
        return self:unique()
    end, {})

    use_effect(function()
        self:add_child(uid, children)

        return function()
            self:remove_child(uid)
        end
    end, { children })

    return nil
end

function Portal:GenericOutlet()
    local re, set_re = use_state(0)
    local rerender = function()
        set_re(re + 1)
    end

    use_effect(function()
        self:observe(rerender)

        return function()
            self:unobserve(rerender)
        end
    end)

    return map(self.children, function(data)
        return data.child
    end)
end

---@type LuaX.Context<LuaX.Portal>
Portal.Context = Context()

function Portal:GenericProvider(props)
    local table = use_context(Portal.Context) or {}

    local name = self.name

    local new_table = { [name] = self }
    for k, v in pairs(table) do
        new_table[k] = v
    end

    return create_element(Portal.Context.Provider, { children = props.children, value = new_table })
end

---@param name string?
function Portal.create(name)
    return Portal(name)
end

return Portal

end)
__bundle_register("src.util.polyfill.list.map", function(require, _LOADED, __bundle_register, __bundle_modules)

---@generic T, R
---@param list T[]
---@param cb fun(item: T, index: number, list: T[]): R
---@return R[]
local function list_map (list, cb)
    local ret = {}

    for k, v in pairs(list) do
        ret[k] = cb(v, k, list)
    end

    return ret
end

return list_map
end)
__bundle_register("src.create_element", function(require, _LOADED, __bundle_register, __bundle_modules)

---@nospec

local ElementNode = require("src.util.ElementNode")

--- Create, but do not render, an instance of a component.
---@param component LuaX.Component | LuaX.ElementNode.LiteralNode
---@param props LuaX.Props
--- @return LuaX.ElementNode
local function create_element(component, props)
    return ElementNode.create(component, props)
end

return create_element

end)
__bundle_register("src.hooks.use_context", function(require, _LOADED, __bundle_register, __bundle_modules)
local RenderInfo = require("src.util.Renderer.RenderInfo")

---@generic T
---@alias LuaX.Hooks.UseContext fun(context: LuaX.Context<T>): T

---@type LuaX.Hooks.UseContext
local function use_context (context)
    local contexts = RenderInfo.get().context

    return contexts[context] or context.default
end

return use_context
end)
__bundle_register("src.Context", function(require, _LOADED, __bundle_register, __bundle_modules)

local class = require("lib.30log")
local RenderInfo = require("src.util.Renderer.RenderInfo")

---@class LuaX.Context<T> : Log.BaseFunctions, { default: T, Provider: LuaX.Component }
---@field protected default table
---@field Provider LuaX.Component
---@operator call:LuaX.Context
local Context = class("Context")

---@param default table
function Context:init(default)
    self.default = default

    -- create_element doesn't know what self is.
    self.Provider = function (props)
        return self:GenericProvider(props)
    end
end

function Context:GenericProvider (props)
    RenderInfo.get().context[self] = props.value
    -- props.__luax_internal.context[self] = props.value

    return props.children
end

---@generic T
---@param default T?
---@return LuaX.Context<T>
function Context.create (default)
    return Context(default)
end

return Context
end)
__bundle_register("src.hooks.use_effect", function(require, _LOADED, __bundle_register, __bundle_modules)
local deep_equals = require("src.util.deep_equals")
local HookState    = require("src.util.HookState")

---@alias LuaX.Hooks.UseEffect.State { deps: any[]?, on_remove: function? }

---@alias LuaX.Hooks.UseEffect fun(callback: (fun(): function?), deps: any[]?)

---@param callback fun(): function? An effect function that optionally returns an unmount handler
---@param deps any[]?
local function use_effect(callback, deps)
    local hookstate = HookState.global.get(true)

    local index = hookstate:get_index()

    local last_value = hookstate:get_value(index) or {} --[[@as LuaX.Hooks.UseEffect.State]]
    local last_deps = last_value.deps

    if not deps or not deep_equals(deps, last_deps, 2) then
        local new_value = { deps = deps }
        -- new_value.hook_name = "use_effect"

        -- set deps initially to prevent hook refiring
        hookstate:set_value_silent(index, new_value)

        if last_value.on_remove then
            last_value.on_remove()
        end

        local callback_result = callback()

        -- this feels wrong but is performant
        new_value.on_remove = callback_result
    end

    hookstate:increment()
end

return use_effect

end)
__bundle_register("src.hooks.use_callback", function(require, _LOADED, __bundle_register, __bundle_modules)
local use_memo = require("src.hooks.use_memo")

local function use_callback (cb, deps)
    return use_memo(function ()
        return cb
    end, deps)
end

return use_callback
end)
__bundle_register("src.components.ErrorBoundary", function(require, _LOADED, __bundle_register, __bundle_modules)
local use_effect = require("src.hooks.use_effect")
local use_state  = require("src.hooks.use_state")
local RenderInfo = require("src.util.Renderer.RenderInfo")
local DrawGroup  = require("src.util.Renderer.DrawGroup")
local create_element = require("src.create_element")

---@alias LuaX.Component.ErrorBoundary LuaX.Generic.Component<LuaX.PropsWithChildren<{ fallback?: string|function|LuaX.ElementNode }>>

--[[
going from returning multiple children to a single value causes a NativeElement
error.

delete_children_by_key tries to delete an element that doesn't exist. this
doesn't fail directly, but causes the children_by_key table to not update properly.

key 1.2 - ErrorBoundary child

delete_children_by_key 1.2.1.2 is called via component == nil, from initial label being removed due to error.
]]

---@type LuaX.Component.ErrorBoundary
local function ErrorBoundary(props)
    local err, set_err = use_state(nil)
    
    use_effect(function ()
        local info = RenderInfo.get()

        local old_group = info.draw_group
        DrawGroup.ref(old_group)
        local group = DrawGroup.create(function (e)
            set_err(e)
        end, function ()
            DrawGroup.unref(old_group)
        end, function ()
            DrawGroup.ref(old_group)
        end)

        -- evil table injection, but it's mostly ok.
        info.draw_group = group
    end, {})

    if err then
        local fallback = props.fallback
        if type(fallback) == "string" or type(fallback) == "function" then
            return create_element(fallback, { error = err })
        else
            -- Returning a string or function component is totally valid.
            return fallback
        end
    else
        return props.children
    end
end

return ErrorBoundary
end)
__bundle_register("src.components.Suspense", function(require, _LOADED, __bundle_register, __bundle_modules)
local DrawGroup         = require("src.util.Renderer.DrawGroup")
local RenderInfo        = require("src.util.Renderer.RenderInfo")
local NativeTextElement = require("src.util.NativeElement.NativeTextElement")
local VirtualElement    = require("src.util.NativeElement.VirtualElement")
local traceback         = require("src.util.debug.traceback")
local use_effect        = require("src.hooks.use_effect")
local use_state         = require("src.hooks.use_state")
local use_memo          = require("src.hooks.use_memo")
local create_element    = require("src.create_element")


local no_op = function() end

---@alias LuaX.Component.Suspense LuaX.Generic.Component<LuaX.PropsWithChildren<{ fallback?: LuaX.ElementNode|string|function }>>

---@type LuaX.Component.Suspense
local function Suspense(props)
    local complete, set_complete = use_state(false)

    --- Clone RenderInfo so that we don't modify current RenderInfo
    ---@type LuaX.RenderInfo.Info
    local info = use_memo(function()
        local info = RenderInfo.clone(RenderInfo.get())

        -- Create new DrawGroup
        local group = DrawGroup.create(info.draw_group.on_error, function()
            set_complete(true)
        end, function()
            set_complete(false)
        end)
        info.draw_group = group

        return info
    end, {})

    local key = info.key
    local container = info.container
    local renderer = info.renderer

    local clone = use_memo(function()
        -- TODO I hate this pattern. How can we createa a generic container?
        -- I can't pass container:get_native() because that could have side
        -- effects (init is non-atomic, eg GtkElement visibility could change.)
        local ok, ret = xpcall(container:get_class().get_root, traceback)

        if not ok then
            error(
                "Looks like this NativeElement implementation doesn't support nil root elements. This is required for Suspense to work. " ..
                tostring(ret))
        end

        local instance = ret

        -- overload clone's insert_child and delete_child methods - we call this on container when ready.
        instance.insert_child = no_op
        instance.delete_child = no_op

        return instance
    end, { container })

    use_effect(function()
        ---@diagnostic disable-next-line:invisible
        renderer.workloop:add(renderer.render_keyed_child, renderer, props.children, clone, key, info)

        renderer.workloop:safely_start()
    end, { renderer, props.children, clone, key, info })

    -- Manage children in container
    use_effect(function()
        -- clear existing children in this key's slot.

        -- Calling container:delete_children_by_key() or returning
        -- props.fallback without this block would mean that cleanup
        -- functions are called, and we don't want that.
        ---@diagnostic disable-next-line:invisible
        local children = container:flatten_children(key)

        ---@diagnostic disable-next-line:invisible
        local delete_index = container:count_children_by_key(key)

        for i = #children, 1, -1 do
            local child = children[i].element

            if child.class ~= VirtualElement then
                local is_text = NativeTextElement:classOf(child.class) or false

                container:delete_child(delete_index, is_text)

                delete_index = delete_index - 1
            end
        end

        ---@diagnostic disable-next-line:invisible
        container:set_child_by_key(key, nil)

        -- check if we insert prerendered children
        if complete then
            -- Insert all rendered children into the real container from the clone

            ---@diagnostic disable-next-line:invisible
            local children = clone:flatten_children(key)

            for _, child in ipairs(children) do
                container:insert_child_by_key(child.key, child.element)
            end
        end
    end, { complete, container, clone, key })

    -- returning props.children here seems weird - see use_effect above
    if complete then
        return props.children
    else
        local fallback = props.fallback
        if type(fallback) == "string" or type(fallback) == "function" then
            return create_element(fallback, {})
        else
            -- Returning a string or function component is totally valid.
            return fallback
        end
    end
end

return Suspense

end)
__bundle_register("src.components.Fragment", function(require, _LOADED, __bundle_register, __bundle_modules)
---@nospec

---@alias LuaX.Component.Fragment LuaX.Generic.FunctionComponent<LuaX.PropsWithChildren<{}>>

---@type LuaX.Component.Fragment
local function Fragment (props)
    return props.children
end

return Fragment
end)
__bundle_register("src.clone_element", function(require, _LOADED, __bundle_register, __bundle_modules)
local create_element = require("src.create_element")

--- Clone an element
---@param element LuaX.ElementNode | LuaX.ElementNode[]
---@param props LuaX.Props?
local function clone_element(element, props)
    if element.type then
        local component = element.type

        local newprops = {}

        -- copy old props
        for k, v in pairs(element.props or {}) do
            newprops[k] = v
        end

        -- overwrite new porps
        for k, v in pairs(props or {}) do
            newprops[k] = v
        end

        return create_element(component, newprops)
    else
        -- This is a list of elements!!
        local ret = {}

        for i, child in ipairs(element) do
            ret[i] = clone_element(child, props)
        end

        return ret
    end
end

return clone_element
end)
__bundle_register("src.Children", function(require, _LOADED, __bundle_register, __bundle_modules)
local ipairs_with_nil = require("src.util.ipairs_with_nil")

---@class LuaX.Children
local Children = {}

---@param children LuaX.ElementNode[] | LuaX.ElementNode | nil
function Children.count (children)
    if not children then
        return 0
    elseif children.type then
        return 1
    else
        local count = 0

        for _, child in ipairs_with_nil(children) do
            count = count + Children.count(child)
        end
    end
end

---@generic T
---@param children LuaX.ElementNode[] | LuaX.ElementNode | nil
---@param cb fun(child: LuaX.ElementNode, index: number): T
---@return T[]
function Children.map(children, cb)
    if not children or children.type then
        children = { children }
    end

    local mapped = {}

    for i, child in ipairs_with_nil(children) do
        mapped[i] = cb(child, i)
    end

    return mapped
end

return Children
end)
__bundle_register("src.util.Renderer", function(require, _LOADED, __bundle_register, __bundle_modules)
---@nospec

-- see decisions/no_code_init.md

return require("src.util.Renderer.Renderer")
end)
__bundle_register("src.util.Renderer.Renderer", function(require, _LOADED, __bundle_register, __bundle_modules)
local class                 = require("lib.30log")
local ipairs_with_nil       = require("src.util.ipairs_with_nil")
local key_add               = require("src.util.key.key_add")
local get_element_name      = require("src.util.debug.get_element_name")
local create_native_element = require("src.util.Renderer.helper.create_native_element")
local deep_equals           = require("src.util.deep_equals")
local can_modify_child      = require("src.util.Renderer.helper.can_modify_child")
local ElementNode           = require("src.util.ElementNode")
local VirtualElement        = require("src.util.NativeElement.VirtualElement")
local DefaultWorkLoop       = require("src.util.WorkLoop.Default")
local RenderInfo            = require("src.util.Renderer.RenderInfo")
local DrawGroup             = require("src.util.Renderer.DrawGroup")
local NativeElement         = require("src.util.NativeElement.NativeElement")


local max = math.max

---@class LuaX.Renderer : Log.BaseFunctions
---@field workloop LuaX.WorkLoop instance of a workloop
---@field native_element LuaX.NativeElement class here, not instance
---@field set_workloop fun (self: self, workloop: LuaX.WorkLoop): self set workloop using either a class or an instance
---@field render fun(self: self, component: LuaX.ElementNode, container: LuaX.NativeElement)
---
---@operator call: LuaX.Renderer
local Renderer = class("Renderer")

function Renderer:init(workloop)
    self:set_workloop(workloop)
end

--- Takes a class, instance, or nil
---@param workloop LuaX.WorkLoop | nil
function Renderer:set_workloop(workloop)
    -- create an instance if handed a class
    -- instances always have a .class field that points to their class
    if workloop and not workloop.class then
        workloop = workloop()
    end

    self.workloop = workloop or DefaultWorkLoop()

    return self
end

---@protected
---@param component LuaX.ElementNode | nil
---@param container LuaX.NativeElement
---@param key LuaX.Key
---@param info LuaX.RenderInfo.Info
function Renderer:render_native_component(component, container, key, info)
    -- log.trace(get_element_name(container), "render_native_component", get_element_name(component), key_to_string(key))

    -- NativeElement:set_prop_safe now consumes DrawGroup.current, so we must update.
    local info_old = RenderInfo.set(info)

    if component == nil then
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

    -- set props
    for prop, value in pairs(component.props) do
        if
            -- children are handled differently than other props
            prop ~= "children" and
            -- LuaX:: signifies a property that LuaX handles innately.
            prop:sub(1, 6) ~= "LuaX::" and
            -- values haven't changed.
            not deep_equals(value, node:get_prop_safe(prop), 2)
        then
            node:set_prop_safe(prop, value)
        end
    end

    -- handle children using workloop
    local children = component.props['children']

    local current_children = node:get_children_by_key({}) or {}
    if children then
        local workloop = self.workloop

        local size = max(#current_children, #children)
        for index, child in ipairs_with_nil(children, size) do
            DrawGroup.ref(info.draw_group)

            workloop:add(self.render_keyed_child, self, child, node, { index }, info)
        end

        workloop:safely_start()
    end

    -- Append to parent node
    if not can_modify then
        container:insert_child_by_key(key, node)
    end

    RenderInfo.set(info_old)
end

---@protected
---@param element LuaX.ElementNode
---@param container LuaX.NativeElement
---@param key LuaX.Key
---@param info LuaX.RenderInfo.Info
function Renderer:render_function_component(element, container, key, info)
    -- check if there's already something in the way
    do
        local existing = container:get_children_by_key(key)

        -- Single existing child or too many children. VirtualElement creates 2.
        if existing and (existing.class or #existing > 2) then
            container:delete_children_by_key(key)
        end
    end

    local virtual_key = key_add(key, 1)
    local render_key = key_add(key, 2)
    local can_modify, existing_child = can_modify_child(element, container,
        virtual_key)

    ---@type LuaX.NativeElement.Virtual
    local node = nil

    local info = RenderInfo.inherit({
        -- we pass render_key to functions so they don't overwrite their own
        -- VirtualElement
        key = render_key,

        container = container,

        renderer = self,
    }, info)

    if can_modify then
        node = existing_child --[[ @as LuaX.NativeElement.Virtual ]]
    else
        if existing_child then
            container:delete_children_by_key(virtual_key)
        end

        node = VirtualElement.create_element(element.type)

        container:insert_child_by_key(virtual_key, node)

        node:set_on_change(function()
            self.workloop:add(function()
                -- log.debug("Component change")
                local old = RenderInfo.set(info)

                -- Force render because a hook changed
                local did_render, render_result = node:render(true)

                if did_render then
                    DrawGroup.ref(info.draw_group)

                    self:render_keyed_child(render_result, container,
                        render_key, info)
                end

                RenderInfo.set(old)
            end)

            -- TODO escape current callback somehow?
            -- start workloop if it isn't running
            self.workloop:safely_start()
        end)
    end

    local old = RenderInfo.set(info)

    RenderInfo.bind(element.props, info)
    node:set_props(element.props)

    -- This feels evil
    local did_render, render_result = node:render()
    if did_render then
        DrawGroup.ref(info.draw_group)

        self.workloop:add(self.render_keyed_child, self, render_result, container, render_key, info)
    end

    RenderInfo.set(old)

    self.workloop:safely_start()
end

---@protected
---@param element LuaX.ElementNode | nil
---@param container LuaX.NativeElement
---@param key LuaX.Key
---@param info LuaX.RenderInfo.Info
function Renderer:render_keyed_child(element, container, key, info)
    -- log.trace(get_element_name(container), "rendering", get_element_name(element), key_to_string(key))

    if not element or type(element.type) == "string" then
        self:render_native_component(element, container, key, info)

        -- TODO element.element_node ~= ElementNode equality check might be slow!
        ---@diagnostic disable-next-line:invisible
    elseif type(element) == "table" and element.element_node ~= ElementNode then
        -- lists of children are valid children
        local current_children = container:get_children_by_key(key) or {}

        if current_children.class and class.isClass(current_children.class) then
            container:delete_children_by_key(key)

            current_children = {}
        end

        local size = max(#current_children, #element)


        for i, child in ipairs_with_nil(element, size) do
            local newkey = key_add(key, i)

            DrawGroup.ref(info.draw_group)

            self.workloop:add(self.render_keyed_child, self, child, container, newkey, info)
        end
    elseif type(element.type) == "function" then
        self:render_function_component(element, container, key, info)
    else
        local component_type = type(element.type)

        error(string.format(
            "Cannot render component of type '%s' (rendered by %s)",
            component_type, get_element_name(container)
        ))
    end

    DrawGroup.unref(info.draw_group)

    -- start workloop in case there's rendering to do and it's stopped
    self.workloop:safely_start()
end

-- TODO maybe children should know parents? error in Renderer:render_keyed_child used to print calling Component if available

---@param component LuaX.ElementNode
---@param container LuaX.NativeElement
function Renderer:render(component, container)
    -- Check arguments to assert theyr'e correct.
    local args = { self, component, container }
    for i, info in ipairs({
        { type = Renderer, name = "self", extra =
        "Are you calling renderer.render() instead of renderer:render()?" },

        { type = "table",       name = "component" },

        { type = NativeElement, name = "container" }
    }) do
        local arg = args[i]

        local extra = info.extra and (" " .. info.extra) or ""

        if type(info.type) == "string" then
            assert(type(arg) == info.type and not class.isInstance(arg),
                string.format("Expected argument %q to be of type %s" .. extra, info.name, info.type))
        else
            local classname = tostring(info.type)
            -- Try to get the name from class '<classname>' (table: 0x<addr>)
            classname = classname:match("class '[^']+'") or classname

            assert(class.isInstance(arg),
                string.format("Expected argument %q to be an instance of %s" .. extra, info.name, classname))
        end
    end

    -- Create a default draw group
    local group = DrawGroup.create(function(err)
        error(err)
    end, function() end, function() end)

    local render_info = {
        key = {},
        context = {},
        draw_group = group
    }
    -- We need an error handler.
    RenderInfo.set(render_info)

    self.workloop:add(self.render_keyed_child, self, component, container, { 1 }, render_info)

    self.workloop:safely_start()
end

return Renderer

end)
__bundle_register("src.util.WorkLoop.Default", function(require, _LOADED, __bundle_register, __bundle_modules)
local WorkLoop = require("src.util.WorkLoop")

---@class LuaX.WorkLoop.Default : LuaX.WorkLoop
local DefaultWorkLoop = WorkLoop:extend("DefaultWorkLoop")

---@param opts { supress_warning?: boolean }
function DefaultWorkLoop:init(opts)
    opts = opts or {}

    if not opts.supress_warning then
        warn(
            "LuaX Renderer is using a default (synchronous) work loop! " ..
            "This is not recommended as it will freeze " ..
            "the main thread until rendering is done."
        )
    end

    ---@diagnostic disable-next-line:undefined-field
    self.super:init()
end

function DefaultWorkLoop:start()
    while self.is_running do
        self:run_once()
    end
end

return DefaultWorkLoop

end)
__bundle_register("src.util.WorkLoop", function(require, _LOADED, __bundle_register, __bundle_modules)
---@nospec

return require("src.util.WorkLoop.WorkLoop")
end)
__bundle_register("src.util.WorkLoop.WorkLoop", function(require, _LOADED, __bundle_register, __bundle_modules)
local class        = require("lib.30log")
local table_pack   = require("src.util.polyfill.table.pack")
local table_unpack = require("src.util.polyfill.table.unpack")
local DrawGroup    = require("src.util.Renderer.DrawGroup")
local traceback    = require("src.util.debug.traceback")

---@alias LuaX.WorkLoop.Item { [1]: function, number: any }

---@class LuaX.WorkLoop : Log.BaseFunctions
---@field protected list_dequue fun(self: self): LuaX.WorkLoop.Item
---@field protected list_enqueue fun(self: self, cb: function, ...)
---@field protected list_is_empty fun(self: self): boolean
---@field protected list LuaX.WorkLoop.Item[]
---@field protected head integer
---@field protected tail integer
---@field protected run_once fun(self: self)
---
--- Abstract
---@field protected is_running boolean
---@field protected stop fun(self: self)
---@field protected start fun(self: self)
---@field safe_start fun(self: self)
---
--- Abstract optional
---@field add fun(self: self, cb: function, ...: any)
local WorkLoop     = class("WorkLoop")

function WorkLoop:init()
    self.list = {}
    self.head = 0
    self.tail = 0
end

function WorkLoop:list_dequue()
    self.head = self.head + 1

    local ret = self.list[self.head]

    self.list[self.head] = nil

    return ret
end

function WorkLoop:list_enqueue(...)
    local item = table_pack(...)

    self.tail = self.tail + 1
    self.list[self.tail] = item
end

function WorkLoop:list_is_empty()
    return self.tail - self.head == 0
end

function WorkLoop:add(cb, ...)
    self:list_enqueue(cb, ...)
end

function WorkLoop:stop()
    self.is_running = false
end

function WorkLoop:run_once()
    if self:list_is_empty() then
        self:stop()
        return
    end

    local item = self:list_dequue()

    -- TODO tie in calling function somehow? for traceback
    local cb = item[1]
    -- luajit has problems with understanding how long tables are. 10 is an arbitrary choice.
    ---@diagnostic disable-next-line:undefined-global
    local upper = jit and 10 or nil
    local ok, err = xpcall(cb, traceback, table_unpack(item, 2, upper))

    if not ok then
        ok, err = pcall(DrawGroup.error, nil, err)
    end

    if not ok then
        error("DrawGroup error handler failed.\n" .. tostring(err))
    end
end

function WorkLoop:safely_start()
    if self.is_running then
        return
    end

    self.is_running = true

    self:start()
end

return WorkLoop

end)
__bundle_register("src.util.Renderer.helper.can_modify_child", function(require, _LOADED, __bundle_register, __bundle_modules)

--- Determine if the existing child of container can be modified to become child, 
--- Or if it must be replaced
---@param child LuaX.ElementNode
---@param container LuaX.NativeElement
---@param key LuaX.Key
local function can_modify_child (child, container, key)
    local existing_children = container:get_children_by_key(key)

    -- Child is currently nil
    if not existing_children then
        return false, existing_children
    end

    -- This is a NativeElement[], not a single NativeElement
    if #existing_children ~= 0 then
        return false, existing_children
    end

    ---@type LuaX.NativeElement
    local existing_child = existing_children

    if existing_child:get_render_name() ~= child.type then              
        return false, existing_children
    end

    return true, existing_child
end

return can_modify_child
end)
__bundle_register("src.util.Renderer.helper.create_native_element", function(require, _LOADED, __bundle_register, __bundle_modules)
local ElementNode = require("src.util.ElementNode")

---@param element LuaX.ElementNode
---@param container LuaX.NativeElement
---@return LuaX.NativeElement
local function create_native_element(element, container)
    local NativeElementImplementation = container:get_class()

    local element_type = element.type

    if type(element_type) ~= "string" then
        error("NativeElement cannot render non-pure component")
    end

    if ElementNode.is_literal(element) and NativeElementImplementation.create_literal then        
        local value = element.props.value

        return NativeElementImplementation.create_literal(value, container)
    else
        local elem = NativeElementImplementation.create_element(element_type)
        elem:set_render_name(element_type)

        local onload = element.props["LuaX::onload"]
        if onload then
            assert(type(onload) == "function", "LuaX::onload value must be a function")

            onload(elem:get_native(), elem)
        end

        return elem
    end
end

return create_native_element
end)
__bundle_register("src.util.debug.get_element_name", function(require, _LOADED, __bundle_register, __bundle_modules)
local get_component_name = require("src.util.debug.get_component_name")
local ElementNode        = require("src.util.ElementNode")
local NativeElement      = require("src.util.NativeElement.NativeElement")
local class              = require("lib.30log")

---@param element LuaX.ElementNode | LuaX.NativeElement | LuaX.Component | nil
---@return string
local function get_element_name(element)
    if element == nil then
        return "nil"
    end

    if type(element) == "function" or type(element) == "string" then
        return get_component_name(element)
    end

    if type(element) ~= "table" then
        return string.format("UNKNOWN (type %s)", type(element))
    end

    ---@diagnostic disable-next-line:invisible
    if element.element_node == ElementNode then
        return get_component_name(element.type)
    end

    if
        class.isInstance(element) and
        (
            element.class == NativeElement or
            ---@diagnostic disable-next-line:undefined-field
            element.class:subclassOf(NativeElement)
        )
    then
        local element = element --[[ @as LuaX.NativeElement ]]

        return element:get_name()
    end

    if #element ~= 0 then
        return string.format("list(%d)", #element)
    end

    if next(element) == nil then
        return "list(nil)"
    end

    return "UNKNOWN"
end

return get_element_name

end)
__bundle_register("src.util.parser.Inline", function(require, _LOADED, __bundle_register, __bundle_modules)
--[[
    Parse inline - leverage the debug library to allow users to render
    components in pure-lua environments
]]

local LuaXParser = require("src.util.parser.LuaXParser")
local traceback = require("src.util.debug.traceback")
local get_locals = require("src.util.debug.get_locals")
local get_function_location = require("src.util.debug.get_function_location")
local get_global_components = require("src.util.parser.transpile.get_global_components")

local get_component_name = require("src.util.debug.get_component_name")

local Fragment = require("src.components.Fragment")
local create_element = require("src.create_element")

local debug = debug or {}
local debug_getinfo = debug.getinfo
local debug_gethook = debug.gethook
local debug_sethook = debug.sethook
local debug_getlocal = debug.getlocal

---@class LuaX.Parser.Inline
local Inline = {
    debuginfo = {},
    transpile_cache = {},
    assertions = {},
    assert = {},

    original_chunks = setmetatable({}, { __mode = "kv" })
}

function Inline.assert.can_use_decorator()
    assert(debug_getinfo, "Cannot use inline parser decorator: debug.getinfo does not exist")

    local function test_function()
        -- assigning then returning allows this assertion to pass under LuaJIT,
        -- otherwise it would JIT optimize the tail call.
        local info = debug_getinfo(1, "f")

        return info
    end

    local info = test_function()

    assert(info.func == test_function,
        "Cannot use inline parser decorator: debug.getinfo API changed")

    assert(debug_sethook, "Cannot use inline parser decorator: debug.sethook does not exist")
    assert(debug_gethook, "Cannot use inline parser decorator: debug.gethook does not exist")
end

function Inline.assert.can_get_local()
    assert(debug, "Cannot use inline parser: debug global does not exist")

    assert(debug_getlocal, "Cannot use inline parser: debug.getlocal does not exist")

    assert(type(debug_getlocal) == "function", "Cannot use inline parser: debug.getlocal is not a function")

    local im_a_local = "Hello World!"

    local name, value = debug_getlocal(1, 1)

    -- we can't make assertions as to the name of this variable (formerly
    -- im_a_local) because it could have been renamed in a minification step
    assert(type(name) == "string" and value == "Hello World!",
        "Cannot use inline parser: debug.getlocal API changed")
end

-- TODO FIXME add in chunk name
---@param chunk string
---@param env table
---@param src string?
function Inline.easy_load(chunk, env, src)
    local chunkname = "inline LuaX"

    local get_output, err = load(chunk, chunkname, nil, env)

    if not get_output then
        err = tostring(err)
        if src then
            err = err:gsub("%[string \"inline LuaX\"%]:1", src)
        end

        error(string.format("Error loading transpiled LuaX.\ntranspilation:\n%s\n\n%s", chunk, err))
    end

    local ok, ret = xpcall(get_output, traceback)

    if ok then
        return ret
    else
        -- TODO try much harder to get current actual line number

        local file, err = ret:match("%[string \"inline LuaX\"%]:1:%s*(.*)$")

        local new_err = string.format("error in inline LuaX in %s: %s", file, tostring(err))

        error(new_err)
    end
end

---@param fn function
function Inline:cached_assert(fn)
    if type(self.assertions[fn]) == "string" then
        error(self.assertions[fn])
    end

    local ok, err = xpcall(fn, traceback)

    if ok then
        self.assertions[fn] = false
    else
        self.assertions[fn] = err

        error(err)
    end
end

--#region transpilation

---@param tag string?
---@param locals table
---@param src string?
function Inline:cache_get(tag, locals, src)
    if not tag then
        return "return nil"
    end

    local cached = self:cache_find(tag)
    if cached then
        return cached
    end

    local parser = LuaXParser.from_inline_string("return " .. tag, src)

    -- mute on_set_variable warnings
    parser:set_handle_variables(function() end)

    local globals = get_global_components()
    if globals then
        parser:set_components(globals, "global")
    else
        parser:set_components(locals, "local")
    end

    local transpiled = parser:transpile()

    self:cache_set(tag, transpiled)

    return transpiled
end

---@param tag string
---@param transpiled string
function Inline:cache_set(tag, transpiled)
    self.transpile_cache[tag] = transpiled
end

function Inline:cache_find(tag)
    return self.transpile_cache[tag]
end

---@param tag string?
function Inline:cache_clear(tag)
    if tag then
        self.transpile_cache[tag] = nil
    else
        self.transpile_cache = {}
    end
end

-- nice debug function that prints locals
function Inline.print_locals(locals)
    for k, v in pairs(locals) do
        print(k, v)
    end
end

---@param chunk function
---@param stackoffset number?
---@return LuaX.FunctionComponent
function Inline:transpile_decorator(chunk, stackoffset)
    self:cached_assert(Inline.assert.can_use_decorator)
    self:cached_assert(Inline.assert.can_get_local)

    local stackoffset = stackoffset or 0

    local chunk_locals, chunk_names = get_locals(3 + stackoffset)

    -- This is compiled, ignore usage of decorator
    ---@diagnostic disable-next-line:invisible
    if chunk_locals[LuaXParser.vars.IS_COMPILED.name] then
        return chunk
    end

    ---@diagnostic disable-next-line:invisible
    chunk_locals[LuaXParser.vars.CREATE_ELEMENT.name] = create_element
    ---@diagnostic disable-next-line:invisible
    chunk_locals[LuaXParser.vars.FRAGMENT.name] = Fragment

    setmetatable(chunk_locals, { __index = _G })
    setmetatable(chunk_names, { __index = _G })

    local inline_luax = function(...)
        -- get hook & mask on debug ( if any ) to re-insert
        local prev_hook, prev_mask = debug_gethook()

        local inner_locals, inner_names

        -- get locals as they come
        debug_sethook(function()
            -- I don't even need name here! yippee!!
            local info = debug_getinfo(2, "f")

            if info.func == chunk then
                inner_locals, inner_names = get_locals(3)
            end
        end, "r")

        local tag = chunk(...)

        debug_sethook(prev_hook, prev_mask)

        local t = type(tag)

        if t == "table" or t == "nil" then
            return tag
        end

        setmetatable(inner_locals, { __index = chunk_locals })
        setmetatable(inner_names, { __index = chunk_names })

        local element_str = self:cache_get(tag, inner_names)

        local chunk_src = get_function_location(chunk)

        local node = self.easy_load(element_str, inner_locals, chunk_src)

        return node
    end

    self.original_chunks[inline_luax] = chunk

    return inline_luax
end

--- Get the original chunk from a function component that has been inline transpiled
---@param fn function
function Inline:get_original_chunk(fn)
    return self.original_chunks[fn]
end

---@param tag string
---@param stackoffset number?
---@return LuaX.ElementNode
function Inline:transpile_string(tag, stackoffset)
    self:cached_assert(self.assert.can_get_local)

    local stackoffset = stackoffset or 0

    -- 3 is a value from trial and error
    local locals, names = get_locals(3 + stackoffset)

    ---@diagnostic disable-next-line:invisible
    local vars = LuaXParser.vars

    locals[vars.CREATE_ELEMENT.name] = create_element
    names[vars.CREATE_ELEMENT.name] = true

    locals[vars.FRAGMENT.name] = Fragment
    names[vars.FRAGMENT.name] = true

    locals[vars.IS_COMPILED.name] = true
    names[vars.IS_COMPILED.name] = true

    -- Get debug info, finding the first non-C caller. This is for cases wrapped
    -- in pcall. 1 is the Inline parser itself, so 2 is the first possible real
    -- caller.
    local stack_height = 2 
    local src
    repeat 
        local info = debug_getinfo(stack_height + stackoffset, "lS")

        if info.source ~= "=[C]" then
            src = info.source:sub(2) .. ":" .. info.currentline
        end

        stack_height = stack_height + 1
    until src
    
    local element_str = self:cache_get(tag, names, src)

    local env = setmetatable(locals, {
        __index = _G
    })

    return self.easy_load(element_str, env, src)
end

--- Inline transpiler, taking either a LuaX string or a Component.
--- Components preferred as locals can be looked up better.
---
---@overload fun (self: self, input: function): LuaX.Component
---@param input string
---@param stackoffset integer?
---@return LuaX.ElementNode
function Inline:transpile(input, stackoffset)
    local t = type(input)

    if t == "function" then
        return self:transpile_decorator(input, stackoffset)
    else
        return self:transpile_string(input, stackoffset)
    end
end

--#endregion

--- Crazy (bad) diamond dependency fix.
do
    ---@type { set_Inline: fun(Inline: LuaX.Parser.Inline)}
    local get_component_name = get_component_name --[[ @as any ]]
    get_component_name.set_Inline(Inline)
end

return Inline

end)
__bundle_register("src.util.debug.get_locals", function(require, _LOADED, __bundle_register, __bundle_modules)

---@param stack integer|function
---@return table<string, any> locals, table<string, any> names
local function get_locals(stack)
    local locals = {}
    local names = {}

    local index = 1

    while true do
        local var_name, var_value = debug.getlocal(stack, index)

        if not var_name then
            break
        end

        locals[var_name] = var_value
        names[var_name] = true

        index = index + 1
    end

    return locals, names
end

return get_locals

end)
return __bundle_require("__root")