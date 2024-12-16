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
local library_root=folder_of_this_file:sub(1, - 1 -  # "util.Renderer.")
require(library_root .. "_shim") end
local class=require"lib_LuaX._dep.lib.30log"
local ipairs_with_nil=require"lib_LuaX.util.ipairs_with_nil"
local key_add=require"lib_LuaX.util.key.key_add"
local get_element_name=require"lib_LuaX.util.Renderer.helper.get_element_name"
local create_native_element=require"lib_LuaX.util.Renderer.helper.create_native_element"
local table_equals=require"lib_LuaX.util.table_equals"
local can_modify_child=require"lib_LuaX.util.Renderer.helper.can_modify_child"
local ElementNode=require"lib_LuaX.util.ElementNode"
local inherit_contexts=require"lib_LuaX.context.inherit"
local log=require"lib_LuaX._dep.lib.log"
local FunctionComponentInstance=require"lib_LuaX.util.FunctionComponentInstance"
local DefaultWorkLoop=require"lib_LuaX.util.WorkLoop.Default"
---@class LuaX.Renderer : Log.BaseFunctions
---@field workloop LuaX.WorkLoop instance of a workloop
---@field native_element LuaX.NativeElement class here, not instance
---@field set_workloop fun (self: self, workloop: LuaX.WorkLoop): self set workloop using either a class or an instance

---@field protected render_function_component fun(self: self, element: LuaX.ElementNode, container: LuaX.NativeElement, key: LuaX.Key)
---@field protected render_pure_component fun(self: self, component: LuaX.ElementNode | nil, container: LuaX.NativeElement, key: LuaX.Key, caller?: LuaX.ElementNode)

---@operator call: LuaX.Renderer
local max=math.max
local Renderer=class"Renderer"
function Renderer:init(workloop) self:set_workloop(workloop) end

---@param workloop LuaX.WorkLoop | nil
function Renderer:set_workloop(workloop) 

if workloop and  not workloop.class then workloop=workloop() end
self.workloop=workloop or DefaultWorkLoop()
return self end
---@protected
---@param component LuaX.ElementNode | nil
---@param container LuaX.NativeElement
---@param key LuaX.Key
---@param caller LuaX.ElementNode?
function Renderer:render_pure_component(component,container,key,caller) if component == nil then 
container:delete_children_by_key(key)
return  end
---@type LuaX.NativeElement
local can_modify,existing_child=can_modify_child(component,container,key)
local node=nil
if can_modify then node=existing_child else if existing_child then container:delete_children_by_key(key) end
node=create_native_element(component,container) end

for prop,value in pairs(component.props) do if prop ~= "children" and  not table_equals(value,node:get_prop(prop)) then node:set_prop_safe(prop,value) end end



local children=component.props.children
local current_children=node:get_children_by_key{} or {}
if children then local workloop=self.workloop
local size=max( # current_children, # children)
for index,child in ipairs_with_nil(children,size) do workloop:add(function () self:render_keyed_child(child,node,{index},caller) end) end
workloop:start() else  end


if  not existing_child then container:insert_child_by_key(key,node) end end
---@protected
---@param element LuaX.ElementNode
---@param container LuaX.NativeElement
---@param key LuaX.Key
function Renderer:render_function_component(element,container,key) 

local rendered=element._component:render(element.props)
if  not element._component.requests_rerender then self:render_keyed_child(rendered,container,key,element) end end
---@param element LuaX.ElementNode | nil
---@param container LuaX.NativeElement
---@param key LuaX.Key
---@param caller LuaX.ElementNode?
function Renderer:render_keyed_child(element,container,key,caller) log.trace(get_element_name(container),"rendering",get_element_name(element),table.concat(key," "))
if  not element or type(element.type) == "string" then self:render_pure_component(element,container,key,caller) elseif type(element) == "table" and element.element_node ~= ElementNode then 
local current_children=container:get_children_by_key(key) or {}
if current_children.class and class.isClass(current_children.class) then container:delete_children_by_key(key)
current_children={} end
local size=max( # current_children, # element)
for i,child in ipairs_with_nil(element,size) do local newkey=key_add(key,i)
self:render_keyed_child(child,container,newkey,caller) end elseif type(element.type) == "function" then if  not element._component then log.trace("Creating new FunctionComponentInstance for",get_element_name(element))
element=ElementNode.inherit_props(element,{["__luax_internal"] = {["renderer"] = self,["container"] = container,["context"] = inherit_contexts(caller)}})
local component=element.type
local component_instance=FunctionComponentInstance(component)
component_instance:on_change(function () 
self.workloop:add(function () self:render_function_component(element,container,key) end)
self.workloop:start() end)
element._component=component_instance end
self:render_function_component(element,container,key) else local component_type=type(element.type)
error(string.format("Cannot render component of type '%s' (rendered by %s)",component_type,get_element_name(container))) end


self.workloop:start() end
---@param component LuaX.ElementNode
---@param container LuaX.NativeElement
function Renderer:render(component,container) self:render_keyed_child(component,container,{1}) end
return Renderer