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
local VirtualElement=require"lib_LuaX.util.NativeElement.VirtualElement"
local flatten_children=require"lib_LuaX.util.NativeElement.helper.flatten_children"
local NativeElement=class"NativeElement"
NativeElement._dependencies={}
NativeElement._dependencies.NativeTextElement=nil
function NativeElement:init() error"NativeElement must be extended to use for components" end
function NativeElement:get_render_name() return self.__render_name end
function NativeElement:set_render_name(name) self.__render_name=name end
function NativeElement:get_name() return self:get_render_name() or "unknown NativeElement" end
function NativeElement:get_children_by_key(key) local children=self._children_by_key
return list_reduce(key,function (children,key_slice) if  not children then return nil end
return children[key_slice] end,children or {}) end
function NativeElement:set_prop_virtual(prop,value) self._virtual_props=self._virtual_props or {}
self._virtual_props[prop]=value
self:set_prop(prop,value) end
function NativeElement:set_prop_safe(prop,value) if self.get_prop ~= NativeElement.get_prop then self.class.set_prop_safe=self.set_prop else self.class.set_prop_safe=self.set_prop_virtual end
self:set_prop_safe(prop,value) end
function NativeElement:get_prop(prop) self._virtual_props=self._virtual_props or {}
return self._virtual_props[prop] end
function NativeElement:count_children_by_key(key,include_virtual) return count_children_by_key(self._children_by_key,key,include_virtual) end
function NativeElement:set_child_by_key(key,child) return set_child_by_key(self._children_by_key,key,child) end
function NativeElement:flatten_children(key) local children=self:get_children_by_key(key)
return flatten_children(children,key) end
function NativeElement:insert_child_by_key(key,child) if  not self._children_by_key then self._children_by_key={} end
if child.class ~= VirtualElement then local insert_index=self:count_children_by_key(key) + 1
local NativeTextElement=self._dependencies.NativeTextElement
local is_text=NativeTextElement and NativeTextElement:classOf(child.class) or false
self:insert_child(insert_index,child,is_text) end
self:set_child_by_key(key,child) end
function NativeElement:delete_children_by_key(key) if  not self._children_by_key then self._children_by_key={}
return  end
local flattened=self:flatten_children(key)
if  # flattened == 0 then return  end
local delete_index=self:count_children_by_key(key)
local NativeTextElement=self._dependencies.NativeTextElement
for i =  # flattened,1, - 1 do local child=flattened[i].element
if child.class ~= VirtualElement then local is_text=NativeTextElement and NativeTextElement:classOf(child.class) or false
self:delete_child(delete_index,is_text)
delete_index=delete_index - 1 end
child:cleanup() end
self:set_child_by_key(key,nil) end
function NativeElement:cleanup()  end
function NativeElement.create_element(element_type) if type(element_type) ~= "string" then error"NativeElement cannot render non-pure component" end
return NativeElement() end
function NativeElement:get_class() return self.class end
function NativeElement:set_props(props) for prop,value in pairs(props) do if prop ~= "children" then self:set_prop(prop,value) end end end
return NativeElement