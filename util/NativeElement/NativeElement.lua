do local folder_of_this_file
local module_arg={...}
if module_arg[1] ~= (arg or {})[1] then folder_of_this_file=module_arg[1] .. "."
local is_implicit_init=module_arg[2]:match(module_arg[1] .. "[/\\]init%.lua")
if  not is_implicit_init then folder_of_this_file=folder_of_this_file:match"(.+%.)[^.]+" or "" end else folder_of_this_file=arg[0]:gsub("[^%./\\]+%..+$","")
do local sep=package.path:sub(1,1)
local pwd=sep == "/" and os.getenv"PWD" or io.popen("cd","r"):read"a"
for _ in folder_of_this_file:gmatch"%.%." do pwd=pwd:gsub("[/\\][^/\\]+[/\\]?$","") end
pwd=pwd .. sep
package.path=package.path .. string.format(";%s?.lua;%s?%sinit.lua",pwd,pwd,sep) end
folder_of_this_file=folder_of_this_file:gsub("[/\\]","."):gsub("^%.+","") end
local library_root=folder_of_this_file:sub(1, - 1 -  # "util.NativeElement.")
require(library_root .. "_shim") end
local class=require"lib_LuaX._dep.lib.30log"
local count_children_by_key=require"lib_LuaX.util.NativeElement.helper.count_children_by_key"
local set_child_by_key=require"lib_LuaX.util.NativeElement.helper.set_child_by_key"
local list_reduce=require"lib_LuaX.util.polyfill.list.reduce"


---@alias LuaX.NativeElement.ChildrenByKey LuaX.NativeElement  | LuaX.NativeElement.ChildrenByKey[] | LuaX.NativeElement.ChildrenByKey[][]
---@class LuaX.NativeElement : Log.BaseFunctions




---@field protected _children_by_key LuaX.NativeElement.ChildrenByKey
---@field _get_key_insert_index fun(self: self, key: LuaX.Key): integer Helper function to get index
---@field get_children_by_key fun(self: self, key: LuaX.Key): LuaX.NativeElement.ChildrenByKey
---@field insert_child_by_key fun(self: self, key: LuaX.Key, child: LuaX.NativeElement)
---@field delete_children_by_key fun(self: self, key: LuaX.Key)

---@field set_prop_safe fun (self: self ,prop: string, value: any)
---@field set_prop_virtual fun (self: self, prop: string, value: any)
---@field _virtual_props table<string, any>


---@field set_prop fun(self: self, prop: string, value: any)
---@field insert_child fun(self: self, index: number, element: LuaX.NativeElement, is_text: boolean)
---@field delete_child fun(self: self, index: number, is_text: boolean)

---@field create_element fun(type: string): LuaX.NativeElement
---@field get_root fun(native: any): LuaX.NativeElement Convert a passed object to a root node


---@field get_type  nil | fun(self: self): string
---@field create_literal nil | fun(value: string, parent: LuaX.NativeElement): LuaX.NativeElement TODO special rules here?

---@field get_prop fun(self: self, prop: string): any

---@field components string[]? class static property - components implemented by this class.
---@operator call : LuaX.NativeElement
local log=require"lib_LuaX._dep.lib.log"
local NativeElement=class"NativeElement"
---@type LuaX.NativeTextElement
NativeElement._dependencies={}
NativeElement._dependencies.NativeTextElement=nil
function NativeElement:init() error"NativeElement must be extended to use for components" end
function NativeElement:get_type_safe() return self.get_type and self:get_type() or "UNKNOWN" end
function NativeElement:get_children_by_key(key) local children=self._children_by_key
return list_reduce(key,function (children,key_slice) if  not children then return nil end


return children[key_slice] end,children or {}) end
function NativeElement:set_prop_virtual(prop,value) self._virtual_props=self._virtual_props or {}
self._virtual_props[prop]=value
self:set_prop(prop,value) end

function NativeElement:set_prop_safe(prop,value) if self.get_prop ~= NativeElement.get_prop then ---@diagnostic disable-next-line:inject-field
self.class.set_prop_safe=self.set_prop else ---@diagnostic disable-next-line:inject-field
self.class.set_prop_safe=self.set_prop_virtual end

self:set_prop_safe(prop,value) end
function NativeElement:get_prop(prop) self._virtual_props=self._virtual_props or {}
return self._virtual_props[prop] end

function NativeElement:_get_key_insert_index(key) if  not self._children_by_key then self._children_by_key={} end
local count=count_children_by_key(self._children_by_key,key)
return count + 1 end

function NativeElement:insert_child_by_key(key,child) local insert_index=self:_get_key_insert_index(key)
local NativeTextElement=self._dependencies.NativeTextElement
local is_text=NativeTextElement and NativeTextElement:classOf(child.class) or false

log.trace(self:get_type(),"insert_child_by_key",insert_index)
set_child_by_key(self._children_by_key,key,child)
self:insert_child(insert_index,child,is_text) end

function NativeElement:delete_children_by_key(key) 
log.trace(self:get_type(),"delete_children_by_key",table.concat(key,"."))
if  not self._children_by_key then self._children_by_key={} end
local delete_end=count_children_by_key(self._children_by_key,key)

local key_children=self:get_children_by_key(key)
if  not key_children then return  end

if key_children.class then key_children={key_children} end

local delete_start=delete_end -  # key_children
for i =  # key_children,1, - 1 do 
local child_index=delete_start + i

local child=key_children[i]
local NativeTextElement=self._dependencies.NativeTextElement
local is_text=NativeTextElement and NativeTextElement:classOf(child.class) or false
self:delete_child(child_index,is_text) end
set_child_by_key(self._children_by_key,key,nil) end
function NativeElement.create_element(element_type) if type(element_type) ~= "string" then error"NativeElement cannot render non-pure component" end
return NativeElement() end

---@return LuaX.NativeElement
function NativeElement:get_class() return self.class end

function NativeElement:set_props(props) for prop,value in pairs(props) do if prop ~= "children" then self:set_prop(prop,value) end end end
---@param children LuaX.NativeElement.ChildrenByKey
function NativeElement.recursive_children_string(children) if type(children) ~= "table" then return tostring(children) end
if  # children ~= 0 then local children_strs={}
for index,child in ipairs(children) do table.insert(children_strs,NativeElement.recursive_children_string(child)) end
return string.format("{ %s }",table.concat(children_strs,", ")) else 
return "Child " .. tostring(children) end end

function NativeElement:__tostring() local component=self:get_type_safe()
local children=NativeElement.recursive_children_string(self._children_by_key)
return component .. " " .. children end
return NativeElement