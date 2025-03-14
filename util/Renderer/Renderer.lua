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
local get_element_name=require"lib_LuaX.util.debug.get_element_name"
local create_native_element=require"lib_LuaX.util.Renderer.helper.create_native_element"
local deep_equals=require"lib_LuaX.util.deep_equals"
local can_modify_child=require"lib_LuaX.util.Renderer.helper.can_modify_child"
local ElementNode=require"lib_LuaX.util.ElementNode"
local VirtualElement=require"lib_LuaX.util.NativeElement.VirtualElement"
local DefaultWorkLoop=require"lib_LuaX.util.WorkLoop.Default"
local RenderInfo=require"lib_LuaX.util.Renderer.RenderInfo"
local DrawGroup=require"lib_LuaX.util.Renderer.DrawGroup"
local NativeElement=require"lib_LuaX.util.NativeElement.NativeElement"
local max=math.max
local Renderer=class"Renderer"
function Renderer:init(workloop) self:set_workloop(workloop) end
function Renderer:set_workloop(workloop) if workloop and  not workloop.class then workloop=workloop() end
self.workloop=workloop or DefaultWorkLoop()
return self end
function Renderer:render_native_component(component,container,key,info) local info_old=RenderInfo.set(info)
if component == nil then container:delete_children_by_key(key)
return  end
local can_modify,existing_child=can_modify_child(component,container,key)
local node=nil
if can_modify then node=existing_child else if existing_child then container:delete_children_by_key(key) end
node=create_native_element(component,container) end
for prop,value in pairs(component.props) do if prop ~= "children" and prop:sub(1,6) ~= "LuaX::" and  not deep_equals(value,node:get_prop_safe(prop),2) then node:set_prop_safe(prop,value) end end
local children=component.props.children
local current_children=node:get_children_by_key{} or {}
if children then local workloop=self.workloop
local size=max( # current_children, # children)
for index,child in ipairs_with_nil(children,size) do DrawGroup.ref(info.draw_group)
workloop:add(self.render_keyed_child,self,child,node,{index},info) end
workloop:safely_start() end
if  not can_modify then container:insert_child_by_key(key,node) end
RenderInfo.set(info_old) end
function Renderer:render_function_component(element,container,key,info) do local existing=container:get_children_by_key(key)
if existing and (existing.class or  # existing > 2) then container:delete_children_by_key(key) end end
local virtual_key=key_add(key,1)
local render_key=key_add(key,2)
local can_modify,existing_child=can_modify_child(element,container,virtual_key)
local node=nil
local info=RenderInfo.inherit({["key"] = render_key,["container"] = container,["renderer"] = self},info)
if can_modify then node=existing_child else if existing_child then container:delete_children_by_key(virtual_key) end
node=VirtualElement.create_element(element.type)
container:insert_child_by_key(virtual_key,node)
node:set_on_change(function () self.workloop:add(function () local old=RenderInfo.set(info)
local did_render,render_result=node:render(true)
if did_render then DrawGroup.ref(info.draw_group)
self:render_keyed_child(render_result,container,render_key,info) end
RenderInfo.set(old) end)
self.workloop:safely_start() end) end
local old=RenderInfo.set(info)
RenderInfo.bind(element.props,info)
node:set_props(element.props)
local did_render,render_result=node:render()
if did_render then DrawGroup.ref(info.draw_group)
self.workloop:add(self.render_keyed_child,self,render_result,container,render_key,info) end
RenderInfo.set(old)
self.workloop:safely_start() end
function Renderer:render_keyed_child(element,container,key,info) if  not element or type(element.type) == "string" then self:render_native_component(element,container,key,info) elseif type(element) == "table" and  not ElementNode.is(element) then local current_children=container:get_children_by_key(key) or {}
if current_children.class and class.isClass(current_children.class) then container:delete_children_by_key(key)
current_children={} end
local size=max( # current_children, # element)
for i,child in ipairs_with_nil(element,size) do local newkey=key_add(key,i)
DrawGroup.ref(info.draw_group)
self.workloop:add(self.render_keyed_child,self,child,container,newkey,info) end elseif type(element.type) == "function" then self:render_function_component(element,container,key,info) else local component_type=type(element.type)
error(string.format("Cannot render component of type '%s' (rendered by %s)",component_type,get_element_name(container))) end
DrawGroup.unref(info.draw_group)
self.workloop:safely_start() end
function Renderer:render(component,container) local args={self,component,container}
for i,info in ipairs{{["type"] = Renderer,["name"] = "self",["extra"] = "Are you calling renderer.render() instead of renderer:render()?"},{["type"] = "table",["name"] = "component"},{["type"] = NativeElement,["name"] = "container"}} do local arg=args[i]
local extra=info.extra and (" " .. info.extra) or ""
if type(info.type) == "string" then assert(type(arg) == info.type and  not class.isInstance(arg),string.format("Expected argument %q to be of type %s" .. extra,info.name,info.type)) else local classname=tostring(info.type)
classname=classname:match"class '[^']+'" or classname
assert(class.isInstance(arg),string.format("Expected argument %q to be an instance of %s" .. extra,info.name,classname)) end end
local group=DrawGroup.create(function (err) error(err) end,function ()  end,function ()  end)
DrawGroup.ref(group)
local render_info={["key"] = {},["context"] = {},["draw_group"] = group}
RenderInfo.set(render_info)
self.workloop:add(self.render_keyed_child,self,component,container,{1},render_info)
self.workloop:safely_start() end
Renderer.Info=RenderInfo
return Renderer